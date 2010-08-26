#lang typed/scheme #:optimize

(provide (rename-out [heap-map map]) fold  filter remove Heap
         heap merge insert find-min/max delete-min/max sorted-list)

(struct: (A) Tree ([rank : Integer]
                   [elem : A]
                   [left : (IntHeap A)]
                   [right : (IntHeap A)]))

(define-type (IntHeap A) (U Null (Tree A)))

(struct: (A) LeftistHeap ([comparer : (A A -> Boolean)]
                          [heap : (IntHeap A)]))

(define-type (Heap A) (LeftistHeap A))

;; An empty heap
(define empty null)

;; Returns the rank of the heap
(: rank : (All (A) ((IntHeap A) -> Integer)))
(define (rank lheap)
  (if (null? lheap) 0 (Tree-rank lheap)))


(: make-lheap : (All (A) (A (IntHeap A) (IntHeap A) -> (IntHeap A))))
(define (make-lheap elem heap1 heap2)
  (let ([rank1 (rank heap1)]
        [rank2 (rank heap2)])
    (if (>= rank1 rank2)
        (Tree (add1 rank2) elem heap1 heap2)
        (Tree (add1 rank1) elem heap2 heap1))))

;; Checks for empty heap
(: empty? : (All (A) ((LeftistHeap A) -> Boolean)))
(define (empty? lheap)
  (null? (LeftistHeap-heap lheap)))

;; Inserts an element into the heap
(: insert : (All (A) (A (LeftistHeap A) -> (LeftistHeap A))))
(define (insert elem lheap)
  (let ([comparer (LeftistHeap-comparer lheap)])
    (LeftistHeap comparer
                 (in-merge (Tree 1 elem empty empty) 
                           (LeftistHeap-heap lheap)
                           comparer))))

;; Merges two heaps.
(: merge : (All (A) ((LeftistHeap A) (LeftistHeap A) -> (LeftistHeap A))))
(define (merge heap1 heap2)
  (let ([comparer (LeftistHeap-comparer heap1)])
    (LeftistHeap comparer
                 (in-merge (LeftistHeap-heap heap1) 
                           (LeftistHeap-heap heap2) 
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
        [tr1-lft (Tree-left tree1)]
        [tr2-lft (Tree-left tree2)]
        [tr1-rgt (Tree-right tree1)]
        [tr2-rgt (Tree-right tree2)])
    (if (comparer tr1-elm tr2-elm)
        (make-lheap tr1-elm tr1-lft 
                    (in-merge tr1-rgt tree2 comparer))
        (make-lheap tr2-elm tr2-lft 
                    (in-merge tree1 tr2-rgt comparer)))))

;; Returns min or max element of the heap
(: find-min/max : (All (A) ((LeftistHeap A) -> A)))
(define (find-min/max lheap)
  (let ([heap (LeftistHeap-heap lheap)]
        [comparer (LeftistHeap-comparer lheap)])
    (if (null? heap)
        (error 'find-min/max "given heap is empty")
        (Tree-elem heap))))

;; Deletes min or max element of the heap
(: delete-min/max : (All (A) ((LeftistHeap A) -> (LeftistHeap A))))
(define (delete-min/max lheap)
  (let ([heap (LeftistHeap-heap lheap)]
        [comparer (LeftistHeap-comparer lheap)])
    (if (null? heap)
        (error 'delete-min/max "given heap is empty")
        (LeftistHeap comparer
                     (in-merge (Tree-left heap) 
                               (Tree-right heap) 
                               comparer)))))

;; Returns a sorted list 
(: sorted-list : (All (A) ((LeftistHeap A) -> (Listof A))))
(define (sorted-list lheap)
  (if (null? (LeftistHeap-heap lheap))
      null
      (cons (find-min/max lheap) (sorted-list (delete-min/max lheap)))))

;; Heap constructor
(: heap : (All (A) ((A A -> Boolean) A * -> (LeftistHeap A))))
(define (heap comparer . lst)
  (let ([first ((inst LeftistHeap A) comparer empty)])
    (foldl (inst insert A) first lst)))

;; similar to list filter function
(: filter : (All (A) ((A -> Boolean) (LeftistHeap A) -> (LeftistHeap A))))
(define (filter func hep)
  (: inner : (All (A) ((A -> Boolean) (LeftistHeap A) (LeftistHeap A) -> (LeftistHeap A))))
  (define (inner func hep accum)
    (if (empty? hep)
        accum
        (let ([head (find-min/max hep)]
              [tail (delete-min/max hep)])
          (if (func head)
              (inner func tail (insert head accum))
              (inner func tail accum)))))
  (inner func hep ((inst LeftistHeap A) (LeftistHeap-comparer hep) empty)))

;; similar to list remove function
(: remove : (All (A) ((A -> Boolean) (LeftistHeap A) -> (LeftistHeap A))))
(define (remove func hep)
  (: inner : (All (A) ((A -> Boolean) (LeftistHeap A) (LeftistHeap A) -> (LeftistHeap A))))
  (define (inner func hep accum)
    (if (empty? hep)
        accum
        (let ([head (find-min/max hep)]
              [tail (delete-min/max hep)])
          (if (func head)
              (inner func tail accum)
              (inner func tail (insert head accum))))))
  (inner func hep ((inst LeftistHeap A) (LeftistHeap-comparer hep) empty)))

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
                  (map-single ((inst LeftistHeap C) comp empty) func heap)]
                 [([comp : (C C -> Boolean)]
                   [func : (A B ... B -> C)]
                   [heap : (Heap A)] . [heaps : (Heap B) ... B])
                  (apply map-multiple
                         ((inst LeftistHeap C) comp empty)
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