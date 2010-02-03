#lang typed-scheme

(require (prefix-in rtq: "realtimequeue.ss"))
(provide empty null-bsqueue? enqueue head tail)
 
(require scheme/promise)

(define-struct: (A) Queue ([F : (Listof A)]
                           [M : (rtq:RealTimeQueue (Promise (Listof A)))]
                           [LenFM : Integer]
                           [R : (Listof A)]
                           [LenR : Integer]))

(define-struct: EmptyBSQueue ([Null : Any]))

(define empty (make-EmptyBSQueue ""))

(define-type-alias BSQueue (All (A) (U EmptyBSQueue (Queue A))))

(: null-bsqueue? : (All (A) ((BSQueue A) -> Boolean)))
(define (null-bsqueue? bsq)
  (EmptyBSQueue? bsq))


(: queue : (All (A) ((Queue A) -> (BSQueue A))))
(define (queue bsq)
    (cond
      [(<= (Queue-LenR bsq) (Queue-LenFM bsq)) (checkF bsq)]
      [else (checkF (make-Queue (Queue-F bsq) 
                                (rtq:enqueue (delay (reverse (Queue-R bsq))) 
                                         (Queue-M bsq)) 
                                (+ (Queue-LenFM bsq) (Queue-LenR bsq)) 
                                null 0))]))

(: enqueue : (All (A) (A (BSQueue A) -> (BSQueue A))))
(define (enqueue elem bsq)
  (if (EmptyBSQueue? bsq)
      (make-Queue (cons elem null) rtq:empty 1 null 0)
      (queue (make-Queue (Queue-F bsq)
                         (Queue-M bsq)
                         (Queue-LenFM bsq)
                         (cons elem (Queue-R bsq))
                         (add1 (Queue-LenR bsq))))))

(: head : (All (A) ((BSQueue A) -> A)))
(define (head bsq)
  (if (EmptyBSQueue? bsq)
      (error "Queue is empty :" 'head)
      (car (Queue-F bsq))))


(: tail : (All (A) ((BSQueue A) -> (BSQueue A))))
(define (tail bsq)
  (if (EmptyBSQueue? bsq)
      (error "Queue is empty :" 'tail)
      (queue (make-Queue (cdr (Queue-F bsq)) 
                         (Queue-M bsq) 
                         (sub1 (Queue-LenFM bsq)) 
                         (Queue-R bsq)
                         (Queue-LenR bsq)))))

(: checkF : (All (A) ((Queue A) -> (BSQueue A))))
(define (checkF que)
  (cond 
    [(and (null? (Queue-F que)) (rtq:empty? (Queue-M que))) empty]
    [(null? (Queue-F que)) (make-Queue (force (rtq:head (Queue-M que)))
                                       (rtq:tail (Queue-M que))
                                       (Queue-LenFM que)
                                       (Queue-R que)
                                       (Queue-LenR que))]
    [else que]))

(: bsqueue->list : (All (A) ((BSQueue A) -> (Listof A))))
(define (bsqueue->list bsq)
  (if (EmptyBSQueue? bsq)
      null
      (cons (head bsq) (bsqueue->list (tail bsq))))) 

(: bsqueue : (All (A) ((Listof A) -> (BSQueue A))))
(define (bsqueue lst)
  (foldl (inst enqueue A) empty lst))