#lang typed-scheme

(define-struct: (A) Node ([rank : Integer]
                          [val : A]
                          [trees : (Listof (Node A))]))

(define-struct: (A) Heap ([comparer : (A A -> Boolean)]
                          [trees : (Listof (Node A))]))

;;;;;;;;;;;---- These guys are not being used----------
(define-struct: (A) Null-Heap ([comparer : (A A -> Boolean)]))
(define-type-alias BHeap (All (A) (U (Heap A) (Null-Heap A))))
;;;;;;;;;;;---- These guys are not being used End----------


(: empty-Heap? : (All (A) ((Heap A) -> Boolean)))
(define (empty-Heap? heap)
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

(: NullHeap? : (All (A) ((Heap A) -> Boolean)))
(define (NullHeap? heap)
  (null? (Heap-trees heap)))

(: insTree : (All (A) ((Node A) (Heap A) -> (Heap A))))
(define (insTree node heap)
  (cond
    [(NullHeap? heap) (make-Heap (Heap-comparer heap) (list node))]
    [(< (rank node) (rank (car (Heap-trees heap)))) 
     (make-Heap (Heap-comparer heap) (cons node (Heap-trees heap)))]
    [else (insTree (link node (car (Heap-trees heap)) (Heap-comparer heap)) 
                   (make-Heap (Heap-comparer heap) (cdr (Heap-trees heap))))]))

(: insert : (All (A) (A (Heap A) -> (Heap A))))
(define (insert val heap)
  (insTree (make-Node 0 val null) heap))


;(: insert : (All (A) (A (BHeap A) -> (Heap A))))
;(define MyInsert; val heap)
;  (pcase-lambda: (A)
;   [([val : A] [heap : (Heap A)]) (insTree (make-Node 0 val null) heap)]
;   [([val : A] [heap : Null-Heap] [func : (A A -> Boolean)])
;    (make-Heap func (list (make-Node 1 val null)))]
;   [([val : A] [heap : Null-Heap]) 
;    (error "Heap is empty. Compare function not provided" 'insert)]))


(: merge : (All (A) ((Heap A) (Heap A) -> (Heap A))))
(define (merge heap1 heap2)
  (cond
    [(null? (Heap-trees heap2)) heap1]
    [(null? (Heap-trees heap1)) heap2]
    [(< (rank (car (Heap-trees heap1))) (rank (car (Heap-trees heap2)))) 
     (make-Heap (Heap-comparer heap1) 
                (list* (car (Heap-trees heap1)) 
                       (Heap-trees (merge (make-Heap (Heap-comparer heap1) (cdr (Heap-trees heap1)))
                                          heap2))))]
    [(> (rank (car (Heap-trees heap1))) (rank (car (Heap-trees heap2))))
     (make-Heap (Heap-comparer heap1) 
                (list* (car (Heap-trees heap2)) 
                       (Heap-trees (merge heap1 
                                          (make-Heap (Heap-comparer heap2) (cdr (Heap-trees heap2)))))))]
    [else (insTree (link (car (Heap-trees heap1)) (car (Heap-trees heap2)) (Heap-comparer heap1)) 
                   (merge (make-Heap (Heap-comparer heap1) (cdr (Heap-trees heap1))) 
                          (make-Heap (Heap-comparer heap2) (cdr (Heap-trees heap2)))))]))

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
                  (if (null? (cdr (Heap-trees intheap)))
                      (make-Heap (Heap-comparer intheap) 
                                 (cons (car (Heap-trees intheap)) null))
                      (let ([pair (getMin (make-Heap (Heap-comparer intheap) 
                                                     (cdr (Heap-trees intheap))))])
                        (if ((Heap-comparer pair) 
                             (root (car (Heap-trees intheap))) 
                             (root (car (Heap-trees pair))))
                            intheap
                            (make-Heap (Heap-comparer pair) 
                                       (cons (car (Heap-trees pair)) 
                                             (cons (car (Heap-trees intheap)) 
                                                   (cdr (Heap-trees pair)))))))))]
        [newpair : (Heap A) (getMin heap)])
               (merge (make-Heap (Heap-comparer newpair) 
                                 (reverse (Node-trees (car (Heap-trees newpair))))) 
                      (make-Heap (Heap-comparer newpair) 
                                 (cdr (Heap-trees newpair)))))))        
                      

(: binomialheap : (All (A) ((A A -> Boolean) (Listof A) -> (Heap A))))
(define (binomialheap func lst)
  (if (null? lst)
      (make-Heap func lst)
      (foldl (inst insert A) (make-Heap func (list (make-Node 1 (car lst) null))) (cdr lst))))


(define heap (make-Heap (lambda: ([a : Integer]
                                  [b : Integer]) (> a b)) null))