#lang typed-scheme

(require scheme/promise)

(provide empty-stream? null-stream stream-cons stream-car
         stream-cdr stream-append stream-reverse stream
         stream->list drop take Stream)

(define-struct: Mt ())

(define-struct: (A) InStream 
  ([elem  : (Promise (Pair A (Stream A)))]))

(define-type-alias (Stream A) (U Mt (InStream A)))

(define null-stream (make-Mt))


(: force-stream : (All (A) ((InStream A) -> (Pair A (Stream A)))))
(define (force-stream strem)
  (force (InStream-elem strem)))

(: empty-stream? : (All (A) ((Stream A) -> Boolean)))
(define (empty-stream? strem)
  (Mt? strem))

(: stream-cons : (All (A) (A (Stream A) -> (Stream A))))
(define (stream-cons elem strem)
  (make-InStream (delay (cons elem strem))))

(: stream-car : (All (A) ((Stream A) -> A)))
(define (stream-car strem)
  (if (Mt? strem)
      (error "Stream is empty :" 'stream-car)
      (car (force-stream strem))))


(: stream-cdr : (All (A) ((Stream A) -> (Stream A))))
(define (stream-cdr strem)
  (if (Mt? strem)
      (error "Stream is empty :" 'stream-cdr)  
      (cdr (force-stream strem))))

(: drop : (All (A) (Integer (Stream A) -> (Stream A))))
(define (drop num strem)
  (cond 
    [(= num 0) strem]
    [(Mt? strem) (error "Not enough elements to drop :" 'drop)]
    [else  (drop (sub1 num) (cdr (force-stream strem)))]))

(: take : (All (A) (Integer (Stream A) -> (Stream A))))
(define (take num strem)
  (if (or (= num 0) (Mt? strem))
      null-stream
      (let ([forced (force-stream strem)])
        (stream-cons (car forced) 
                     (take (sub1 num) (cdr forced))))))


(: stream-append : (All (A) ((Stream A) (Stream A) -> (Stream A))))
(define (stream-append strem1 strem2)
  (cond 
    [(Mt? strem1) strem2]
    [(Mt? strem2) strem1]
    [else (let ([forcd1 (force-stream strem1)])
            (make-InStream 
             (delay (cons (car forcd1) 
                          (stream-append (cdr forcd1) strem2)))))]))


(: stream-reverse : (All (A) ((Stream A) -> (Stream A))))
(define (stream-reverse strem)
  (: rev : ((Stream A) (Stream A) -> (Stream A)))
  (define (rev int-strem accum)
    (if (Mt? int-strem)
        accum
        (let ([forcd (force-stream int-strem)])
          (rev (cdr forcd)
               (stream-cons (car forcd) accum)))))
  (rev strem null-stream))


(: stream->list : (All (A) ((Stream A) -> (Listof A))))
(define (stream->list strem)
  (if (Mt? strem)
      null
      (let ([forcd (force-stream strem)])
        (cons (car forcd) (stream->list (cdr forcd))))))

(: stream : (All (A) (A A * -> (Stream A))))
(define (stream elem . elems)
  (let ([first (make-InStream (delay (cons elem null-stream)))])
    (if (null? elems)
        first
        (foldr (inst stream-cons A) null-stream (cons elem elems)))))