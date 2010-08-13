#lang typed-scheme

(provide (rename-out [heap-map map]) fold  filter remove
         heap merge insert find-min/max
         delete-min/max sorted-list empty?)

(require scheme/promise
         scheme/match)

(define-struct: Mt ())
(define-struct: (A) IntHeap ([elem : A]
                             [heap : (PHeap A)]
                             [lazy : (Promise (PHeap A))]))

(define-type-alias (PHeap A) (U Mt (IntHeap A)))

(define-struct: (A) PairingHeap ([comparer : (A A -> Boolean)]
                                 [heap : (PHeap A)]))

(define-type-alias (Heap A) (PairingHeap A))

;; Checks for empty
(: empty? : (All (A) ((PairingHeap A) -> Boolean)))
(define (empty? pheap)
  (Mt? (PairingHeap-heap pheap)))

;; An empty heap
(define empty (make-Mt))

;; Merges two given heaps
(: merge : (All (A) ((PairingHeap A) (PairingHeap A) -> (PairingHeap A))))
(define (merge pheap1 pheap2)
  (let ([func (PairingHeap-comparer pheap1)]
        [heap1 (PairingHeap-heap pheap1)]
        [heap2 (PairingHeap-heap pheap2)])
    (make-PairingHeap func (merge-help heap1 heap2 func))))

;; Helper for merge
(: merge-help : (All (A) ((PHeap A) (PHeap A) (A A -> Boolean) -> (PHeap A))))
(define (merge-help pheap1 pheap2 func)
  (match (cons pheap1 pheap2)
    [(cons (struct Mt ()) _) pheap2]
    [(cons _ (struct Mt ())) pheap1]
    [(cons (and h1 (struct IntHeap (x _ _))) (and h2 (struct IntHeap (y _ _)))) 
     (if (func x y)
         (link h1 h2 func)
         (link h2 h1 func))]))

(: link : (All (A) ((IntHeap A) (IntHeap A) (A A -> Boolean) -> (PHeap A))))
(define (link heap1 heap2 func)
  (match heap1
    [(struct IntHeap (x (struct Mt ()) m)) (make-IntHeap x heap2 m)]
    [(struct IntHeap (x b m)) 
     (make-IntHeap x (make-Mt) (delay (merge-help (merge-help heap2 b func)
                                                  (force m)
                                                  func)))]))

;; Inserts an element into the heap
(: insert : (All (A) (A (PairingHeap A) -> (PairingHeap A))))
(define (insert elem pheap)
  (let ([func (PairingHeap-comparer pheap)]
        [heap (PairingHeap-heap pheap)])
    (make-PairingHeap func (merge-help (make-IntHeap elem (make-Mt)
                                                     (delay (make-Mt)))
                                       heap func))))

;; Returns min or max element of the heap
(: find-min/max : (All (A) ((PairingHeap A) -> A)))
(define (find-min/max pheap)
  (let ([heap (PairingHeap-heap pheap)])
    (if (Mt? heap)
        (error 'find-min/max "given heap is empty")
        (IntHeap-elem heap))))

;; Deletes min or max element of the heap
(: delete-min/max : (All (A) ((PairingHeap A) -> (PairingHeap A))))
(define (delete-min/max pheap)
  (let ([heap (PairingHeap-heap pheap)]
        [func (PairingHeap-comparer pheap)])
    (if (Mt? heap)
        (error 'delete-min/max "given heap is empty")
        (make-PairingHeap func (merge-help (IntHeap-heap heap) 
                                           (force (IntHeap-lazy heap)) 
                                           func)))))

;; Heap constructor
(: heap : (All (A) ((A A -> Boolean) A * -> (PairingHeap A))))
(define (heap comparer . lst)
  (let ([first ((inst make-PairingHeap A) comparer (make-Mt))])
    (foldl (inst insert A) first lst)))


(: sorted-list : (All (A) ((PairingHeap A) -> (Listof A))))
(define (sorted-list pheap)
  (let ([heap (PairingHeap-heap pheap)])
    (if (Mt? heap)
        null
        (cons (find-min/max pheap) (sorted-list (delete-min/max pheap))))))


;; Similar to list map function
(: heap-map : 
   (All (A C B ...) ((C C -> Boolean) 
                     (A B ... B -> C) 
                     (PairingHeap A) 
                     (PairingHeap B) ... B -> (PairingHeap C))))
(define (heap-map comp func fst . rst)
  (: in-map : 
     (All (A C B ...) ((PairingHeap C) 
                       (A B ... B -> C) 
                       (PairingHeap A) 
                       (PairingHeap B) ... B -> (PairingHeap C))))
  (define (in-map accum func fst . rst)
    (if (or (empty? fst) (ormap empty? rst))
        accum
        (apply in-map
               (insert (apply func (find-min/max fst) (map find-min/max rst)) accum)
               func
               (delete-min/max fst) 
               (map delete-min/max rst))))
  (apply in-map ((inst make-PairingHeap C) comp empty) func fst rst))

;; Similar to list filter function
(: filter : (All (A) ((A -> Boolean) (PairingHeap A) -> (PairingHeap A))))
(define (filter func hep)
  (: inner : (All (A) ((A -> Boolean) (PairingHeap A) (PairingHeap A) -> (PairingHeap A))))
  (define (inner func hep accum)
    (if (empty? hep)
        accum
        (let ([head (find-min/max hep)]
              [tail (delete-min/max hep)])
          (if (func head)
              (inner func tail (insert head accum))
              (inner func tail accum)))))
  (inner func hep ((inst make-PairingHeap A) (PairingHeap-comparer hep) empty)))

;; Similar to list remove function
(: remove : (All (A) ((A -> Boolean) (PairingHeap A) -> (PairingHeap A))))
(define (remove func hep)
  (: inner : (All (A) ((A -> Boolean) (PairingHeap A) (PairingHeap A) -> (PairingHeap A))))
  (define (inner func hep accum)
    (if (empty? hep)
        accum
        (let ([head (find-min/max hep)]
              [tail (delete-min/max hep)])
          (if (func head)
              (inner func tail accum)
              (inner func tail (insert head accum))))))
  (inner func hep ((inst make-PairingHeap A) (PairingHeap-comparer hep) empty)))

;; Similar to list fold function
(: fold : (All (A C B ...)
               ((C A B ... B -> C) C (Heap A) (Heap B) ... B -> C)))
(define (fold func base hep . heps)
  (if (or (empty? hep) (ormap empty? heps))
      base
      (apply fold 
             func 
             (apply func base (find-min/max hep) (map find-min/max heps))
             (delete-min/max hep)
             (map delete-min/max heps))))
