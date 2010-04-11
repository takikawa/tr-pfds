#lang typed-scheme

(require scheme/promise)

(provide empty-stream? null-stream stream-cons stream-car
         stream-cdr stream-append stream-reverse stream
         stream->list drop take Stream)

(define-struct: Mt ())

(define-type-alias (InStream A) (Pair A (Stream A)))

(define-type-alias (StreamCell A) (U Mt (InStream A)))
;
(define-struct: (A) Stream ([elem : (Promise (StreamCell A))]))
;
(define null-stream (make-Stream (delay (make-Mt))))

(: force-stream : (All (A) ((Stream A) -> (StreamCell A))))
(define (force-stream strem)
  (force (Stream-elem strem)))

(: empty-stream? : (All (A) ((Stream A) -> Boolean)))
(define (empty-stream? strem)
  (Mt? (force-stream strem)))

(: stream-cons : (All (A) (A (Stream A) -> (Stream A))))
(define (stream-cons elem strem)
  (make-Stream (delay (cons elem strem))))

(: stream-car : (All (A) ((Stream A) -> A)))
(define (stream-car strem)
  (let ([instr (force-stream strem)])
    (if (Mt? instr)
        (error "Stream is empty :" 'stream-car)
        (car instr))))


(: stream-cdr : (All (A) ((Stream A) -> (Stream A))))
(define (stream-cdr strem)
  (let ([instr (force-stream strem)])
    (if (Mt? instr)
        (error "Stream is empty :" 'stream-cdr)  
        (cdr instr))))

(: drop : (All (A) (Integer (Stream A) -> (Stream A))))
(define (drop num strem)
  (if (zero? num) 
      strem
      (let ([instr (force-stream strem)]) 
        (if (Mt? instr)
            (error "Not enough elements to drop :" 'drop)
            (drop (sub1 num) (cdr instr))))))

(: take : (All (A) (Integer (Stream A) -> (Stream A))))
(define (take num in-strem)
  (if (zero? num)
      in-strem
      (let ([forced (force-stream in-strem)])
        (if (Mt? forced)
            (error "Not enough elements to take :" 'take)
            (make-Stream (delay (cons (car forced)
                                      (take (sub1 num) (cdr forced)))))))))


(: stream-append : (All (A) ((Stream A) (Stream A) -> (Stream A))))
(define (stream-append in-strem1 in-strem2) 
  (: local : (All (A) ((Stream A) (Stream A) -> (Stream A))))
  (define (local strem1 strem2)
    (let ([forcd (force-stream strem1)])
      (if (Mt? forcd)
          strem2
          (make-Stream (delay (cons (car forcd)
                                    (stream-append (cdr forcd) strem2)))))))
  (if (Mt? (force-stream in-strem2))
      in-strem1
      (local in-strem1 in-strem2)))

(: stream-reverse : (All (A) ((Stream A) -> (Stream A))))
(define (stream-reverse strem)
  (: rev : ((Stream A) (Stream A) -> (Stream A)))
  (define (rev int-strem accum)
    (let ([forcd (force-stream int-strem)])
      (if (Mt? forcd)
          accum
          (rev (cdr forcd)
               (make-Stream (delay (cons (car forcd) accum)))))))
  (rev strem null-stream))

(: stream->list : (All (A) ((Stream A) -> (Listof A))))
(define (stream->list strem)
  (let ([forcd (force-stream strem)])
    (if (Mt? forcd)
        null
        (cons (car forcd) 
              (stream->list (cdr forcd))))))

(: stream : (All (A) (A * -> (Stream A))))
(define (stream . elems)
  (foldr (inst stream-cons A) null-stream elems))