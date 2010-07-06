#lang typed-scheme

(provide (rename-out [heap-map map]) fold  filter remove
         empty empty? insert merge find-min/max 
         delete-min/max sorted-list heap Heap)

(require scheme/match)

(define-struct: Mt ())

(define-struct: (A) Tree ([left : (IntHeap A)]
                          [elem : A]
                          [right : (IntHeap A)]))

(define-type-alias (IntHeap A) (U Mt (Tree A)))

(define-struct: (A) Heap ([comparer : (A A -> Boolean)]
                          [heap : (IntHeap A)]))

;(define-type-alias (Heap A) (Heap A))

(define empty (make-Mt))

(: partition : 
   (All (A) (A (IntHeap A) (A A -> Boolean) -> (Pair (IntHeap A) (IntHeap A)))))
(define (partition pivot heap func)
  (if (Mt? heap)
      (cons empty empty)
      (partition-helper pivot heap func)))

(: partition-helper : 
   (All (A) (A (Tree A) (A A -> Boolean) -> (Pair (IntHeap A) (IntHeap A)))))
(define (partition-helper pivot tree func)
  (let ([elem (Tree-elem tree)]
        [left (Tree-left tree)]
        [right (Tree-right tree)])
    (: phelp-rgt : (IntHeap A) -> (Pair (IntHeap A) (IntHeap A)))
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
    (: phelp-lft : (IntHeap A) -> (Pair (IntHeap A) (IntHeap A)))
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
  (Mt? (Heap-heap heap)))

(: insert : (All (A) (A (Heap A) -> (Heap A))))
(define (insert elem sheap)
  (let* ([comparer (Heap-comparer sheap)]
         [pair (partition elem (Heap-heap sheap) comparer)])
    (make-Heap comparer (make-Tree (car pair) elem (cdr pair)))))

(: merge : (All (A) ((Heap A) (Heap A) -> (Heap A))))
(define (merge sheap1 sheap2)
  (let ([heap1 (Heap-heap sheap1)]
        [heap2 (Heap-heap sheap2)]
        [func (Heap-comparer sheap1)])
    (make-Heap func (merge-help heap1 heap2 func))))

(: merge-help : (All (A) ((IntHeap A) (IntHeap A) (A A -> Boolean) -> (IntHeap A))))
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

(: find-min/max : (All (A) ((Heap A) -> A)))
(define (find-min/max sheap)
  (let ([heap (Heap-heap sheap)]
        [func (Heap-comparer sheap)])
    (match heap
      [(struct Mt ()) (error 'find-min/max "given heap is empty")]
      [(struct Tree ((struct Mt ()) elem b)) elem]
      [(struct Tree (a elem b)) (find-min/max (make-Heap func a))])))

(: delete-min/max : (All (A) ((Heap A) -> (Heap A))))
(define (delete-min/max sheap)
  (let ([heap (Heap-heap sheap)]
        [func (Heap-comparer sheap)])
    (match heap
      [(struct Mt ()) (error 'delete-min/max "given heap is empty")]
      [(struct Tree ((struct Mt ()) elem b)) (make-Heap func b)]
      [(struct Tree ((struct Tree ((struct Mt ()) el a)) elem b))
       (make-Heap func (make-Tree a elem b))]
      [(struct Tree ((struct Tree (a el b)) elem c)) 
       (make-Heap func 
                       (make-Tree 
                        (Heap-heap (delete-min/max (make-Heap func a)))
                        el 
                        (make-Tree b elem c)))])))

(: sorted-list : (All (A) ((Heap A) -> (Listof A))))
(define (sorted-list sheap)
  (if (Mt? (Heap-heap sheap))
      null
      (cons (find-min/max sheap) (sorted-list (delete-min/max sheap)))))

(: heap : (All (A) ((A A -> Boolean) A * -> (Heap A))))
(define (heap func . rst)
  (let ([sheap ((inst make-Heap A) func (make-Mt))])
    (foldl (inst insert A) sheap rst)))


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
