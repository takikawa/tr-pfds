#lang typed-scheme

(require "stream.ss")

(define-struct: (A) RTQueue
  ([front : (Stream A)]   
   [rear  : (Listof A)]
   [scdul : (Stream A)]))


(define empty-rtq (make-RTQueue null-stream null null-stream))


(: rtq-empty? : (All (A) ((RTQueue A) -> Boolean)))
(define (rtq-empty? rtq)
  (empty-stream? (RTQueue-front rtq)))


(: rotate : (All (A) ((Stream A) (Listof A) (Stream A) -> (Stream A))))
(define (rotate frnt rer accum)
  (if (empty-stream? frnt)
      (stream-cons (car rer) accum)
      (stream-cons (stream-car frnt) (rotate (stream-cdr frnt) 
                                             (cdr rer) 
                                             (stream-cons (car rer) accum)))))

(: internal-rtqueue : (All (A) ((RTQueue A) -> (RTQueue A))))
(define (internal-rtqueue rtq)
  (if (empty-stream? (RTQueue-scdul rtq))
      (let ([newf (rotate (RTQueue-front rtq) (RTQueue-rear rtq) (RTQueue-scdul rtq))])
        (make-RTQueue newf null newf))
      (make-RTQueue (RTQueue-front rtq) 
                    (RTQueue-rear rtq) 
                    (stream-cdr (RTQueue-scdul rtq)))))


(: rtq-enqueue : (All (A) (A (RTQueue A) -> (RTQueue A))))
(define (rtq-enqueue elem rtq)
  (internal-rtqueue (make-RTQueue (RTQueue-front rtq)
                                  (cons elem (RTQueue-rear rtq))
                                  (RTQueue-scdul rtq))))


(: rtq-head : (All (A) ((RTQueue A) -> A)))
(define (rtq-head rtq)
  (if (rtq-empty? rtq)
      (error "The given Real Time Queue is empty :" 'rtq-head)
      (stream-car (RTQueue-front rtq))))


(: rtq-tail : (All (A) ((RTQueue A) -> (RTQueue A))))
(define (rtq-tail rtq)
  (if (rtq-empty? rtq)
      (error "The given Real Time Queue is empty :" 'rtq-tail)
      (internal-rtqueue (make-RTQueue (stream-cdr (RTQueue-front rtq)) 
                                      (RTQueue-rear rtq) 
                                      (RTQueue-scdul rtq)))))


(: rtqueue : (All (A) ((Listof A) -> (RTQueue A))))
(define (rtqueue lst)
  (foldl (inst rtq-enqueue A) empty-rtq lst))

;; --------------------------------------------------------------------------
(: rtq->list : (All (A) ((RTQueue A) -> (Listof A))))
(define (rtq->list rtq)
  (if (rtq-empty? rtq)
      null
      (cons (rtq-head rtq) (rtq->list (rtq-tail rtq)))))

(: rtq-eq? : (All (A) ((RTQueue A) (RTQueue A) -> Boolean)))
(define (rtq-eq? rtq1 rtq2)
  (andmap equal? (rtq->list rtq1) (rtq->list rtq2)))


(and
 (rtq-empty? empty-rtq)
 (eq? (rtq-empty? (rtqueue (list 1 2 3))) #f)
 
 (eq? (rtq-head (rtqueue (list 1 2 3))) 1)
 (eq? (rtq-head (rtqueue (list 5 8 3))) 5)  
 
 (rtq-eq? (rtq-tail (rtqueue (list 1 2 3))) 
            (rtqueue (list 2 3)))
 (rtq-eq? (rtq-tail (rtqueue (list 5 6 1 2 3))) 
            (rtqueue (list 6 1 2 3)))
 (rtq-eq? (rtq-tail (rtqueue (list 3))) empty-rtq)
 
 (rtq-eq? (rtq-enqueue 5 (rtqueue (list 2 3)))
      (rtqueue (list 2 3 5)))
 (rtq-eq? (rtq-enqueue 5 empty-rtq)
      (rtqueue (list 5)))
 
 (rtq-eq? (rtq-enqueue '(1) (rtqueue (list '(2 2) '(3 4) '(5 6 7) '(5))))
      (rtqueue (list '(2 2) '(3 4) '(5 6 7) '(5) '(1)))))