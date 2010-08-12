#lang typed/scheme ;#:optimize

(provide (rename-out [heap-map map]) fold  filter remove Heap
         heap merge insert find-min/max delete-min/max sorted-list)

(define-struct: Mt ())
(define-struct: (A) Tree ([rank : Integer]
                          [elem : A]
                          [left : (IntHeap A)]
                          [right : (IntHeap A)]))

(define-type-alias (IntHeap A) (U Mt (Tree A)))

(define-struct: (A) LeftistHeap ([comparer : (A A -> Boolean)]
                                 [heap : (IntHeap A)]))

(define-type-alias (Heap A) (LeftistHeap A))

;; An empty heap
(define empty (make-Mt))

;; Returns the rank of the heap
(: rank : (All (A) ((IntHeap A) -> Integer)))
(define (rank lheap)
  (if (Mt? lheap) 0 (Tree-rank lheap)))


(: make-lheap : (All (A) (A (IntHeap A) (IntHeap A) -> (IntHeap A))))
(define (make-lheap elem heap1 heap2)
  (let ([rank1 (rank heap1)]
        [rank2 (rank heap2)])
    (if (>= rank1 rank2)
        (make-Tree (add1 rank2) elem heap1 heap2)
        (make-Tree (add1 rank1) elem heap2 heap1))))

;; Checks for empty heap
(: empty? : (All (A) ((LeftistHeap A) -> Boolean)))
(define (empty? lheap)
  (Mt? (LeftistHeap-heap lheap)))

;; Inserts an element into the heap
(: insert : (All (A) (A (LeftistHeap A) -> (LeftistHeap A))))
(define (insert elem lheap)
  (let ([comparer (LeftistHeap-comparer lheap)])
    (make-LeftistHeap comparer
                      (in-merge (make-Tree 1 elem empty empty) 
                                (LeftistHeap-heap lheap)
                                comparer))))

;; Merges two heaps.
(: merge : (All (A) ((LeftistHeap A) (LeftistHeap A) -> (LeftistHeap A))))
(define (merge heap1 heap2)
  (let ([comparer (LeftistHeap-comparer heap1)])
    (make-LeftistHeap comparer
                      (in-merge (LeftistHeap-heap heap1) 
                                (LeftistHeap-heap heap2) 
                                comparer))))

;; Helper for merge
(: in-merge : 
   (All (A) ((IntHeap A) (IntHeap A) (A A -> Boolean) -> (IntHeap A))))
(define (in-merge heap1 heap2 comparer)
  (cond
    [(Mt? heap2) heap1]
    [(Mt? heap1) heap2]
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
    (if (Mt? heap)
        (error 'find-min/max "given heap is empty")
        (Tree-elem heap))))

;; Deletes min or max element of the heap
(: delete-min/max : (All (A) ((LeftistHeap A) -> (LeftistHeap A))))
(define (delete-min/max lheap)
  (let ([heap (LeftistHeap-heap lheap)]
        [comparer (LeftistHeap-comparer lheap)])
    (if (Mt? heap)
        (error 'delete-min/max "given heap is empty")
        (make-LeftistHeap comparer
                          (in-merge (Tree-left heap) 
                                    (Tree-right heap) 
                                    comparer)))))

;; Returns a sorted list 
(: sorted-list : (All (A) ((LeftistHeap A) -> (Listof A))))
(define (sorted-list lheap)
  (if (Mt? (LeftistHeap-heap lheap))
      null
      (cons (find-min/max lheap) (sorted-list (delete-min/max lheap)))))

;; Heap constructor
(: heap : (All (A) ((A A -> Boolean) A * -> (LeftistHeap A))))
(define (heap comparer . lst)
  (let ([first ((inst make-LeftistHeap A) comparer empty)])
    (foldl (inst insert A) first lst)))

;; similar to list map function
(: heap-map : 
   (All (A C B ...) ((C C -> Boolean) 
                     (A B ... B -> C) 
                     (LeftistHeap A) 
                     (LeftistHeap B) ... B -> (LeftistHeap C))))
(define (heap-map comp func fst . rst)
  (: in-map : 
     (All (A C B ...) ((LeftistHeap C) 
                       (A B ... B -> C) 
                       (LeftistHeap A) 
                       (LeftistHeap B) ... B -> (LeftistHeap C))))
  (define (in-map accum func fst . rst)
    (if (or (empty? fst) (ormap empty? rst))
        accum
        (apply in-map
               (insert (apply func (find-min/max fst) (map find-min/max rst)) accum)
               func
               (delete-min/max fst) 
               (map delete-min/max rst))))
  (apply in-map ((inst make-LeftistHeap C) comp empty) func fst rst))

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
  (inner func hep ((inst make-LeftistHeap A) (LeftistHeap-comparer hep) empty)))

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
  (inner func hep ((inst make-LeftistHeap A) (LeftistHeap-comparer hep) empty)))

;; similar to list fold function
(: fold : (All (A C B ...)
               ((C A B ... B -> C) C (LeftistHeap A) (LeftistHeap B) ... B -> C)))
(define (fold func base hep . heps)
  (if (or (empty? hep) (ormap empty? heps))
      base
      (apply fold 
             func 
             (apply func base (find-min/max hep) (map find-min/max heps))
             (delete-min/max hep)
             (map delete-min/max heps))))
