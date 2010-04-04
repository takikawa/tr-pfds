#lang typed-scheme

(provide empty empty? insert merge find-min/max 
         delete-min/max sorted-list splayheap)

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
      (match rheap 
        [(struct Mt ()) (cons tree empty)]
        [(struct Tree (l e r))
         (if (func e pivot)
             (let ([pair (partition pivot r func)])
               (cons (make-Tree (make-Tree left elem l) e (car pair))
                     (cdr pair)))
             (let ([pair (partition pivot l func)])
               (cons (make-Tree left elem (car pair))
                     (make-Tree (cdr pair) e r))))]))
    (: phelp-lft : (Heap A) -> (Pair (Heap A) (Heap A)))
    (define (phelp-lft lheap)
      (match lheap
        [(struct Mt ()) (cons empty tree)]
        [(struct Tree (l e r))
         (if (func e pivot)
             (let ([pair (partition pivot r func)])
               (cons (make-Tree l e (car pair))
                     (make-Tree (cdr pair) elem right)))
             (let ([pair (partition pivot l func)])
               (cons (car pair)
                     (make-Tree (cdr pair) e 
                                (make-Tree r elem right)))))]))
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
      [(cons _ (struct Mt ())) heap1]
      [(cons (struct Tree (a elem b)) _) 
       (let ([in-pair (partition elem heap2 func)])
         (make-Tree (merge-help (car in-pair) a func) 
                    elem
                    (merge-help (cdr in-pair) b func)))])))

(: find-min/max : (All (A) ((SplayHeap A) -> A)))
(define (find-min/max sheap)
  (let ([heap (SplayHeap-heap sheap)]
        [func (SplayHeap-comparer sheap)])
    (match heap
      [(struct Mt ()) (error "Heap is empty :" 'find-min)]
      [(struct Tree ((struct Mt ()) elem b)) elem]
      [(struct Tree (a elem b)) (find-min/max (make-SplayHeap func a))])))

(: delete-min/max : (All (A) ((SplayHeap A) -> (SplayHeap A))))
(define (delete-min/max sheap)
  (let ([heap (SplayHeap-heap sheap)]
        [func (SplayHeap-comparer sheap)])
    (match heap
      [(struct Mt ()) (error "Heap is empty :" 'delete-min)]
      [(struct Tree ((struct Mt ()) elem b)) (make-SplayHeap func b)]
      [(struct Tree ((struct Tree ((struct Mt ()) el a)) elem b))
       (make-SplayHeap func (make-Tree a elem b))]
      [(struct Tree ((struct Tree (a el b)) elem c)) 
       (make-SplayHeap func 
                       (make-Tree 
                        (SplayHeap-heap (delete-min/max (make-SplayHeap func a)))
                        el 
                        (make-Tree b elem c)))])))

(: sorted-list : (All (A) ((SplayHeap A) -> (Listof A))))
(define (sorted-list sheap)
  (if (Mt? (SplayHeap-heap sheap))
      null
      (cons (find-min/max sheap) (sorted-list (delete-min/max sheap)))))

(: splayheap : (All (A) ((A A -> Boolean) A * -> (SplayHeap A))))
(define (splayheap func . rst)
  (let ([sheap ((inst make-SplayHeap A) func (make-Mt))])
    (foldl (inst insert A) sheap rst)))