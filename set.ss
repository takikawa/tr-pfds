#lang typed/scheme #:optimize

(provide set (rename-out [set-map map]) difference union filter
         remove empty? member? insert set->list subset? intersection
         subset?)

(require scheme/match)

(define-struct: Mt ())
(define-struct: (A) Tree ([lset : (USet A)]
                          [elem : A]                         
                          [rset : (USet A)]))

(define-type-alias (USet A) (U Mt (Tree A)))

(define-struct: (A) Set ([comparer : (A A -> Boolean)]
                         [set : (USet A)]))

(define empty (make-Mt))

(: empty? : (All (A) ((Set A) -> Boolean)))
(define (empty? uset)
  (Mt? (Set-set uset)))
  

(: member? : (All (A) (A (Set A) -> Boolean)))
(define (member? key uset)
  (let ([func (Set-comparer uset)]
        [set (Set-set uset)])
    (match set
      [(struct Mt ()) #f]
      [(struct Tree (l e r)) (member-help l r e key func)])))


(: member-help : 
   (All (A) ((USet A) (USet A) A A (A A -> Boolean) -> Boolean)))
(define (member-help left rgt elem key f)
  (let ([fst (f key elem)]
        [snd (f elem key)])
    (cond
      [(and fst snd) #t]
      [(and (not fst) (not snd)) #t]
      [fst (member? key (make-Set f left))]
      [else (member? key (make-Set f rgt))])))


(: ins : (All (A) (A (USet A) (A A -> Boolean) -> (USet A))))
(define (ins elem set func)
  (match set
    [(struct Mt ()) (make-Tree empty elem empty)]
    [(struct Tree (a y b)) (let ([lt (func elem y)]
                                 [gt (func y elem)]) 
                             (cond 
                               [(or (and gt lt) (and (not gt) (not lt))) set]
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
  (if (Mt? set)
      accum
      (helper (Tree-lset set) 
              (cons (Tree-elem set) (helper (Tree-rset set) accum)))))

(: set->list : (All (A) ((Set A) -> (Listof A))))
(define (set->list set)
  (helper (Set-set set) null))


(: union-helper : (All (A) ((USet A) (USet A) (A A -> Boolean) -> (USet A))))
(define (union-helper set accum comp)
  (if (Mt? set)
      accum
      (union-helper (Tree-lset set) 
                    (ins (Tree-elem set) 
                         (union-helper (Tree-rset set) accum comp)
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
      (if (Mt? uset)
            accum
            (let ([elem (Tree-elem uset)]
                  [lset (Tree-lset uset)]
                  [rset (Tree-rset uset)])
              (if (member? elem set)
                  (helper set rset (helper set lset (ins elem accum comp)))
                  (helper set rset (helper set lset accum))))))
    (make-Set comp (helper set1 (Set-set set2) (make-Mt))))) 


(: difference : (All (A) ((Set A) (Set A) -> (Set A))))
(define (difference set1 set2)
  (let ([comp (Set-comparer set1)])
    (: helper : (All (A) ((Set A) (USet A) (USet A) -> (USet A))))
    (define (helper set uset accum)
      (if (Mt? uset)
            accum
            (let ([elem (Tree-elem uset)]
                  [lset (Tree-lset uset)]
                  [rset (Tree-rset uset)])
              (if (member? elem set)
                  (helper set rset (helper set lset accum))
                  (helper set rset (helper set lset (ins elem accum comp)))))))
    (make-Set comp (helper set2 (Set-set set1) (make-Mt)))))


(: subset? : (All (A) ((Set A) (Set A) -> Boolean)))
(define (subset? set1 set2)
  (let ([comp (Set-comparer set1)])
    (: helper : (All (A) ((Set A) (USet A) -> Boolean)))
    (define (helper set uset)
      (or (Mt? uset)
          (let ([elem (Tree-elem uset)]
                [lset (Tree-lset uset)]
                [rset (Tree-rset uset)])
            (and (member? elem set) (helper set rset) (helper set lset)))))
    (helper set1 (Set-set set2))))


;; 3 functions are redundent. But because of TR I wrote them
(: lset : (All (A) ((USet A) -> (USet A))))
(define (lset uset)
  (if (Mt? uset)
      (error "Internal error")
      (Tree-lset uset)))

(: rset : (All (A) ((USet A) -> (USet A))))
(define (rset uset)
  (if (Mt? uset)
      (error "Internal error")
      (Tree-rset uset)))

(: elem : (All (A) ((USet A) -> A)))
(define (elem uset)
  (if (Mt? uset)
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
        (make-Tree (apply in-map func (Tree-lset fst) (map lset rst))
                   (apply func (Tree-elem fst) (map elem rst))
                   (apply in-map func (Tree-rset fst) (map rset rst)))
        empty))
  (make-Set comp (apply in-map func (Set-set fst) (map Set-set rst))))



;; similar to list filter function
(: filter : (All (A) ((A -> Boolean) (Set A) -> (Set A))))
(define (filter pred set)
  (let ([comp (Set-comparer set)])
    (: helper : (All (A) ((USet A) (USet A) -> (USet A))))
    (define (helper uset accum)
      (if (Mt? uset)
          accum
          (let ([elem (Tree-elem uset)]
                [lset (Tree-lset uset)]
                [rset (Tree-rset uset)])
            (if (pred elem)
                (helper rset (helper lset (ins elem accum comp)))
                (helper rset (helper lset accum))))))
    (make-Set comp (helper (Set-set set) (make-Mt)))))

;;; similar to list remove function
(: remove : (All (A) ((A -> Boolean) (Set A) -> (Set A))))
(define (remove pred set)
  (let ([comp (Set-comparer set)])
    (: helper : (All (A) ((USet A) (USet A) -> (USet A))))
    (define (helper uset accum)
      (if (Mt? uset)
          accum
          (let ([elem (Tree-elem uset)]
                [lset (Tree-lset uset)]
                [rset (Tree-rset uset)])
            (if (pred elem)
                (helper rset (helper lset accum))
                (helper rset (helper lset (ins elem accum comp)))))))
    (make-Set comp (helper (Set-set set) (make-Mt)))))