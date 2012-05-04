#lang typed-scheme
(require "../queue/bootstrapped.rkt")
(require typed/test-engine/scheme-tests)

(check-expect (empty? empty) #t)
(check-expect (empty? (queue 1)) #f)
(check-expect (empty? (queue 1 2)) #f)

(check-expect (head (queue 4 5 2 3)) 4)
(check-expect (head (queue 2)) 2)  

(check-expect (queue->list (tail (queue 4 5 2 3)))
              (list 5 2 3))
(check-expect (queue->list (tail (queue 1))) null)
(check-error (tail (tail (queue 1))) "tail: given queue is empty")

(check-expect (queue->list (enqueue 1 empty)) (list 1))
(check-expect (queue->list (enqueue 1 (queue 1 2 3))) (list 1 2 3 1))

(check-expect (head (enqueue 1 empty)) 1)
(check-expect (head (enqueue 10 (queue 5 2 3))) 5)

(check-error (head (tail (queue 1))) "head: given queue is empty")

(check-expect (queue->list (map + (queue 1 2 3 4 5) (queue 1 2 3 4 5)))
              (list 2 4 6 8 10))

(check-expect (queue->list (map - (queue 1 2 3 4 5) (queue 1 2 3 4 5)))
              (list 0 0 0 0 0))

(check-expect (fold + 0 (queue 1 2 3 4 5)) 15)

(check-expect (fold + 0 (queue 1 2 3 4 5) (queue 1 2 3 4 5)) 30)

(check-expect (queue->list (filter positive? (queue 1 2 -4 5 0 -6 12 3 -2)))
              (list 1 2 5 12 3))

(check-expect (queue->list (filter negative? (queue 1 2 -4 5 0 -6 12 3 -2)))
              (list -4 -6 -2))

(check-expect (queue->list (remove positive? (queue 1 2 -4 5 0 -6 12 3 -2)))
              (list -4 0 -6 -2))

(check-expect (queue->list (remove negative? (queue 1 2 -4 5 0 -6 12 3 -2)))
              (list 1 2 5 0 12 3))

(test)
