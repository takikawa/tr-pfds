#lang typed-scheme

(require (prefix-in rtq: "realtimequeue.ss"))
(provide empty empty? enqueue head tail queue queue->list)

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


(: internal-queue : 
   (All (A) ((Listof A) 
             (rtq:RealTimeQueue (Promise (Listof A))) 
             Integer 
             (Listof A)
             Integer -> (BSQueue A))))
(define (internal-queue f m lenfm r lenr)
  (if (<= lenr lenfm) 
      (checkF (make-Queue f m lenfm r lenr))
      (checkF (make-Queue f (rtq:enqueue (delay (reverse r)) m) 
                          (+ lenfm lenr)
                          null 0))))

(: enqueue : (All (A) (A (BSQueue A) -> (BSQueue A))))
(define (enqueue elem bsq)
  (if (EmptyBSQueue? bsq)
      (make-Queue (cons elem null) rtq:empty 1 null 0)
      (internal-queue (Queue-F bsq)
                      (Queue-M bsq)
                      (Queue-LenFM bsq)
                      (cons elem (Queue-R bsq))
                      (add1 (Queue-LenR bsq)))))

(: head : (All (A) ((BSQueue A) -> A)))
(define (head bsq)
  (if (EmptyBSQueue? bsq)
      (error "Queue is empty :" 'head)
      (car (Queue-F bsq))))


(: tail : (All (A) ((BSQueue A) -> (BSQueue A))))
(define (tail bsq)
  (if (EmptyBSQueue? bsq)
      (error "Queue is empty :" 'tail)
      (internal-queue (cdr (Queue-F bsq)) 
                      (Queue-M bsq) 
                      (sub1 (Queue-LenFM bsq)) 
                      (Queue-R bsq)
                      (Queue-LenR bsq))))

(: checkF : (All (A) ((Queue A) -> (BSQueue A))))
(define (checkF que)
  (let* ([front (Queue-F que)]
         [mid (Queue-M que)])
    (if (null? front) 
        (if (rtq:empty? mid) 
            empty
            (make-Queue (force (rtq:head mid))
                        (rtq:tail mid)
                        (Queue-LenFM que)
                        (Queue-R que)
                        (Queue-LenR que)))
        que)))

(: queue->list : (All (A) ((BSQueue A) -> (Listof A))))
(define (queue->list bsq)
  (if (EmptyBSQueue? bsq)
      null
      (cons (head bsq) (queue->list (tail bsq))))) 

(: queue : (All (A) (A * -> (BSQueue A))))
(define (queue . lst)
  (foldl (inst enqueue A) empty lst))