#lang typed-scheme

(provide rtqueue rtqueue->list empty empty? 
         head tail enqueue RealTimeQueue list->rtqueue)

(require "stream.ss")

(define-struct: (A) RTQueue
  ([front : (Stream A)]   
   [rear  : (Listof A)]
   [scdul : (Stream A)]))

(define-type-alias RealTimeQueue (All (A) (RTQueue A)))
(define empty (make-RTQueue null-stream null null-stream))


(: empty? : (All (A) ((RTQueue A) -> Boolean)))
(define (empty? rtq)
  (empty-stream? (RTQueue-front rtq)))


(: rotate : (All (A) ((Stream A) (Listof A) (Stream A) -> (Stream A))))
(define (rotate frnt rer accum)
  (let ([carrer (car rer)])
    (if (empty-stream? frnt)
        (stream-cons carrer accum)
        (stream-cons (stream-car frnt) 
                     (rotate (stream-cdr frnt) 
                             (cdr rer) 
                             (stream-cons carrer accum))))))

(: internal-rtqueue : (All (A) ((RTQueue A) -> (RTQueue A))))
(define (internal-rtqueue rtq)
  (let ([front (RTQueue-front rtq)]
        [rear (RTQueue-rear rtq)]
        [schdl (RTQueue-scdul rtq)])
    (if (empty-stream? schdl)
        (let ([newf (rotate front rear schdl)])
          (make-RTQueue newf null newf))
        (make-RTQueue front rear (stream-cdr schdl)))))


(: enqueue : (All (A) (A (RTQueue A) -> (RTQueue A))))
(define (enqueue elem rtq)
  (internal-rtqueue (make-RTQueue (RTQueue-front rtq)
                                  (cons elem (RTQueue-rear rtq))
                                  (RTQueue-scdul rtq))))


(: head : (All (A) ((RTQueue A) -> A)))
(define (head rtq)
  (if (empty? rtq)
      (error "Queue is empty :" 'head)
      (stream-car (RTQueue-front rtq))))


(: tail : (All (A) ((RTQueue A) -> (RTQueue A))))
(define (tail rtq)
  (if (empty? rtq)
      (error "Queue is empty :" 'tail)
      (internal-rtqueue (make-RTQueue (stream-cdr (RTQueue-front rtq)) 
                                      (RTQueue-rear rtq) 
                                      (RTQueue-scdul rtq)))))

(: rtqueue->list : (All (A) ((RTQueue A) -> (Listof A))))
(define (rtqueue->list rtq)
  (if (empty? rtq)
      null
      (cons (head rtq) (rtqueue->list (tail rtq)))))

(: list->rtqueue : (All (A) ((Listof A) -> (RTQueue A))))
(define (list->rtqueue lst)
  (foldl (inst enqueue A) empty lst))

(: rtqueue : (All (A) (A * -> (RTQueue A))))
(define (rtqueue . lst)
  (foldl (inst enqueue A) empty lst))
