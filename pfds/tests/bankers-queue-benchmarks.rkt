#lang typed/racket
(require "../queue/bankers.rkt")

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

;; 2013-03-10, on Steve's desktop (i7-2600k, 16GB), in drracket
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

;; 2013-03-10, on Steve's desktop (i7-2600k, 16GB), in drracket
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

;; 2013-03-10, on Steve's desktop (i7-2600k, 16GB), in drracket
;; after fix: 
;;   cpu time: 60 real time: 61 gc time: 48
;;   cpu time: 0 real time: 0 gc time: 0


;; Test to show performance improvement from less laziness
;; (ie using partial stream instead of stream)
;; -------------------------------------------------------

#;(let ([q (time (build-queue (expt 2 21) add1))])
    (time 
     (let: loop : Integer ([q : (Queue Integer) q])
       (if (empty? q) 0 (+ (head q) (loop (tail q)))))))

;; 2013-03-11, on Steve's desktop (i7-2600k, 16GB), from racket cmd line
;; before commit 98c2723e35326291fb6909c2217b3f7c4b89ce39
;; (1st time is queue build, 2nd is summing queue elements)
;cpu time: 1748 real time: 1752 gc time: 1464
;cpu time: 1776 real time: 1779 gc time: 1072
;; after: 
;cpu time: 516 real time: 517 gc time: 336
;cpu time: 1468 real time: 1470 gc time: 852

