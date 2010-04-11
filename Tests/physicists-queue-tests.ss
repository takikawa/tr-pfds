#lang typed-scheme
(require "../physicists-queue.ss")
(require typed/test-engine/scheme-tests)

(check-expect (empty? empty) #t)
(check-expect (empty? (queue 1)) #f)
(check-expect (empty? (queue 1 2)) #f)

(check-expect (head (queue 1)) 1)
(check-expect (head (queue 4 1 2)) 4)
(check-error (head (list->queue (list))) "Queue is empty : head")

(check-expect (queue->list (tail (queue 1))) null)
(check-expect (queue->list (tail (queue 4 1 2))) (list 1 2))
(check-expect (queue->list (tail (queue 4 1 2 10 15 23 -10))) 
              (list 1 2 10 15 23 -10))
(check-error (tail (list->queue (list))) "Queue is empty : tail")


(check-expect (queue->list (enqueue 1 empty)) (list 1))
(check-expect (queue->list (enqueue 1 (queue 4 1 2))) (list 4 1 2 1))
(check-expect (queue->list (enqueue 1 (queue 4 1 2 5))) 
              (list 4 1 2 5 1))

(check-expect (queue->list (queue '(1) '(2 2) '(3 4) '(5 6 7) '(5)))
              (list '(1) '(2 2) '(3 4) '(5 6 7) '(5)))

(test)