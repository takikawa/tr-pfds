#lang typed-scheme

(require scheme/match)

(define-struct: Mt ())
(define-struct: (A) Tree ([lset : (Set A)]
                          [elem : A]                         
                          [rset : (Set A)]))

(define-type-alias (Set A) (U Mt (Tree A)))

(define-struct: (A) USet ([comparer : (A A -> Boolean)]
                          [set : (Set A)]))

(define empty (make-Mt))

(: empty? : (All (A) ((USet A) -> Boolean)))
(define (empty? uset)
  (Mt? (USet-set uset)))
  

(: member? : (All (A) (A (USet A) -> Boolean)))
(define (member? key uset)
  (let ([func (USet-comparer uset)]
        [set (USet-set uset)])
    (match set
      [(struct Mt ()) #f]
      [(struct Tree (l e r)) (member-help l r e key func)])))


(: member-help : 
   (All (A) ((Set A) (Set A) A A (A A -> Boolean) -> Boolean)))
(define (member-help left rgt elem key f)
  (let ([fst (f key elem)]
        [snd (f elem key)])
    (cond
      [(and fst snd) #t]
      [(and (not fst) (not snd)) #t]
      [fst (member? key (make-USet f left))]
      [else (member? key (make-USet f rgt))])))

;
;(define (merge-help heap1 heap2 func)
;  (match (cons heap1 heap2)
;    [(cons (struct Mt ()) b) b]
;    [(cons a (struct Mt ())) a]
;    [(cons (struct Tree (x _ _)) (struct Tree (y _ _)))
;     (if (func x y) (link heap1 heap2 func) (link heap2 heap1 func))]))

(: ins : (All (A) (A (Set A) (A A -> Boolean) -> (Set A))))
(define (ins elem set func)
  (match set
    [(struct Mt ()) (make-Tree empty elem empty)]
    [(struct Tree (a y b)) (let ([lt (func elem y)]
                                 [gt (func y elem)]) 
                             (cond 
                               [(and gt lt) set]
                               [lt (make-Tree (ins elem a func) y b)]
                               [else (make-Tree a y (ins elem b func))]))]))

(: insert : (All (A) (A (USet A) -> (USet A))))
(define (insert elem uset)
  (let ([func (USet-comparer uset)]
        [set (USet-set uset)])
    (make-USet func (ins elem set func))))

(: unbalanced-set : (All (A) ((A A -> Boolean) A A * -> (USet A))))
(define (unbalanced-set func fst . rst)
  (let ([first (make-USet func (make-Tree empty fst empty))])
    (if (null? rst)
        first
        (foldl (inst insert A) first rst))))