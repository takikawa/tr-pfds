#lang typed/racket

;; basic delay and force implementations for typed/racket based on lambda + box
;; used in okasaki data structure implementations
(provide Promiseof delay force)

;; - Outer box is for memoization
;; - Inner box is so TR can distinguished a forced promise from an unforced one
;;     I would have used a struct like Prom instead of the inner box, but TR
;;     cannnot distinguish structs from procedures?
(define-type Promiseof
  (All (A) (Boxof (U (-> (Boxof A))
                     (Boxof A)))))


(define-syntax-rule (delay e) (box (λ () (box e))))

(: force : (All (A) ((Promiseof A) -> A)))
(define (force b)
  (let ([ub (unbox b)])
    (if (procedure? ub)
        (let ([v (ub)])
          (set-box! b v)
          (unbox v))
        (unbox ub))))
