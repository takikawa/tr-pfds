#lang typed-scheme

(provide empty empty? head tail last init 
         enqueue snoc deque->list implicit-deque)

(require scheme/promise)

(define-struct: Zero ([Null : Any]))
(define-struct: (A) One ([elem : A]))
(define-struct: (A) Two ([fst : A] 
                         [snd : A]))
(define-struct: (A) Three ([fst : A] 
                           [snd : A]
                           [trd : A]))
(define-type-alias D (All (A) (U Zero (One A) (Two A) (Three A))))
(define-type-alias D1 (All (A) (U Zero (One A) (Two A))))
(define-struct: (A) Shallow ([elem : (D A)]))
(define-struct: (A) Deep ([F : (D A)]
                          [M : (Promise (Pair (ImplDeque A) (ImplDeque A)))]
                          [R : (D A)]))

(define-type-alias ImplDeque (All (A) (U (Shallow A) (Deep A))))

(define empty (make-Shallow (make-Zero "")))

(: empty? : (All (A) ((ImplDeque A) -> Boolean)))
(define (empty? que)
  (and (Shallow? que) (Zero? (Shallow-elem que))))

(: dcons :(All (A) (A (D1 A) -> (D A))))
(define (dcons elem d1)
  (cond
    [(Zero? d1) (make-One elem)]
    [(One? d1) (make-Two elem (One-elem d1))]
    [else (make-Three elem (Two-fst d1) (Two-snd d1))]))

(: dsnoc :(All (A) (A (D1 A) -> (D A))))
(define (dsnoc elem d1)
  (cond
    [(Zero? d1) (make-One elem)]
    [(One? d1) (make-Two (One-elem d1) elem)]
    [else (make-Three (Two-fst d1) (Two-snd d1) elem)]))

(: dhead :(All (A) ((D A) -> A)))
(define (dhead d)
  (cond
    [(Zero? d) (error "Queue is empty :" 'head)]
    [(One? d) (One-elem d)]
    [(Two? d) (Two-fst d)]
    [else (Three-fst d)]))

(: dlast :(All (A) ((D A) -> A)))
(define (dlast d)
  (cond
    [(Zero? d) (error "Queue is empty :" 'last)]
    [(One? d) (One-elem d)]
    [(Two? d) (Two-snd d)]
    [else (Three-trd d)]))

(: dtail :(All (A) ((D A) -> (D A))))
(define (dtail d)
  (cond
    [(Zero? d) (error "Queue is empty :" 'tail)]
    [(One? d) (make-Zero "")]
    [(Two? d) (make-One (Two-snd d))]
    [else (make-Two (Three-snd d) (Three-trd d))]))

(: dinit :(All (A) ((D A) -> (D A))))
(define (dinit d)
  (cond
    [(Zero? d) (error "Queue is empty :" 'init)]
    [(One? d) (make-Zero "")]
    [(Two? d) (make-One (Two-fst d))]
    [else (make-Two (Three-fst d) (Three-snd d))]))

(: enqueueS : (All (A) (A (Shallow A) -> (ImplDeque A))))
(define (enqueueS elem shq)
  (let ([d (Shallow-elem shq)])
    (if (Three? d) 
        (make-Deep (make-Two elem (Three-fst d)) 
                   (delay (cons empty empty)) 
                   (make-Two (Three-snd d) (Three-trd d)))
        (make-Shallow (dcons elem d)))))

(: enqueueD : (All (A) (A (Deep A) -> (ImplDeque A))))
(define (enqueueD elem dpq)
  (let ([d (Deep-F dpq)])
    (if (Three? d)
        (let* ([forced-mid (force (Deep-M dpq))]
               [fst (car forced-mid)]
               [snd (cdr forced-mid)])
          (make-Deep (make-Two elem (Three-fst d)) 
                     (delay (cons (enqueue (Three-snd d) fst) 
                                  (enqueue (Three-trd d) snd)))
                     (Deep-R dpq)))
        (make-Deep (dcons elem d) (Deep-M dpq) (Deep-R dpq)))))

(: enqueue : (All (A) (A (ImplDeque A) -> (ImplDeque A))))
(define (enqueue elem d)
  (cond
    [(Shallow? d) (enqueueS elem d)]
    [else (enqueueD elem d)]))


(: snocS : (All (A) (A (Shallow A) -> (ImplDeque A))))
(define (snocS elem shq)
  (let ([d (Shallow-elem shq)])
    (if (Three? d) 
        (make-Deep (make-Two (Three-fst d) (Three-snd d)) 
                   (delay (cons empty empty)) 
                   (make-Two (Three-trd d) elem))
        (make-Shallow (dsnoc elem d)))))

(: snocD : (All (A) (A (Deep A) -> (ImplDeque A))))
(define (snocD elem dpq)
  (let ([d (Deep-F dpq)])
    (if (Three? d)
        (let* ([forced-mid (force (Deep-M dpq))]
               [fst (car forced-mid)]
               [snd (cdr forced-mid)])
          (make-Deep (make-Two (Three-fst d) (Three-snd d)) 
                     (delay (cons (snoc (Three-trd d) fst) (snoc elem snd)))
                     (Deep-R dpq)))
        (make-Deep (dsnoc elem d) (Deep-M dpq) (Deep-R dpq)))))

(: snoc : (All (A) (A (ImplDeque A) -> (ImplDeque A))))
(define (snoc elem d)
  (if (Shallow? d) 
      (snocS elem d)
      (snocD elem d)))

(: head : (All (A) ((ImplDeque A) -> A)))
(define (head deque)
  (if (Shallow? deque)
      (dhead (Shallow-elem deque))
      (dhead (Deep-F deque))))

(: last : (All (A) ((ImplDeque A) -> A)))
(define (last deque)
  (if (Shallow? deque)
      (dlast (Shallow-elem deque))
      (dlast (Deep-R deque))))

(: tailOne : (All (A) ((Deep A) -> (ImplDeque A))))
(define (tailOne deque)
  (let ([m (force (Deep-M deque))]
        [r (Deep-R deque)])
    (if (empty? (car m))
        (make-Shallow r)
        (let* ([carm (car m)]
               [cdrm (cdr m)]
               [fst (head carm)]
               [snd (head cdrm)])
          (make-Deep (make-Two fst snd) 
                     (delay (cons (tail carm) (tail cdrm))) r)))))

(: tail : (All (A) ((ImplDeque A) -> (ImplDeque A))))
(define (tail deque)
  (cond
    [(Shallow? deque) (make-Shallow (dtail (Shallow-elem deque)))]
    [(One? (Deep-F deque)) (tailOne deque)]
    [else (make-Deep (dtail (Deep-F deque)) (Deep-M deque) (Deep-R deque))]))

(: initOne : (All (A) ((Deep A) -> (ImplDeque A))))
(define (initOne deque)
  (let* ([m (force (Deep-M deque))]
         [f (Deep-F deque)]
         [carm (car m)])
    (if (empty? carm)
        (make-Shallow f)
        (let* ([cdrm (cdr m)]
               [fst (head carm)]
               [snd (head cdrm)])
          (make-Deep f (delay (cons (init carm) (init cdrm))) 
                     (make-Two fst snd))))))

(: init : (All (A) ((ImplDeque A) -> (ImplDeque A))))
(define (init deque)
  (cond
    [(Shallow? deque) (make-Shallow (dinit (Shallow-elem deque)))]
    [(One? (Deep-R deque)) (initOne deque)]
    [else (make-Deep (Deep-F deque) (Deep-M deque) (dinit (Deep-R deque)))]))


(: deque->list : (All (A) ((ImplDeque A) -> (Listof A))))
(define (deque->list que)
  (if (empty? que)
      null
      (cons (last que) (deque->list (init que)))))


(: implicit-deque : (All (A) ((Listof A) -> (ImplDeque A))))
(define (implicit-deque lst)
  (foldl (inst enqueue A) (make-Shallow (make-Zero "")) lst))