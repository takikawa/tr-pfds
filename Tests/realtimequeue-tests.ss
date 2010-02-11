#lang typed-scheme
(require "../realtimequeue.ss")
(require typed/test-engine/scheme-tests)

(check-expect (empty? empty) #t)
(check-expect (empty? (rtqueue 1)) #f)
(check-expect (head (rtqueue 1)) 1)
(check-error (head empty) "Queue is empty : head")
(check-expect (head (rtqueue 1 2)) 1)
(check-expect (head (rtqueue 10 2 34 55)) 10)

(check-expect (rtqueue->list (tail (rtqueue 1))) null)
(check-error (tail empty) "Queue is empty : tail")
(check-expect (rtqueue->list (tail (rtqueue 10 12))) (list 12))
(check-expect (rtqueue->list (tail (rtqueue 23 45 -6))) (list 45 -6))
(check-expect (rtqueue->list (tail (rtqueue 23 45 -6 15))) 
              (list 45 -6 15))

(check-expect (rtqueue->list (enqueue 10 (rtqueue 23 45 -6 15))) 
              (list 23 45 -6 15 10))
(check-expect (rtqueue->list (enqueue 10 empty)) (list 10))

(check-expect (rtqueue->list (enqueue 10 (rtqueue 20))) 
              (list 20 10))

(test)