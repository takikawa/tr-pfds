#lang typed-scheme
(require (rename-in "../catenablelist.ss" [list catlist]))
(require typed/test-engine/scheme-tests)

(check-expect (head (clist 1 2 3 4 5 6 7)) 1)
(check-expect (head (clist "" "")) "")
(check-expect (tail (clist 1)) empty)
(check-expect (head (tail (clist 1 2 3 4 5 6 7))) 2)

(check-expect (empty? (tail (clist 1))) #t)
(check-expect (empty? (tail (clist 2 1))) #f)
(check-expect (empty? empty) #t)
(check-error (head empty) "head: given list is empty")
(check-error (tail empty) "tail: given list is empty")
(check-expect (clist->list (tail (clist 1 2 3 4 5 6 7)))
              (list 2 3 4 5 6 7))

(check-expect (clist->list (tail (tail (clist 1 2 3 4 5 6 7))))
              (list 3 4 5 6 7))

(check-expect (clist->list (append (clist 1) 
                                  (clist 1 2 3 4 5 6 7))) 
              (list 1 1 2 3 4 5 6 7))

(check-expect (clist->list (append empty 
                                  (clist 1 2 3 4 5 6 7))) 
              (list 1 2 3 4 5 6 7))

(check-expect (clist->list (append (clist 1 2 3 4 5 6 7) empty)) 
              (list 1 2 3 4 5 6 7))

(check-expect (clist->list (append empty empty)) null)

(check-expect (clist->list (kons-rear 0 (clist 1 2 3 4 5 6 7)))
              (list 1 2 3 4 5 6 7 0))

(check-expect (clist->list (kons-rear 0 (clist 1 2 3)))
              (list 1 2 3 0))

(check-expect (clist->list (kons 0 (clist 1)))
              (list 0 1))

(check-expect (clist->list (kons-rear 0 empty)) (list 0))

(check-expect (clist->list (kons 0 empty)) (list 0))

(define lst (build-list 100 (λ (x) x)))

(check-expect (clist->list (apply clist lst)) lst)

(test)
