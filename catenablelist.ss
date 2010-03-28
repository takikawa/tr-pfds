#lang typed-scheme

(provide catenable-list empty? clist->list head tail CatenableList
         merge kons kons-rear empty)
(require scheme/promise)

(require (prefix-in rtq: "realtimequeue.ss"))

(define-struct: EmptyList ())

(define-struct: (A) List ([elem : A]
                          [ques : (rtq:RealTimeQueue (Promise (List A)))]))

(define-type-alias CatenableList (All (A) (U (List A) EmptyList)))

(define empty (make-EmptyList))

(: empty? : (All (A) ((CatenableList A) -> Boolean)))
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

(: merge : (All (A) ((CatenableList A) (CatenableList A) -> (CatenableList A))))
(define (merge cat1 cat2)
  (cond
    [(EmptyList? cat1) cat2]
    [(EmptyList? cat2) cat1]
    [else (link cat1 (delay cat2))]))


(: kons : (All (A) (A (CatenableList A) -> (CatenableList A))))
(define (kons elem cat)
  (merge (make-List elem rtq:empty) cat))

(: kons-rear : (All (A) (A (CatenableList A) -> (CatenableList A))))
(define (kons-rear elem cat)
  (merge cat (make-List elem rtq:empty)))

(: head : (All (A) ((CatenableList A) -> A)))
(define (head cat)
  (if (EmptyList? cat)
      (error "List is empty :" 'head)
      (List-elem cat)))

(: tail : (All (A) ((CatenableList A) -> (CatenableList A))))
(define (tail cat)
  (if (EmptyList? cat) 
      (error "List is empty :" 'tail)
      (tail-helper cat)))

(: tail-helper : (All (A) ((List A) -> (CatenableList A))))
(define (tail-helper cat)
  (let ([ques (List-ques cat)])
    (if (rtq:empty? ques) 
        empty
        (link-all ques))))

(: catenable-list : (All (A) (A * -> (CatenableList A))))
(define (catenable-list . lst)
  (foldr (inst kons A) empty lst))

(: clist->list : (All (A) ((CatenableList A) -> (Listof A))))
(define (clist->list cat)
  (if (EmptyList? cat)
      null
      (cons (head cat) (clist->list (tail cat)))))