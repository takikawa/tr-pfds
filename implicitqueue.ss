#lang typed-scheme

(provide empty empty? enqueue head tail queue->list implicit-queue)
(require scheme/promise)

(define-struct: (A) Zero ([Null : Any]))
(define-struct: (A) One ([elem : A]))
(define-struct: (A) Two ([fst : A]
                         [snd : A]))
(define-type-alias ZeroOne (All (A) (U Zero (One A))))
(define-type-alias OneTwo (All (A) (U (One A) (Two A))))
(define-struct: (A) Shallow ([elem : (ZeroOne A)]))
(define-struct: (A) Deep ([F : (OneTwo A)]
                          [M : (Promise (Pair (ImplQueue A) (ImplQueue A)))]
                          [R : (ZeroOne A)]))

(define-type-alias ImplQueue (All (A) (U (Shallow A) (Deep A))))

(define empty (make-Shallow (make-Zero "")))

(: empty? : (All (A) ((ImplQueue A) -> Boolean)))
(define (empty? que)
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
        (make-Deep (make-Two (One-elem shelem) elem)
                   (delay (cons (make-Shallow (make-Zero ""))
                                (make-Shallow (make-Zero ""))))
                   (make-Zero "")))))

(: enqueueD : (All (A) (A (Deep A) -> (ImplQueue A))))
(define (enqueueD elem dpq)
  (let ([rear (Deep-R dpq)]
        [front (Deep-F dpq)]
        [mid (Deep-M dpq)])
    (if (Zero? rear)
        (make-Deep front mid (make-One elem))
        (let ([forced-mid (force mid)])
          (make-Deep (Deep-F dpq)
                     (delay (cons (enqueue (One-elem rear) (car forced-mid))
                                  (enqueue elem (cdr forced-mid))))
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
        (Two-fst front))))

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
       (make-Deep (make-One (Two-snd front)) (Deep-M dpq) (Deep-R dpq))]
      [else (tailD-helper dpq)])))

(: tailD-helper : (All (A) ((Deep A) -> (ImplQueue A))))
(define (tailD-helper dpq)
  (let* ([forced-mid (force (Deep-M dpq))]
         [carm (car forced-mid)]
         [cdrm (cdr forced-mid)])
    (cond
      [(empty? carm) (make-Shallow (Deep-R dpq))]
      [else (let ([fst (head carm)]
                  [snd (head cdrm)]
                  [new-mid (delay (cons (tail carm) (tail cdrm)))])
              (make-Deep (make-Two fst snd) new-mid (Deep-R dpq)))])))

(: queue->list : (All (A) ((ImplQueue A) -> (Listof A))))
(define (queue->list que)
  (if (and (Shallow? que) (Zero? (Shallow-elem que)))
      null
      (cons (head que) (queue->list (tail que)))))

(: implicit-queue : (All (A) ((Listof A) -> (ImplQueue A))))
(define (implicit-queue lst)
  (foldl (inst enqueue A) (make-Shallow (make-Zero "")) lst))