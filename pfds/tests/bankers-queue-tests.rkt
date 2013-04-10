#lang typed-scheme
(require pfds/queue/bankers)
;;(require "../queue/bankers.rkt")
(require typed/test-engine/scheme-tests)

(check-expect (empty? (empty Integer)) #t)
(check-expect (empty? (queue 1)) #f)
(check-expect (empty? (queue 1 2)) #f)

(check-expect (head (queue 4 5 2 3)) 4)
(check-expect (head (queue 2)) 2)

(check-expect (queue->list (tail (queue 4 5 2 3)))
              (list 5 2 3))
(check-expect (queue->list (tail (queue 1))) null)
(check-error (tail (empty Integer)) "tail: given queue is empty")

(check-expect (queue->list (enqueue 1 (empty Integer)))
              (list 1))
(check-expect (queue->list (enqueue 1 (queue 1 2 3))) (list 1 2 3 1))

(check-expect (head (enqueue 1 (empty Integer))) 1)
(check-expect (head (enqueue 10 (queue 5 2 3))) 5)

(check-error (head (empty Integer)) "head: given queue is empty")

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

;; #########################
;; Performance-related Tests
;; #########################

;; Testing proper queue rotation (see issue #3 on github)
;; ------------------------------------------------------
;; When doing a "rotation", ie reversing the rear list and appending that to 
;; the end of the front list, the reverse operation should be delayed and only
;; forced when that section of the front list is needed.

;; To demonstrate, build a queue of size 2^n - 2. Taking the tail of this queue
;; triggers a rotation. In a proper implementation, the reversing is delayed 
;; so the tail operation should be instantaneous (ie should take 0 time).

;; n = 21
#;(let ([q (build-queue (assert (- (expt 2 21) 2) positive?) add1)])
  (time (tail q)))

;; 2013-03-10, on Steve's desktop (i7-2600k, 16GB)
;; (I dont know why the gc time is so high, probably an anomaly, but the
;;  important number is 0 after the fix)
;; before fix: cpu time: 468 real time: 469 gc time: 400
;;  after fix: cpu time: 0 real time: 0 gc time: 0


;; Another way to expose premature rotation is to manipulate a queue into a
;; state such that the next tail operation forces the reversing thunk. If the
;; reversing was done prematurely, then taking the tail of this queue will be
;; instantaneous. But in a proper implementation, taking the tail should be an
;; expensive operation.

;; To get such a queue, build a queue of size 2^n - 2 and then drop the first
;; 2^(n-1) - 1 elements (ie, half). In a proper implementation, taking the tail
;; of this queue should be an expensive operation in a correct implementation.

;; n = 21, 2^21 - 2 = 2097150; 2^20 - 1 = 1048575
#;(let* ([n 21]
       [thresh (sub1 (expt 2 (sub1 n)))])
  (let loop ([q (build-queue (assert (- (expt 2 n) 2) positive?) add1)] 
             [i 0])
    (if (< i thresh)
        (loop (tail q) (add1 i))
        (time (tail q)))))

;; 2013-03-10, on Steve's desktop (i7-2600k, 16GB)
;; before fix: cpu time: cpu time: 0 real time: 0 gc time: 0
;;  after fix: cpu time: 56 real time: 60 gc time: 44



;; Testing queues used persistently (assumes fixed issue#3, described above)
;; ---------------------------------------------------------------------------
;; To maintain constant, amortized time operations when the queue is used 
;; persistently, doing an expensive rotation should memoize the result so that
;; repeating the same expensive operation completes instantaneously.

;; This is the same as the second example above, except the "expensive" tail
;; is called twice. The second call should be instantaneous.
#;(let* ([n 21]
       [thresh (sub1 (expt 2 (sub1 n)))])
  (let loop ([q (build-queue (assert (- (expt 2 n) 2) positive?) add1)] 
             [i 0])
    (if (< i thresh)
        (loop (tail q) (add1 i))
        (begin
          (time (tail q))
          (time (tail q))))))

;; 2013-03-10, on Steve's desktop (i7-2600k, 16GB)
;; after fix: 
;;   cpu time: 60 real time: 61 gc time: 48
;;   cpu time: 0 real time: 0 gc time: 0