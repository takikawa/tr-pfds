#lang typed/racket #:optimize

(provide (rename-out [heap-map map]
                     [heap-ormap ormap] [heap-andmap andmap]) 
         fold  filter remove
         empty? insert find-min/max delete-min/max empty
         merge sorted-list heap BSHeap Heap build-heap)

(require (prefix-in ph: "pairingheap.ss")
         scheme/match)

(struct: (A) IntHeap ([elem : A]
                      [heap : (ph:Heap (IntHeap A))]))

(define-type (Heaps A) (U Null (IntHeap A)))

(struct: (A) BSHeap ([comparer : (A A -> Boolean)]
                     [heap : (Heaps A)]))

(define-type (Heap A) (BSHeap A))

;; An empty heap
(define empty null)

;; Checks for empty
(: empty? : (All (A) ((BSHeap A) -> Boolean)))
(define (empty? bsheap)
  (let ([hp (BSHeap-heap bsheap)])
    (if (null? hp) #t (ph:empty? (IntHeap-heap hp)))))

;; Merges two given heaps
(: merge : (All (A) ((BSHeap A) (BSHeap A) -> (BSHeap A))))
(define (merge heap1 heap2)
  (let ([func (BSHeap-comparer heap1)]
        [inheap1 (BSHeap-heap heap1)]
        [inheap2 (BSHeap-heap heap2)])
    (BSHeap func (merge-help inheap1 inheap2 func))))

;; Helper
(: merge-help : (All (A) ((Heaps A) (Heaps A) (A A -> Boolean) -> (Heaps A))))
(define (merge-help heap1 heap2 func)
  (cond
    [(null? heap1) heap2]
    [(null? heap2) heap1]
    [else (let ([elem1 (IntHeap-elem heap1)]
                [elem2 (IntHeap-elem heap2)]
                [p1 (IntHeap-heap heap1)]
                [p2 (IntHeap-heap heap2)]) 
            (if (func elem1 elem2)
                (IntHeap elem1 (ph:insert heap2 p1))
                (IntHeap elem2 (ph:insert heap1 p2))))]))

;; Inserts an element into the heap
(: insert : (All (A) (A (BSHeap A) -> (BSHeap A))))
(define (insert elem bsheap)
  (let ([func (BSHeap-comparer bsheap)]
        [inheap (BSHeap-heap bsheap)])
    (: comp : ((IntHeap A) (IntHeap A) -> Boolean))
    (define (comp h1 h2)
      (cond
        [(null? h1) #f]
        [(null? h2) #f]
        [else (func (IntHeap-elem h1) (IntHeap-elem h2))]))
    (BSHeap func 
            (merge-help (IntHeap elem 
                                 (ann ((inst ph:heap (IntHeap A)) 
                                       comp)
                                      (ph:Heap (IntHeap A))))
                        inheap func))))

;; Returns the min or max element of the heap
(: find-min/max : (All (A) ((BSHeap A) -> A)))
(define (find-min/max bsheap)
  (let ([heap (BSHeap-heap bsheap)])
    (if (null? heap)
        (error 'find-min/max "given heap is empty")
        (IntHeap-elem heap))))

;; Deletes min or max element of the heap
(: delete-min/max : (All (A) ((BSHeap A) -> (BSHeap A))))
(define (delete-min/max bsheap)
  (let ([heap (BSHeap-heap bsheap)]
        [func (BSHeap-comparer bsheap)])
    (if (null? heap)
        (error 'delete-min/max "given heap is empty")
        (let ([bheap (IntHeap-heap heap)])
          (if (ph:empty? bheap)
              ((inst BSHeap A) func (ann null (Heaps A)))
              (let ([min-heap (ph:find-min/max bheap)]
                    [del (ph:delete-min/max bheap)])
                (BSHeap func 
                        (IntHeap (IntHeap-elem min-heap) 
                                 (ph:merge (IntHeap-heap min-heap) 
                                           del)))))))))

;; Heap constructor 
(: heap : (All (A) ((A A -> Boolean) A * -> (BSHeap A))))
(define (heap func . lst)
  (: comp : ((Heaps A) (Heaps A) -> Boolean))
  (define (comp h1 h2)
    (cond
      [(null? h1) #f]
      [(null? h2) #f]
      [else (func (IntHeap-elem h1) (IntHeap-elem h2))]))
  (foldl (inst insert A)
         ((inst BSHeap A) func (ann null (Heaps A)))
         lst))

(: sorted-list : (All (A) ((BSHeap A) -> (Listof A))))
(define (sorted-list bsheap)
  (let ([heap (BSHeap-heap bsheap)])
    (cond 
      [(null? heap) null]
      [(ph:empty? (IntHeap-heap heap)) (list (IntHeap-elem heap))]
      [else (cons (find-min/max bsheap) 
                  (sorted-list (delete-min/max bsheap)))])))

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
  (inner func hep ((inst BSHeap A) (BSHeap-comparer hep) empty)))

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
  (inner func hep ((inst BSHeap A) (BSHeap-comparer hep) empty)))

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
                  (map-single ((inst BSHeap C) comp empty) func heap)]
                 [([comp : (C C -> Boolean)]
                   [func : (A B ... B -> C)]
                   [heap : (Heap A)] . [heaps : (Heap B) ... B])
                  (apply map-multiple
                         ((inst BSHeap C) comp empty)
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
            ((inst BSHeap A) comparer empty)
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