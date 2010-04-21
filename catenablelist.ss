#lang typed-scheme

(provide clist empty? clist->list head tail CatenableList
         append kons kons-rear empty)
(require scheme/promise)

(require (prefix-in rtq: "realtimequeue.ss"))

(define-struct: EmptyList ())

(define-struct: (A) List ([elem : A]
                          [ques : (rtq:Queue (Promise (List A)))]))

(define-type-alias CatenableList (All (A) (U (List A) EmptyList)))

(define empty (make-EmptyList))

(: empty? : (All (A) ((CatenableList A) -> Boolean)))
(define (empty? cat)
  (EmptyList? cat))


(: link : (All (A) ((List A) (Promise (List A)) -> (List A))))
(define (link lst cat)
  (make-List (List-elem lst) (rtq:enqueue cat (List-ques lst))))

(: link-all : (All (A) ((rtq:Queue (Promise (List A))) -> (List A))))
(define (link-all rtq)
  (let ([hd (force (rtq:head rtq))]
        [tl (rtq:tail rtq)])
    (if (rtq:empty? tl)
        hd
        (link hd (delay (link-all tl))))))

(: append : (All (A) ((CatenableList A) (CatenableList A) -> (CatenableList A))))
(define (append cat1 cat2)
  (cond
    [(EmptyList? cat1) cat2]
    [(EmptyList? cat2) cat1]
    [else (link cat1 (delay cat2))]))


(: kons : (All (A) (A (CatenableList A) -> (CatenableList A))))
(define (kons elem cat)
  (append (make-List elem rtq:empty) cat))

(: kons-rear : (All (A) (A (CatenableList A) -> (CatenableList A))))
(define (kons-rear elem cat)
  (append cat (make-List elem rtq:empty)))

(: head : (All (A) ((CatenableList A) -> A)))
(define (head cat)
  (if (EmptyList? cat)
      (error 'head "Given list is empty")
      (List-elem cat)))

(: tail : (All (A) ((CatenableList A) -> (CatenableList A))))
(define (tail cat)
  (if (EmptyList? cat) 
      (error 'tail "Given list is empty")
      (tail-helper cat)))

(: tail-helper : (All (A) ((List A) -> (CatenableList A))))
(define (tail-helper cat)
  (let ([ques (List-ques cat)])
    (if (rtq:empty? ques) 
        empty
        (link-all ques))))

(: clist : (All (A) (A * -> (CatenableList A))))
(define (clist . lst)
  (foldr (inst kons A) empty lst))

(: clist->list : (All (A) ((CatenableList A) -> (Listof A))))
(define (clist->list cat)
  (if (EmptyList? cat)
      null
      (cons (head cat) (clist->list (tail cat)))))
