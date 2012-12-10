#lang typed/racket

(provide filter remove fold 
         (rename-out [heap-map map]
                     [heap-ormap ormap] [heap-andmap andmap])
         empty? insert find-min/max delete-min/max
         merge sorted-list heap Heap build-heap)

(struct: (A) Node ([rank  : Integer]
                   [val   : A]
                   [trees : (Listof (Node A))]))

(struct: (A) Heap ([comparer : (A A -> Boolean)]
                   [trees    : (Listof (Node A))]))

;; Checks for empty heap
(: empty? : (All (A) ((Heap A) -> Boolean)))
(define (empty? heap)
  (null? (Heap-trees heap)))


;; merges two given nodes
;(: link : (All (A) ((Node A) (Node A) (A A -> Boolean) -> (Node A))))
(define-syntax-rule (link node1 node2 func)
  (let ([val1  (Node-val node1)]
        [val2  (Node-val node2)]
        [rank1 (add1 (Node-rank node1))])
    (if (func val1 val2)
        (Node rank1 val1 (cons node2 (Node-trees node1)))
        (Node rank1 val2 (cons node1 (Node-trees node2))))))



;; Inserts a node into the tree
(: ins-tree : (All (A) ((Node A) (Listof (Node A)) (A A -> Boolean) -> (Heap A))))
(define (ins-tree node trees comparer)
  (let ([first (car trees)])
    (if (< (Node-rank node) (Node-rank first))
        (Heap comparer (cons node trees))
        (let ([rest (cdr trees)]
              [new  (link node first comparer)])
          (if (null? rest)
              (Heap comparer (list new))
              (ins-tree new rest comparer))))))

;; Inserts an element into the heap
(: insert : (All (A) (A (Heap A) -> (Heap A))))
(define (insert val heap)
  (let ([new-node (Node 0 val null)]
        [comparer (Heap-comparer heap)]
        [trees    (Heap-trees heap)])
    (if (null? trees)
        (Heap comparer (list new-node))
        (ins-tree new-node trees comparer))))


;; Merges two given heaps
(: merge : (All (A) ((Heap A) (Heap A) -> (Heap A))))
(define (merge heap1 heap2)
  (let ([heap1-trees (Heap-trees heap1)]
        [heap2-trees (Heap-trees heap2)])
    (cond
      [(null? heap2-trees) heap1]
      [(null? heap1-trees) heap2]
      [else (merge-helper heap1-trees
                          heap2-trees
                          (Heap-comparer heap1))])))

;; Helper for merge
(: merge-helper : 
   (All (A) ((Listof (Node A)) (Listof (Node A)) (A A -> Boolean) -> (Heap A))))
(define (merge-helper heap1-trees heap2-trees comp)
  (let* ([first-tree1 (car heap1-trees)]
         [first-tree2 (car heap2-trees)]
         [heap1       (Heap comp (cdr heap1-trees))]
         [heap2       (Heap comp (cdr heap2-trees))]
         [rank1       (Node-rank first-tree1)]
         [rank2       (Node-rank first-tree2)])
    (cond
      [(< rank1 rank2)
       (Heap comp (cons first-tree1
                        (Heap-trees (merge heap1 (Heap comp heap2-trees)))))]
      [(> rank1 rank2)
       (Heap comp (cons first-tree2
                        (Heap-trees (merge (Heap comp heap1-trees) heap2))))]
      [else (let ([rest (Heap-trees (merge heap1 heap2))]
                  [new  (link first-tree1 first-tree2 comp)])
               (if (null? rest)
                   (Heap comp (list new))
                   (ins-tree new rest comp)))])))

;; Returns the min element if min-heap else returns the max element 
(: find-min/max : (All (A) ((Heap A) -> A)))
(define (find-min/max heap)
  (let ([trees (Heap-trees heap)])
    (cond
      [(null? trees)       (error 'find-min/max "given heap is empty")]
      [(null? (cdr trees)) (Node-val (car trees))]
      [else (let* ([comparer (Heap-comparer heap)]
                   [x (Node-val (car trees))]
                   [y (find-min/max (Heap comparer (cdr trees)))])
               (if (comparer x y) x y))])))

;; Deletes min or max element (depends on min or max heap) 
(: delete-min/max : (All (A) ((Heap A) -> (Heap A))))
(define (delete-min/max heap)
  (: get-min : (All (A) ((Listof (Node A)) (A A -> Boolean) -> (Heap A))))
  (define (get-min trees func)
    (let ([first (car trees)]
          [rest  (cdr trees)]
          [heap  (Heap func trees)])
      (if (null? rest)
          heap
          (let* ([min-trees  (Heap-trees (get-min rest func))]
                 [first-tree (car min-trees)])
            (if (func (Node-val first) (Node-val first-tree))
                heap
                (Heap func (cons first-tree (cons first (cdr min-trees)))))))))
  (if (null? (Heap-trees heap))
      (error 'delete-min/max "given heap is empty")
      (let* ([func (Heap-comparer heap)]
             [newpair (get-min (Heap-trees heap) func)]
             [newpair-trees (Heap-trees newpair)])
         (merge (Heap func (reverse (Node-trees (car newpair-trees))))
                (Heap func (cdr newpair-trees))))))

;; Returns a sorted list (sorting depends on min or max heap)
(: sorted-list : (All (A) ((Heap A) -> (Listof A))))
(define (sorted-list heap)
  (if (empty? heap)
      null
      (cons (find-min/max heap)
            (sorted-list (delete-min/max heap)))))

;; Heap constructor
(: heap : (All (A) ((A A -> Boolean) A * -> (Heap A))))
(define (heap func . lst)
  (foldl (inst insert A) ((inst Heap A) func empty) lst))


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
                  (map-single ((inst Heap C) comp empty) func heap)]
                 [([comp : (C C -> Boolean)]
                   [func : (A B ... B -> C)]
                   [heap : (Heap A)] . [heaps : (Heap B) ... B])
                  (apply map-multiple
                         ((inst Heap C) comp empty)
                         func heap heaps)]))


(: map-single : (All (A C) ((Heap C) (A -> C) (Heap A) -> (Heap C))))
(define (map-single accum func heap)
  (if (empty? heap)
      accum
      (map-single (insert (func (find-min/max heap)) accum) func
                  (delete-min/max heap))))

(: map-multiple :
   (All (A C B ...)
        ((Heap C) (A B ... B -> C) (Heap A) (Heap B) ... B -> (Heap C))))
(define (map-multiple accum func heap . heaps)
  (if (or (empty? heap) (ormap empty? heaps))
      accum
      (apply map-multiple
             (insert (apply func (find-min/max heap) (map find-min/max heaps))
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

;; similar to list filter function
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
  (inner func hep ((inst Heap A) (Heap-comparer hep) empty)))

;; similar to list remove function
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
  (inner func hep ((inst Heap A) (Heap-comparer hep) empty)))

;; Similar to build-list
(: build-heap : (All (A) (Natural (Natural -> A) (A A -> Boolean) -> (Heap A))))
(define (build-heap size func comparer)
  (let: loop : (Heap A) ([n : Natural size])
        (if (zero? n)
            ((inst Heap A) comparer empty)
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
                   [heap : (Heap A)])
                  (or (empty? heap)
                      (and (func (find-min/max heap))
                           (heap-andmap func (delete-min/max heap))))]
                 [([func  : (A B ... B -> Boolean)]
                   [heap : (Heap A)] . [heaps : (Heap B) ... B])
                  (or (empty? heap) (ormap empty? heaps)
                      (and (apply func (find-min/max heap) 
                                  (map find-min/max heaps))
                           (apply heap-andmap func (delete-min/max heap) 
                                  (map delete-min/max heaps))))]))

;; Similar to ormap
(: heap-ormap : 
   (All (A B ...) 
        (case-lambda ((A -> Boolean) (Heap A) -> Boolean)
                     ((A B ... B -> Boolean) (Heap A) (Heap B) ... B 
                                             -> Boolean))))
(define heap-ormap
  (pcase-lambda: (A B ... ) 
                 [([func  : (A -> Boolean)]
                   [heap : (Heap A)])
                  (and (not (empty? heap))
                       (or (func (find-min/max heap))
                           (heap-ormap func (delete-min/max heap))))]
                 [([func  : (A B ... B -> Boolean)]
                   [heap : (Heap A)] . [heaps : (Heap B) ... B])
                  (and (not (or (empty? heap) (ormap empty? heaps)))
                       (or (apply func (find-min/max heap) 
                                  (map find-min/max heaps))
                           (apply heap-ormap func (delete-min/max heap) 
                                  (map delete-min/max heaps))))]))
