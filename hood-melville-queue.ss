#lang typed-scheme

(define-struct: Idle ())
(define-struct: (A) Reversing ([count : Integer]
                               [fst : (Listof A)]
                               [snd : (Listof A)]
                               [trd : (Listof A)]
                               [frt : (Listof A)]))
(define-struct: (A) Appending ([count : Integer]
                               [fst : (Listof A)]
                               [snd : (Listof A)]))
(define-struct: (A) Done ([fst : (Listof A)]))

(define-type-alias (RotationState A) 
  (U Idle (Reversing A) (Appending A) (Done A)))