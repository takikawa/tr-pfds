#lang typed-scheme

(require scheme/promise)

(provide empty-stream? null-stream stream-cons stream-car
         stream-cdr stream-append stream-reverse stream
         stream->list drop take Stream)

(define-struct: (A) Stream 
  ([elem  : (Promise (U (Pair A (Stream A)) String))]))

(define null-stream (make-Stream (delay "stream-begin")))


(: force-stream : (All (A) ((Stream A) -> (U (Pair A (Stream A)) String))))
(define (force-stream strem)
  (force (Stream-elem strem)))

(: empty-stream? : (All (A) ((Stream A) -> Boolean)))
(define (empty-stream? strem)
  (eq? strem null-stream))

(: stream-cons : (All (A) (A (Stream A) -> (Stream A))))
(define (stream-cons elem strem)
  (make-Stream (delay (cons elem strem))))

(: stream-car : (All (A) ((Stream A) -> A)))
(define (stream-car strem)
  (let ([forcd (force-stream strem)])
    (if (string? forcd)
        (error "Stream is empty :" 'stream-car)
        (car forcd))))


(: stream-cdr : (All (A) ((Stream A) -> (Stream A))))
(define (stream-cdr strem)
  (let ([forcd (force-stream strem)])
    (if (string? forcd)
        (error "Stream is empty :" 'stream-cdr)  
        (cdr forcd))))

(: drop : (All (A) (Integer (Stream A) -> (Stream A))))
(define (drop num strem)
  (if (or (= num 0) (empty-stream? strem)) 
      strem
      (drop (sub1 num) (stream-cdr strem))))

(: take : (All (A) (Integer (Stream A) -> (Stream A))))
(define (take num strem)
  (if (or (= num 0) (empty-stream? strem)) 
      null-stream
      (stream-cons (stream-car strem) (take (sub1 num) (stream-cdr strem)))))


(: stream-append : (All (A) ((Stream A) (Stream A) -> (Stream A))))
(define (stream-append strem1 strem2)
  (let ([forcd1 (force-stream strem1)]
        [forcd2 (force-stream strem2)])
    (cond 
      [(string? forcd1) (make-Stream (delay forcd2))]
      [(string? forcd2) (make-Stream (delay forcd1))]
      [(and (string? forcd2) (string? forcd1)) null-stream]
      [else (make-Stream (delay (cons (car forcd1) 
                                      (stream-append (cdr forcd1) 
                                                     strem2))))])))


(: stream-reverse : (All (A) ((Stream A) -> (Stream A))))
(define (stream-reverse strem)
  (letrec: ([reverse : ((Stream A) (Stream A) -> (Stream A))
                     (lambda: ([int-strem : (Stream A)] 
                              [accum : (Stream A)])
                              (let ([forcd (force-stream int-strem)]) 
                                (if (string? forcd)
                                    accum
                                    (reverse (cdr forcd)
                                             (stream-cons (car forcd) accum)))))])
           (reverse strem null-stream)))


(: stream->list : (All (A) ((Stream A) -> (Listof A))))
(define (stream->list strem)
  (let ([forcd (force-stream strem)])
    (if (string? forcd)
        null
        (cons (car forcd) (stream->list (cdr forcd))))))

(: stream : (All (A) ((Listof A) -> (Stream A))))
(define (stream items)
  (foldr (inst stream-cons A) null-stream items))

