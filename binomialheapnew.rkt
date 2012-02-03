#lang typed-scheme

(define-struct: (A) Elem ([val : A]))

(define-struct: (A) Node ([rank : Integer]
                          [elem : (Elem A)]
                          [trees : (Listof (Tree A))]))

(define-struct: Null-Tree ([Null : Any]))

(define null-tree (make-Null-Tree ""))

(define-type-alias Tree (All (A) (Node A)))

(define-type-alias Heap (All (A) (Listof (Tree A))))

(define: comparer : (Boxof (Any Any -> Boolean)) (box eq?))


(: isEmpty? : (All (A) ((Tree A) -> Boolean)))
(define (isEmpty? tre)
  (Null-Tree? tre))


(: empty-Heap? : (All (A) ((Heap A) -> Boolean)))
(define (empty-Heap? heap)
  (null? heap))

(: rank : (All (A) ((Node A) -> Integer)))
(define (rank node)
  (Node-rank node))


(: root : (All (A) ((Node A) -> A)))
(define (root node)
  (Elem-val (Node-elem node)))


(: link : (All (A) ((Node A) (Node A) -> (Node A))))
(define (link node1 node2)
  (let* ([elem1 (Node-elem node1)]
         [elem2 (Node-elem node2)]
         [func (unbox comparer)]
         [val1 (Elem-val elem1)]
         [val2 (Elem-val elem2)])
    (if (func val1 val2)
        (make-Node (add1 (Node-rank node1)) elem1 (cons node2 (Node-trees node1)))
        (make-Node (add1 (Node-rank node1)) elem2 (cons node1 (Node-trees node2))))))


(: insTree : (All (A) ((Tree A) (Heap A) -> (Heap A))))
(define (insTree node heap)
  (cond
    [(null? heap) (list node)]
    [(< (rank node) (rank (car heap))) (cons node heap)]
    [else (insTree (link node (car heap)) (cdr heap))]))

(: insert : (All (A) (A (Heap A) -> (Heap A))))
(define (insert val heap)
  (insTree (make-Node 0 (make-Elem val) null) heap))

(: merge : (All (A) ((Heap A) (Heap A) -> (Heap A))))
(define (merge heap1 heap2)
  (cond
    [(null? heap2) heap1]
    [(null? heap1) heap2]
    [(< (rank (car heap1)) (rank (car heap2))) (cons (car heap1) (merge (cdr heap1) heap2))]
    [(> (rank (car heap1)) (rank (car heap2))) (cons (car heap2) (merge heap1 (cdr heap2)))]
    [else (insTree (link (car heap1) (car heap2)) (merge (cdr heap1) (cdr heap2)))]))

(: findMin : (All (A) ((Heap A) -> A)))
(define (findMin heap)
  (cond
    [(null? heap) (error "Heap is empty" 'findMin)]
    [(null? (cdr heap)) (Elem-val (Node-elem (car heap)))]
    [else (let ([x (root (car heap))]
                [y (findMin (cdr heap))])
            (if ((unbox comparer) x y) x y))]))


(: deleteMin : (All (A) ((Heap A) -> (Heap A))))
(define (deleteMin heap)
  (if (null? heap)
      (error "Heap is empty" 'deleteMin)
      (letrec: ([getMin : (All (A) ((Heap A) -> (Heap A))) 
                        (lambda (intheap)
                          (if (null? (cdr intheap))
                              (cons (car intheap) null)
                              (let ([pair (getMin (cdr intheap))])
                                (if ((unbox comparer) (root (car intheap)) (root (car pair)))
                                    intheap
                                    (cons (car pair) (cons (car intheap) (cdr pair)))))))]
                [newpair : (Heap A) (getMin heap)])
               (merge (reverse (Node-trees (car newpair))) (cdr newpair)))))

(: binomialheap : (All (A) ((Any Any -> Boolean) (Listof A) -> (Heap A))))
(define (binomialheap func lst)
  (begin
    (set-box! comparer func)
    (foldl (inst insert A) null lst)))