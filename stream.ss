#lang typed-scheme

(require scheme/promise)

(provide empty? empty stream-cons stream-car
         stream-cdr stream-append stream-reverse stream
         stream->list drop take Stream)

(define-struct: Mt ())

(define-struct: (A) InStream ([fst : A] 
                              [rst : (Stream A)]))

(define-type-alias (StreamCell A) (U Mt (InStream A)))

(define-type-alias (Stream A) (Promise (StreamCell A)))

(define empty (delay (make-Mt)))

(: force-stream : (All (A) ((Stream A) -> (StreamCell A))))
(define (force-stream strem)
  (force strem))

(: empty? : (All (A) ((Stream A) -> Boolean)))
(define (empty? strem)
  (Mt? (force strem)))

(: stream-cons : (All (A) (A (Stream A) -> (Stream A))))
(define (stream-cons elem strem)
  (delay (make-InStream elem strem)))

(: stream-car : (All (A) ((Stream A) -> A)))
(define (stream-car strem)
  (let ([instr (force strem)])
    (if (Mt? instr)
        (error "Stream is empty :" 'stream-car)
        (InStream-fst instr))))


(: stream-cdr : (All (A) ((Stream A) -> (Stream A))))
(define (stream-cdr strem)
  (let ([instr (force strem)])
    (if (Mt? instr)
        (error "Stream is empty :" 'stream-cdr)  
        (InStream-rst instr))))

(: drop : (All (A) (Integer (Stream A) -> (Stream A))))
(define (drop num strem)
  (if (zero? num) 
      strem
      (let ([instr (force strem)]) 
        (if (Mt? instr) 
            (error "Not enough elements to drop :" 'drop)
            (drop (sub1 num) (InStream-rst instr))))))

(: take : (All (A) (Integer (Stream A) -> (Stream A))))
(define (take num in-strem)
  (if (zero? num)
      empty
      (let ([forced (force in-strem)])
        (if (Mt? forced)
            (error "Not enough elements to take :" 'take)
            (delay (make-InStream (InStream-fst forced)
                                  (take (sub1 num) (InStream-rst forced))))))))


(: stream-append : (All (A) ((Stream A) (Stream A) -> (Stream A))))
(define (stream-append in-strem1 in-strem2) 
  (: local : (All (A) ((Stream A) (Stream A) -> (Stream A))))
  (define (local strem1 strem2)
    (let ([forcd (force-stream strem1)])
    (if (Mt? forcd)
        strem2
        (delay (make-InStream (InStream-fst forcd)
                              (stream-append (InStream-rst forcd) strem2))))))
  (if (Mt? (force in-strem2)) 
      in-strem1
      (local in-strem1 in-strem2)))

(: stream-reverse : (All (A) ((Stream A) -> (Stream A))))
(define (stream-reverse strem)
  (: rev : ((Stream A) (Stream A) -> (Stream A)))
  (define (rev int-strem accum)
    (let ([forcd (force int-strem)])
      (if (Mt? forcd)
          accum
          (rev (InStream-rst forcd)
               (delay (make-InStream (InStream-fst forcd) accum))))))
  (rev strem empty))

(: stream->list : (All (A) ((Stream A) -> (Listof A))))
(define (stream->list strem)
  (let ([forcd (force-stream strem)])
    (if (Mt? forcd)
        null
        (cons (InStream-fst forcd) 
              (stream->list (InStream-rst forcd))))))

(: stream : (All (A) (A * -> (Stream A))))
(define (stream . elems)
  (foldr (inst stream-cons A) empty elems))