#lang typed-scheme
(require "../realtimedeque.ss")
(require typed/test-engine/scheme-tests)

(check-expect (empty? empty) #t)
(check-expect (empty? (rtdeque (list 1))) #f)
(check-expect (head (rtdeque (list 1))) 1)
(check-expect (last (rtdeque (list 1))) 1)
(check-expect (head (rtdeque (list 4 5 1 2 -1))) -1)
(check-expect (head (tail (rtdeque (list 4 5 1 2 -1)))) 2)
(check-expect (last (rtdeque (list 4 5 1 2 -1))) 4)
(check-expect (last (init (rtdeque (list 4 5 1 2 -1)))) 5)
(check-expect (head (tail (init (rtdeque (list 4 5 1 2 -1))))) 2)
(check-expect (last (tail (init (rtdeque (list 4 5 1 2 -1))))) 5)

(check-error (head (rtdeque (list))) "Deque is empty : head")
(check-error (last (rtdeque (list))) "Deque is empty : last")
(check-error (tail (rtdeque (list))) "Deque is empty : tail")
(check-error (init (rtdeque (list))) "Deque is empty : init")

(check-expect (rtdeque->list (tail (rtdeque (list 1)))) null)
(check-expect (rtdeque->list (init (rtdeque (list 1)))) null)
(check-expect (rtdeque->list (tail (rtdeque (list 1 2 3 4)))) (list 1 2 3))
(check-expect (rtdeque->list (init (rtdeque (list 1 2 3 4)))) (list 2 3 4))

(check-expect (rtdeque->list (enqueue 1 (rtdeque (list)))) (list 1))
(check-expect (rtdeque->list (snoc 1 (rtdeque (list)))) (list 1))
(check-expect (rtdeque->list (enqueue 1 (rtdeque (list 2)))) (list 2 1))
(check-expect (rtdeque->list (snoc 1 (rtdeque (list 2)))) (list 1 2))
(check-expect (rtdeque->list (enqueue 1 (rtdeque (list 2 3)))) (list 2 3 1))
(check-expect (rtdeque->list (snoc 1 (rtdeque (list 2 3)))) (list 1 2 3))

(test)