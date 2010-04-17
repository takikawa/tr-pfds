#lang typed-scheme

(provide pairingheap merge insert find-min/max
         delete-min/max sorted-list empty?)

(require scheme/promise
         scheme/match)

(define-struct: Mt ())
(define-struct: (A) Heap ([elem : A]
                          [heap : (PHeap A)]
                          [lazy : (Promise (PHeap A))]))

(define-type-alias (PHeap A) (U Mt (Heap A)))

(define-struct: (A) PairingHeap ([comparer : (A A -> Boolean)]
                                 [heap : (PHeap A)]))

(: empty? : (All (A) ((PairingHeap A) -> Boolean)))
(define (empty? pheap)
  (Mt? pheap))

(define empty (make-Mt))

(: merge : (All (A) ((PairingHeap A) (PairingHeap A) -> (PairingHeap A))))
(define (merge pheap1 pheap2)
  (let ([func (PairingHeap-comparer pheap1)]
        [heap1 (PairingHeap-heap pheap1)]
        [heap2 (PairingHeap-heap pheap2)])
    (make-PairingHeap func (merge-help heap1 heap2 func))))

(: merge-help : (All (A) ((PHeap A) (PHeap A) (A A -> Boolean) -> (PHeap A))))
(define (merge-help pheap1 pheap2 func)
  (match (cons pheap1 pheap2)
    [(cons (struct Mt ()) _) pheap2]
    [(cons _ (struct Mt ())) pheap1]
    [(cons (and h1 (struct Heap (x _ _))) (and h2 (struct Heap (y _ _)))) 
     (if (func x y)
         (link h1 h2 func)
         (link h2 h1 func))]))

(: link : (All (A) ((Heap A) (Heap A) (A A -> Boolean) -> (PHeap A))))
(define (link heap1 heap2 func)
  (match heap1
    [(struct Heap (x (struct Mt ()) m)) (make-Heap x heap2 m)]
    [(struct Heap (x b m)) 
     (make-Heap x (make-Mt) (delay (merge-help (merge-help heap2 b func)
                                               (force m)
                                               func)))]))

(: insert : (All (A) (A (PairingHeap A) -> (PairingHeap A))))
(define (insert elem pheap)
  (let ([func (PairingHeap-comparer pheap)]
        [heap (PairingHeap-heap pheap)])
    (make-PairingHeap func (merge-help (make-Heap elem (make-Mt) (delay (make-Mt)))
                                       heap func))))

(: find-min/max : (All (A) ((PairingHeap A) -> A)))
(define (find-min/max pheap)
  (let ([heap (PairingHeap-heap pheap)])
    (if (Mt? heap)
        (error 'find-min/max "Given heap is empty")
        (Heap-elem heap))))

(: delete-min/max : (All (A) ((PairingHeap A) -> (PairingHeap A))))
(define (delete-min/max pheap)
  (let ([heap (PairingHeap-heap pheap)]
        [func (PairingHeap-comparer pheap)])
    (if (Mt? heap)
        (error 'delete-min/max "Given heap is empty")
        (make-PairingHeap func (merge-help (Heap-heap heap) 
                                           (force (Heap-lazy heap)) 
                                           func)))))

(: pairingheap : (All (A) ((A A -> Boolean) A * -> (PairingHeap A))))
(define (pairingheap comparer . lst)
  (let ([first ((inst make-PairingHeap A) comparer (make-Mt))])
    (foldl (inst insert A) first lst)))


(: sorted-list : (All (A) ((PairingHeap A) -> (Listof A))))
(define (sorted-list pheap)
  (let ([heap (PairingHeap-heap pheap)])
    (if (Mt? heap)
        null
        (cons (find-min/max pheap) (sorted-list (delete-min/max pheap))))))
