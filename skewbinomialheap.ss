#lang typed-scheme

(provide empty? insert merge find-min/max delete-min/max 
         binomialheap sorted-list empty BinomialHeap)

(require scheme/match)

(define-struct: (A) Tree ([rank : Integer]
                          [elem : A]
                          [elems : (Listof A)]
                          [trees : (Trees A)]))

(define-struct: (A) Heap ([comparer : (A A -> Boolean)]
                          [trees : (Trees A)]))

(define-type-alias (BinomialHeap A) (Heap A))
(define-type-alias (Trees A) (Listof (Tree A)))

(define-type-alias (FUNC A) (A A -> Boolean))
(: empty? : (All (A) ((Heap A) -> Boolean)))
(define (empty? heap)
  (null? (Heap-trees heap)))

(define empty null)

(: rank : (All (A) ((Tree A) -> Integer)))
(define (rank tree)
  (Tree-rank tree))

(: root : (All (A) ((Tree A) -> A)))
(define (root tree)
  (Tree-elem tree))

(: link : (All (A) ((Tree A) (Tree A) (A A -> Boolean) -> (Tree A))))
(define (link tree1 tree2 func)
  (let ([root1 (root tree1)]
        [root2 (root tree2)]
        [new-rank (add1 (rank tree1))])
    (if (func root1 root2)
        (make-Tree new-rank root1 (Tree-elems tree1) 
                   (cons tree2 (Tree-trees tree1)))
        (make-Tree new-rank root2 (Tree-elems tree2) 
                   (cons tree1 (Tree-trees tree2))))))

(: skew-link : (All (A) (A (Tree A) (Tree A) (FUNC A) -> (Tree A))))
(define (skew-link elem tree1 tree2 func)
  (let* ([tree (link tree1 tree2 func)]
         [lroot (root tree)]
         [lrank (rank tree)]
         [lelems (Tree-elems tree)]
         [ltrees (Tree-trees tree)])
    (if (func elem lroot)
        (make-Tree lrank elem (cons lroot lelems) ltrees)
        (make-Tree lrank lroot (cons elem lelems) ltrees))))

(: ins-tree : (All (A) ((Tree A) (Trees A) (FUNC A) -> (Trees A))))
(define (ins-tree tree lst func)
  (if (null? lst)
      (list tree)
      (let ([fst (car lst)])
        (if (< (rank tree) (rank fst))
            (cons tree lst)
            (ins-tree (link tree fst func) (cdr lst) func)))))


(: merge-trees : (All (A) ((Trees A) (Trees A) (FUNC A) -> (Trees A))))
(define (merge-trees list1 list2 func)
  (cond 
    [(null? list1) list2]
    [(null? list2) list1]
    [else (merge-help (car list1) (cdr list1) (car list2) (cdr list2) func)]))


(: merge-help : 
   (All (A) ((Tree A) (Trees A) (Tree A) (Trees A) (FUNC A) -> (Trees A))))
(define (merge-help tre1 tres1 tre2 tres2 fun)
  (let ([rank1 (rank tre1)]
        [rank2 (rank tre2)])
    (cond
      [(< rank1 rank2) (cons tre1 (merge-trees tres1 (cons tre2 tres2) fun))]
      [(> rank2 rank1) (cons tre2 (merge-trees (cons tre1 tres1) tres2 fun))]
      [else 
       (ins-tree (link tre1 tre2 fun) (merge-trees tres1 tres2 fun) fun)])))

(: normalize : (All (A) ((Trees A) (FUNC A) -> (Trees A))))
(define (normalize trees func)
  (if (null? trees)
      trees
      (ins-tree (car trees) (cdr trees) func)))

(: insert : (All (A) (A (Heap A) -> (Heap A))))
(define (insert elem heap)
  (let* ([trees (Heap-trees heap)]
         [func (ann (Heap-comparer heap) (FUNC A))]
         [new-ts (make-Heap func (cons (make-Tree 0 elem null null) trees))])
    (match trees
      [(list t1 t2 #{ts : (Trees A)} ...) 
       (if (= (rank t1) (rank t2))
           (make-Heap func 
                      (cons (skew-link elem t1 t2 func) ts))
           new-ts)]
      [else new-ts])))

(: merge : (All (A) ((Heap A) (Heap A) -> (Heap A))))
(define (merge heap1 heap2)
  (let ([func (Heap-comparer heap1)]
        [trees1 (Heap-trees heap1)]
        [trees2 (Heap-trees heap2)])
    (make-Heap func (merge-trees (normalize trees1 func) 
                                 (normalize trees2 func)
                                 func))))

(: remove-mintree : 
   (All (A) ((Trees A) (FUNC A) -> (Pair (Tree A) (Trees A)))))
(define (remove-mintree trees func)
  (match trees 
    [(list) (error "Heap is empty")]
    [(list t) (cons t null)]
    [(list t #{ts : (Trees A)} ...) 
     (let* ([pair (remove-mintree ts func)]
            [t1 (car pair)]
            [ts1 (cdr pair)])
       (if (func (root t) (root t1))
           (cons t ts)
           (cons t1 (cons t ts1))))]))

(: find-min/max : (All (A) ((Heap A) -> A)))
(define (find-min/max heap)
  (let* ([func (Heap-comparer heap)]
         [trees (Heap-trees heap)]
         [pair (with-handlers 
                   ([exn:fail? (lambda (error?) 
                                 (error 'find-min/max "Given heap is empty"))])
                 (remove-mintree trees func))]
         [tree (car pair)])
    (root tree)))

(: delete-min/max : (All (A) ((Heap A) -> (Heap A))))
(define (delete-min/max heap)
  (let* ([func (Heap-comparer heap)]
         [trees (Heap-trees heap)]
         [pair (with-handlers 
                   ([exn:fail? (lambda (error?) 
                                 (error 'delete-min/max
                                        "Given heap is empty"))])
                 (remove-mintree trees func))]
         [tree (car pair)]
         [ts (cdr pair)])
    (: ins-all : ((Listof A) (Heap A) -> (Heap A)))
    (define (ins-all lst hp)
      (if (null? lst)
          hp
          (ins-all (cdr lst) (insert (car lst) hp))))
    (ins-all (Tree-elems tree) 
             (merge (make-Heap func (reverse (Tree-trees tree))) 
                    (make-Heap func ts)))))


(: binomialheap : (All (A) ((FUNC A) A * -> (Heap A))))
(define (binomialheap func . lst)
  (foldl (inst insert A) ((inst make-Heap A) func null) lst))

(: sorted-list : (All (A) ((Heap A) -> (Listof A))))
(define (sorted-list heap)
  (if (empty? heap)
      null
      (cons (find-min/max heap) (sorted-list (delete-min/max heap)))))
