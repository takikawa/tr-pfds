#lang typed-scheme

(provide filter remove fold (rename-out [heap-map map])
         empty? insert find-min/max delete-min/max
         merge sorted-list heap Heap)

(define-struct: (A) Node ([rank : Integer]
                          [val : A]
                          [trees : (Listof (Node A))]))

(define-struct: (A) Heap ([comparer : (A A -> Boolean)]
                          [trees : (Listof (Node A))]))


(: empty? : (All (A) ((Heap A) -> Boolean)))
(define (empty? heap)
  (null? (Heap-trees heap)))

(define empty null)

(: rank : (All (A) ((Node A) -> Integer)))
(define (rank node)
  (Node-rank node))

(: root : (All (A) ((Node A) -> A)))
(define (root node)
  (Node-val node))

(: link : (All (A) ((Node A) (Node A) (A A -> Boolean) -> (Node A))))
(define (link node1 node2 func)
  (let ([val1 (Node-val node1)]
        [val2 (Node-val node2)]
        [rank1 (add1 (Node-rank node1))])
    (if (func val1 val2)
        (make-Node rank1 val1 (cons node2 (Node-trees node1)))
        (make-Node rank1 val2 (cons node1 (Node-trees node2))))))

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
        [comp (Heap-comparer heap1)])
    (cond
      [(null? hp2-trees) heap1]
      [(null? hp1-trees) heap2]
      [else (merge-helper hp1-trees hp2-trees comp)])))

(: merge-helper : 
   (All (A) ((Listof (Node A)) (Listof (Node A)) (A A -> Boolean) -> (Heap A))))
(define (merge-helper heap1-trees heap2-trees comp)
  (let* ([fst-tre1 (car heap1-trees)]
         [rst-tre1 (cdr heap1-trees)]
         [fst-tre2 (car heap2-trees)]
         [rst-tre2 (cdr heap2-trees)]
         [heap1 (make-Heap comp rst-tre1)]
         [heap2 (make-Heap comp rst-tre2)]
         [rank1 (rank fst-tre1)]
         [rank2 (rank fst-tre2)])
    (cond
      [(< rank1 rank2) 
       (make-Heap 
        comp (list* fst-tre1 
                    (Heap-trees (merge heap1 (make-Heap comp heap2-trees)))))]
      [(> rank1 rank2)
       (make-Heap 
        comp (list* fst-tre2 
                    (Heap-trees (merge (make-Heap comp heap1-trees) heap2))))]
      [else 
       (insNode (link fst-tre1 fst-tre2 comp) 
                (Heap-trees (merge heap1 heap2)) comp)])))

(: find-min/max : (All (A) ((Heap A) -> A)))
(define (find-min/max heap)
  (let ([trees (Heap-trees heap)])
    (cond
      [(null? trees) (error 'find-min/max "given heap is empty")]
      [(null? (cdr trees)) (Node-val (car trees))]
      [else (let* ([comparer (Heap-comparer heap)]
                   [x (root (car trees))]
                   [y (find-min/max (make-Heap comparer (cdr trees)))])
              (if (comparer x y) x y))])))


(: delete-min/max : (All (A) ((Heap A) -> (Heap A))))
(define (delete-min/max heap)
  (: getMin : (All (A) ((Listof (Node A)) (A A -> Boolean) -> (Heap A))))
  (define (getMin inthp-trees func)
    (let* ([fst-trees (car inthp-trees)]
           [rst-trees (cdr inthp-trees)]
           [int-heap (make-Heap func inthp-trees)])
      (if (null? rst-trees)
          int-heap
          (let* ([pair (getMin rst-trees func)]
                 [fst-pair (car (Heap-trees pair))]
                 [rst-pair (cdr (Heap-trees pair))])
            (if (func (root fst-trees) (root fst-pair))
                int-heap
                (make-Heap func (cons fst-pair 
                                      (cons fst-trees rst-pair))))))))
  (if (null? (Heap-trees heap))
      (error 'delete-min/max "given heap is empty")
       (let* ([func (Heap-comparer heap)]
              [newpair (getMin (Heap-trees heap) func)]
              [newpair-trees (Heap-trees newpair)])
         (merge (make-Heap func (reverse (Node-trees (car newpair-trees))))
                (make-Heap func (cdr newpair-trees))))))

(: sorted-list : (All (A) ((Heap A) -> (Listof A))))
(define (sorted-list heap)
  (if (empty? heap)
      null
      (cons (find-min/max heap) (sorted-list (delete-min/max heap)))))

(: heap : (All (A) ((A A -> Boolean) A * -> (Heap A))))
(define (heap func . lst)
  (foldl (inst insert A) ((inst make-Heap A) func empty) lst))


(: heap-map : (All (A C B ...) ((C C -> Boolean) (A B ... B -> C) (Heap A) (Heap B) ... B -> (Heap C))))
(define (heap-map comp func fst . rst)
  (: in-map : (All (A C B ...) ((Heap C) (A B ... B -> C) (Heap A) (Heap B) ... B -> (Heap C))))
  (define (in-map accum func fst . rst)
    (if (or (empty? fst) (ormap empty? rst))
        accum
        (apply in-map
               (insert (apply func (find-min/max fst) (map find-min/max rst)) accum)
               func
               (delete-min/max fst) 
               (map delete-min/max rst))))
  (apply in-map ((inst make-Heap C) comp empty) func fst rst))


(: fold : (All (A C B ...)
               ((C A B ... B -> C) C (Heap A) (Heap B) ... B -> C)))
(define (fold func base hep . heps)
  (if (or (empty? hep) (ormap empty? heps))
      base
      (apply fold 
             func 
             (apply func base (find-min/max hep) (map find-min/max heps))
             (delete-min/max hep)
             (map delete-min/max heps))))


(: filter : (All (A) ((A -> Boolean) (Heap A) -> (Heap A))))
(define (filter func hep)
  (: inner : (All (A) ((A -> Boolean) (Heap A) (Heap A) -> (Heap A))))
  (define (inner func hep accum)
    (if (empty? hep)
        accum
        (let ([head (find-min/max hep)]
              [tail (delete-min/max hep)])
          (if (func head)
              (inner func tail (insert head accum))
              (inner func tail accum)))))
  (inner func hep ((inst make-Heap A) (Heap-comparer hep) empty)))


(: remove : (All (A) ((A -> Boolean) (Heap A) -> (Heap A))))
(define (remove func hep)
  (: inner : (All (A) ((A -> Boolean) (Heap A) (Heap A) -> (Heap A))))
  (define (inner func hep accum)
    (if (empty? hep)
        accum
        (let ([head (find-min/max hep)]
              [tail (delete-min/max hep)])
          (if (func head)
              (inner func tail accum)
              (inner func tail (insert head accum))))))
  (inner func hep ((inst make-Heap A) (Heap-comparer hep) empty)))
