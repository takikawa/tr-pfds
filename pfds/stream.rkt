#lang typed/racket

(provide empty-stream? empty-stream stream-cons stream-car
         stream-cdr stream-append stream-reverse stream
         stream->list drop take Stream
         #;stream-map #;stream-foldl #;stream-foldr)

(define-type Stream
  (All (A) (Rec Stream (U Null (Boxof (U (-> (Pair A Stream))
                                         (Pair A Stream)))))))

(define empty-stream null)

(: empty-stream? : (All (A) ((Stream A) -> Boolean)))
(define (empty-stream? stream) (null? stream))


(: stream-car : (All (A) ((Stream A) -> A)))
(define (stream-car stream)
  (if (null? stream)
      (error 'stream-car "given stream is empty")
      (let ([p (unbox stream)])
        (if (procedure? p)
            (let ([pair (p)])
              (set-box! stream pair)
              (car pair))
            (car p)))))

(: stream-cdr : (All (A) ((Stream A) -> (Stream A))))
(define (stream-cdr stream)
  (if (null? stream)
      (error 'stream-cdr "given stream is empty")
      (let ([p (unbox stream)])
        (if (procedure? p)
            (let ([pair (p)])
              (set-box! stream pair)
              (cdr pair))
            (cdr p)))))

(define-syntax-rule (stream-cons x stream)
  (box (lambda () (cons x stream))))

(: stream-append : (All (A) (Stream A) (Stream A) -> (Stream A)))
(define (stream-append stream1 stream2)
  (cond
    [(null? stream1) stream2]
    [(null? stream2) stream1]
    [else (stream-cons (stream-car stream1)
                       (stream-append (stream-cdr stream1) stream2))]))

(: stream-reverse : (All (A) (Stream A) -> (Stream A)))
(define (stream-reverse stream)
  (: loop : (All (A) (Stream A) (Stream A) -> (Stream A)))
  (define (loop stream accum)
    (if (null? stream)
        accum
        (loop (stream-cdr stream) 
              (ann (stream-cons (stream-car stream) accum) (Stream A)))))
  (loop stream empty-stream))

(: stream : (All (A) (A * -> (Stream A))))
(define (stream . xs)
  (: loop : (All (A) ((Listof A) -> (Stream A))))
  (define (loop xs)
    (if (null? xs)
        '()
        (box (cons (car xs) (loop (cdr xs))))))
  (loop xs))

(: stream->list : (All (A) ((Stream A) -> (Listof A))))
(define (stream->list stream)
  (if (null? stream)
      '()
      (cons (stream-car stream) (stream->list (stream-cdr stream)))))


(: drop : (All (A) (Integer (Stream A) -> (Stream A))))
(define (drop num stream)
  (cond 
    [(zero? num)    stream] 
    [(null? stream) (error 'drop "not enough elements to drop")]
    [else (let ([forced (unbox stream)])
            (if (procedure? forced)
                (let ([pair (forced)])
                  (set-box! stream pair)
                  (drop (sub1 num) (cdr pair)))
                (drop (sub1 num) (cdr forced))))]))


(: take : (All (A) (Integer (Stream A) -> (Stream A))))
(define (take num stream)
  (cond 
    [(zero? num)    empty-stream]
    [(null? stream) (error 'take "not enough elements to take")]
    [else (let ([forced (unbox stream)])
            (if (procedure? forced)
                (let ([pair (forced)])
                  (set-box! stream pair)
                  (stream-cons (car pair) (take (sub1 num) (cdr pair))))
                (stream-cons (car forced) (take (sub1 num) (cdr forced)))))]))




;(: stream-map : (All (A C B ...) ((A B ... B -> C) (Stream A) 
;                                                   (Stream B) ... B -> 
;                                                   (Stream C))))
;(define (stream-map func strm . strms)
;  (if (or (empty? strm) (ormap empty? strms))
;      empty
;      (delay (make-InStream (apply func 
;                                   (stream-car strm) 
;                                   (map stream-car strms)) 
;                            (apply stream-map 
;                                   func 
;                                   (stream-cdr strm) 
;                                   (map stream-cdr strms))))))
;
;(: stream-foldl : 
;   (All (C A B ...) ((C A B ... B -> C) C (Stream A) 
;                                        (Stream B) ... B -> C)))
;(define (stream-foldl func base fst . rst)
;  (if (or (empty? fst) (ormap empty? rst))
;      base
;      (apply stream-foldl 
;             func 
;             (apply func base (stream-car fst) (map stream-car rst))
;             (stream-cdr fst)
;             (map stream-cdr rst))))
;
;(: stream-foldr : 
;   (All (C A B ...) ((C A B ... B -> C) C (Stream A) 
;                                        (Stream B) ... B -> C)))
;(define (stream-foldr func base fst . rst)
;  (if (or (empty? fst) (ormap empty? rst))
;      base
;      (apply func (apply stream-foldr 
;                         func 
;                         base
;                         (stream-cdr fst)
;                         (map stream-cdr rst)) 
;             (stream-car fst) 
;             (map stream-car rst))))
;



;;(: stream-filter : (All (A) ((A -> Boolean) (Stream A) -> (Stream A))))
;;(define (filter func strm)
;;  (: inner : (All (A) ((A -> Boolean) (Stream A) (Stream A) -> (Stream A))))
;;  (define (inner func strm accum)
;;    (if (empty? strm)
;;        accum
;;        (let ([head (head strm)]
;;              [tail (tail strm)])
;;          (if (func head)
;;              (inner func tail (stream-cons head accum))
;;              (inner func tail accum)))))
;;  (inner func strm empty))
;;
;;
;;(: stream-remove : (All (A) ((A -> Boolean) (Stream A) -> (Stream A))))
;;(define (remove func strm)
;;  (: inner : (All (A) ((A -> Boolean) (Stream A) (Stream A) -> (Stream A))))
;;  (define (inner func strm accum)
;;    (if (empty? strm)
;;        accum
;;        (let ([head (head strm)]
;;              [tail (tail strm)])
;;          (if (func head)
;;              (inner func tail accum)
;;              (inner func tail (stream-cons head accum))))))
;;  (inner func strm empty))
