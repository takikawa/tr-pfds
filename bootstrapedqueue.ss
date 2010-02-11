#lang typed-scheme

(require (prefix-in rtq: "realtimequeue.ss"))
(provide empty empty? enqueue head tail bsqueue bsqueue->list)
 
(require scheme/promise)

(define-struct: (A) Queue ([F : (Listof A)]
                           [M : (rtq:RealTimeQueue (Promise (Listof A)))]
                           [LenFM : Integer]
                           [R : (Listof A)]
                           [LenR : Integer]))

(define-struct: EmptyBSQueue ())

(define empty (make-EmptyBSQueue))

(define-type-alias BSQueue (All (A) (U EmptyBSQueue (Queue A))))

(: empty? : (All (A) ((BSQueue A) -> Boolean)))
(define (empty? bsq)
  (EmptyBSQueue? bsq))


(: queue : (All (A) ((Queue A) -> (BSQueue A))))
(define (queue bsq)
  (let ([lenr (Queue-LenR bsq)]
        [lenfm (Queue-LenFM bsq)])
    (if (<= lenr lenfm) 
        (checkF bsq)
        (checkF (make-Queue (Queue-F bsq) 
                            (rtq:enqueue (delay (reverse (Queue-R bsq))) 
                                         (Queue-M bsq)) 
                            (+ lenfm lenr) 
                            null 0)))))

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
  (let* ([front (Queue-F que)]
         [f-null? (null? front)]
         [mid (Queue-M que)])
    (cond 
      [(and f-null? (rtq:empty? mid)) empty]
      [f-null? (make-Queue (force (rtq:head mid))
                           (rtq:tail mid)
                           (Queue-LenFM que)
                           (Queue-R que)
                           (Queue-LenR que))]
      [else que])))

(: bsqueue->list : (All (A) ((BSQueue A) -> (Listof A))))
(define (bsqueue->list bsq)
  (if (EmptyBSQueue? bsq)
      null
      (cons (head bsq) (bsqueue->list (tail bsq))))) 

(: bsqueue : (All (A) (A * -> (BSQueue A))))
(define (bsqueue . lst)
  (foldl (inst enqueue A) empty lst))