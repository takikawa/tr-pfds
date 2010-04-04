#lang typed/scheme

(provide vlist vlist->list vcons empty empty? size get first rest last
         vreverse vmap vfoldr vfoldl vfilter)

(require (prefix-in ra: "skewbinaryrandomaccesslist.ss"))
(define-struct: (A) Base ([prevbase : (Block A)]
                          [prevoffset : Integer]
                          [elems : (ra:RAList A)]
                          [size : Integer]))
(define-struct: Mt ())

(define-type-alias Block (All (A) (U Mt (Base A))))

(define-struct: (A) VList ([offset : Integer]
                           [base : (Base A)]
                           [size : Integer]))

(define empty (make-VList 0 (make-Base (make-Mt) 0 ra:empty 1) 0))

(: empty? : (All (A) ((VList A) -> Boolean)))
(define (empty? vlist)
  (zero? (VList-size vlist)))

(: vcons : (All (A) (A (VList A) -> (VList A))))
(define (vcons elem vlst)
  (let* ([offset (VList-offset vlst)]
         [size (VList-size vlst)]
         [base (VList-base vlst)]
         [prevbase (Base-prevbase base)]
         [prevoffset (Base-prevoffset base)]
         [lst (Base-elems base)]
         [basesize (Base-size base)]
         [newoffset (add1 offset)]
         [lsthan (< offset basesize)])
    (if lsthan 
        (make-VList newoffset (make-Base prevbase 
                                         prevoffset
                                         (ra:kons elem lst)
                                         basesize)
                    (add1 size))
        (make-VList 1 (make-Base base 
                                 offset
                                 (ra:kons elem ra:empty)
                                 (* basesize 2))
                    (add1 size)))))

(: first : (All (A) ((VList A) -> A)))
(define (first vlst)
  (if (empty? vlst)
      (error "VList is empty :" 'first)
      (ra:head (Base-elems (VList-base vlst)))))

(: last : (All (A) ((VList A) -> A)))
(define (last vlst)
  (if (empty? vlst)
      (error "VList is empty :" 'last)
      (last-helper (VList-base vlst))))

(: last-helper : (All (A) ((Base A) -> A)))
(define (last-helper base)
  (let ([prevbase (Base-prevbase base)])
    (if (Mt? prevbase)
        (ra:head (Base-elems base))
        (last-helper prevbase))))

(: rest : (All (A) ((VList A) -> (VList A))))
(define (rest vlst)
  (let* ([offset (VList-offset vlst)]
         [size (VList-size vlst)]
         [base (VList-base vlst)]
         [prev (Base-prevbase base)])
    (cond 
      [(empty? vlst) (error "VList is empty :" 'rest)]
      [(> offset 1) (make-VList (sub1 offset) 
                                (make-Base (Base-prevbase base)
                                           (Base-prevoffset base)
                                           (ra:tail (Base-elems base))
                                           (Base-size base)) 
                                (sub1 size))]
      [(Base? prev) (make-VList (Base-prevoffset base) prev (sub1 size))]
      [else empty])))


(: size : (All (A) ((VList A) -> Integer)))
(define (size vlst)
  (VList-size vlst))

(: vlist->list : (All (A) ((VList A) -> (Listof A))))
(define (vlist->list vlist)
  (if (zero? (VList-size vlist))
      null
      (cons (first vlist) (vlist->list (rest vlist)))))

(: get : (All (A) (Integer (VList A) -> A)))
(define (get index vlist)
  (cond
    [(> index (sub1 (VList-size vlist))) (error "Index out of bound :" 'get)]
    [(zero? index) (first vlist)]
    [else (get-helper index vlist)]))

(: get-helper : (All (A) (Integer (VList A) -> A)))
(define (get-helper index vlist)
  (let* ([base (VList-base vlist)]
         [offset (VList-offset vlist)]
         [prev (Base-prevbase base)])
    (if (and (> index (sub1 offset)) (Base? prev))
        (get-helper (- index offset) 
                    (make-VList (Base-prevoffset base) prev (VList-size vlist)))
        (ra:lookup index (Base-elems base)))))

(: vreverse : (All (A) ((VList A) -> (VList A))))
(define (vreverse vlist)
  (: vreverse-helper : (All (A) ((VList A) (VList A) -> (VList A))))
  (define (vreverse-helper inner-vl accum)
    (if (zero? (VList-size inner-vl))
        accum
        (vreverse-helper (rest inner-vl) (vcons (first inner-vl) accum))))
  (vreverse-helper vlist empty))

(: base-size : (All (A) ((Block A) -> (Listof Integer))))
(define (base-size block)
  (if (Mt? block)
      null
      (cons (Base-size block) (base-size (Base-prevbase block)))))

(: vlist : (All (A) (A * -> (VList A))))
(define (vlist . lst)
  (foldr (inst vcons A) empty lst))

(: vmap : (All (A C B ...) ((A ... -> C) (VList A) ... -> (VList C))))
(define (vmap func . lst)
  (if (ormap empty? lst)
      empty
      (vcons (apply func (map first lst)) 
                (apply vmap func (map rest lst)))))

(: vfoldl : 
   (All (C A B ...) ((C A B ... -> C) C (VList A) (VList B) ... B -> C)))
(define (vfoldl func base fst . rst)
  (if (or (empty? fst) (ormap empty? rst))
      base
      (apply vfoldl 
             func 
             (apply func base (first fst) (map first rst))
             (rest fst)
             (map rest rst))))

(: vfoldr : 
   (All (C A B ...) ((C A B ... -> C) C (VList A) (VList B) ... B -> C)))
(define (vfoldr func base fst . rst)
  (if (or (empty? fst) (ormap empty? rst))
      base
      (apply func (apply vfoldr 
                         func 
                         base
                         (rest fst)
                         (map rest rst)) (first fst) (map first rst))))

(: vfilter : (All (C A B) ((A -> Boolean) (VList A) -> (VList A))))
(define (vfilter func lst)
  (if (empty? lst)
      empty
      (let ([firsts (first lst)]
            [rests (vfilter func (rest lst))])
        (if (func firsts)
            (vcons firsts rests)
            rests))))