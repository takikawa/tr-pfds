#lang typed/racket

(require "../delay.rkt")
(require "../partialstream.rkt")
(require typed/rackunit)
  
(: sum : ((PartialStreamof Integer) -> Integer))
(define (sum lst)
  (if (null? lst) 
      0
      (+ (pscar lst) (sum (pscdr lst)))))

(define-syntax-rule (check-type e t) (check-equal? (ann e t) e))

(check-type (list 1 2 3) (Listof Integer))
(check-type (list 1 2 3) (PartialStreamof Integer))
(check-type (reverse (list 1 2 3)) (Listof Integer))
(check-type (reverse (list 1 2 3)) (PartialStreamof Integer))
    
(check-equal?
 (sum
  (psappend 
   (ann (delay (ann (reverse (list 1 2 3)) (PartialStreamof Integer))) 
        (PartialStreamof Integer))
     (ann (delay (ann (reverse (list 4 5 6)) (PartialStreamof Integer))) 
          (PartialStreamof Integer))))
 21)