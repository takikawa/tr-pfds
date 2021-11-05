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

(provide PartialStreamof pscar pscdr psappend pstake psdrop psreverse)

(define-type (PartialStreamof A)
  (Rec X (U Null
            (Pair A X)
            (Promiseof X))))

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
  (cond [(null? l1) l2]
        [(null? l2) l1]
        [(pair? l1) (cons (car l1) (ann (delay (psappend (cdr l1) l2))
                                        (PartialStreamof A)))]
        [else (psappend (force l1) l2)]))

(: pstake : (All (A) (Integer (PartialStreamof A) -> (PartialStreamof A))))
(define (pstake num lst)
  (cond [(zero? num) null]
        [(null? lst) (error 'pstake "not enough elements to take")]
        [(pair? lst) (cons (car lst) (ann (delay (pstake (sub1 num) (cdr lst)))
                                          (PartialStreamof A)))]
        [else (pstake num (force lst))]))

(: psdrop : (All (A) (Integer (PartialStreamof A) -> (PartialStreamof A))))
(define (psdrop num lst)
  (cond [(zero? num) lst]
        [(null? lst) (error 'psdrop "not enough elements to drop")]
        [(pair? lst) (psdrop (sub1 num) (cdr lst))]
        [else (psdrop num (force lst))]))

(: psreverse : (All (A) (PartialStreamof A) -> (PartialStreamof A)))
(define (psreverse lst)
  (: loop : (All (A) (PartialStreamof A) (PartialStreamof A) -> (PartialStreamof A)))
  (define (loop lst accum)
    (cond [(null? lst) accum]
          [(pair? lst) (loop (cdr lst) (cons (car lst) accum))]
          [else (loop (force lst) accum)]))
  (loop lst null))
