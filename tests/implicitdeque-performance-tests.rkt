#lang racket
(require "../deque/implicit.rkt")


;; tests run with Racket 5.3.0.11, in DrRacket, 
;; on a Intel i7-920 processor machine with 12GB memory


;;;;; test enqueue

; with bug
; cpu time: 19828 real time: 19856 gc time: 9329

; bug fixed (let* moved inside delay)
; cpu time: 2797 real time: 2809 gc time: 532

(time (build-deque 1000000 add1))


;;;;; test enqueue-front

; with bug
; cpu time: 49500 real time: 49721 gc time: 15297

; bug fixed (let* moved inside delay)
; cpu time: 26953 real time: 26983 gc time: 2489

(time
 (for/fold ([dq (deque)]) ([i (in-range 1000000)])
   (enqueue-front i dq)))