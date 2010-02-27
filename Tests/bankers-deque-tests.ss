#lang typed-scheme
(require "../bankers-deque.ss")
(require typed/test-engine/scheme-tests)

(check-expect (empty? empty) #t)
(check-expect (empty? (deque (list 1 2 3))) #f)

(check-expect (head (deque (list 1 2 3))) 1)
(check-expect (head (deque (list 5 6 2 3))) 5)
(check-error (head (deque (list))) "Deque is empty : head")

(check-expect (last (deque (list 1 2 3))) 3)
(check-expect (last (deque (list 5 6 2 8))) 8)
(check-error (last (deque (list))) "Deque is empty : last")

(check-expect (deque->list (tail (deque (list 1 2 3)))) (list 2 3))
(check-expect (deque->list (tail (deque (list 1 2 3 5 7 8)))) 
              (list 2 3 5 7 8))
(check-error (tail (deque (list))) "Deque is empty : tail")

(check-expect (deque->list (init (deque (list 1 2 3)))) (list 1 2))
(check-expect (deque->list (init (deque (list 1 2 3 5 7 8)))) 
              (list 1 2 3 5 7))
(check-error (init (deque (list))) "Deque is empty : init")

(check-expect (deque->list (enqueue 1 empty)) (list 1))
(check-expect (deque->list (enqueue 4 (deque (list 1 2)))) (list 1 2 4))

(check-expect (deque->list (enqueue-rear 1 empty)) (list 1))
(check-expect (deque->list (enqueue-rear 4 (deque (list 1 2)))) (list 4 1 2))

(test)