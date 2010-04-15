#lang typed-scheme

(provide queue queue->list empty empty? 
         head tail enqueue RealTimeQueue list->queue)

(require "stream.ss")

(define-struct: (A) RTQueue
  ([front : (Stream A)]
   [rear  : (Listof A)]
   [scdul : (Stream A)]))

(define-type-alias RealTimeQueue (All (A) (RTQueue A)))
(define empty (make-RTQueue empty-stream null empty-stream))


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

(: internal-queue : (All (A) ((Stream A) (Listof A) (Stream A) -> (RTQueue A))))
(define (internal-queue front rear schdl)
  (if (empty-stream? schdl)
      (let ([newf (rotate front rear schdl)])
        (make-RTQueue newf null newf))
      (make-RTQueue front rear (stream-cdr schdl))))


(: enqueue : (All (A) (A (RTQueue A) -> (RTQueue A))))
(define (enqueue elem rtq)
  (internal-queue (RTQueue-front rtq)
                  (cons elem (RTQueue-rear rtq))
                  (RTQueue-scdul rtq)))


(: head : (All (A) ((RTQueue A) -> A)))
(define (head rtq)
  (if (empty? rtq)
      (error "Queue is empty :" 'head)
      (stream-car (RTQueue-front rtq))))


(: tail : (All (A) ((RTQueue A) -> (RTQueue A))))
(define (tail rtq)
  (if (empty? rtq)
      (error "Queue is empty :" 'tail)
      (internal-queue (stream-cdr (RTQueue-front rtq)) 
                      (RTQueue-rear rtq) 
                      (RTQueue-scdul rtq))))

(: queue->list : (All (A) ((RTQueue A) -> (Listof A))))
(define (queue->list rtq)
  (if (empty? rtq)
      null
      (cons (head rtq) (queue->list (tail rtq)))))

(: list->queue : (All (A) ((Listof A) -> (RTQueue A))))
(define (list->queue lst)
  (foldl (inst enqueue A) empty lst))

(: queue : (All (A) (A * -> (RTQueue A))))
(define (queue . lst)
  (foldl (inst enqueue A) empty lst))