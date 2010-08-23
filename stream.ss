#lang typed/scheme #:optimize

(require scheme/promise)

(provide empty-stream? empty-stream stream-cons stream-car
         stream-cdr stream-append stream-reverse stream
         stream->list drop take Stream
         stream-map stream-foldl stream-foldr)

(define-struct: Mt ())

(define-struct: (A) InStream ([fst : A] 
                              [rst : (Stream A)]))

(define-type-alias (StreamCell A) (U Mt (InStream A)))

(define-type-alias (Stream A) (Promise (StreamCell A)))

(define empty-stream (delay (make-Mt)))

(define empty empty-stream)

(: force-stream : (All (A) ((Stream A) -> (StreamCell A))))
(define (force-stream strem)
  (force strem))

(: empty-stream? : (All (A) ((Stream A) -> Boolean)))
(define (empty-stream? strem)
  (Mt? (force strem)))

(define empty? empty-stream?)

(: stream-cons : (All (A) (A (Stream A) -> (Stream A))))
(define (stream-cons elem strem)
  (delay (make-InStream elem strem)))

(: stream-car : (All (A) ((Stream A) -> A)))
(define (stream-car strem)
  (let ([instr (force strem)])
    (if (Mt? instr)
        (error 'stream-car "given stream is empty")
        (InStream-fst instr))))


(: stream-cdr : (All (A) ((Stream A) -> (Stream A))))
(define (stream-cdr strem)
  (let ([instr (force strem)])
    (if (Mt? instr)
        (error 'stream-cdr "given stream is empty")
        (InStream-rst instr))))

(: drop : (All (A) (Integer (Stream A) -> (Stream A))))
(define (drop num strem)
  (if (zero? num) 
      strem
      (let ([instr (force strem)]) 
        (if (Mt? instr) 
            (error 'drop "Not enough elements to drop")
            (drop (sub1 num) (InStream-rst instr))))))

(: take : (All (A) (Integer (Stream A) -> (Stream A))))
(define (take num in-strem)
  (if (zero? num)
      empty-stream
      (let ([forced (force in-strem)])
        (if (Mt? forced)
            (error 'take "Not enough elements to take")
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
  (rev strem empty-stream))


(: stream-map : (All (A C B ...) ((A B ... B -> C) (Stream A) 
                                             (Stream B) ... B -> 
                                             (Stream C))))
(define (stream-map func strm . strms)
  (if (or (empty? strm) (ormap empty? strms))
      empty
      (delay (make-InStream (apply func 
                                   (stream-car strm) 
                                   (map stream-car strms)) 
                            (apply stream-map 
                                   func 
                                   (stream-cdr strm) 
                                   (map stream-cdr strms))))))

(: stream-foldl : 
   (All (C A B ...) ((C A B ... B -> C) C (Stream A) 
                                        (Stream B) ... B -> C)))
(define (stream-foldl func base fst . rst)
  (if (or (empty? fst) (ormap empty? rst))
      base
      (apply stream-foldl 
             func 
             (apply func base (stream-car fst) (map stream-car rst))
             (stream-cdr fst)
             (map stream-cdr rst))))

(: stream-foldr : 
   (All (C A B ...) ((C A B ... B -> C) C (Stream A) 
                                        (Stream B) ... B -> C)))
(define (stream-foldr func base fst . rst)
  (if (or (empty? fst) (ormap empty? rst))
      base
      (apply func (apply stream-foldr 
                         func 
                         base
                         (stream-cdr fst)
                         (map stream-cdr rst)) 
             (stream-car fst) 
             (map stream-car rst))))



(: stream->list : (All (A) ((Stream A) -> (Listof A))))
(define (stream->list strem)
  (let ([forcd (force-stream strem)])
    (if (Mt? forcd)
        null
        (cons (InStream-fst forcd) 
              (stream->list (InStream-rst forcd))))))

(: stream : (All (A) (A * -> (Stream A))))
(define (stream . elems)
  (foldr (inst stream-cons A) empty-stream elems))


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
