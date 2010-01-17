#lang typed-scheme

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
                          [M : (Promise (ImplDeque (Pair A A)))]
                          [R : (D A)]))

(define-type-alias ImplDeque (All (A) (U (Shallow A) (Deep A))))

(define empty (make-Shallow (make-Zero "")))

(: isEmpty? : (All (A) ((ImplDeque A) -> Boolean)))
(define (isEmpty? que)
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
    [(Zero? d) (error "Queue is empty" 'head)]
    [(One? d) (One-elem d)]
    [(Two? d) (Two-fst d)]
    [else (Three-fst d)]))

(: dlast :(All (A) ((D A) -> A)))
(define (dlast d)
  (cond
    [(Zero? d) (error "Queue is empty" 'head)]
    [(One? d) (One-elem d)]
    [(Two? d) (Two-snd d)]
    [else (Three-trd d)]))

(: dtail :(All (A) ((D A) -> (D A))))
(define (dtail d)
  (cond
    [(Zero? d) (error "Queue is empty" 'head)]
    [(One? d) (make-Zero "")]
    [(Two? d) (make-One (Two-snd d))]
    [else (make-Two (Three-snd d) (Three-trd d))]))

(: dinit :(All (A) ((D A) -> (D A))))
(define (dinit d)
  (cond
    [(Zero? d) (error "Queue is empty" 'head)]
    [(One? d) (make-Zero "")]
    [(Two? d) (make-One (Two-fst d))]
    [else (make-Two (Three-fst d) (Three-snd d))]))

(: enqueueS : (All (A) (A (Shallow A) -> (D A))))
(define (enqueueS elem shq)
  (let ([d (Shallow-elem shq)])
    (if (Three? d) 
        (make-Deep (make-Two elem (Three-fst d)) 
                   (delay empty) 
                   (make-Two (Three-snd d) (Three-trd d)))
        (make-Shallow (dcons elem d)))))

(: enqueueD : (All (A) (A (Deep A) -> (D A))))
(define (enqueueD elem dpq)
  (let ([d (Deep-F dpq)])
    (if (Three? d) 
        (make-Deep (make-Two elem (Three-fst d)) 
                   (delay (enqueue (cons (Three-snd d) (Three-trd d))
                                   (force (Deep-M dpq)))) 
                   (Deep-R dpq))
        (make-Deep (dcons elem d) (Deep-M dpq) (Deep-R dpq)))))

(: enqueue : (All (A) (A (ImplDeque A) -> (D A))))
(define (enqueue elem d)
  (cond
    [(Shallow? d) (enqueueS elem d)]
    [else (enqueueD elem d)]))


(: snocS : (All (A) (A (Shallow A) -> (ImplDeque A))))
(define (snocS elem shq)
  (let ([d (Shallow-elem shq)])
    (if (Three? d) 
        (make-Deep (make-Two (Three-fst d) (Three-snd d)) 
                   (delay empty) 
                   (make-Two (Three-trd d) elem))
        (make-Shallow (dsnoc elem d)))))

(: snocD : (All (A) (A (Deep A) -> (ImplDeque A))))
(define (snocD elem dpq)
  (let ([d (Deep-F dpq)])
    (if (Three? d) 
        (make-Deep (make-Two (Three-fst d) (Three-snd d)) 
                   (delay (snoc (cons (Three-trd d) elem)
                                (force (Deep-M dpq)))) 
                   (Deep-R dpq))
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
    (if (isEmpty? m)
        (make-Shallow r)
        (let ([pair (head m)])
          (make-Deep (make-Two (car pair) (cdr pair)) 
                     (delay (tail m)) r)))))

(: tail : (All (A) ((ImplDeque A) -> (ImplDeque A))))
(define (tail deque)
  (cond
    [(Shallow? deque) (dtail (Shallow-elem deque))]
    [(One? (Deep-F deque)) (tailOne deque)]
    [else (make-Deep (dtail (Deep-F deque)) (Deep-M deque) (Deep-R deque))]))

(: initOne : (All (A) ((Deep A) -> (ImplDeque A))))
(define (initOne deque)
  (let ([m (force (Deep-M deque))]
        [f (Deep-F deque)])
    (if (isEmpty? m)
        (make-Shallow f)
        (let ([pair (last m)])
          (make-Deep f (delay (init m)) 
                     (make-Two (car pair) (cdr pair)))))))

(: init : (All (A) ((ImplDeque A) -> (ImplDeque A))))
(define (init deque)
  (cond
    [(Shallow? deque) (dinit (Shallow-elem deque))]
    [(One? (Deep-R deque)) (initOne deque)]
    [else (make-Deep (Deep-F deque) (Deep-M deque) (dinit (Deep-R deque)))]))