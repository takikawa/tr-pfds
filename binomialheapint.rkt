#lang typed-scheme

(define-struct: Node ([rank : Integer]
                      [elem : Integer]
                      [trees : (Listof Node)]))

(define-type-alias Heap (Listof Node))

(define comparer (box >=))


(: empty-Heap? : (Heap -> Boolean))
(define (empty-Heap? heap)
  (null? heap))

(: rank : (Node -> Integer))
(define (rank node)
  (Node-rank node))


(: root : (Node -> Integer))
(define (root node)
  (Node-elem node))


(: link : (Node Node -> Node))
(define (link node1 node2)
  (let* ([val1 (Node-elem node1)]
         [val2 (Node-elem node2)]
         [func (unbox comparer)])
    (if (func val1 val2)
        (make-Node (add1 (Node-rank node1)) val1 (cons node2 (Node-trees node1)))
        (make-Node (add1 (Node-rank node1)) val2 (cons node1 (Node-trees node2))))))


(: insTree : (Node Heap -> Heap))
(define (insTree node heap)
  (cond
    [(null? heap) (list node)]
    [(< (rank node) (rank (car heap))) (cons node heap)]
    [else (insTree (link node (car heap)) (cdr heap))]))

(: insert : (Integer Heap -> Heap))
(define (insert val heap)
  (insTree (make-Node 0 val null) heap))

(: merge : (Heap Heap -> Heap))
(define (merge heap1 heap2)
  (cond
    [(null? heap2) heap1]
    [(null? heap1) heap2]
    [(< (rank (car heap1)) (rank (car heap2))) (cons (car heap1) (merge (cdr heap1) heap2))]
    [(> (rank (car heap1)) (rank (car heap2))) (cons (car heap2) (merge heap1 (cdr heap2)))]
    [else (insTree (link (car heap1) (car heap2)) (merge (cdr heap1) (cdr heap2)))]))

(: findMin : (Heap -> Integer))
(define (findMin heap)
  (cond
    [(null? heap) (error "Heap is empty" 'findMin)]
    [(null? (cdr heap)) (Node-elem (car heap))]
    [else (let ([x (root (car heap))]
                [y (findMin (cdr heap))])
            (if ((unbox comparer) x y) x y))]))

(: deleteMin : (All (A) (Heap -> Heap)))
(define (deleteMin heap)
  (if (null? heap)
      (error "Heap is empty" 'deleteMin)
      (letrec: ([getMin : (Heap -> Heap)
                        (lambda (intheap)
                          (if (null? (cdr intheap))
                              (cons (car intheap) null)
                              (let ([pair (getMin (cdr intheap))])
                                (if ((unbox comparer) (root (car intheap)) (root (car pair)))
                                    intheap
                                    (cons (car pair) (cons (car intheap) (cdr pair)))))))]
                [newpair : Heap (getMin heap)])
               (merge (reverse (Node-trees (car newpair))) (cdr newpair)))))

(: binomialheap : ((Number Number Number * -> Boolean) (Listof Integer) -> Heap))
(define (binomialheap func lst)
  (begin
    (set-box! comparer func)
    (foldl insert null lst)))