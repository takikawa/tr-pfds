#lang typed/racket

(require (rename-in pfds/vlist
                    [map vmap] 
                    [reverse vreverse] 
                    [length size]
                    [foldr vfoldr]
                    [foldl vfoldl]
                    [filter vfilter]
                    [list-ref get])
         (prefix-in rk: racket/base))

(require typed/test-engine/scheme-tests)

(define lst (rk:build-list 100 (λ:([x : Integer]) x)))

(define vlst (apply list lst))

(check-expect (->list vlst) lst)

(check-expect (->list (vmap add1 vlst)) 
              (map add1 lst))

(check-expect (vfoldl + 0 vlst) (foldl + 0 lst))

(check-expect (vfoldl * 1 vlst) (foldl * 1 lst))

(check-expect (vfoldl + 0 vlst vlst) (foldl + 0 lst lst))

(check-expect (vfoldr + 0 vlst) (foldr + 0 lst))

(check-expect (vfoldr * 1 vlst) (foldr * 1 lst))

(check-expect (vfoldr + 0 vlst vlst) (foldr + 0 lst lst))

(check-expect (->list (vfilter (λ:([x : Integer]) (> x 50)) vlst)) 
              (filter (λ:([x : Integer]) (> x 50)) lst))

(check-expect (->list (vreverse vlst)) (reverse lst))

(check-expect (get vlst (sub1 (size vlst))) (last vlst))

(check-expect (get vlst 0) (first vlst))

(check-error (get vlst (+ 5 (size vlst))) "list-ref: given index out of bounds")

(check-expect (->list (rest vlst)) (cdr lst))

(check-error (first empty) "first: given vlist is empty")

(check-error (last empty) "last: given vlist is empty")

(check-error (rest empty) "rest: given vlist is empty")

(check-expect (size empty) 0)

(check-expect (size vlst) (length lst))

(check-expect (empty? empty) #t)

(check-expect (empty? vlst) #f)

(test)
