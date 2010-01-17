#lang typed-scheme

(provide empty-heap? insert findMin deleteMin 
         merge sorted-list binomialheap)

(define-struct: (A) Node ([rank : Integer]
                          [val : A]
                          [trees : (Listof (Node A))]))

(define-struct: (A) Heap ([comparer : (A A -> Boolean)]
                          [trees : (Listof (Node A))]))

(: empty-heap? : (All (A) ((Heap A) -> Boolean)))
(define (empty-heap? heap)
  (null? (Heap-trees heap)))

(: rank : (All (A) ((Node A) -> Integer)))
(define (rank node)
  (Node-rank node))

(: root : (All (A) ((Node A) -> A)))
(define (root node)
  (Node-val node))

(: link : (All (A) ((Node A) (Node A) (A A -> Boolean) -> (Node A))))
(define (link node1 node2 func)
  (let* ([val1 (Node-val node1)]
         [val2 (Node-val node2)])
    (if (func val1 val2)
        (make-Node (add1 (Node-rank node1)) val1 
                   (cons node2 (Node-trees node1)))
        (make-Node (add1 (Node-rank node1)) val2 
                   (cons node1 (Node-trees node2))))))

(: insTree : (All (A) ((Node A) (Listof (Node A)) (A A -> Boolean) -> (Heap A))))
(define (insTree node trees comparer)
  (let ([fst (car trees)])
    (if (< (rank node) (rank fst))
        (make-Heap comparer (cons node trees))
        (insNode (link node fst comparer) (cdr trees) comparer))))

(: insert : (All (A) (A (Heap A) -> (Heap A))))
(define (insert val heap)
  (let ([newNode (make-Node 0 val null)]
        [comparer (Heap-comparer heap)]
        [trees (Heap-trees heap)])
    (if (null? trees) 
        (make-Heap comparer (list newNode))
        (insTree newNode trees comparer))))

(: insNode : (All (A) ((Node A) (Listof (Node A)) (A A -> Boolean) -> (Heap A))))
(define (insNode node trees comparer)
  (if (null? trees) 
      (make-Heap comparer (list node))
      (insTree node trees comparer)))

(: merge : (All (A) ((Heap A) (Heap A) -> (Heap A))))
(define (merge heap1 heap2)
  (let ([hp1-trees (Heap-trees heap1)]
        [hp2-trees (Heap-trees heap2)]
        [hp1-comp (Heap-comparer heap1)]
        [hp2-comp (Heap-comparer heap2)])
    (cond
      [(null? hp2-trees) heap1]
      [(null? hp1-trees) heap2]
      [else (merge-helper hp1-trees hp2-trees hp1-comp)])))

(: merge-helper : (All (A) ((Listof (Node A)) (Listof (Node A)) (A A -> Boolean) -> (Heap A))))
(define (merge-helper heap1-trees heap2-trees comp)
  (let* ([fst-tre1 (car heap1-trees)]
         [rst-tre1 (cdr heap1-trees)]
         [fst-tre2 (car heap2-trees)]
         [rst-tre2 (cdr heap2-trees)]
         [rank1 (rank fst-tre1)]
         [rank2 (rank fst-tre2)])
    (cond
      [(< rank1 rank2) 
       (make-Heap comp 
                  (list* fst-tre1 
                         (Heap-trees (merge (make-Heap comp rst-tre1) 
                                            (make-Heap comp heap2-trees)))))]
      [(> rank1 rank2)
       (make-Heap comp 
                  (list* fst-tre2 (Heap-trees (merge (make-Heap comp heap1-trees) 
                                                     (make-Heap comp rst-tre2)))))]
      [else (insNode (link fst-tre1 fst-tre2 comp)
                     (Heap-trees (merge (make-Heap comp rst-tre1) 
                                        (make-Heap comp rst-tre2))) comp)])))

(: findMin : (All (A) ((Heap A) -> A)))
(define (findMin heap)
  (cond
    [(null? (Heap-trees heap)) (error "Heap is empty" 'findMin)]
    [(null? (cdr (Heap-trees heap))) (Node-val (car (Heap-trees heap)))]
    [else (let ([x (root (car (Heap-trees heap)))]
                [y (findMin (make-Heap (Heap-comparer heap) (cdr (Heap-trees heap))))])
            (if ((Heap-comparer heap) x y) x y))]))


(: deleteMin : (All (A) ((Heap A) -> (Heap A))))
(define (deleteMin heap)
  (if (null? (Heap-trees heap))
      (error "Heap is empty" 'deleteMin)
      (letrec: 
       ([getMin : (All (A) ((Heap A) -> (Heap A))) 
                (lambda (intheap)
                  (let* ([comp-heap (Heap-comparer intheap)]
                         [inthp-trees (Heap-trees intheap)]
                         [fst-trees (car inthp-trees)]
                         [rst-trees (cdr inthp-trees)])
                    (if (null? rst-trees)
                        (make-Heap comp-heap (cons fst-trees null))
                        (let* ([pair (getMin (make-Heap comp-heap rst-trees))]
                               [comp-pair (Heap-comparer pair)]
                               [fst-pair (car (Heap-trees pair))]
                               [rst-pair (cdr (Heap-trees pair))])
                          (if (comp-pair (root fst-trees) (root fst-pair))
                              intheap
                              (make-Heap comp-pair (cons fst-pair 
                                                         (cons fst-trees 
                                                               rst-pair))))))))]
        [newpair : (Heap A) (getMin heap)]
        [comparer : (A A -> Boolean) (Heap-comparer newpair)]
        [newpair-trees : (Listof (Node A)) (Heap-trees newpair)])
       (merge (make-Heap comparer (reverse (Node-trees (car newpair-trees))))
              (make-Heap comparer (cdr newpair-trees))))))
                      

(: sorted-list : (All (A) ((Heap A) -> (Listof A))))
(define (sorted-list heap)
  (if (empty-heap? heap)
      null
      (cons (findMin heap) (sorted-list (deleteMin heap)))))

(: binomialheap : (All (A) ((A A -> Boolean) (Listof A) -> (Heap A))))
(define (binomialheap func lst)
  (if (null? lst)
      (make-Heap func lst)
      (foldl (inst insert A) (make-Heap func (list (make-Node 1 (car lst) null))) (cdr lst))))