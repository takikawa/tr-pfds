#lang typed-scheme

(define-struct: Mt ())
(define-struct: (A) Tree ([rank : Integer]
                          [elem : A]
                          [left : (Heap A)]
                          [right : (Heap A)]))

(define-type-alias (Heap A) (U Mt (Tree A)))

(define-struct: (A) LeftistHeap ([comparer : (A A -> Boolean)]
                                 [heap : (Heap A)]))

(define empty (make-Mt))

(: rank : (All (A) ((Heap A) -> Integer)))
(define (rank lheap)
  (if (Mt? lheap) 0 (Tree-rank lheap)))

(: make-lheap : (All (A) (A (Heap A) (Heap A) -> (Heap A))))
(define (make-lheap elem heap1 heap2)
  (let ([rank1 (rank heap1)]
        [rank2 (rank heap2)])
    (if (>= rank1 rank2)
        (make-Tree (add1 rank2) elem heap1 heap2)
        (make-Tree (add1 rank1) elem heap2 heap1))))

(: is-empty? : (All (A) ((LeftistHeap A) -> Boolean)))
(define (is-empty? lheap)
  (Mt? (LeftistHeap-heap lheap)))

(: insert : (All (A) (A (LeftistHeap A) -> (LeftistHeap A))))
(define (insert elem lheap)
  (let ([comparer (LeftistHeap-comparer lheap)])
    (make-LeftistHeap comparer
                      (in-merge (make-Tree 1 elem empty empty) 
                                (LeftistHeap-heap lheap)
                                comparer))))

(: merge : (All (A) ((LeftistHeap A) (LeftistHeap A) -> (LeftistHeap A))))
(define (merge heap1 heap2)
  (let ([comparer (LeftistHeap-comparer heap1)])
    (make-LeftistHeap comparer
                      (in-merge (LeftistHeap-heap heap1) 
                                (LeftistHeap-heap heap2) 
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
        [tr1-lft (Tree-left tree1)]
        [tr2-lft (Tree-left tree2)]
        [tr1-rgt (Tree-right tree1)]
        [tr2-rgt (Tree-right tree2)])
    (if (comparer tr1-elm tr2-elm)
        (make-lheap tr1-elm tr1-lft 
                    (in-merge tr1-rgt tree2 comparer))
        (make-lheap tr2-elm tr2-lft 
                    (in-merge tree1 tr2-rgt comparer)))))

(: find-min : (All (A) ((LeftistHeap A) -> A)))
(define (find-min lheap)
  (let ([heap (LeftistHeap-heap lheap)]
        [comparer (LeftistHeap-comparer lheap)])
    (if (Mt? heap)
        (error "Heap is empty :" 'find-min)
        (Tree-elem heap))))

(: delete-min : (All (A) ((LeftistHeap A) -> (LeftistHeap A))))
(define (delete-min lheap)
  (let ([heap (LeftistHeap-heap lheap)]
        [comparer (LeftistHeap-comparer lheap)])
    (if (Mt? heap)
        (error "Heap is empty :" 'delete-min)
        (make-LeftistHeap comparer
                          (in-merge (Tree-left heap) 
                                    (Tree-right heap) 
                                    comparer)))))

(: get-sorted-list : (All (A) ((LeftistHeap A) -> (Listof A))))
(define (get-sorted-list lheap)
  (: helper : (All (A) ((LeftistHeap A) (Listof A) -> (Listof A))))
  (define (helper inheap lst)
    (let ([heap (LeftistHeap-heap inheap)])
      (if (Mt? heap)
          lst
          (helper (delete-min inheap) (cons (find-min inheap) lst)))))
  (helper lheap null))

(: leftistheap : (All (A) ((Listof A) (A A -> Boolean) -> (LeftistHeap A))))
(define (leftistheap lst comparer)
  (if (null? lst)
      (error "At least one element expected in the input list" 'leftistheap)
      (foldl (inst insert A) 
             (make-LeftistHeap comparer 
                               (make-Tree 1 (car lst) empty empty))
             (cdr lst))))