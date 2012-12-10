#lang typed/racket

(provide (rename-out [heap-map map]
                     [heap-ormap ormap] [heap-andmap andmap]) 
         fold  filter remove Heap empty?
         heap merge insert find-min/max delete-min/max sorted-list
         build-heap)

(struct: (A) Tree ([elem : A]
                   [heaps : (Listof (IntHeap A))]))

(define-type (IntHeap A) (U Null (Tree A)))

(struct: (A) PairingHeap ([comparer : (A A -> Boolean)]
                          [heap : (IntHeap A)]))

(define-type (Heap A) (PairingHeap A))

;; An empty heap
(define empty null)

;; Checks for empty
(: empty? : (All (A) ((PairingHeap A) -> Boolean)))
(define (empty? pheap)
  (null? (PairingHeap-heap pheap)))

;; Insers an element into the heap
(: insert : (All (A) (A (PairingHeap A) -> (PairingHeap A))))
(define (insert elem pheap)
  (let ([comparer (PairingHeap-comparer pheap)])
    (PairingHeap comparer
                 (in-merge (Tree elem null) 
                           (PairingHeap-heap pheap)
                           comparer))))

;; Merges two given heaps
(: merge : (All (A) ((PairingHeap A) (PairingHeap A) -> (PairingHeap A))))
(define (merge heap1 heap2)
  (let ([comparer (PairingHeap-comparer heap1)])
    (PairingHeap comparer
                 (in-merge (PairingHeap-heap heap1) 
                           (PairingHeap-heap heap2) 
                           comparer))))

;; Helper for merge
(: in-merge : 
   (All (A) ((IntHeap A) (IntHeap A) (A A -> Boolean) -> (IntHeap A))))
(define (in-merge heap1 heap2 comparer)
  (cond
    [(null? heap2) heap1]
    [(null? heap1) heap2]
    [else (in-merge-helper heap1 heap2 comparer)]))

(: in-merge-helper : 
   (All (A) ((Tree A) (Tree A) (A A -> Boolean) -> (IntHeap A))))
(define (in-merge-helper tree1 tree2 comparer)
  (let ([tr1-elm (Tree-elem tree1)]
        [tr2-elm (Tree-elem tree2)]
        [tr1-heaps (Tree-heaps tree1)]
        [tr2-heaps (Tree-heaps tree2)])
    (if (comparer tr1-elm tr2-elm)
        (Tree tr1-elm (cons tree2 tr1-heaps))
        (Tree tr2-elm (cons tree1 tr2-heaps)))))

;; Returns min or max element of the heap
(: find-min/max : (All (A) ((PairingHeap A) -> A)))
(define (find-min/max pheap)
  (let ([heap (PairingHeap-heap pheap)]
        [comparer (PairingHeap-comparer pheap)])
    (if (null? heap)
        (error 'find-min/max "given heap is empty")
        (Tree-elem heap))))

;; A helper for delete-min/max
(: merge-pairs : (All (A) ((Listof (IntHeap A)) (A A -> Boolean) -> (IntHeap A))))
(define (merge-pairs lst comparer)
  (cond
    [(null? lst) empty]
    [(null? (cdr lst)) (car lst)]
    [else (in-merge (in-merge (car lst) (cadr lst) comparer) 
                    (merge-pairs (cddr lst) comparer) 
                    comparer)]))

;; Deletes an element of the heap
(: delete-min/max  : (All (A) ((PairingHeap A) -> (PairingHeap A))))
(define (delete-min/max pheap)
  (let ([heap (PairingHeap-heap pheap)]
        [comparer (PairingHeap-comparer pheap)])
    (if (null? heap)
        (error 'delete-min/max "given heap is empty")
        (PairingHeap comparer
                     (merge-pairs (Tree-heaps heap) comparer)))))

;; Similar to list filter function
(: filter : (All (A) ((A -> Boolean) (Heap A) -> (Heap A))))
(define (filter func hep)
  (: inner : (All (A) ((A -> Boolean) (Heap A) (Heap A) -> (Heap A))))
  (define (inner func hep accum)
    (if (empty? hep)
        accum
        (let ([head (find-min/max hep)]
              [tail (delete-min/max hep)])
          (if (func head)
              (inner func tail (insert head accum))
              (inner func tail accum)))))
  (inner func hep ((inst PairingHeap A)
                   (PairingHeap-comparer hep)
                   null)))

;; Similar to list remove function
(: remove : (All (A) ((A -> Boolean) (Heap A) -> (Heap A))))
(define (remove func hep)
  (: inner : (All (A) ((A -> Boolean) (Heap A) (Heap A) -> (Heap A))))
  (define (inner func hep accum)
    (if (empty? hep)
        accum
        (let ([head (find-min/max hep)]
              [tail (delete-min/max hep)])
          (if (func head)
              (inner func tail accum)
              (inner func tail (insert head accum))))))
  (inner func hep ((inst PairingHeap A) (PairingHeap-comparer hep) null)))


(: sorted-list : (All (A) ((PairingHeap A) -> (Listof A))))
(define (sorted-list pheap)
  (if (null? (PairingHeap-heap pheap))
      null
      (cons (find-min/max pheap) (sorted-list (delete-min/max pheap)))))

;; Heap constructor function
(: heap : (All (A) ((A A -> Boolean) A * -> (PairingHeap A))))
(define (heap comparer . lst)
  (let ([first ((inst PairingHeap A) comparer null)])
    (foldl (inst insert A) first lst)))

;; similar to list map function. apply is expensive so using case-lambda
;; in order to saperate the more common case
(: heap-map : 
   (All (A C B ...) 
        (case-lambda 
          ((C C -> Boolean) (A -> C) (Heap A) -> (Heap C))
          ((C C -> Boolean)
           (A B ... B -> C) (Heap A) (Heap B) ... B -> (Heap C)))))
(define heap-map
  (pcase-lambda: (A C B ...)
                 [([comp : (C C -> Boolean)]
                   [func : (A -> C)]
                   [heap : (Heap A)])
                  (map-single ((inst PairingHeap C) comp empty) func heap)]
                 [([comp : (C C -> Boolean)]
                   [func : (A B ... B -> C)]
                   [heap : (Heap A)] . [heaps : (Heap B) ... B])
                  (apply map-multiple
                         ((inst PairingHeap C) comp empty)
                         func heap heaps)]))


(: map-single : (All (A C) ((Heap C) (A -> C) (Heap A) -> (Heap C))))
(define (map-single accum func heap)
  (if (empty? heap)
      accum
      (map-single (insert (func (find-min/max heap)) accum)
                  func
                  (delete-min/max heap))))

(: map-multiple : 
   (All (A C B ...) 
        ((Heap C) (A B ... B -> C) (Heap A) (Heap B) ... B -> (Heap C))))
(define (map-multiple accum func heap . heaps)
  (if (or (empty? heap) (ormap empty? heaps))
      accum
      (apply map-multiple
             (insert (apply func
                            (find-min/max heap)
                            (map find-min/max heaps))
                     accum)
             func 
             (delete-min/max heap)
             (map delete-min/max heaps))))


;; similar to list foldr or foldl
(: fold : 
   (All (A C B ...) 
        (case-lambda ((C A -> C) C (Heap A) -> C)
                     ((C A B ... B -> C) C (Heap A) (Heap B) ... B -> C))))
(define fold
  (pcase-lambda: (A C B ...) 
                 [([func : (C A -> C)]
                   [base : C]
                   [heap  : (Heap A)])
                  (if (empty? heap)
                      base
                      (fold func (func base (find-min/max heap))
                            (delete-min/max heap)))]
                 [([func : (C A B ... B -> C)]
                   [base : C]
                   [heap  : (Heap A)] . [heaps : (Heap B) ... B])
                  (if (or (empty? heap) (ormap empty? heaps))
                      base
                      (apply fold 
                             func 
                             (apply func base (find-min/max heap)
                                    (map find-min/max heaps))
                             (delete-min/max heap)
                             (map delete-min/max heaps)))]))

;; Similar to build-list
(: build-heap : (All (A) (Natural (Natural -> A) (A A -> Boolean) -> (Heap A))))
(define (build-heap size func comparer)
  (let: loop : (Heap A) ([n : Natural size])
        (if (zero? n)
            ((inst PairingHeap A) comparer empty)
            (let ([nsub1 (sub1 n)])
              (insert (func nsub1) (loop nsub1))))))


;; similar to list andmap function
(: heap-andmap : 
   (All (A B ...) 
        (case-lambda ((A -> Boolean) (Heap A) -> Boolean)
                     ((A B ... B -> Boolean) (Heap A) (Heap B) ... B 
                                             -> Boolean))))
(define heap-andmap
  (pcase-lambda: (A B ... ) 
                 [([func  : (A -> Boolean)]
                   [deque : (Heap A)])
                  (or (empty? deque)
                      (and (func (find-min/max deque))
                           (heap-andmap func (delete-min/max deque))))]
                 [([func  : (A B ... B -> Boolean)]
                   [deque : (Heap A)] . [deques : (Heap B) ... B])
                  (or (empty? deque) (ormap empty? deques)
                      (and (apply func (find-min/max deque) 
                                  (map find-min/max deques))
                           (apply heap-andmap func (delete-min/max deque) 
                                  (map delete-min/max deques))))]))

;; Similar to ormap
(: heap-ormap : 
   (All (A B ...) 
        (case-lambda ((A -> Boolean) (Heap A) -> Boolean)
                     ((A B ... B -> Boolean) (Heap A) (Heap B) ... B 
                                             -> Boolean))))
(define heap-ormap
  (pcase-lambda: (A B ... ) 
                 [([func  : (A -> Boolean)]
                   [deque : (Heap A)])
                  (and (not (empty? deque))
                       (or (func (find-min/max deque))
                           (heap-ormap func (delete-min/max deque))))]
                 [([func  : (A B ... B -> Boolean)]
                   [deque : (Heap A)] . [deques : (Heap B) ... B])
                  (and (not (or (empty? deque) (ormap empty? deques)))
                       (or (apply func (find-min/max deque) 
                                  (map find-min/max deques))
                           (apply heap-ormap func (delete-min/max deque) 
                                  (map delete-min/max deques))))]))
