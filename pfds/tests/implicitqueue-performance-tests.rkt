#lang racket
(require pfds/queue/implicit)


;; tests run with Racket 5.3.0.11, in DrRacket, 
;; on a Intel i7-920 processor machine with 12GB memory


;;;;; test enqueue

; with bug
; cpu time: 22234 real time: 22320 gc time: 11126

; bug fixed (let* moved inside delay)
; cpu time: 4703 real time: 4704 gc time: 1442

(time (build-queue 1000000 add1))
