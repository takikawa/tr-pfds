#lang typed-scheme

(provide empty null-bsqueue? enqueue head tail)
 
(require scheme/promise)

(define-struct: (A) Queue ([F : (Listof A)]
                           [M : (BSQueue (Promise (Listof A)))]
                           [LenFM : Integer]
                           [R : (Listof A)]
                           [LenR : Integer]))

(define-struct: EmptyBSQueue ([Null : Any]))

(define empty (make-EmptyBSQueue ""))

(define-type-alias BSQueue (All (A) (U EmptyBSQueue (Queue A))))

(: null-bsqueue? : (All (A) ((BSQueue A) -> Boolean)))
(define (null-bsqueue bsq)
  (EmptyBSQueue? bsq))


(: queue : (All (A) ((BSQueue A) -> (BSQueue A))))
(define (queue bsq)
    (cond
      [(EmptyBSQueue? bsq) empty]
      [(<= (Queue-LenR bsq) (Queue-LenFM bsq)) (checkF bsq)]
      [else (checkF (make-Queue (Queue-F bsq) 
                                (enqueue (delay (reverse (Queue-R bsq))) 
                                         (Queue-M bsq)) 
                                (+ (Queue-LenFM bsq) (Queue-LenR bsq)) 
                                null 0))]))

(: enqueue : (All (A) (A (BSQueue A) -> (BSQueue A))))
(define (enqueue elem bsq)
  (if (EmptyBSQueue? bsq)
      (make-Queue (list elem) null 1 null 0)
      (queue (make-Queue (Queue-F bsq)
                         (Queue-M bsq)
                         (Queue-LenFM bsq)
                         (cons elem (Queue-R bsq))
                         (add1 (Queue-LenR bsq))))))

(: head : (All (A) ((BSQueue A) -> A)))
(define (head bsq)
  (if (EmptyBSQueue? bsq)
      (error "Queue is empty" 'head)
      (car (Queue-F bsq))))


(: tail : (All (A) ((BSQueue A) -> (BSQueue A))))
(define (tail bsq)
  (if (EmptyBSQueue? bsq)
      (error "Queue is empty" 'tail)
      (queue (make-Queue (cdr (Queue-F bsq)) 
                         (Queue-M bsq) 
                         (sub1 (Queue-LenFM bsq)) 
                         (Queue-R bsq)
                         (Queue-LenR bsq)))))

(: checkF : (All (A) ((Queue A) -> (BSQueue A))))
(define (checkF que)
  (cond 
    [(and (null? (Queue-F que)) (null? (Queue-M que))) empty]
    [(null? (Queue-F que)) (make-Queue (force (head (Queue-M que)))
                                       (tail (Queue-M que))
                                       (Queue-LenFM que)
                                       (Queue-R que)
                                       (Queue-LenR que))]
    [else que]))