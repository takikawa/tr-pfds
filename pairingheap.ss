#lang typed-scheme

(provide pairingheap merge insert find-min/max delete-min/max sorted-list)

(define-struct: Mt ())
(define-struct: (A) Tree ([elem : A]
                          [heaps : (Listof (Heap A))]))

(define-type-alias (Heap A) (U Mt (Tree A)))

(define-struct: (A) PairingHeap ([comparer : (A A -> Boolean)]
                                 [heap : (Heap A)]))

(define empty (make-Mt))

(: merge-pairs : (All (A) ((Listof (Heap A)) (A A -> Boolean) -> (Heap A))))
(define (merge-pairs lst comparer)
  (cond
    [(null? lst) empty]
    [(null? (cdr lst)) (car lst)]
    [else (in-merge (in-merge (car lst) (cadr lst) comparer) 
                    (merge-pairs (cddr lst) comparer) 
                    comparer)]))

(: empty? : (All (A) ((PairingHeap A) -> Boolean)))
(define (empty? pheap)
  (Mt? (PairingHeap-heap pheap)))


(: insert : (All (A) (A (PairingHeap A) -> (PairingHeap A))))
(define (insert elem pheap)
  (let ([comparer (PairingHeap-comparer pheap)])
    (make-PairingHeap comparer
                      (in-merge (make-Tree elem null) 
                                (PairingHeap-heap pheap)
                                comparer))))

(: merge : (All (A) ((PairingHeap A) (PairingHeap A) -> (PairingHeap A))))
(define (merge heap1 heap2)
  (let ([comparer (PairingHeap-comparer heap1)])
    (make-PairingHeap comparer
                      (in-merge (PairingHeap-heap heap1) 
                                (PairingHeap-heap heap2) 
                                comparer))))

(: in-merge : 
   (All (A) ((Heap A) (Heap A) (A A -> Boolean) -> (Heap A))))
(define (in-merge heap1 heap2 comparer)
  (cond
    [(Mt? heap2) heap1]
    [(Mt? heap1) heap2]
    [else (in-merge-helper heap1 heap2 comparer)]))

(: in-merge-helper : 
   (All (A) ((Tree A) (Tree A) (A A -> Boolean) -> (Heap A))))
(define (in-merge-helper tree1 tree2 comparer)
  (let ([tr1-elm (Tree-elem tree1)]
        [tr2-elm (Tree-elem tree2)]
        [tr1-heaps (Tree-heaps tree1)]
        [tr2-heaps (Tree-heaps tree2)])
    (if (comparer tr1-elm tr2-elm)
        (make-Tree tr1-elm (cons tree2 tr1-heaps))
        (make-Tree tr2-elm (cons tree1 tr2-heaps)))))

(: find-min/max : (All (A) ((PairingHeap A) -> A)))
(define (find-min/max pheap)
  (let ([heap (PairingHeap-heap pheap)]
        [comparer (PairingHeap-comparer pheap)])
    (if (Mt? heap)
        (error "Heap is empty :" 'find-min/max)
        (Tree-elem heap))))

(: delete-min/max  : (All (A) ((PairingHeap A) -> (PairingHeap A))))
(define (delete-min/max  pheap)
  (let ([heap (PairingHeap-heap pheap)]
        [comparer (PairingHeap-comparer pheap)])
    (if (Mt? heap)
        (error "Heap is empty :" 'delete-min/max )
        (make-PairingHeap comparer
                          (merge-pairs (Tree-heaps heap) comparer)))))

(: sorted-list : (All (A) ((PairingHeap A) -> (Listof A))))
(define (sorted-list pheap)
  (if (Mt? (PairingHeap-heap pheap))
      null
      (cons (find-min/max pheap) (sorted-list (delete-min/max pheap)))))

(: pairingheap : (All (A) ((A A -> Boolean) A * -> (PairingHeap A))))
(define (pairingheap comparer . lst)
  (let ([first ((inst make-PairingHeap A) comparer (make-Mt))])
    (foldl (inst insert A) first lst)))