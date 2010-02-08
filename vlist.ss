#lang typed-scheme
(require "skewbinaryrandomaccesslist.ss")
(define-struct: (A) Base ([prevbase : (Block A)]
                          [prevoffset : Integer]
                          [elems : (RAList A)]
                          [size : Integer]))
(define-struct: Mt ())

(define-type-alias Block (All (A) (U Mt (Base A))))

(define-struct: (A) VList ([offset : Integer]
                           [base : (Base A)]
                           [size : Integer]))

;(define-type-alias VList (All (A) (List A)))

(define empty-vlist (make-VList 0 (make-Base (make-Mt) 0 empty 1) 0))

(: isempty? : (All (A) ((VList A) -> Boolean)))
(define (isempty? vlist)
  (zero? (VList-size vlist)))

(: add-elem : (All (A) (A (VList A) -> (VList A))))
(define (add-elem elem vlst)
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
        (make-VList newoffset 
                   (make-Base prevbase 
                              prevoffset
                              (ralist-cons elem lst)
                              basesize)
                   (add1 size))
        (make-VList 1 
                   (make-Base base 
                              offset
                              (ralist-cons elem empty)
                              (* basesize 2))
                   (add1 size)))))

(: first : (All (A) ((VList A) -> A)))
(define (first vlst)
  (let ([offset (VList-offset vlst)]
        [size (VList-size vlst)]
        [base (VList-base vlst)])
    (if (< (sub1 offset) size)
        (head (Base-elems base))
        (error "List is empty :" 'first))))

(: last : (All (A) ((VList A) -> A)))
(define (last vlst)
  (if (zero? (size vlst))
      (error "List is empty :" 'last)
      (last-helper (VList-base vlst))))

(: last-helper : (All (A) ((Base A) -> A)))
(define (last-helper base)
  (let ([prevbase (Base-prevbase base)])
    (if (Mt? prevbase)
        (head (Base-elems base))
        (last-helper prevbase))))

(: rest : (All (A) ((VList A) -> (VList A))))
(define (rest vlst)
  (let* ([offset (VList-offset vlst)]
         [size (VList-size vlst)]
         [base (VList-base vlst)]
         [len (Base-size base)]
         [prev (Base-prevbase base)])
    (cond 
      [(and (zero? len) (zero? offset)) (error "List is empty :" 'rest)]
      [(> offset 1) (make-VList (sub1 offset) 
                               (make-Base (Base-prevbase base)
                                          (Base-prevoffset base)
                                          (tail (Base-elems base))
                                          (Base-size base)) 
                               (sub1 size))]
      [(Base? prev) (make-VList (Base-prevoffset base) prev (sub1 size))]
      [else empty-vlist])))
        

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
         [prev (Base-prevbase base)]
         [prevoffset (Base-prevoffset base)])
    (if (and (> index (sub1 offset)) (Base? prev))
        (get-helper (- index offset) 
                    (make-VList prevoffset prev (VList-size vlist)))
        (lookup (Base-elems base) index))))
      
(: reverse : (All (A) ((VList A) -> (VList A))))
(define (reverse vlist)
  (: reverse-helper : (All (A) ((VList A) (VList A) -> (VList A))))
  (define (reverse-helper inner-vl accum)
    (if (zero? (VList-size inner-vl))
        accum
        (reverse-helper (rest inner-vl) (add-elem (first inner-vl) accum))))
  (reverse-helper vlist empty-vlist))

(: base-size : (All (A) ((Block A) -> (Listof Integer))))
(define (base-size block)
  (if (Mt? block)
      null
      (cons (Base-size block) (base-size (Base-prevbase block)))))

(: vlist : (All (A) ((Listof A) -> (VList A))))
(define (vlist lst)
  (foldr (inst add-elem A) empty-vlist lst))

(: vmap : (All (A C B ...) ((A ... -> C) (VList A) ... -> (VList C))))
(define (vmap func . lst)
  (if (ormap isempty? lst)
      empty-vlist
      (add-elem (apply func (map first lst)) 
               (apply vmap func (map rest lst)))))


;(: vfoldl : (All (A B) ((A B -> B) B (VList A) -> B)))
;(define (vfoldl func base lst)
;  (cond
;    [(isempty? lst) base]
;    [(isempty? (rest lst)) (func (first lst) base)]
;    [else (vfoldl func 
;                  (func (first lst) base)
;                  (rest lst))]))

(: vfoldl : 
   (All (C A B ...) ((C A B ... -> C) C (VList A) (VList B) ... B -> C)))
(define (vfoldl func base fst . rst)
  (if (or (isempty? fst) (ormap isempty? rst))
      base
      (apply vfoldl 
             func 
             (apply func base (first fst) (map first rst))
             (rest fst)
             (map rest rst))))

(: vfoldr : 
   (All (C A B ...) ((C A B ... -> C) C (VList A) (VList B) ... B -> C)))
(define (vfoldr func base fst . rst)
  (if (or (isempty? fst) (ormap isempty? rst))
      base
      (apply func (apply vfoldr 
                         func 
                         base
                         (rest fst)
                         (map rest rst)) (first fst) (map first rst))))

;(: vfoldr : (All (A B) ((A B -> B) B (VList A) -> B)))
;(define (vfoldr func base lst)
;  (cond
;    [(isempty? lst) base]
;    [(isempty? (rest lst)) (func (first lst) base)]
;    [else (func (first lst)
;                (vfoldr func 
;                        base 
;                        (rest lst)))]))


;(: vfoldr1 : (All (C A B ...) ((C A B ... B -> C) C (VList A) (VList B) ... B -> C)))
;(define (vfoldr1 func base fst . rst)
;  (if (or (isempty? fst) (ormap isempty? rst))
;      base
;      (apply vfoldr1 
;             func
;             (apply func base (first fst) (map first rst)) 
;             (rest fst) 
;             (map rest rst))))

;(: vfoldr1 : (All (A C B ...) ((C B ... -> C) C (VList B) ... B -> C)))
;(define (vfoldr1 func base . lst)
;  (cond
;    [(ormap isempty? lst) base]
;    [(ormap isempty? (map rest lst)) (apply func (car (map first lst)) (append (cdr (map first lst)) (list base)))]
;    [else (apply func (map first lst) (apply vfoldr1 
;                                             func 
;                                             base 
;                                             (map rest lst)))]))


(: vfilter : (All (C A B) ((A -> Boolean) (VList A) -> (VList A))))
(define (vfilter func lst)
  (if (isempty? lst)
      empty-vlist
      (let ([firsts (first lst)]
            [rests (vfilter func (rest lst))])
        (if (func firsts)
            (add-elem firsts rests)
            rests))))