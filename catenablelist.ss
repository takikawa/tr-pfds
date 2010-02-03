#lang typed-scheme
(require scheme/promise)
(require (prefix-in rtq: "realtimequeue.ss"))

(define-struct: EmptyList ())

(define-struct: (A) List ([elem : A]
                          [ques : (rtq:RealTimeQueue (Promise (List A)))]))

(define-type-alias Cat (All (A) (U (List A) EmptyList)))

(define empty (make-EmptyList))

(: empty? : (All (A) ((Cat A) -> Boolean)))
(define (empty? cat)
  (EmptyList? cat))


(: link : (All (A) ((List A) (Promise (List A)) -> (List A))))
(define (link lst cat)
  (make-List (List-elem lst) (rtq:enqueue cat (List-ques lst))))

(: link-all : (All (A) ((rtq:RealTimeQueue (Promise (List A))) -> (List A))))
(define (link-all rtq)
  (let ([hd (force (rtq:head rtq))]
        [tl (rtq:tail rtq)])
    (if (rtq:empty? tl)
        hd
        (link hd (delay (link-all tl))))))

(: merge : (All (A) ((Cat A) (Cat A) -> (Cat A))))
(define (merge cat1 cat2)
  (cond
    [(EmptyList? cat1) cat2]
    [(EmptyList? cat2) cat1]
    [else (link cat1 (delay cat2))]))


(: cl-cons : (All (A) (A (Cat A) -> (Cat A))))
(define (cl-cons elem cat)
  (merge (make-List elem rtq:empty) cat))

(: cl-snoc : (All (A) (A (Cat A) -> (Cat A))))
(define (cl-snoc elem cat)
  (merge cat (make-List elem rtq:empty)))

(: head : (All (A) ((Cat A) -> A)))
(define (head cat)
  (if (EmptyList? cat)
      (error "List is empty :" 'head)
      (List-elem cat)))

(: tail : (All (A) ((Cat A) -> (Cat A))))
(define (tail cat)
  (if (EmptyList? cat) 
      (error "List is empty :" 'tail)
      (tail-helper cat)))

(: tail-helper : (All (A) ((List A) -> (Cat A))))
(define (tail-helper cat)
  (let ([ques (List-ques cat)])
    (if (rtq:empty? ques) 
        empty
        (link-all ques))))

(: catenable-list : (All (A) ((Listof A) -> (Cat A))))
(define (catenable-list lst)
  (foldr (inst cl-cons A) empty lst))

(: clist->list : (All (A) ((Cat A) -> (Listof A))))
(define (clist->list cat)
  (if (EmptyList? cat)
      null
      (cons (head cat) (clist->list (tail cat)))))