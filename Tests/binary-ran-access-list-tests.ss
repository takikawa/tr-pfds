#lang typed-scheme
(require "../binaryrandomaccesslist.ss")
(require typed/test-engine/scheme-tests)

(check-expect (head (ralist (list 1 2 3 4 5 6 7))) 1)
(check-expect (head (ralist (list "" ""))) "")
(check-expect (tail (ralist (list 1))) (ralist (list)))
(check-expect (head (tail (ralist (list 1 2 3 4 5 6 7)))) 2)

(check-expect (null? (tail (ralist (list 1)))) #t)
(check-expect (null? (tail (ralist (list 2 1)))) #f)

(check-expect (ralist->list (tail (ralist (list 1 2 3 4 5 6 7)))) 
              (list 2 3 4 5 6 7))

(check-expect (ralist->list (tail (tail (ralist (list 1 2 3 4 5 6 7)))))
              (list 3 4 5 6 7))

(check-expect (drop (ralist (list 1)) 1) (ralist (list)))
(check-expect (ralist->list (drop (ralist (list 1 2 3 4 5 6 7)) 2)) 
              (list 3 4 5 6 7))

(check-expect (ralist->list (drop (ralist (list 1 2 3 4 5 6 7)) 0)) 
              (list 1 2 3 4 5 6 7))
(check-error (drop (ralist (list 1 2 3 4 5 6 7)) 8) 
             "Index out of bound : drop")
(check-error (drop (ralist (list 1 2 3 4 5 6 7)) -1) 
             "Index out of bound : drop")

(check-expect (ralist->list (update (ralist (list 1 2 3 4 5 6 7)) 2 1234)) 
              (list 1 2 1234 4 5 6 7))

(check-expect (ralist->list (update (ralist (list 1 2 3 4 5 6 7)) 0 1234)) 
              (list 1234 2 3 4 5 6 7))

(check-error (update (ralist (list 1 2 3 4 5 6 7)) -2 1234)
             "Index out of bound : update")

(check-error (update (ralist (list 1 2 3 4 5 6 7)) -2 1234)
             "Index out of bound : update")

(check-expect (list-size (ralist (list))) 0)
(check-expect (list-size (ralist (list 1))) 1)
(check-expect (list-size (ralist (list 1 2 3 4 5 6 7))) 7)
(test)