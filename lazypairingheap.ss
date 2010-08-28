#lang typed/racket #:optimize

(provide (rename-out [heap-map map]) fold  filter remove
         heap merge insert find-min/max
         delete-min/max sorted-list empty?)

(require scheme/match)

(struct: (A) IntHeap ([elem : A]
                      [heap : (PHeap A)]
                      [lazy : (Promise (PHeap A))]))

(define-type (PHeap A) (U Null (IntHeap A)))

(struct: (A) PairingHeap ([comparer : (A A -> Boolean)]
                          [heap : (PHeap A)]))

(define-type (Heap A) (PairingHeap A))

;; Checks for empty
(: empty? : (All (A) ((PairingHeap A) -> Boolean)))
(define (empty? pheap)
  (null? (PairingHeap-heap pheap)))

;; An empty heap
(define empty null)

;; Merges two given heaps
(: merge : (All (A) ((PairingHeap A) (PairingHeap A) -> (PairingHeap A))))
(define (merge pheap1 pheap2)
  (let ([func (PairingHeap-comparer pheap1)]
        [heap1 (PairingHeap-heap pheap1)]
        [heap2 (PairingHeap-heap pheap2)])
    (PairingHeap func (merge-help heap1 heap2 func))))

;; Helper for merge
(: merge-help : (All (A) ((PHeap A) (PHeap A) (A A -> Boolean) -> (PHeap A))))
(define (merge-help pheap1 pheap2 func)
  (match (cons pheap1 pheap2)
    [(cons '() _) pheap2]
    [(cons _ '()) pheap1]
    [(cons (and h1 (struct IntHeap (x _ _))) (and h2 (struct IntHeap (y _ _)))) 
     (if (func x y)
         (link h1 h2 func)
         (link h2 h1 func))]))

(: link : (All (A) ((IntHeap A) (IntHeap A) (A A -> Boolean) -> (PHeap A))))
(define (link heap1 heap2 func)
  (match heap1
    [(struct IntHeap (x '() m)) (IntHeap x heap2 m)]
    [(struct IntHeap (x b m)) 
     (IntHeap x '() (delay (merge-help (merge-help heap2 b func)
                                       (force m)
                                       func)))]))

;; Inserts an element into the heap
(: insert : (All (A) (A (PairingHeap A) -> (PairingHeap A))))
(define (insert elem pheap)
  (let ([func (PairingHeap-comparer pheap)]
        [heap (PairingHeap-heap pheap)])
    (PairingHeap func (merge-help (IntHeap elem '()
                                           (delay '()))
                                  heap func))))

;; Returns min or max element of the heap
(: find-min/max : (All (A) ((PairingHeap A) -> A)))
(define (find-min/max pheap)
  (let ([heap (PairingHeap-heap pheap)])
    (if (null? heap)
        (error 'find-min/max "given heap is empty")
        (IntHeap-elem heap))))

;; Deletes min or max element of the heap
(: delete-min/max : (All (A) ((PairingHeap A) -> (PairingHeap A))))
(define (delete-min/max pheap)
  (let ([heap (PairingHeap-heap pheap)]
        [func (PairingHeap-comparer pheap)])
    (if (null? heap)
        (error 'delete-min/max "given heap is empty")
        (PairingHeap func (merge-help (IntHeap-heap heap) 
                                      (force (IntHeap-lazy heap)) 
                                      func)))))

;; Heap constructor
(: heap : (All (A) ((A A -> Boolean) A * -> (PairingHeap A))))
(define (heap comparer . lst)
  (let ([first ((inst PairingHeap A) comparer '())])
    (foldl (inst insert A) first lst)))


(: sorted-list : (All (A) ((PairingHeap A) -> (Listof A))))
(define (sorted-list pheap)
  (let ([heap (PairingHeap-heap pheap)])
    (if (null? heap)
        null
        (cons (find-min/max pheap) (sorted-list (delete-min/max pheap))))))


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
  (inner func hep ((inst PairingHeap A) (PairingHeap-comparer hep) empty)))

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
  (inner func hep ((inst PairingHeap A) (PairingHeap-comparer hep) empty)))

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
