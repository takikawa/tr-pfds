#lang typed/racket #:optimize

(provide clist empty? head tail reverse
         CatenableList append empty filter remove
         (rename-out [clist->list ->list] [clist list] [kons cons]
                     [head first] [tail rest] [kons-rear cons-to-end] 
                     [list-map map] [list-foldl foldl] [list-foldr foldr] 
                     [list-ormap ormap] [list-andmap andmap]) 
         build-list make-list)

(require (prefix-in bsq: "bootstrapedqueue.rkt"))

(struct: (A) List ([elem : A]
                   [ques : (bsq:Queue (Promise (List A)))]))

(define-type (CatenableList A) (U (List A) Null))

;; An empty list
(define empty null)

;; Checks for empty list
(: empty? : (All (A) ((CatenableList A) -> Boolean)))
(define (empty? cat)
  (null? cat))


(: link : (All (A) ((List A) (Promise (List A)) -> (List A))))
(define (link lst cat)
  (List (List-elem lst) (bsq:enqueue cat (List-ques lst))))

(: link-all : (All (A) ((bsq:Queue (Promise (List A))) -> (List A))))
(define (link-all rtq)
  (let ([hd (force (bsq:head rtq))]
        [tl (bsq:tail rtq)])
    (if (bsq:empty? tl)
        hd
        (link hd (delay (link-all tl))))))

;; Append helper 
(: append-inner :
   (All (A) ((CatenableList A) (CatenableList A) -> (CatenableList A))))
(define (append-inner cat1 cat2)
  (cond
    [(null? cat1) cat2]
    [(null? cat2) cat1]
    [else (link cat1 (delay cat2))]))

;; List append
(: append : (All (A) ((CatenableList A) * -> (CatenableList A))))
(define (append . cats)
  (if (null? cats)
      empty
      (append-inner (car cats) (apply append (cdr cats)))))

;; Similar to list cons function
(: kons : (All (A) (A (CatenableList A) -> (CatenableList A))))
(define (kons elem cat)
  (append (List elem bsq:empty) cat))

;; Inserts an element at the rear end of the list
(: kons-rear : (All (A) (A (CatenableList A) -> (CatenableList A))))
(define (kons-rear elem cat)
  (append cat (List elem bsq:empty)))

;; Similar to list car function
(: head : (All (A) ((CatenableList A) -> A)))
(define (head cat)
  (if (null? cat)
      (error 'first "given list is empty")
      (List-elem cat)))

;; Similar to list cdr function
(: tail : (All (A) ((CatenableList A) -> (CatenableList A))))
(define (tail cat)
  (if (null? cat)
      (error 'rest "given list is empty")
      (tail-helper cat)))

(: tail-helper : (All (A) ((List A) -> (CatenableList A))))
(define (tail-helper cat)
  (let ([ques (List-ques cat)])
    (if (bsq:empty? ques)
        empty
        (link-all ques))))

;; similar to list map function. apply is expensive so using case-lambda
;; in order to saperate the more common case
(: list-map :
   (All (A C B ...)
        (case-lambda
          ((A -> C) (CatenableList A) -> (CatenableList C))
          ((A B ... B -> C)
           (CatenableList A) (CatenableList B) ... B -> (CatenableList C)))))
(define list-map
  (pcase-lambda: (A C B ...)
                 [([func : (A -> C)]
                   [list  : (CatenableList A)])
                  (map-single empty func list)]
                 [([func : (A B ... B -> C)]
                   [list  : (CatenableList A)]
                   .
                   [lists : (CatenableList B) ... B])
                  (apply map-multiple empty func list lists)]))


(: map-single :
   (All (A C)
        ((CatenableList C) (A -> C) (CatenableList A) -> (CatenableList C))))
(define (map-single accum func list)
  (if (empty? list)
      accum
      (map-single (kons (func (head list)) accum) func (tail list))))

(: map-multiple :
   (All (A C B ...)
        ((CatenableList C) (A B ... B -> C)
                           (CatenableList A) (CatenableList B) ... B -> (CatenableList C))))
(define (map-multiple accum func list . lists)
  (if (or (empty? list) (ormap empty? lists))
      accum
      (apply map-multiple
             (kons (apply func (head list) (map head lists)) accum)
             func
             (tail list)
             (map tail lists))))



;; Similar to list foldr function. apply is expensive so using case-lambda
;; in order to saperate the more common case
(: list-foldr : 
   (All (A C B ...) 
        (case-lambda ((C A -> C) C (CatenableList A) -> C)
                     ((C A B ... B -> C)
                      C
                      (CatenableList A) (CatenableList B) ... B -> C))))
(define list-foldr
  (pcase-lambda: (A C B ...)
                 [([func : (C A -> C)]
                   [base : C]
                   [list : (CatenableList A)])
                  (if (empty? list)
                      base
                      (func (list-foldr func base (tail list)) (head list)))]
                 [([func : (C A B ... B -> C)]
                   [base : C]
                   [list  : (CatenableList A)]
                   .
                   [lists : (CatenableList B) ... B])
                  (if (or (empty? list) (ormap empty? lists))
                      base
                      (apply func (apply list-foldr func base
                                         (tail list) (map tail lists))
                             (head list)
                             (map head lists)))]))

;; similar to list foldl function
(: list-foldl :
   (All (A C B ...) 
        (case-lambda ((C A -> C) C (CatenableList A) -> C)
                     ((C A B ... B -> C) C
                                         (CatenableList A) (CatenableList B) ... B -> C))))
(define list-foldl
  (pcase-lambda: (A C B ...) 
                 [([func : (C A -> C)]
                   [base : C]
                   [list : (CatenableList A)])
                  (if (empty? list)
                      base
                      (list-foldl func (func base (head list)) (tail list)))]
                 [([func : (C A B ... B -> C)]
                   [base : C]
                   [list  : (CatenableList A)]
                   .
                   [lists : (CatenableList B) ... B])
                  (if (or (empty? list) (ormap empty? lists))
                      base
                      (apply list-foldl func
                             (apply func base (head list) (map head lists))
                             (tail list)
                             (map tail lists)))]))

;; Similar to list filter function
(: filter : (All (A) ((A -> Boolean) (CatenableList A) -> (CatenableList A))))
(define (filter func list)
  (: inner :
     (All (A) ((A -> Boolean)
               (CatenableList A) (CatenableList A) -> (CatenableList A))))
  (define (inner func list accum)
    (if (empty? list)
        accum
        (let ([head (head list)]
              [tail (tail list)])
          (if (func head)
              (inner func tail (kons head accum))
              (inner func tail accum)))))
  (inner func list empty))

;; Similar to list remove function
(: remove : (All (A) ((A -> Boolean) (CatenableList A) -> (CatenableList A))))
(define (remove func list)
  (: inner :
     (All (A) ((A -> Boolean) (CatenableList A)
                              (CatenableList A) -> (CatenableList A))))
  (define (inner func list accum)
    (if (empty? list)
        accum
        (let ([head (head list)]
              [tail (tail list)])
          (if (func head)
              (inner func tail accum)
              (inner func tail (kons head accum))))))
  (inner func list empty))

;; list constructor
(: clist : (All (A) (A * -> (CatenableList A))))
(define (clist . list)
  (foldr (inst kons A) empty list))


(: clist->list : (All (A) ((CatenableList A) -> (Listof A))))
(define (clist->list cat)
  (if (null? cat)
      null
      (cons (head cat) (clist->list (tail cat)))))

;; Similar to list reverse function
(: reverse : (All (A) ((CatenableList A) -> (CatenableList A))))
(define (reverse list)
  (: local-reverse : (All (A) ((CatenableList A) (CatenableList A)
                                                 ->
                                                 (CatenableList A))))
  (define (local-reverse list accum)
    (if (empty? list)
        accum
        (local-reverse (tail list) (kons (head list) accum))))
  (local-reverse list empty))



;; Similar to build-list function of racket list
(: build-list : (All (A) (Natural (Natural -> A) -> (CatenableList A))))
(define (build-list size func)
  (let: loop : (CatenableList A) ([n : Natural size]
                                  [accum : (CatenableList A) empty])
        (if (zero? n)
            accum
            (loop (sub1 n) (kons (func (sub1 n)) accum)))))

;; Similar to make-list function of racket list
(: make-list : (All (A) (Natural A -> (CatenableList A))))
(define (make-list size elem)
  (let: loop : (CatenableList A) ([n : Natural size] [accum : (CatenableList A) empty])
        (if (zero? n)
            accum
            (loop (sub1 n) (kons elem accum)))))


;; similar to list andmap function
(: list-andmap :
   (All (A B ...)
        (case-lambda ((A -> Boolean) (CatenableList A) -> Boolean)
                     ((A B ... B -> Boolean) (CatenableList A) 
                                             (CatenableList B) ... B 
                                             -> Boolean))))
(define list-andmap
  (pcase-lambda: (A B ... ) 
                 [([func : (A -> Boolean)]
                   [list  : (CatenableList A)])
                  (or (empty? list)
                      (and (func (head list))
                           (list-andmap func (tail list))))]
                 [([func : (A B ... B -> Boolean)]
                   [list  : (CatenableList A)]
                   .
                   [lists : (CatenableList B) ... B])
                  (or (empty? list) (ormap empty? lists)
                      (and (apply func (head list) (map head lists))
                           (apply list-andmap func (tail list)
                                  (map tail lists))))]))


;; similar to list ormap function
(: list-ormap : 
   (All (A B ...) 
        (case-lambda ((A -> Boolean) (CatenableList A) -> Boolean)
                     ((A B ... B -> Boolean) (CatenableList A)
                                             (CatenableList B) ... B
                                             -> Boolean))))
(define list-ormap
  (pcase-lambda: (A B ... )
                 [([func : (A -> Boolean)]
                   [list  : (CatenableList A)])
                  (and (not (empty? list))
                       (or (func (head list))
                           (list-ormap func (tail list))))]
                 [([func : (A B ... B -> Boolean)]
                   [list  : (CatenableList A)]
                   .
                   [lists : (CatenableList B) ... B])
                  (and (not (or (empty? list) (ormap empty? lists)))
                       (or (apply func (head list) (map head lists))
                           (apply list-ormap func (tail list)
                                  (map tail lists))))]))
