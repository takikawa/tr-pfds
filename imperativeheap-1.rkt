#lang scheme
(provide (all-defined-out))
;; A Leftist-Heap is one of
;; - mt
;; - tree-node

(define-struct LH (func hp) #:mutable)

(define-struct treenode (elem left right dist) #:mutable)

;; left and right are leftist heaps
;; elem and npl are of type int

(define-struct mt ())

;; Makes a empty Leftist-Heap
;; (make-heap : (a a -> Boolean) -> Leftist-Heap)
(define (make-heap func)
  (make-LH func (make-mt)))

(define (merge lh1 lh2)
  (let ([func (LH-func lh1)]
        [hp1 (LH-hp lh1)]
        [hp2 (LH-hp lh2)])
    (set-LH-hp! lh1 (merge1 func hp1 hp2))
    lh1))

;; Merges two given Leftist-Heaps
;; (merge : (Leftist-Heap Leftist-Heap -> Leftist-Heap))
(define (merge1 func hp1 hp2)
  (cond
    [(mt? hp1) hp2]
    [(mt? hp2) hp1]
    [(func (treenode-elem hp1) (treenode-elem hp2)) 
     (begin
       (set-treenode-right! hp1 (merge1 func (treenode-right hp1) hp2))
       (fixdist hp1)
       hp1)]
    [else 
     (begin
       (set-treenode-right! hp2 (merge1 func hp1 (treenode-right hp2)))
       (fixdist hp2)
       hp2)]))

;; Fixdist
;; fixdist : Leftist-Heap -> Leftist-Heap
(define (fixdist hp)
  (let* ([left (treenode-left hp)]
         [right (treenode-right hp)]
         [ldist (distance left)]
         [rdist (distance right)])
    (if (< ldist rdist)
        (begin
          (set-treenode-right! hp left)
          (set-treenode-left! hp right)
          (set-treenode-dist! hp (add1 rdist))
          hp)
        (begin
          (set-treenode-dist! hp (add1 rdist))
          hp))))

;; Gets the distance
;; distance : LeftistHeap -> Integer
(define (distance hp)
  (if (mt? hp) 0 (treenode-dist hp)))

(define (insert elem lh)
  (set-LH-hp! lh (insert1 (LH-func lh) elem (LH-hp lh)))
  lh)
;; Inserts an element into the heap
;; insert : LeftistHeap -> LeftistHeap
(define (insert1 func elem hp)
  (let
      ([new (make-treenode elem (make-mt) (make-mt) 1)])
    (cond
      [(mt? hp) new]
      [(func (treenode-elem hp) (treenode-elem new)) 
       (begin
         (set-treenode-right! hp (insert1 func elem (treenode-right hp)))
         (fixdist hp)
         hp)]
      [else 
       (begin
         (set-treenode-left! new hp)
         new)])))

(define (delete-min lh)
  (set-LH-hp! lh (delete-min1 (LH-func lh) (LH-hp lh)))
  lh)

(define (delete-min1 func hp)
  (if (mt? hp)
      (error "No elements" 'delete-min)
      (let ([new (merge1 func (treenode-left hp) (treenode-right hp))])
        (begin
          (set-treenode-elem! hp (treenode-elem new))
          (set-treenode-left! hp (treenode-left new))
          (set-treenode-right! hp (treenode-right new))
          (set-treenode-dist! hp (treenode-dist new))
          hp))))

(define (find-min lh)
  (let ([hp (LH-hp lh)])
    (if (mt? hp)
        (error "No elements" 'find-min)
        (treenode-elem hp))))

(define (heap func fst . rst)
  (foldl insert (make-LH func (make-mt)) (cons fst rst)))