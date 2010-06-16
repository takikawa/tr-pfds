#lang scheme

(require (prefix-in ih: "imperativeheap-1.ss")
         (prefix-in lh: "LeftistHeaps.ss")
         (prefix-in sh: "skewbinomialheap.ss")
         (prefix-in bh: "bootstrapedheap.ss"))

;(define len (build-list 1000 (λ: ([x : Integer]) x)))
;(define lst (build-list 1000001 (λ (x) x)))
(define lst (build-list 1000 (λ (x) x)))
(define lst1 (build-list 1000 (λ (x) (+ x 1000))))

#;(define bh (apply heap < lst))
#;(define bh1 (apply heap < lst1))
#;(define lst2 (make-list 40 (cons (apply heap < lst) (apply heap < lst1))))
;(time (for-each (λ: ([x : Integer]) (find-min/max bh)) len))

(displayln "Imperative")

(time (for ([id (in-range 100)])
        (let ([h1 (apply ih:heap < lst)]
              [h2 (apply ih:heap < lst1)])
          (ih:merge h1 h2))))

(displayln "Leftist")
(time (for ([id (in-range 100)])
        (let ([h1 (apply lh:heap < lst)]
              [h2 (apply lh:heap < lst1)])
          (lh:merge h1 h2))))

(displayln "Skew")
(time (for ([id (in-range 100)])
        (let ([h1 (apply sh:heap < lst)]
              [h2 (apply sh:heap < lst1)])
          (sh:merge h1 h2))))

(displayln "Bootstrap")
(time (for ([id (in-range 100)])
        (let ([h1 (apply bh:heap < lst)]
              [h2 (apply bh:heap < lst1)])
          (bh:merge h1 h2))))
