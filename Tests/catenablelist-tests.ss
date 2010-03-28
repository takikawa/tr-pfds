#lang typed-scheme
(require "../catenablelist.ss")
(require typed/test-engine/scheme-tests)

(check-expect (head (catenable-list 1 2 3 4 5 6 7)) 1)
(check-expect (head (catenable-list "" "")) "")
(check-expect (tail (catenable-list 1)) empty)
(check-expect (head (tail (catenable-list 1 2 3 4 5 6 7))) 2)

(check-expect (empty? (tail (catenable-list 1))) #t)
(check-expect (empty? (tail (catenable-list 2 1))) #f)

(check-expect (clist->list (tail (catenable-list 1 2 3 4 5 6 7)))
              (list 2 3 4 5 6 7))

(check-expect (clist->list (tail (tail (catenable-list 1 2 3 4 5 6 7))))
              (list 3 4 5 6 7))

(check-expect (clist->list (merge (catenable-list 1) 
                                  (catenable-list 1 2 3 4 5 6 7))) 
              (list 1 1 2 3 4 5 6 7))

(check-expect (clist->list (merge empty 
                                  (catenable-list 1 2 3 4 5 6 7))) 
              (list 1 2 3 4 5 6 7))

(check-expect (clist->list (merge (catenable-list 1 2 3 4 5 6 7) empty)) 
              (list 1 2 3 4 5 6 7))

(check-expect (clist->list (merge empty empty)) null)

(check-expect (clist->list (kons-rear 0 (catenable-list 1 2 3 4 5 6 7)))
              (list 1 2 3 4 5 6 7 0))

(check-expect (clist->list (kons-rear 0 (catenable-list 1 2 3)))
              (list 1 2 3 0))

(check-expect (clist->list (kons 0 (catenable-list 1)))
              (list 0 1))

(check-expect (clist->list (kons-rear 0 empty)) (list 0))

(check-expect (clist->list (kons 0 empty)) (list 0))

(define lst (build-list 100 (λ (x) x)))

(check-expect (clist->list (apply catenable-list lst)) lst)

(test)