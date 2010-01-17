#lang typed-scheme
(require "../implicitdeque.ss")
(require typed/test-engine/scheme-tests)

(check-expect (empty? empty) #t)
(check-expect (empty? (implicit-deque (list 1))) #f)
(check-expect (head (implicit-deque (list 1))) 1)
(check-expect (last (implicit-deque (list 1))) 1)
(check-expect (head (implicit-deque (list 4 5 1 2 -1))) -1)
(check-expect (head (tail (implicit-deque (list 4 5 1 2 -1)))) 2)
(check-expect (last (implicit-deque (list 4 5 1 2 -1))) 4)
(check-expect (last (init (implicit-deque (list 4 5 1 2 -1)))) 5)
(check-expect (head (tail (init (implicit-deque (list 4 5 1 2 -1))))) 2)
(check-expect (last (tail (init (implicit-deque (list 4 5 1 2 -1))))) 5)

(check-error (head (implicit-deque (list))) "Queue is empty : head")
(check-error (last (implicit-deque (list))) "Queue is empty : last")
(check-error (tail (implicit-deque (list))) "Queue is empty : tail")
(check-error (init (implicit-deque (list))) "Queue is empty : init")

(check-expect (deque->list (tail (implicit-deque (list 1)))) null)
(check-expect (deque->list (init (implicit-deque (list 1)))) null)
(check-expect (deque->list (tail (implicit-deque (list 1 2 3 4)))) (list 1 2 3))
(check-expect (deque->list (init (implicit-deque (list 1 2 3 4)))) (list 2 3 4))

(check-expect (deque->list (enqueue 1 (implicit-deque (list)))) (list 1))
(check-expect (deque->list (snoc 1 (implicit-deque (list)))) (list 1))
(check-expect (deque->list (enqueue 1 (implicit-deque (list 2)))) (list 2 1))
(check-expect (deque->list (snoc 1 (implicit-deque (list 2)))) (list 1 2))
(check-expect (deque->list (enqueue 1 (implicit-deque (list 2 3)))) (list 2 3 1))
(check-expect (deque->list (snoc 1 (implicit-deque (list 2 3)))) (list 1 2 3))

(test)