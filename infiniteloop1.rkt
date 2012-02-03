#lang typed-scheme

(require scheme/promise)

(define-struct: (A) Zero ([Null : Any]))
(define-struct: (A) One ([elem : A]))
(define-struct: (A) Two ([fst : A]
                         [snd : A]))
(define-type-alias ZeroOne (All (A) (U Zero (One A))))
(define-type-alias OneTwo (All (A) (U (One A) (Two A))))
(define-struct: (A) Shallow ([elem : (ZeroOne A)]))
(define-struct: (A) Deep ([F : (OneTwo A)]
                          [M : (Promise (Pair (ImplQueue A) (ImplQueue A)))]
                          [R : (ZeroOne A)]))

(define-type-alias ImplQueue (All (A) (U (Shallow A) (Deep A))))

(: enqueueS : (All (A) (A (Shallow A) -> (ImplQueue A))))
(define (enqueueS elem shq)
  (let ([shelem (Shallow-elem shq)])
    (if (Zero? shelem)
        (make-Shallow (make-One elem))
        (make-Deep (make-Two (One-elem shelem) elem)
                   (delay (cons (make-Shallow (make-Zero "")) 
                                (make-Shallow (make-Zero ""))))
                   (make-Zero "")))))