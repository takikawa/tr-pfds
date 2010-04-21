#lang typed-scheme
(require "../vlist.ss")
(require typed/test-engine/scheme-tests)

(define lst (build-list 100 (λ:([x : Integer]) x)))

(define vlst (apply vlist lst))

(check-expect (vlist->list vlst) lst)

(check-expect (vlist->list (vmap add1 vlst)) 
              (map add1 lst))

(check-expect (vfoldl + 0 vlst) (foldl + 0 lst))

(check-expect (vfoldl * 1 vlst) (foldl * 1 lst))

(check-expect (vfoldl + 0 vlst vlst) (foldl + 0 lst lst))

(check-expect (vfoldr + 0 vlst) (foldr + 0 lst))

(check-expect (vfoldr * 1 vlst) (foldr * 1 lst))

(check-expect (vfoldr + 0 vlst vlst) (foldr + 0 lst lst))

(check-expect (vlist->list (vfilter (λ:([x : Integer]) (> x 50)) vlst)) 
              (filter (λ:([x : Integer]) (> x 50)) lst))

(check-expect (vlist->list (vreverse vlst)) (reverse lst))

(check-expect (get (sub1 (size vlst)) vlst) (last vlst))

(check-expect (get 0 vlst) (first vlst))

(check-error (get (+ 5 (size vlst)) vlst) "get: given index out of bounds")

(check-expect (vlist->list (rest vlst)) (cdr lst))

(check-error (first empty) "first: given vlist is empty")

(check-error (last empty) "last: given vlist is empty")

(check-error (rest empty) "rest: given vlist is empty")

(check-expect (size empty) 0)

(check-expect (size vlst) (length lst))

(check-expect (empty? empty) #t)

(check-expect (empty? vlst) #f)

(test)
