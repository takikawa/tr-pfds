#lang typed/racket #:optimize

(provide empty empty? first rest last list-ref List
         (rename-out [vlist->list ->list] [vlist list] [vcons cons]
                     [list-length length] [vreverse reverse] [list-map map]
                     [list-foldr foldr] [list-foldl foldl] [vfilter filter]
                     [vremove remove]
                     [list-ormap ormap] [list-andmap andmap]
                     [list-second second] [list-third third] 
                     [list-fourth fourth] [list-fifth fifth] 
                     [list-sixth sixth] [list-seventh seventh] 
                     [list-eighth eighth] [list-ninth ninth] 
                     [list-tenth tenth]
                     [list-length length]) build-list make-list)

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
                   [list : (List A)] . [lists : (List B) ... B])
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

;; Similar to list filter function
(: vremove : (All (A) ((A -> Boolean) (List A) -> (List A))))
(define (vremove func lst)
  (if (empty? lst)
      empty
      (let ([firsts (first lst)]
            [rests (vremove func (rest lst))])
        (if (func firsts)
            rests
            (vcons firsts rests)))))



;; Similar to build-list function of racket list
(: build-list : (All (A) (Natural (Natural -> A) -> (List A))))
(define (build-list size func)
  (let: loop : (List A) ([n : Natural size] [accum : (List A) empty])
        (if (zero? n)
            accum 
            (loop (sub1 n) (vcons (func (sub1 n)) accum)))))

;; Similar to make-list function of racket list
(: make-list : (All (A) (Natural A -> (List A))))
(define (make-list size elem)
  (let: loop : (List A) ([n : Natural size] [accum : (List A) empty])
        (if (zero? n)
            accum 
            (loop (sub1 n) (vcons elem accum)))))


;; similar to list andmap function
(: list-andmap : 
   (All (A B ...) 
        (case-lambda ((A -> Boolean) (List A) -> Boolean)
                     ((A B ... B -> Boolean) (List A) (List B) ... B -> Boolean))))
(define list-andmap
  (pcase-lambda: (A B ... ) 
                 [([func : (A -> Boolean)]
                   [list  : (List A)])
                  (or (empty? list)
                      (and (func (first list))
                           (list-andmap func (rest list))))]
                 [([func : (A B ... B -> Boolean)]
                   [list  : (List A)] . [lists : (List B) ... B])
                  (or (empty? list) (ormap empty? lists)
                      (and (apply func (first list) (map first lists))
                           (apply list-andmap func (rest list) 
                                  (map rest lists))))]))


;; similar to list ormap function
(: list-ormap : 
   (All (A B ...) 
        (case-lambda ((A -> Boolean) (List A) -> Boolean)
                     ((A B ... B -> Boolean) (List A) (List B) ... B -> Boolean))))
(define list-ormap
  (pcase-lambda: (A B ... ) 
                 [([func : (A -> Boolean)]
                   [list  : (List A)])
                  (and (not (empty? list))
                       (or (func (first list))
                           (list-ormap func (rest list))))]
                 [([func : (A B ... B -> Boolean)]
                   [list  : (List A)] . [lists : (List B) ... B])
                  (and (not (or (empty? list) (ormap empty? lists)))
                       (or (apply func (first list) (map first lists))
                           (apply list-ormap func (rest list) 
                                  (map rest lists))))]))



(: list-second : (All (A) (List A) -> A))
(define (list-second ls) (list-ref ls 1))

(: list-third : (All (A) (List A) -> A))
(define (list-third ls) (list-ref ls 2))

(: list-fourth : (All (A) (List A) -> A))
(define (list-fourth ls) (list-ref ls 3))

(: list-fifth : (All (A) (List A) -> A))
(define (list-fifth ls) (list-ref ls 4))

(: list-sixth : (All (A) (List A) -> A))
(define (list-sixth ls) (list-ref ls 5))

(: list-seventh : (All (A) (List A) -> A))
(define (list-seventh ls) (list-ref ls 6))

(: list-eighth : (All (A) (List A) -> A))
(define (list-eighth ls) (list-ref ls 7))

(: list-ninth : (All (A) (List A) -> A))
(define (list-ninth ls) (list-ref ls 8))

(: list-tenth : (All (A) (List A) -> A))
(define (list-tenth ls) (list-ref ls 9))
