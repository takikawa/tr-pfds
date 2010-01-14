#lang typed-scheme

(define-struct: (A) List ([base : (VList A)]
                          [size : Integer]
                          [last-used : Integer]
                          [lst : (Listof A)]))
(define-struct: Mt ())

(define-type-alias VList (All (A) (U Mt (List A))))


(define empty (make-Mt))
(define fab (make-List (empty 1 1 (list 1))))