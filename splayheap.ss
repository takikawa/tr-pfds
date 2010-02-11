#lang typed-scheme

(require scheme/match)

(define-struct: Mt ())

(define-struct: (A) Tree ([left : (Heap A)]
                          [elem : A]
                          [right : (Heap A)]))

(define-type-alias (Heap A) (U Mt (Tree A)))

(define-struct: (A) SplayHeap ([comparer : (A A -> Boolean)]
                               [heap : (Heap A)]))

(define empty (make-Mt))

(: partition : 
   (All (A) (A (Heap A) (A A -> Boolean) -> (Pair (Heap A) (Heap A)))))
(define (partition pivot heap func)
  (if (Mt? heap)
      (cons empty empty)
      (partition-helper pivot heap func)))

(: partition-helper : 
   (All (A) (A (Tree A) (A A -> Boolean) -> (Pair (Heap A) (Heap A)))))
(define (partition-helper pivot tree func)
  (let ([elem (Tree-elem tree)]
        [left (Tree-left tree)]
        [right (Tree-right tree)])
    (: phelp-rgt : (Heap A) -> (Pair (Heap A) (Heap A)))
    (define (phelp-rgt rheap)
      (if (Mt? rheap)
          (cons tree empty)
          (let ([rheap-elem (Tree-elem rheap)]
                [rheap-left (Tree-left rheap)]
                [rheap-rgt (Tree-right rheap)])
            (if (func rheap-elem pivot)
                (let ([pair (partition pivot rheap-rgt func)])
                  (cons (make-Tree (make-Tree left elem rheap-left) 
                                   rheap-elem 
                                   (car pair))
                        (cdr pair)))
                (let ([pair (partition pivot rheap-left func)])
                  (cons (make-Tree left elem (car pair))
                        (make-Tree (cdr pair) rheap-elem rheap-rgt)))))))
    (: phelp-lft : (Heap A) -> (Pair (Heap A) (Heap A)))
    (define (phelp-lft lheap)
      (if (Mt? lheap)
          (cons empty tree)
          (let ([lheap-elem (Tree-elem lheap)]
                [lheap-left (Tree-left lheap)]
                [lheap-rgt (Tree-right lheap)])
            (if (func lheap-elem pivot)
                (let ([pair (partition pivot lheap-rgt func)])
                  (cons (make-Tree lheap-left lheap-elem (car pair))
                        (make-Tree (cdr pair) elem right)))
                (let ([pair (partition pivot lheap-left func)])
                  (cons (car pair)
                        (make-Tree (cdr pair) lheap-elem right)))))))
    (if (func elem pivot)
        (phelp-rgt right)
        (phelp-lft left))))

(: empty? : (All (A) ((Heap A) -> Boolean)))
(define (empty? heap)
  (Mt? heap))

(: insert : (All (A) (A (SplayHeap A) -> (SplayHeap A))))
(define (insert elem sheap)
  (let* ([comparer (SplayHeap-comparer sheap)]
         [pair (partition elem (SplayHeap-heap sheap) comparer)])
    (make-SplayHeap comparer (make-Tree (car pair) elem (cdr pair)))))

(: merge : (All (A) ((SplayHeap A) (SplayHeap A) -> (SplayHeap A))))
(define (merge sheap1 sheap2)
  (let ([heap1 (SplayHeap-heap sheap1)]
        [heap2 (SplayHeap-heap sheap2)]
        [func (SplayHeap-comparer sheap1)])
    (make-SplayHeap func (merge-help heap1 heap2 func))))

(: merge-help : (All (A) ((Heap A) (Heap A) (A A -> Boolean) -> (Heap A))))
(define (merge-help heap1 heap2 func)
  (let ([pair (cons heap1 heap2)])
    (match pair
      [(cons (struct Mt ()) _) heap2]
      [(cons (struct Tree (a elem b)) _) 
       (let ([in-pair (partition elem heap2 func)])
         (make-Tree (merge-help (car pair) a func) 
                    elem
                    (merge-help (cdr pair) b func)))])))

(: find-min : (All (A) ((SplayHeap A) -> A)))
(define (find-min sheap)
  (let ([heap (SplayHeap-heap sheap)]
        [func (SplayHeap-comparer sheap)])
    (match heap
      [(struct Mt ()) (error "Heap is empty :" 'find-min)]
      [(struct Tree ((struct Mt ()) elem b)) elem]
      [(struct Tree (a elem b)) (find-min (make-SplayHeap func a))])))

(: delete-min : (All (A) ((SplayHeap A) -> (SplayHeap A))))
(define (delete-min sheap)
  (let ([heap (SplayHeap-heap sheap)]
        [func (SplayHeap-comparer sheap)])
    (match heap
      [(struct Mt ()) (error "Heap is empty :" 'find-min)]
      [(struct Tree ((struct Mt ()) elem b)) (make-SplayHeap func b)]
      [(struct Tree ((struct Tree ((struct Mt ()) el a)) elem b))
       (make-SplayHeap func (make-Tree a elem b))]
      [(struct Tree ((struct Tree (a el b)) elem c)) 
       (make-SplayHeap func 
                       (make-Tree 
                        (SplayHeap-heap (delete-min (make-SplayHeap func a)))
                        el 
                        (make-Tree b elem c)))])))

(: sorted-list : (All (A) ((SplayHeap A) -> (Listof A))))
(define (sorted-list sheap)
  (if (Mt? (SplayHeap-heap sheap))
      null
      (cons (find-min sheap) (sorted-list (delete-min sheap)))))

(: splayheap : (All (A) ((A A -> Boolean) A A * -> (SplayHeap A))))
(define (splayheap func fst . rst)
  (let ([sheap (make-SplayHeap func (make-Tree empty fst empty))])
    (if (null? rst)
        sheap
        (foldl (inst insert A) sheap rst))))