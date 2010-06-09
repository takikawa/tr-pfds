#lang typed/scheme
(provide id)
(define-struct: (A) Type1 
  ([elem : A]))

(define-struct: Mt ())

(define-type-alias (Union A) (U (Type1 A) Mt))

(: id : (All (A) (A Integer -> (Union A))))
(define (id elem int)
  (if (> int 5)
      (make-Type1 elem)
      (make-Mt)))