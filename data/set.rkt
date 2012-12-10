#lang typed/racket #:optimize

(provide set (rename-out [set-map map]) difference union filter
         remove empty? member? insert set->list subset? intersection
         subset? Set)

(require scheme/match
         racket/bool)

;(define-struct: Mt ())
(define-struct: (A) Tree ([left : (USet A)]
                          [elem : A]                         
                          [right : (USet A)]))

(define-type (USet A) (U Null (Tree A)))

(define-struct: (A) Set ([comparer : (A A -> Boolean)]
                         [set : (USet A)]))

(define empty null)

(: empty? : (All (A) ((Set A) -> Boolean)))
(define (empty? uset)
  (null? (Set-set uset)))

(: member? : (All (A) (A (Set A) -> Boolean)))
(define (member? key uset)
  (let ([func (Set-comparer uset)]
        [set (Set-set uset)])
    (match set
      ['() #f]
      [(struct Tree (l e r)) (member-help l r e key func)])))


(: member-help : 
   (All (A) ((USet A) (USet A) A A (A A -> Boolean) -> Boolean)))
(define (member-help left rgt elem key f)
  (let ([fst (f key elem)]
        [snd (f elem key)])
    (cond
      [(xor fst snd) #t]
      [fst (member? key (make-Set f left))]
      [else (member? key (make-Set f rgt))])))


(: ins : (All (A) (A (USet A) (A A -> Boolean) -> (USet A))))
(define (ins elem set func)
  (match set
    ['() (make-Tree empty elem empty)]
    [(struct Tree (a y b)) 
     (let ([lt (func elem y)]
           [gt (func y elem)]) 
       (cond 
         [(xor gt lt) set]
         [lt (make-Tree (ins elem a func) y b)]
         [else (make-Tree a y (ins elem b func))]))]))

(: insert : (All (A) (A (Set A) -> (Set A))))
(define (insert elem uset)
  (let ([func (Set-comparer uset)]
        [set (Set-set uset)])
    (make-Set func (ins elem set func))))

(: set : (All (A) ((A A -> Boolean) A * -> (Set A))))
(define (set func . lst)
  (foldl (inst insert A) ((inst make-Set A) func empty) lst))

(: helper : (All (A) ((USet A) (Listof A) -> (Listof A))))
(define (helper set accum)
  (if (null? set)
      accum
      (helper (Tree-left set) 
              (cons (Tree-elem set) (helper (Tree-right set) accum)))))

(: set->list : (All (A) ((Set A) -> (Listof A))))
(define (set->list set)
  (helper (Set-set set) null))


(: union-helper : (All (A) ((USet A) (USet A) (A A -> Boolean) -> (USet A))))
(define (union-helper set accum comp)
  (if (null? set)
      accum
      (union-helper (Tree-left set) 
                    (ins (Tree-elem set) 
                         (union-helper (Tree-right set) accum comp)
                         comp)
                    comp)))

(: union : (All (A) ((Set A) (Set A) -> (Set A))))
(define (union set1 set2)
  (let ([comp (Set-comparer set1)])
    (make-Set comp 
              (union-helper (Set-set set2) (Set-set set1) comp))))


(: intersection : (All (A) ((Set A) (Set A) -> (Set A))))
(define (intersection set1 set2)
  (let ([comp (Set-comparer set1)])
    (: helper : (All (A) ((Set A) (USet A) (USet A) -> (USet A))))
    (define (helper set uset accum)
      (if (null? uset)
          accum
          (let ([elem (Tree-elem uset)]
                [left (Tree-left uset)]
                [right (Tree-right uset)])
            (if (member? elem set)
                (helper set right (helper set left (ins elem accum comp)))
                (helper set right (helper set left accum))))))
    (make-Set comp (helper set1 (Set-set set2) null)))) 


(: difference : (All (A) ((Set A) (Set A) -> (Set A))))
(define (difference set1 set2)
  (let ([comp (Set-comparer set1)])
    (: helper : (All (A) ((Set A) (USet A) (USet A) -> (USet A))))
    (define (helper set uset accum)
      (if (null? uset)
          accum
          (let ([elem (Tree-elem uset)]
                [left (Tree-left uset)]
                [right (Tree-right uset)])
            (if (member? elem set)
                (helper set right (helper set left accum))
                (helper set right (helper set left (ins elem accum comp)))))))
    (make-Set comp (helper set2 (Set-set set1) null))))


(: subset? : (All (A) ((Set A) (Set A) -> Boolean)))
(define (subset? set1 set2)
  (let ([comp (Set-comparer set1)])
    (: helper : (All (A) ((Set A) (USet A) -> Boolean)))
    (define (helper set uset)
      (or (null? uset)
          (let ([elem (Tree-elem uset)]
                [left (Tree-left uset)]
                [right (Tree-right uset)])
            (and (member? elem set) (helper set right) (helper set left)))))
    (helper set1 (Set-set set2))))


;; 3 functions are redundent. But because of TR I wrote them
(: left : (All (A) ((USet A) -> (USet A))))
(define (left uset)
  (if (null? uset)
      (error "Internal error")
      (Tree-left uset)))

(: right : (All (A) ((USet A) -> (USet A))))
(define (right uset)
  (if (null? uset)
      (error "Internal error")
      (Tree-right uset)))

(: elem : (All (A) ((USet A) -> A)))
(define (elem uset)
  (if (null? uset)
      (error "Internal error")
      (Tree-elem uset)))


;; similar to list map function
;; There is some problem with andmap because of which I had to write 
;; the above 3 functions.
(: set-map : 
   (All (A C B ...) ((C C -> Boolean) 
                     (A B ... B -> C) 
                     (Set A)
                     (Set B) ... B -> (Set C))))
(define (set-map comp func fst . rst)
  (: in-map : 
     (All (A C B ...) ((A B ... B -> C) (USet A) (USet B) ... B -> (USet C))))
  (define (in-map func fst . rst)
    (if (and (Tree? fst) (andmap Tree? rst))
        (make-Tree (apply in-map func (Tree-left fst) (map left rst))
                   (apply func (Tree-elem fst) (map elem rst))
                   (apply in-map func (Tree-right fst) (map right rst)))
        empty))
  (make-Set comp (apply in-map func (Set-set fst) (map Set-set rst))))



;; similar to list filter function
(: filter : (All (A) ((A -> Boolean) (Set A) -> (Set A))))
(define (filter pred set)
  (let ([comp (Set-comparer set)])
    (: helper : (All (A) ((USet A) (USet A) -> (USet A))))
    (define (helper uset accum)
      (if (null? uset)
          accum
          (let ([elem (Tree-elem uset)]
                [left (Tree-left uset)]
                [right (Tree-right uset)])
            (if (pred elem)
                (helper right (helper left (ins elem accum comp)))
                (helper right (helper left accum))))))
    (make-Set comp (helper (Set-set set) null))))

;;; similar to list remove function
(: remove : (All (A) ((A -> Boolean) (Set A) -> (Set A))))
(define (remove pred set)
  (let ([comp (Set-comparer set)])
    (: helper : (All (A) ((USet A) (USet A) -> (USet A))))
    (define (helper uset accum)
      (if (null? uset)
          accum
          (let ([elem (Tree-elem uset)]
                [left (Tree-left uset)]
                [right (Tree-right uset)])
            (if (pred elem)
                (helper right (helper left accum))
                (helper right (helper left (ins elem accum comp)))))))
    (make-Set comp (helper (Set-set set) null))))
