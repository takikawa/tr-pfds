#lang typed-scheme

(provide empty empty? head tail last init deque->rev-list
         enqueue-front enqueue deque->list deque)

(require scheme/promise scheme/match)

(define-struct: Zero ())
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
                          [M : (Promise (Pair (Deque A) (Deque A)))]
                          [R : (D A)]))

(define-type-alias Deque (All (A) (U (Shallow A) (Deep A))))

(define empty (make-Shallow (make-Zero)))

(: empty? : (All (A) ((Deque A) -> Boolean)))
(define (empty? que)
  (and (Shallow? que) (Zero? (Shallow-elem que))))

(: enqueue-front : (All (A) (A (Deque A) -> (Deque A))))
(define (enqueue-front elem que)
  (match que    
    [(struct Shallow ((struct Zero ()))) (make-Shallow (make-One elem))]
    [(struct Shallow ((struct One (a)))) (make-Shallow (make-Two elem a))]
    [(struct Shallow ((struct Two (a b)))) 
     (make-Shallow (make-Three elem a b))]
    [(struct Shallow ((struct Three (f s t))))
     (make-Deep (make-Two elem f) (delay (cons empty empty)) (make-Two s t))]
    [(struct Deep ((struct Zero ()) m r)) (make-Deep (make-One elem) m r)]
    [(struct Deep ((struct One (a)) m r)) (make-Deep (make-Two elem a) m r)]
    [(struct Deep ((struct Two (a b)) m r)) 
     (make-Deep (make-Three elem a b) m r)]
    [(struct Deep ((struct Three (f s t)) m r)) 
     (let* ([forced-mid (force m)]
            [fst (car forced-mid)]
            [snd (cdr forced-mid)])
          (make-Deep (make-Two elem f) 
                     (delay (cons (enqueue-front s fst) (enqueue-front t snd)))
                     r))]))

(: enqueue : (All (A) (A (Deque A) -> (Deque A))))
(define (enqueue elem que)
  (match que    
    [(struct Shallow ((struct Zero ()))) (make-Shallow (make-One elem))]
    [(struct Shallow ((struct One (a)))) (make-Shallow (make-Two a elem))]
    [(struct Shallow ((struct Two (a b)))) 
     (make-Shallow (make-Three a b elem))]
    [(struct Shallow ((struct Three (f s t))))
     (make-Deep (make-Two f s) (delay (cons empty empty)) (make-Two t elem))]
    [(struct Deep (f m (struct Zero ()))) (make-Deep f m (make-One elem))]
    [(struct Deep (f m (struct One (a)))) (make-Deep f m (make-Two a elem))]
    [(struct Deep (f m (struct Two (a b)))) 
     (make-Deep f m (make-Three a b elem))]
    [(struct Deep (fi m (struct Three (f s t)))) 
     (let* ([forced-mid (force m)]
            [fst (car forced-mid)]
            [snd (cdr forced-mid)])
          (make-Deep fi
                     (delay (cons (enqueue f fst) (enqueue s snd)))
                     (make-Two t elem)))]))

(: head : (All (A) ((Deque A) -> A)))
(define (head que)
  (match que    
    [(struct Shallow ((struct Zero ()))) (error 'head "Given deque is empty")]
    [(struct Shallow ((struct One (f)))) f]
    [(struct Shallow ((struct Two (f s)))) f]
    [(struct Shallow ((struct Three (f s t)))) f]
    [(struct Deep ((struct Zero ()) m r)) (error 'head "Given deque is empty")]
    [(struct Deep ((struct One (f)) m r)) f]
    [(struct Deep ((struct Two (f s)) m r)) f]
    [(struct Deep ((struct Three (f s t)) m r)) f]))

(: last : (All (A) ((Deque A) -> A)))
(define (last que)
  (match que    
    [(struct Shallow ((struct Zero ()))) (error 'last "Given deque is empty")]
    [(struct Shallow ((struct One (f)))) f]
    [(struct Shallow ((struct Two (f s)))) s]
    [(struct Shallow ((struct Three (f s t)))) t]
    [(struct Deep (f m (struct Zero ()))) (error 'last "Given deque is empty")]
    [(struct Deep (fi m (struct One (f)))) f]
    [(struct Deep (fi m (struct Two (f s)))) s]
    [(struct Deep (fi m (struct Three (f s t)))) t]))


(: tail : (All (A) ((Deque A) -> (Deque A))))
(define (tail que)
  (match que    
    [(struct Shallow ((struct Zero ()))) (error 'tail "Given deque is empty")]
    [(struct Shallow ((struct One (_)))) (make-Shallow (make-Zero))]
    [(struct Shallow ((struct Two (_ s)))) (make-Shallow (make-One s))]
    [(struct Shallow ((struct Three (_ s t)))) (make-Shallow (make-Two s t))]
    [(struct Deep ((struct Zero ()) m r)) (error 'tail "Given deque is empty")]
    [(struct Deep ((struct One (_)) mid r)) 
     (let ([m (force mid)])
       (if (empty? (car m))
           (make-Shallow r)
           (let* ([carm (car m)]
                  [cdrm (cdr m)]
                  [fst (head carm)]
                  [snd (head cdrm)])
             (make-Deep (make-Two fst snd) 
                        (delay (cons (tail carm) (tail cdrm))) r))))]
    [(struct Deep ((struct Two (_ s)) m r)) (make-Deep (make-One s) m r)]
    [(struct Deep ((struct Three (_ s t)) m r)) 
     (make-Deep (make-Two s t) m r)]))


(: init : (All (A) ((Deque A) -> (Deque A))))
(define (init que)
  (match que
    [(struct Shallow ((struct Zero ()))) (error 'init "Given deque is empty")]
    [(struct Shallow ((struct One (f)))) (make-Shallow (make-Zero))]
    [(struct Shallow ((struct Two (f _)))) 
     (make-Shallow (make-One f))]
    [(struct Shallow ((struct Three (f s _)))) (make-Shallow (make-Two f s))]
    [(struct Deep (f m (struct Zero ()))) (error 'init "Given deque is empty")]
    [(struct Deep (f mid (struct One (a))))
     (let* ([m (force mid)]
            [carm (car m)])
       (if (empty? carm)
           (make-Shallow f)
           (let* ([cdrm (cdr m)]
                  [fst (last carm)]
                  [snd (last cdrm)])
             (make-Deep f (delay (cons (init carm) (init cdrm))) 
                        (make-Two fst snd)))))]
    [(struct Deep (fi m (struct Two (f _)))) (make-Deep fi m (make-One f))]
    [(struct Deep (fi m (struct Three (f s t)))) 
     (make-Deep fi m (make-Two f s))]))


(: deque->list : (All (A) ((Deque A) -> (Listof A))))
(define (deque->list que)
  (if (empty? que)
      null
      (cons (head que) (deque->list (tail que)))))

(: deque->rev-list : (All (A) ((Deque A) -> (Listof A))))
(define (deque->rev-list que)
  (if (and (Shallow? que) (Zero? (Shallow-elem que)))
      null
      (cons (last que) (deque->rev-list (init que)))))

(: deque : (All (A) (A * -> (Deque A))))
(define (deque . lst)
  (foldl (inst enqueue A) empty lst))
