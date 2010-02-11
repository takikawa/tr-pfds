#lang typed-scheme
(require "../bankers-queue-streams.ss")
(require typed/test-engine/scheme-tests)

(check-expect (empty? empty) #t)
(check-expect (empty? (queue (list 1))) #f)
(check-expect (empty? (queue (list 1 2))) #f)

(check-expect (head (queue (list 4 5 2 3))) 4)
(check-expect (head (queue (list 2))) 2)  

(check-expect (queue->list (tail (queue (list 4 5 2 3))))
              (list 5 2 3))
(check-expect (queue->list (tail (queue (list 1)))) null)
(check-error (tail (queue (list))) "Queue is empty : tail")

(check-expect (queue->list (enqueue 1 empty)) (list 1))
(check-expect (queue->list (enqueue 1 (queue (list 1 2 3)))) (list 1 2 3 1))

(check-expect (head (enqueue 1 empty)) 1)
(check-expect (head (enqueue 10 (queue (list 5 2 3)))) 5)

(check-error (head (queue (list))) "Queue is empty : head")

(test)