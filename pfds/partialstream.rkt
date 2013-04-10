#lang typed/racket

;; A "partial stream" is a list where the tail of each of the segments may or 
;; may not be delayed. Thus, both a completely eager list and a standard stream
;; (where all tails are delayed) are instances of a partial stream.

;; A partial stream is practically advantageous over a standard stream in cases
;; where delaying the tail has no benefit. An example is when the tail is null.
;; Since null is already a value, delaying it has no advantages. Another example 
;; is when the tail is the result of reversing a stream. Since reverse is a
;; monolithic operation, ie it traverses the entire list or stream regardless
;; of laziness, any suspensions in the result have no benefit (but still incur
;; the cost of creating them). A situation where the latter example occurs is in
;; banker's queue.

(require "delay.rkt")

(provide PartialStreamof pscar pscdr psappend)

(define-type PartialStreamof 
  (All (A) (Rec X (U Null
                     (Pair A X)
                     (Promiseof X)))))

(: pscar : (All (A) ((PartialStreamof A) -> A)))
(define (pscar lst)
  (cond [(null? lst)  (error 'pscar "given list is empty")]
        [(pair? lst) (car lst)]
        [else (pscar (force lst))]))

(: pscdr : (All (A) ((PartialStreamof A) -> (PartialStreamof A))))
(define (pscdr lst)
  (cond [(null? lst) (error 'pscdr "given list is empty")]
        [(pair? lst) (cdr lst)]
        [else (pscdr (force lst))]))

(: psappend : 
   (All (A) (PartialStreamof A) (PartialStreamof A) -> (PartialStreamof A)))
(define (psappend l1 l2)
  (cond
    [(null? l1) l2]
    [(null? l2) l1]
    [else (cons (pscar l1) (ann (delay (psappend (pscdr l1) l2))
                                (PartialStreamof A)))]))


;; tests
;(: sum : ((PartialStreamof Integer) -> Integer))
;(define (sum lst)
;  (if (null? lst) 
;      0
;      (+ (pscar lst) (sum (pscdr lst)))))
;
;(sum
; (psappend 
;  (ann (delay (ann (reverse (list 1 2 3)) (PartialStreamof Integer))) 
;       (PartialStreamof Integer))
;  (ann (delay (ann (reverse (list 4 5 6)) (PartialStreamof Integer))) 
;       (PartialStreamof Integer))))