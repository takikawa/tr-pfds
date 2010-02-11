#lang typed-scheme
(require "../bootstrapedqueue.ss")
(require typed/test-engine/scheme-tests)

(check-expect (empty? empty) #t)
(check-expect (empty? (bsqueue 1)) #f)
(check-expect (empty? (bsqueue 1 2)) #f)

(check-expect (head (bsqueue 4 5 2 3)) 4)
(check-expect (head (bsqueue 2)) 2)  

(check-expect (bsqueue->list (tail (bsqueue 4 5 2 3)))
              (list 5 2 3))
(check-expect (bsqueue->list (tail (bsqueue 1))) null)
(check-error (tail (tail (bsqueue 1))) "Queue is empty : tail")

(check-expect (bsqueue->list (enqueue 1 empty)) (list 1))
(check-expect (bsqueue->list (enqueue 1 (bsqueue 1 2 3))) (list 1 2 3 1))

(check-expect (head (enqueue 1 empty)) 1)
(check-expect (head (enqueue 10 (bsqueue 5 2 3))) 5)

(check-error (head (tail (bsqueue 1))) "Queue is empty : head")

(test)