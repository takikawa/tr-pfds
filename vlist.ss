#lang typed/scheme #:optimize

(provide vlist->list empty empty? first rest last list-ref)
(provide (rename-out
          [vlist list]
          [vcons cons]
          [list-length length]
          [vreverse reverse]
          [list-map map]
          [list-foldr foldr]
          [list-foldl foldl]
          [vfilter filter]))

(require (prefix-in ra: "skewbinaryrandomaccesslist.ss"))
(define-struct: (A) Base ([prevbase : (Block A)]
                          [elems : (ra:List A)]))

(define-type-alias Block (All (A) (U Null (Base A))))

(define-struct: (A) List ([offset : Integer]
                          [base : (Base A)]
                          [size : Integer]))

;; An empty list
(define empty (make-List 0 (make-Base null ra:empty) 0))

;; Checks for empty
(: empty? : (All (A) ((List A) -> Boolean)))
(define (empty? vlist)
  (zero? (List-size vlist)))

;; Similar to list cons function
(: vcons : (All (A) (A (List A) -> (List A))))
(define (vcons elem vlst)
  (let ([offset (List-offset vlst)]
        [size (List-size vlst)]
        [base (List-base vlst)])
    (cond 
      [(zero? size) (make-List 1 (make-Base null 
                                            (ra:cons elem ra:empty)) 1)]
      [(= offset size)
       (make-List 1 (make-Base base (ra:cons elem ra:empty)) (* size 2))]
      [else (make-List (add1 offset) 
                       (make-Base (Base-prevbase base) 
                                  (ra:cons elem (Base-elems base))) 
                       size)])))

;; Similar to list car function
(: first : (All (A) ((List A) -> A)))
(define (first vlst)
  (if (zero? (List-size vlst))
    (error 'first "given vlist is empty")
    (ra:first (Base-elems (List-base vlst)))))

;; Similar to list last function
(: last : (All (A) ((List A) -> A)))
(define (last vlst)
  (if (zero? (List-size vlst))
    (error 'last "given vlist is empty")
    (last-helper (List-base vlst))))

(: last-helper : (All (A) ((Base A) -> A)))
(define (last-helper base)
  (let ([prevbase (Base-prevbase base)])
    (if (null? prevbase)
      (ra:first (Base-elems base))
      (last-helper prevbase))))

;; Similar to list cdr function
(: rest : (All (A) ((List A) -> (List A))))
(define (rest vlst)
  (let* ([new-offset (sub1 (List-offset vlst))]
         [size (List-size vlst)]
         [base (List-base vlst)]
         [prev (Base-prevbase base)])
    (cond 
      [(zero? size) (error 'rest "given vlist is empty")]
      [(zero? new-offset) 
       (let ([newsize (arithmetic-shift size -1)]) 
         (if (Base? prev) (make-List newsize prev newsize) empty))]
      [else (make-List new-offset 
                       (make-Base prev (ra:tail (Base-elems base)))
                       size)])))

;; Similar to list length function
(: list-length : (All (A) ((List A) -> Integer)))
(define (list-length vlst)
  (let ([size (List-size vlst)])
    (if (zero? size) 0 (+ size (sub1 (List-offset vlst))))))

(: vlist->list : (All (A) ((List A) -> (Listof A))))
(define (vlist->list vlist)
  (if (zero? (List-size vlist))
    null
    (cons (first vlist) (vlist->list (rest vlist)))))

;; Similar to list-ref function
(: get : (All (A) (Integer (List A) -> A)))
(define (get index vlist)
  (cond
    [(> index (sub1 (list-length vlist))) 
     (error 'list-ref "given index out of bounds")]
    [(zero? index) (first vlist)]
    [else (get-helper index vlist)]))

(: list-ref : (All (A) ((List A) Integer -> A)))
(define (list-ref vlist index) (get index vlist))

(: get-helper : (All (A) (Integer (List A) -> A)))
(define (get-helper index vlist)
  (let* ([base (List-base vlist)]
         [offset (List-offset vlist)]
         [prev (Base-prevbase base)])
    (if (and (> index (sub1 offset)) (Base? prev))
      (helper (- index offset) prev (arithmetic-shift (List-size vlist) -1))
      (begin (display index) (ra:list-ref (Base-elems base) index)))))

(: helper : (All (A) (Integer (Block A) Integer -> A)))
(define (helper index block size)
  (if (Base? block) 
    (if (> index (sub1 size)) 
      (helper (- index size) 
              (Base-prevbase block) 
              (arithmetic-shift size -1))
      (ra:list-ref (Base-elems block) index))
    (error 'list-ref "given index out of bounds")))

;; Similar to list reverse function
(: vreverse : (All (A) ((List A) -> (List A))))
(define (vreverse vlist)
  (: vreverse-helper : (All (A) ((List A) (List A) -> (List A))))
  (define (vreverse-helper inner-vl accum)
    (if (zero? (List-size inner-vl))
      accum
      (vreverse-helper (rest inner-vl) (vcons (first inner-vl) accum))))
  (vreverse-helper vlist empty))

;; list constructor
(: vlist : (All (A) (A * -> (List A))))
(define (vlist . lst)
  (foldr (inst vcons A) empty lst))

;; similar to list map function. apply is expensive so using case-lambda
;; in order to saperate the more common case
(: list-map : 
   (All (A C B ...) 
        (case-lambda 
          ((A -> C) (List A) -> (List C))
          ((A B ... B -> C) (List A) (List B) ... B -> (List C)))))
(define list-map
  (pcase-lambda: (A C B ...)
                 [([func : (A -> C)]
                   [list : (List A)])
                  (if (empty? list)
                    empty
                    (vcons (func (first list)) (list-map func (rest list))))]
                 [([func : (A B ... B -> C)]
                   [list  : (List A)] . [lists : (List B) ... B])
                  (if (or (empty? list) (ormap empty? lists))
                    empty
                    (vcons (apply func (first list) (map first lists))
                           (apply list-map func (rest list)
                                  (map rest lists))))]))


;; Similar to list foldr function. apply is expensive so using case-lambda
;; in order to saperate the more common case
(: list-foldr : 
   (All (A C B ...) 
        (case-lambda ((C A -> C) C (List A) -> C)
                     ((C A B ... B -> C) C (List A) (List B) ... B -> C))))
(define list-foldr
  (pcase-lambda: (A C B ...) 
                 [([func : (C A -> C)]
                   [base : C]
                   [list  : (List A)])
                  (if (empty? list)
                    base
                    (func (list-foldr func base (rest list))
                          (first list)))]
                 [([func : (C A B ... B -> C)]
                   [base : C]
                   [list  : (List A)] . [lists : (List B) ... B])
                  (if (or (empty? list) (ormap empty? lists))
                    base
                    (apply func (apply list-foldr func base (rest list)
                                       (map rest lists))
                           (first list) (map first lists)))]))

;; similar to list foldl function
(: list-foldl : 
   (All (A C B ...) 
        (case-lambda ((C A -> C) C (List A) -> C)
                     ((C A B ... B -> C) C (List A) (List B) ... B -> C))))
(define list-foldl
  (pcase-lambda: (A C B ...) 
                 [([func : (C A -> C)]
                   [base : C]
                   [list  : (List A)])
                  (if (empty? list)
                    base
                    (list-foldl func (func base (first list)) (rest list)))]
                 [([func : (C A B ... B -> C)]
                   [base : C]
                   [list  : (List A)] . [lists : (List B) ... B])
                  (if (or (empty? list) (ormap empty? lists))
                    base
                    (apply list-foldl func
                           (apply func base (first list) (map first lists))
                           (rest list) (map rest lists)))]))

;; Similar to list filter function
(: vfilter : (All (A) ((A -> Boolean) (List A) -> (List A))))
(define (vfilter func lst)
  (if (empty? lst)
    empty
    (let ([firsts (first lst)]
          [rests (vfilter func (rest lst))])
      (if (func firsts)
        (vcons firsts rests)
        rests))))
