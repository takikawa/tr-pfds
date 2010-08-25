#lang typed/scheme #:optimize

(provide (rename-out [heap-map map]) fold  filter remove
         empty empty? insert merge find-min/max 
         delete-min/max sorted-list heap Heap)

(require scheme/match)

(define-struct: Mt ())

(define-struct: (A) Tree ([left : (IntHeap A)]
                          [elem : A]
                          [right : (IntHeap A)]))

(define-type-alias (IntHeap A) (U Mt (Tree A)))

(define-struct: (A) Heap ([comparer : (A A -> Boolean)]
                          [heap : (IntHeap A)]))

;; An empy heap
(define empty (make-Mt))

;; Helper function to find the location for the insert function
(: partition : 
   (All (A) (A (IntHeap A) (A A -> Boolean) -> (Pair (IntHeap A) (IntHeap A)))))
(define (partition pivot heap func)
  (if (Mt? heap)
      (cons empty empty)
      (partition-helper pivot heap func)))

(: partition-helper : 
   (All (A) (A (Tree A) (A A -> Boolean) -> (Pair (IntHeap A) (IntHeap A)))))
(define (partition-helper pivot tree func)
  (let ([elem (Tree-elem tree)]
        [left (Tree-left tree)]
        [right (Tree-right tree)])
    (: phelp-rgt : (IntHeap A) -> (Pair (IntHeap A) (IntHeap A)))
    (define (phelp-rgt rheap)
      (match rheap 
        [(struct Mt ()) (cons tree empty)]
        [(struct Tree (l e r))
         (if (func e pivot)
             (let ([pair (partition pivot r func)])
               (cons (make-Tree (make-Tree left elem l) e (car pair))
                     (cdr pair)))
             (let ([pair (partition pivot l func)])
               (cons (make-Tree left elem (car pair))
                     (make-Tree (cdr pair) e r))))]))
    (: phelp-lft : (IntHeap A) -> (Pair (IntHeap A) (IntHeap A)))
    (define (phelp-lft lheap)
      (match lheap
        [(struct Mt ()) (cons empty tree)]
        [(struct Tree (l e r))
         (if (func e pivot)
             (let ([pair (partition pivot r func)])
               (cons (make-Tree l e (car pair))
                     (make-Tree (cdr pair) elem right)))
             (let ([pair (partition pivot l func)])
               (cons (car pair)
                     (make-Tree (cdr pair) e 
                                (make-Tree r elem right)))))]))
    (if (func elem pivot)
        (phelp-rgt right)
        (phelp-lft left))))

;; Checks for empty
(: empty? : (All (A) ((Heap A) -> Boolean)))
(define (empty? heap)
  (Mt? (Heap-heap heap)))

;; Inserts an element into the heap
(: insert : (All (A) (A (Heap A) -> (Heap A))))
(define (insert elem sheap)
  (let* ([comparer (Heap-comparer sheap)]
         [pair (partition elem (Heap-heap sheap) comparer)])
    (make-Heap comparer (make-Tree (car pair) elem (cdr pair)))))

;; Merges two given heaps
(: merge : (All (A) ((Heap A) (Heap A) -> (Heap A))))
(define (merge sheap1 sheap2)
  (let ([heap1 (Heap-heap sheap1)]
        [heap2 (Heap-heap sheap2)]
        [func (Heap-comparer sheap1)])
    (make-Heap func (merge-help heap1 heap2 func))))

;; Helper for merge
(: merge-help : (All (A) ((IntHeap A) (IntHeap A) (A A -> Boolean) -> (IntHeap A))))
(define (merge-help heap1 heap2 func)
  (let ([pair (cons heap1 heap2)])
    (match pair
      [(cons (struct Mt ()) _) heap2]
      [(cons _ (struct Mt ())) heap1]
      [(cons (struct Tree (a elem b)) _) 
       (let ([in-pair (partition elem heap2 func)])
         (make-Tree (merge-help (car in-pair) a func) 
                    elem
                    (merge-help (cdr in-pair) b func)))])))

;; Returns min or max element of the heap 
(: find-min/max : (All (A) ((Heap A) -> A)))
(define (find-min/max sheap)
  (let ([heap (Heap-heap sheap)]
        [func (Heap-comparer sheap)])
    (match heap
      [(struct Mt ()) (error 'find-min/max "given heap is empty")]
      [(struct Tree ((struct Mt ()) elem b)) elem]
      [(struct Tree (a elem b)) (find-min/max (make-Heap func a))])))

;; Deletes min or max element of the heap
(: delete-min/max : (All (A) ((Heap A) -> (Heap A))))
(define (delete-min/max sheap)
  (let ([heap (Heap-heap sheap)]
        [func (Heap-comparer sheap)])
    (match heap
      [(struct Mt ()) (error 'delete-min/max "given heap is empty")]
      [(struct Tree ((struct Mt ()) elem b)) (make-Heap func b)]
      [(struct Tree ((struct Tree ((struct Mt ()) el a)) elem b))
       (make-Heap func (make-Tree a elem b))]
      [(struct Tree ((struct Tree (a el b)) elem c)) 
       (make-Heap func 
                       (make-Tree 
                        (Heap-heap (delete-min/max (make-Heap func a)))
                        el 
                        (make-Tree b elem c)))])))

;; Returns a sorted list (depends on min or max heap)
(: sorted-list : (All (A) ((Heap A) -> (Listof A))))
(define (sorted-list sheap)
  (if (Mt? (Heap-heap sheap))
      null
      (cons (find-min/max sheap) (sorted-list (delete-min/max sheap)))))

;; Heap constructor
(: heap : (All (A) ((A A -> Boolean) A * -> (Heap A))))
(define (heap func . rst)
  (let ([sheap ((inst make-Heap A) func (make-Mt))])
    (foldl (inst insert A) sheap rst)))


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
  (inner func hep ((inst make-Heap A) (Heap-comparer hep) empty)))

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
  (inner func hep ((inst make-Heap A) (Heap-comparer hep) empty)))

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
                  (map-single ((inst make-Heap C) comp empty) func heap)]
                 [([comp : (C C -> Boolean)]
                   [func : (A B ... B -> C)]
                   [heap : (Heap A)] . [heaps : (Heap B) ... B])
                  (apply map-multiple
                         ((inst make-Heap C) comp empty)
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
