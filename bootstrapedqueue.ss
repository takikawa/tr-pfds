#lang typed-scheme

(require (prefix-in rtq: "realtimequeue.ss"))
(provide empty empty? enqueue head tail queue queue->list Queue
         (rename-out [qmap map]) fold)

(require scheme/promise)
(define-type-alias (Mid A) (rtq:Queue (Promise (Listof A))))
(define-struct: (A) IntQue ([F : (Listof A)]
                            [M : (Mid A)]
                            [LenFM : Integer]
                            [R : (Listof A)]
                            [LenR : Integer]))

(define-struct: EmptyBSQueue ())

(define empty (make-EmptyBSQueue))

(define-type-alias (Queue A) (U EmptyBSQueue (IntQue A)))

(: empty? : (All (A) ((Queue A) -> Boolean)))
(define (empty? bsq)
  (EmptyBSQueue? bsq))


(: internal-queue : (All (A) ((Listof A) (Mid A) Integer (Listof A) Integer 
                                         -> (Queue A))))
(define (internal-queue f m lenfm r lenr)
  (if (<= lenr lenfm) 
      (checkF (make-IntQue f m lenfm r lenr))
      (checkF (make-IntQue f (rtq:enqueue (delay (reverse r)) m) 
                          (+ lenfm lenr)
                          null 0))))

(: enqueue : (All (A) (A (Queue A) -> (Queue A))))
(define (enqueue elem bsq)
  (if (EmptyBSQueue? bsq)
      (make-IntQue (cons elem null) rtq:empty 1 null 0)
      (internal-queue (IntQue-F bsq)
                      (IntQue-M bsq)
                      (IntQue-LenFM bsq)
                      (cons elem (IntQue-R bsq))
                      (add1 (IntQue-LenR bsq)))))

(: head : (All (A) ((Queue A) -> A)))
(define (head bsq)
  (if (EmptyBSQueue? bsq)
      (error 'head "given queue is empty")
      (car (IntQue-F bsq))))


(: tail : (All (A) ((Queue A) -> (Queue A))))
(define (tail bsq)
  (if (EmptyBSQueue? bsq)
      (error 'tail "given queue is empty")
      (internal-queue (cdr (IntQue-F bsq)) 
                      (IntQue-M bsq) 
                      (sub1 (IntQue-LenFM bsq)) 
                      (IntQue-R bsq)
                      (IntQue-LenR bsq))))

(: checkF : (All (A) ((IntQue A) -> (Queue A))))
(define (checkF que)
  (let* ([front (IntQue-F que)]
         [mid (IntQue-M que)])
    (if (null? front) 
        (if (rtq:empty? mid) 
            empty
            (make-IntQue (force (rtq:head mid))
                        (rtq:tail mid)
                        (IntQue-LenFM que)
                        (IntQue-R que)
                        (IntQue-LenR que)))
        que)))


(: qmap : (All (A C B ...) 
               ((A B ... B -> C) (Queue A) (Queue B) ... B -> (Queue C))))
(define (qmap func que . ques)
  (: in-map : (All (A C B ...) 
                   ((Queue C) (A B ... B -> C) (Queue A) (Queue B) ... B -> 
                              (Queue C))))
  (define (in-map accum func que . ques)
    (if (or (empty? que) (ormap empty? ques))
        accum
        (apply in-map 
               (enqueue (apply func (head que) (map head ques)) accum)
               func 
               (tail que)
               (map tail ques))))
  (apply in-map empty func que ques))


(: fold : (All (A C B ...)
               ((C A B ... B -> C) C (Queue A) (Queue B) ... B -> C)))
(define (fold func base que . ques)
  (if (or (empty? que) (ormap empty? ques))
        base
        (apply fold 
               func 
               (apply func base (head que) (map head ques))
               (tail que)
               (map tail ques))))

(: queue->list : (All (A) ((Queue A) -> (Listof A))))
(define (queue->list bsq)
  (if (EmptyBSQueue? bsq)
      null
      (cons (head bsq) (queue->list (tail bsq))))) 

(: queue : (All (A) (A * -> (Queue A))))
(define (queue . lst)
  (foldl (inst enqueue A) empty lst))
