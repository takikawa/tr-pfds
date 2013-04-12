#lang typed/racket
(require "../deque/bankers.rkt")

;; #########################
;; Performance-related Tests
;; #########################


;; Test to show performance improvement from less laziness
;; (ie using partial stream instead of stream)
;; -------------------------------------------------------

;; enqueue in rear, pull from front
(let ([q (time (build-deque (expt 2 21) add1))])
    (time 
     (let: loop : Integer ([q : (Deque Positive-Integer) q])
       (if (empty? q) 0 (+ (head q) (loop (tail q)))))))
;; on Steve's desktop (i7-2600k, 16GB), from cmd line
;; (1st time is deque build, 2nd is summing deque elements)
;; with streams:
;cpu time: 1424 real time: 1428 gc time: 1132
;cpu time: 3612 real time: 3621 gc time: 2344
;; with partial streams:
;cpu time: 512 real time: 512 gc time: 340
;cpu time: 3580 real time: 3590 gc time: 2384


;; enqueue in rear, pull from rear
(let ([q (time (build-deque (expt 2 21) add1))])
    (time 
     (let: loop : Integer ([q : (Deque Positive-Integer) q])
       (if (empty? q) 0 (+ (last q) (loop (init q)))))))
;; on Steve's desktop (i7-2600k, 16GB), from cmd line
;; (1st time is deque build, 2nd is summing deque elements)
;; with streams:
;cpu time: 1544 real time: 1549 gc time: 1252
;cpu time: 2293 real time: 2302 gc time: 1393
;; with partial streams:
;cpu time: 536 real time: 538 gc time: 380
;cpu time: 2824 real time: 2832 gc time: 1892
;; build is faster but extra checks in partial stream results in slower dequeing

;; enqueue in front, pull from front
(let ([q (time (build-deque-front (expt 2 21) add1))])
    (time 
     (let: loop : Integer ([q : (Deque Positive-Integer) q])
       (if (empty? q) 0 (+ (head q) (loop (tail q)))))))
;; on Steve's desktop (i7-2600k, 16GB), from cmd line
;; (1st time is deque build, 2nd is summing deque elements)
;; with streams:
;cpu time: 1452 real time: 1455 gc time: 1204
;cpu time: 2264 real time: 2270 gc time: 1348
;; with partial streams:
;cpu time: 380 real time: 380 gc time: 216
;cpu time: 2621 real time: 2626 gc time: 1688
;; build is faster but extra checks in partial stream results in slower dequeing


;; enqueue in front, pull from rear
(let ([q (time (build-deque-front (expt 2 21) add1))])
    (time 
     (let: loop : Integer ([q : (Deque Positive-Integer) q])
       (if (empty? q) 0 (+ (last q) (loop (init q)))))))
;; on Steve's desktop (i7-2600k, 16GB), from cmd line
;; (1st time is deque build, 2nd is summing deque elements)
;; with streams:
;cpu time: 1444 real time: 1449 gc time: 1172
;cpu time: 3568 real time: 3580 gc time: 2368
;; with partial streams:
;cpu time: 384 real time: 384 gc time: 224
;cpu time: 3736 real time: 3748 gc time: 2524
