#lang typed-scheme
(require "../stream.ss")
(require typed/test-engine/scheme-tests)

(check-expect (empty-stream? empty-stream) #t)
(check-expect (empty-stream? (stream 1)) #f)
(check-expect (empty-stream? (stream 1 2 3)) #f)

(check-expect (stream-car (stream 1)) 1)
(check-expect (stream-car (stream 2 3 1)) 2)
(check-error (stream-car empty-stream) "stream-car: given stream is empty")

(check-expect (stream->list (stream-cdr (stream 1))) null)
(check-expect (stream->list (stream-cdr (stream 2 3 1))) (list 3 1))
(check-error (stream-cdr empty-stream) "stream-cdr: given stream is empty")

(define lst1 (build-list 100 (λ: ([x : Integer]) x)))
(define lst2 (build-list 100 (λ: ([x : Integer]) (+ x 100))))
(define lst3 (build-list 90 (λ: ([x : Integer]) (+ x 10))))

(check-expect (stream->list (stream-cdr (apply stream lst1)))
              (cdr lst1))

(check-expect (stream->list (stream-append (apply stream lst1)
                                           (apply stream lst2)))
              (append lst1 lst2))

(check-expect (stream->list (stream-reverse (apply stream lst1)))
              (reverse lst1))

(check-expect (stream->list (drop 10 (apply stream lst1)))
              lst3)

(check-expect (stream->list (drop 0 (apply stream lst1)))
              lst1)

(check-expect (stream->list (drop 1 (apply stream lst1)))
              (cdr lst1))

(check-expect (stream->list (drop 50 (apply stream lst1)))
              (build-list 50 (λ: ([x : Integer]) (+ x 50))))

(check-expect (stream->list (take 0 (apply stream lst1)))
              null)

(check-error (stream->list (take 10 (stream 1 2 3 4)))
             "take: not enough elements to take")

(check-error (stream->list (drop 10 (stream 1 2 3 4)))
             "drop: not enough elements to drop")

(check-expect (stream->list (take 10 (apply stream lst1)))
              (list 0 1 2 3 4 5 6 7 8 9))

(check-expect (stream->list (take 5 (apply stream lst1)))
              (list 0 1 2 3 4))

(check-expect (stream->list (take 90 (apply stream lst1)))
              (build-list 90 (λ: ([x : Integer]) x)))

(test)
