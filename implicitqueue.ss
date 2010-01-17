#lang typed-scheme

(require scheme/promise)

(define-struct: Zero ([Null : Any]))
(define-struct: (A) One ([elem : A]))
(define-struct: (A) Two ([pair : (Pair A A)]))
(define-type-alias ZeroOne (All (A) (U Zero (One A))))
(define-type-alias OneTwo (All (A) (U (One A) (Two A))))
(define-struct: (A) Shallow ([elem : (ZeroOne A)]))
(define-struct: (A) Deep ([F : (OneTwo A)]
                          [M : (Promise (ImplQueue (Pair A A)))]
                          [R : (ZeroOne A)]))

(define-type-alias ImplQueue (All (A) (U (Shallow A) (Deep A))))

(define empty (make-Shallow (make-Zero "")))

(: isEmpty? : (All (A) ((ImplQueue A) -> Boolean)))
(define (isEmpty? que)
  (and (Shallow? que) (Zero? (Shallow-elem que))))

(: enqueue : (All (A) (A (ImplQueue A) -> (ImplQueue A))))
(define (enqueue elem que)
  (cond
    [(Shallow? que) (enqueueS elem que)]
    [else (enqueueD elem que)]))

(: enqueueS : (All (A) (A (Shallow A) -> (ImplQueue A))))
(define (enqueueS elem shq)
  (let ([shelem (Shallow-elem shq)])
    (if (Zero? shelem)
        (make-Shallow (make-One elem))
        (make-Deep (make-Two (cons (One-elem elem))
                             (delay (make-Shallow (make-Two null)))
                             (make-Zero ""))))))

(: enqueueD : (All (A) (A (Deep A) -> (ImplQueue A))))
(define (enqueueD elem dpq)
  (let ([rear (Deep-R dpq)])
    (if (Zero? rear)
        (make-Deep (make-Deep (Deep-F dpq) (Deep-M dpq) (make-One elem)))
        (make-Deep (make-Two (Deep-F dpq)
                             (delay (enqueue elem (Deep-M dpq)))
                             (make-Zero ""))))))


(: head : (All (A) ((ImplQueue A) -> A)))
(define (head que)
  (cond
    [(Shallow? que) (headS que)]
    [else (headD que)]))

(: headS : (All (A) ((Shallow A) -> A)))
(define (headS shq)
  (let ([elem (Shallow-elem shq)])
    (if (Zero? elem)
        (error "Queue is empty :" 'head)
        (One-elem elem))))

(: headD : (All (A) ((Deep A) -> A)))
(define (headD dpq)
  (let ([front (Deep-F dpq)])
    (if (One? front)
        (One-elem front)
        (car (Two-pair front)))))

(: tail : (All (A) ((ImplQueue A) -> (ImplQueue A))))
(define (tail que)
  (cond
    [(Shallow? que) (tailS que)]
    [else (tailD que)]))

(: tailS : (All (A) ((Shallow A) -> (ImplQueue A))))
(define (tailS shq)
  (let ([elem (Shallow-elem shq)])
    (if (Zero? elem)
        (error "Queue is empty :" 'tail)
        (make-Shallow (make-Zero "")))))

(: tailD : (All (A) ((Deep A) -> (ImplQueue A))))
(define (tailD dpq)
  (let ([front (Deep-F dpq)])
    (cond 
      [(Two? front) 
       (make-Deep (make-One (cdr (Two-pair front))) (Deep-M dpq) (Deep-R dpq))]
      [(isEmpty? (Deep-M dpq)) (make-Shallow (Deep-R dpq))]
      [else (let* ([que (force (Deep-M dpq))]
                   [hd (head que)]
                   [tl (delay (tail que))])
              (make-Deep (make-Two (car hd) (car hd)) tl (Deep-R dpq)))])))