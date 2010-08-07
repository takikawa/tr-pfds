#lang typed/scheme
(require (prefix-in sh: scheme/base))
(provide filter remove
         list ->list empty? cons empty head tail
         (rename-out [first* first] [rest* rest] [ramap map] 
                     [rafoldr foldr] [rafoldl foldl]) 
         list-ref list-set drop list-length List)

(define-struct: (A) Leaf ([fst : A]))
(define-struct: (A) Node ([fst : A]
                          [lft : (Tree A)] 
                          [rgt : (Tree A)]))
(define-type-alias Tree (All (A) (U (Leaf A) (Node A))))
(define-struct: (A) Root ([weight : Integer]
                          [fst  : (Tree A)]))

(define-type-alias List (All (A) (Listof (Root A))))

;; An empty list
(define empty null)

;; Checks for empty
(: empty? : (All (A) ((List A) -> Boolean)))
(define (empty? sralist)
  (null? sralist))

;; Helper to get the weight of the root
(: getWeight : (All (A) ((Root A) -> Integer)))
(define (getWeight root)
  (Root-weight root))

;; Similar to list cons function
(: cons  : (All (A) (A (List A) -> (List A))))
(define (cons  elem sralist)
  (if (or (null? sralist) (null? (cdr sralist)))
      (sh:cons (make-Root 1 (make-Leaf elem)) sralist)
      (let ([wgt1 (getWeight (car sralist))]
            [wgt2 (getWeight (car (cdr sralist)))])
        (if (eq? wgt1 wgt2)
            (sh:cons (make-Root (+ 1 wgt1 wgt2) 
                             (make-Node elem 
                                        (Root-fst (car sralist)) 
                                        (Root-fst (car (cdr sralist)))))
                  (cdr (cdr sralist)))
            (sh:cons (make-Root 1 (make-Leaf elem)) sralist)))))

;; Similar to list car function
(: head : (All (A) ((List A) -> A)))
(define (head sralist)
  (if (null? sralist) 
      (error 'head "given list is empty")
      (let ([fst (Root-fst (car sralist))])
        (if (Leaf? fst) 
            (Leaf-fst fst)
            (Node-fst fst)))))

;; Similar to list cdr function
(: tail : (All (A) ((List A) -> (List A))))
(define (tail sralist)
  (if (null? sralist)
      (error 'tail "given list is empty")
      (let* ([fst (Root-fst (car sralist))]
             [wgt (arithmetic-shift (getWeight (car sralist)) -1)])
        (if (Leaf? fst) 
            (cdr sralist) 
            (list* (make-Root wgt (Node-lft fst))
                   (make-Root wgt (Node-rgt fst))
                   (cdr sralist))))))

;; Helper for list-ref
(: tree-lookup : (All (A) (Integer (Tree A) Integer -> A)))
(define (tree-lookup wgt tre pos)
  (let ([new-wgt (arithmetic-shift wgt -1)]
        [pos0? (zero? pos)])
    (cond
      [(and (Leaf? tre) pos0?) (Leaf-fst tre)]
      [(Node? tre) (tl-help new-wgt tre pos pos0?)]
      [else (error 'list-ref "given index out of bounds")])))


(: tl-help : (All (A) (Integer (Node A) Integer Boolean -> A)))
(define (tl-help new-wgt tre pos pos0?)
  (cond
    [pos0? (Node-fst tre)]
    [(<= pos new-wgt)
     (tree-lookup new-wgt (Node-lft tre) (sub1 pos))]
    [else (tree-lookup new-wgt (Node-rgt tre) (- pos 1 new-wgt))]))

;; Helper for list-set
(: tree-update : (All (A) (Integer (Tree A) Integer A -> (Tree A))))
(define (tree-update wgt tre pos elem)
  (let ([new-wgt (arithmetic-shift wgt -1)]
        [pos0? (zero? pos)])
    (cond
      [(and (Leaf? tre) pos0?) (make-Leaf elem)]
      [(Node? tre) (tu-help new-wgt tre pos pos0? elem)]
      [else (error 'list-set "given index out of bounds")])))


(: tu-help : (All (A) (Integer (Node A) Integer Boolean A -> (Tree A))))
(define (tu-help new-wgt tre pos pos0? elem)
  (let ([lft (Node-lft tre)]
        [rgt (Node-rgt tre)]
        [fst (Node-fst tre)])
    (cond
      [pos0? (make-Node elem lft rgt)]
      [(<= pos new-wgt) (make-Node fst 
                                   (tree-update new-wgt lft (sub1 pos) elem)
                                   rgt)]
      [else (make-Node fst lft (tree-update new-wgt rgt 
                                            (- pos 1 new-wgt) elem))])))

;; Similar to list list-ref function
(: list-ref : (All (A) ((List A) Integer -> A)))
(define (list-ref sralist pos)
  (cond
    [(null? sralist) (error 'list-ref "given index out of bounds")]
    [(< pos (getWeight (car sralist)))
     (tree-lookup (getWeight (car sralist)) (Root-fst (car sralist)) pos)]
    [else (list-ref (cdr sralist) (- pos (getWeight (car sralist))))]))

;; Similar to list list-set function
(: list-set : (All (A) ((List A) Integer A -> (List A))))
(define (list-set sralist pos elem)
  (cond
    [(null? sralist) (error 'list-set "given index out of bounds")]
    [(< pos (getWeight (car sralist)))
     (sh:cons (make-Root (getWeight (car sralist)) 
                         (tree-update (getWeight (car sralist))
                                      (Root-fst (car sralist)) pos elem)) 
           (cdr sralist))]
    [else (sh:cons (car sralist)
                   (list-set (cdr sralist)
                             (- pos (getWeight (car sralist)))
                             elem))]))

;; Helper for drop
(: tree-drop : (All (A) (Integer (Tree A) Integer (List A) -> (List A))))
(define (tree-drop size tre pos ralist)
  (let ([newsize (arithmetic-shift size -1)])
    (cond 
      [(zero? pos) (sh:cons (make-Root size tre) ralist)]
      [(and (Leaf? tre) (= pos 1)) ralist]
      [(and (Node? tre) (<= pos newsize)) 
       (tree-drop newsize 
                  (Node-lft tre) (- pos 1) 
                  (sh:cons (make-Root newsize (Node-rgt tre)) ralist))]
      [(and (Node? tre) (> pos newsize)) 
       (tree-drop newsize 
                  (Node-rgt tre) (- pos 1 newsize) 
                  ralist)]
      [else (error 'drop "given index out of bounds")])))

;; Similar to list drop function
(: drop : (All (A) (Integer (List A) -> (List A))))
(define (drop pos ralist)
  (cond
    [(zero? pos) ralist]
    [(null? ralist) (error 'drop "given index out of bounds")]
    [else (drop-helper (car ralist) (cdr ralist) pos)]))

(: drop-helper : (All (A) ((Root A) (List A) Integer -> (List A))))
(define (drop-helper root rest pos)
  (let ([size (Root-weight root)]
        [tree (Root-fst root)])
  (if (< pos size)
      (tree-drop size tree pos rest)
      (drop (- pos size) rest))))

;; Similar to list length function
(: list-length : (All (A) ((List A) -> Integer)))
(define (list-length ralist)
  (foldl + 0 (map (inst getWeight A) ralist)))

;; Similar to list map function
(: ramap : (All (A C B ...) 
                ((A B ... B -> C) (List A) (List B) ... B -> (List C))))
(define (ramap func lst . lsts)
  (if (or (empty? lst) (ormap empty? lsts))
      empty
      (cons (apply func (head lst) (map head lsts))
            (apply ramap 
                   func 
                   (tail lst)
                   (map tail lsts)))))

;; Similar to list foldr function
(: rafoldr : (All (A C B ...)
                  ((C A B ... B -> C) C (List A) (List B) ... B -> C)))
(define (rafoldr func base lst . lsts)
  (if (or (empty? lst) (ormap empty? lsts))
      base
      (apply func (apply rafoldr 
                         func 
                         base
                         (tail lst)
                         (map tail lsts)) (head lst) (map head lsts))))

;; Similar to list foldl function
(: rafoldl : (All (A C B ...)
                  ((C A B ... B -> C) C (List A) (List B) ... B -> C)))
(define (rafoldl func base lst . lsts)
  (if (or (empty? lst) (ormap empty? lsts))
        base
        (apply rafoldl 
               func 
               (apply func base (head lst) (map head lsts))
               (tail lst)
               (map tail lsts))))

;; RAList to normal list
(: ->list : (All (A) ((List A) -> (Listof A))))
(define (->list ralist)
  (if (empty? ralist)
      null
      (sh:cons (head ralist) (->list (tail ralist)))))

;; list constructor
(: list : (All (A) (A * -> (List A))))
(define (list . lst)
  (foldr (inst cons  A) null lst))

(define first* head)
(define rest* tail)

;; Similar to list filter function
(: filter : (All (A) ((A -> Boolean) (List A) -> (List A))))
(define (filter func ral)
  (if (empty? ral)
    empty
    (let ([head (head ral)]
          [tail (tail ral)])
      (if (func head)
        (cons head (filter func tail))
        (filter func tail)))))

;; Similar to list remove function
(: remove : (All (A) ((A -> Boolean) (List A) -> (List A))))
(define (remove func ral)
  (if (empty? ral)
    empty
    (let ([head (head ral)]
          [tail (tail ral)])
      (if (func head)
        (remove func tail)
        (cons head (remove func tail))))))
