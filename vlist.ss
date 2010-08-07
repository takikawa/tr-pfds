#lang typed/scheme

(provide vlist->list empty empty? first rest last list-ref)
(provide (rename-out
          [vlist list]
          [vcons cons]
          [size length]
          [vreverse reverse]
          [vmap map]
          [vfoldr foldr]
          [vfoldl foldl]
          [vfilter filter]))

(require (prefix-in ra: "skewbinaryrandomaccesslist.ss"))
(define-struct: (A) Base ([prevbase : (Block A)]
                          [prevoffset : Integer]
                          [elems : (ra:List A)]
                          [size : Integer]))
(define-struct: Mt ())

(define-type-alias Block (All (A) (U Mt (Base A))))

(define-struct: (A) List ([offset : Integer]
                          [base : (Base A)]
                          [size : Integer]))

;; An empty list
(define empty (make-List 0 (make-Base (make-Mt) 0 ra:empty 1) 0))

;; Checks for empty
(: empty? : (All (A) ((List A) -> Boolean)))
(define (empty? vlist)
  (zero? (List-size vlist)))

;; Similar to list cons function
(: vcons : (All (A) (A (List A) -> (List A))))
(define (vcons elem vlst)
  (let* ([offset (List-offset vlst)]
         [size (List-size vlst)]
         [base (List-base vlst)]
         [prevbase (Base-prevbase base)]
         [prevoffset (Base-prevoffset base)]
         [lst (Base-elems base)]
         [basesize (Base-size base)]
         [newoffset (add1 offset)]
         [lsthan (< offset basesize)])
    (if lsthan 
        (make-List newoffset (make-Base prevbase 
                                        prevoffset
                                        (ra:cons elem lst)
                                        basesize)
                   (add1 size))
        (make-List 1 (make-Base base 
                                offset
                                (ra:cons elem ra:empty)
                                (* basesize 2))
                   (add1 size)))))

;; Similar to list car function
(: first : (All (A) ((List A) -> A)))
(define (first vlst)
  (if (empty? vlst)
      (error 'first "given vlist is empty")
      (ra:head (Base-elems (List-base vlst)))))

;; Similar to list last function
(: last : (All (A) ((List A) -> A)))
(define (last vlst)
  (if (empty? vlst)
      (error 'last "given vlist is empty")
      (last-helper (List-base vlst))))

(: last-helper : (All (A) ((Base A) -> A)))
(define (last-helper base)
  (let ([prevbase (Base-prevbase base)])
    (if (Mt? prevbase)
        (ra:head (Base-elems base))
        (last-helper prevbase))))

;; Similar to list cdr function
(: rest : (All (A) ((List A) -> (List A))))
(define (rest vlst)
  (let* ([offset (List-offset vlst)]
         [size (List-size vlst)]
         [base (List-base vlst)]
         [prev (Base-prevbase base)])
    (cond 
      [(empty? vlst) (error 'rest "given vlist is empty")]
      [(> offset 1) (make-List (sub1 offset) 
                               (make-Base (Base-prevbase base)
                                          (Base-prevoffset base)
                                          (ra:tail (Base-elems base))
                                          (Base-size base)) 
                               (sub1 size))]
      [(Base? prev) (make-List (Base-prevoffset base) prev (sub1 size))]
      [else empty])))

;; Similar to list length function
(: size : (All (A) ((List A) -> Integer)))
(define (size vlst)
  (List-size vlst))

(: vlist->list : (All (A) ((List A) -> (Listof A))))
(define (vlist->list vlist)
  (if (zero? (List-size vlist))
      null
      (cons (first vlist) (vlist->list (rest vlist)))))

;; Similar to list-ref function
(: get : (All (A) (Integer (List A) -> A)))
(define (get index vlist)
  (cond
    [(> index (sub1 (List-size vlist))) (error 'list-ref
                                               "given index out of bounds")]
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
        (get-helper (- index offset) 
                    (make-List (Base-prevoffset base) prev (List-size vlist)))
        (ra:list-ref (Base-elems base) index))))

;; Similar to list reverse function
(: vreverse : (All (A) ((List A) -> (List A))))
(define (vreverse vlist)
  (: vreverse-helper : (All (A) ((List A) (List A) -> (List A))))
  (define (vreverse-helper inner-vl accum)
    (if (zero? (List-size inner-vl))
        accum
        (vreverse-helper (rest inner-vl) (vcons (first inner-vl) accum))))
  (vreverse-helper vlist empty))

(: base-size : (All (A) ((Block A) -> (Listof Integer))))
(define (base-size block)
  (if (Mt? block)
      null
      (cons (Base-size block) (base-size (Base-prevbase block)))))

;; list constructor
(: vlist : (All (A) (A * -> (List A))))
(define (vlist . lst)
  (foldr (inst vcons A) empty lst))

;; Similar to list map function
(: vmap : (All (A C B ...) ((A B ... B -> C) (List A) (List B) ... B -> (List C))))
(define (vmap func lst . lsts)
  (if (or (empty? lst) (ormap empty? lsts))
      empty
      (vcons (apply func (first lst) (map first lsts)) 
             (apply vmap func (rest lst) (map rest lsts)))))

;; Similar to list foldl function
(: vfoldl : 
   (All (C A B ...) ((C A B ... B -> C) C (List A) (List B) ... B -> C)))
(define (vfoldl func base fst . rst)
  (if (or (empty? fst) (ormap empty? rst))
      base
      (apply vfoldl 
             func 
             (apply func base (first fst) (map first rst))
             (rest fst)
             (map rest rst))))

;; Similar to list foldr function
(: vfoldr : 
   (All (C A B ...) ((C A B ... B -> C) C (List A) (List B) ... B -> C)))
(define (vfoldr func base fst . rst)
  (if (or (empty? fst) (ormap empty? rst))
      base
      (apply func (apply vfoldr 
                         func 
                         base
                         (rest fst)
                         (map rest rst)) (first fst) (map first rst))))

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

