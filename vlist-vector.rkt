#lang typed/scheme

;(provide (all-defined-out))
(provide vlist vlist->list vcons empty empty? size get first rest last
         vreverse vmap vfoldr vfoldl vfilter list-ref)
(provide (rename-out
	  [vlist list]
	  [vcons cons]
	  [size length]
	  [vreverse reverse]
	  [vmap map]))

;(require (prefix-in ra: "skewbinaryrandomaccesslist.ss"))
(define-struct: (A) Base ([prevbase : (Block A)]
                          [prevoffset : Integer]
                          [elems : (Vectorof A)]
                          [size : Integer]) #:transparent)
(define-struct: (A) Single ([elem : A]) #:transparent)

(define-type-alias Block (All (A) (U (Single A) (Base A))))

(define-struct: (A) List ([offset : Integer]
                          [base : (Block A)]
                          [size : Integer]) #:transparent)

;(define empty (make-List 0 (make-Base (make-Mt) 0 (inst #() (Vector A)) 1) 0))
;
(: empty? : (All (A) ((List A) -> Boolean)))
(define (empty? lst)
  (zero? (List-size lst)))

(: vcons : (All (A) (A (List A) -> (List A))))
(define (vcons elem vlst)
  (let ([offset (List-offset vlst)]
        [size (List-size vlst)]
        [base (List-base vlst)])
    (if (Single? base) 
        (if (zero? size)
            (make-List 0 (make-Single elem) 1)
            (make-List 0 (make-Base base 0 (make-vector 2 elem) 2) (add1 size)))
        (let* ([prevbase (Base-prevbase base)]
               [prevoffset (Base-prevoffset base)]
               [lst (Base-elems base)]
               [basesize (Base-size base)]
               [newoffset (add1 offset)])
          (if (= newoffset basesize)
              (make-List 0 (make-Base base 
                                      offset
                                      (make-vector (* basesize 2) elem)
                                      (* basesize 2))
                         (add1 size))
              (begin
                (vector-set! lst newoffset elem)
                (make-List newoffset 
                           (make-Base prevbase prevoffset lst basesize)
                           (add1 size))))))))

(: first : (All (A) ((List A) -> A)))
(define (first vlst)
  (let ([base (List-base vlst)])
    (cond 
      [(empty? vlst) (error 'first "given vlist is empty")]
      [(Single? base) (Single-elem base)]
      [else (vector-ref (Base-elems base) (List-offset vlst))])))

(: last : (All (A) ((List A) -> A)))
(define (last vlst)
  (let ([base (List-base vlst)])
    (cond 
      [(empty? vlst) (error 'last "given vlist is empty")]
      [(Single? base) (Single-elem base)]
      [else (last-helper base)])))

(: last-helper : (All (A) ((Base A) -> A)))
(define (last-helper base)
  (let ([prevbase (Base-prevbase base)])
    (if (Single? prevbase)
        (Single-elem prevbase)
        (last-helper prevbase))))

(: rest : (All (A) ((List A) -> (List A))))
(define (rest vlst)
  (let* ([offset (List-offset vlst)]
         [size (List-size vlst)]
         [base (List-base vlst)])
    (cond 
      [(empty? vlst) (error 'rest "given vlist is empty")]
      [(Single? base) (make-List (sub1 offset) base (sub1 size))]
      [(= offset 0) (make-List (Base-prevoffset base) (Base-prevbase base) (sub1 size))]
      [else (make-List (sub1 offset) base (sub1 size))])))

(: size : (All (A) ((List A) -> Integer)))
(define (size vlst)
  (List-size vlst))

(: vlist->list : (All (A) ((List A) -> (Listof A))))
(define (vlist->list vlist)
  (if (zero? (List-size vlist))
      null
      (cons (first vlist) (vlist->list (rest vlist)))))

(: get : (All (A) (Integer (List A) -> A)))
(define (get index vlist)
  (let ([size (sub1 (List-size vlist))])
    (cond
      [(> index size) (error 'list-ref "given index out of bounds")]
      [(zero? index) (first vlist)]
      [(= index size) (last vlist)]
      [else (get-helper (sub1 index) vlist)])))

(: list-ref : (All (A) ((List A) Integer -> A)))
(define (list-ref vlist index) (get index vlist))

(: get-helper : (All (A) (Integer (List A) -> A)))
(define (get-helper index vlist)
  (let* ([base (List-base vlist)]
         [offset (List-offset vlist)])
    (cond
      [(Single? base) (error 'list-ref "given index out of bounds")]
      [(>= index offset)
         (get-helper (- index (add1 offset)) 
                     (make-List (Base-prevoffset base) 
                                (Base-prevbase base) 
                                (List-size vlist)))]
      [else (vector-ref (Base-elems base) (- offset (add1 index)))])))

(: vreverse : (All (A) ((List A) -> (List A))))
(define (vreverse vlst)
  (: vreverse-helper : (All (A) ((List A) (List A) -> (List A))))
  (define (vreverse-helper inner-vl accum)
    (if (zero? (List-size inner-vl))
        accum
        (vreverse-helper (rest inner-vl) (vcons (first inner-vl) accum))))
  (if (empty? vlst)
      vlst
      (vreverse-helper (rest vlst) (vlist (first vlst)))))

(require (prefix-in l: racket/list))
(: vlist : (All (A) (A * -> (List A))))
(define (vlist . lst)
  (foldr (inst vcons A) 
         (make-List 1 (make-Single (l:last lst)) 1) (reverse (cdr (reverse lst)))))
 
(: vmap : (All (A C B ...) ((A ... -> C) (List A) ... -> (List C))))
(define (vmap func . lst)
  (if (ormap empty? (map rest lst))
      (vlist (apply func (map first lst)))
      (vcons (apply func (map first lst)) 
             (apply vmap func (map rest lst)))))

(: vfoldl : 
   (All (C A B ...) ((C A B ... -> C) C (List A) (List B) ... B -> C)))
(define (vfoldl func base fst . rst)
  (if (or (empty? fst) (ormap empty? rst))
      base
      (apply vfoldl 
             func 
             (apply func base (first fst) (map first rst))
             (rest fst)
             (map rest rst))))

(: vfoldr : 
   (All (C A B ...) ((C A B ... -> C) C (List A) (List B) ... B -> C)))
(define (vfoldr func base fst . rst)
  (if (or (empty? fst) (ormap empty? rst))
      base
      (apply func (apply vfoldr 
                         func 
                         base
                         (rest fst)
                         (map rest rst)) (first fst) (map first rst))))

(: vfilter : (All (C A B) ((A -> Boolean) (List A) -> (List A))))
(define (vfilter func lst)
  (if (empty? lst)
      lst
      (let ([firsts (first lst)]
            [rests (vfilter func (rest lst))])
        (if (func firsts)
            (vcons firsts rests)
            rests))))