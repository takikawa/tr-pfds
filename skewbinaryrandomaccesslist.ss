#lang typed/racket #:optimize
(require (prefix-in sh: scheme/base))
(provide filter remove reverse
         list ->list empty? cons empty head tail
         (rename-out [first* first] [rest* rest] [list-map map] 
                     [list-foldr foldr] [list-foldl foldl]
                     [list-ormap ormap] [list-andmap andmap]
                     [list-second second] [list-third third] 
                     [list-fourth fourth] [list-fifth fifth] 
                     [list-sixth sixth] [list-seventh seventh] 
                     [list-eighth eighth] [list-ninth ninth] 
                     [list-tenth tenth] [list-last last]
                     [list-length length]) build-list make-list
         list-ref list-set drop List)

(struct: (A) Leaf ([fst : A]))
(struct: (A) Node ([fst : A]
                   [lft : (Tree A)] 
                   [rgt : (Tree A)]))
(define-type (Tree A) (U (Leaf A) (Node A)))
(struct: (A) Root ([weight : Integer]
                   [fst  : (Tree A)]))

(define-type (List A) (Listof (Root A)))

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
      (sh:cons (Root 1 (Leaf elem)) sralist)
      (let ([wgt1 (getWeight (car sralist))]
            [wgt2 (getWeight (car (cdr sralist)))])
        (if (eq? wgt1 wgt2)
            (sh:cons (Root (+ 1 wgt1 wgt2) 
                           (Node elem 
                                 (Root-fst (car sralist)) 
                                 (Root-fst (car (cdr sralist)))))
                     (cdr (cdr sralist)))
            (sh:cons (Root 1 (Leaf elem)) sralist)))))

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
            (list* (Root wgt (Node-lft fst))
                   (Root wgt (Node-rgt fst))
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
      [(and (Leaf? tre) pos0?) (Leaf elem)]
      [(Node? tre) (tu-help new-wgt tre pos pos0? elem)]
      [else (error 'list-set "given index out of bounds")])))


(: tu-help : (All (A) (Integer (Node A) Integer Boolean A -> (Tree A))))
(define (tu-help new-wgt tre pos pos0? elem)
  (let ([lft (Node-lft tre)]
        [rgt (Node-rgt tre)]
        [fst (Node-fst tre)])
    (cond
      [pos0? (Node elem lft rgt)]
      [(<= pos new-wgt) (Node fst 
                              (tree-update new-wgt lft (sub1 pos) elem)
                              rgt)]
      [else (Node fst lft (tree-update new-wgt rgt 
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
     (sh:cons (Root (getWeight (car sralist)) 
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
      [(zero? pos) (sh:cons (Root size tre) ralist)]
      [(and (Leaf? tre) (= pos 1)) ralist]
      [(and (Node? tre) (<= pos newsize)) 
       (tree-drop newsize 
                  (Node-lft tre) (- pos 1) 
                  (sh:cons (Root newsize (Node-rgt tre)) ralist))]
      [(and (Node? tre) (> pos newsize)) 
       (tree-drop newsize 
                  (Node-rgt tre) (- pos 1 newsize) 
                  ralist)]
      [else (error 'drop "not enough elements to drop")])))

;; Similar to list drop function
(: drop : (All (A) (Integer (List A) -> (List A))))
(define (drop pos ralist)
  (cond
    [(zero? pos) ralist]
    [(null? ralist) (error 'drop "not enough elements to drop")]
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


;; similar to list map function. apply is expensive so using case-lambda
;; in order to saperate the more common case
(: list-map : 
   (All (A C B ...) 
        (case-lambda 
          ((A -> C) (List A) -> (List C))
          ((A B ... B -> C) (List A) (List B) ... B -> (List C)))))
(define list-map
  (pcase-lambda: (A C B ...)
                 [([func : (A -> C)]
                   [list  : (List A)])
                  (if (empty? list)
                      empty
                      (cons (func (head list)) (list-map func (tail list))))]
                 [([func : (A B ... B -> C)]
                   [list  : (List A)] . [lists : (List B) ... B])
                  (if (or (empty? list) (ormap empty? lists))
                      empty
                      (cons (apply func (head list) (map head lists))
                            (apply list-map func (tail list)
                                   (map tail lists))))]))


;; Similar to list foldr function. apply is expensive so using case-lambda
;; in order to saperate the more common case
(: list-foldr : 
   (All (A C B ...) 
        (case-lambda ((C A -> C) C (List A) -> C)
                     ((C A B ... B -> C) C (List A) (List B) ... B -> C))))
(define list-foldr
  (pcase-lambda: (A C B ...) 
                 [([func : (C A -> C)]
                   [base : C]
                   [list  : (List A)])
                  (if (empty? list)
                      base
                      (func (list-foldr func base (tail list))
                            (head list)))]
                 [([func : (C A B ... B -> C)]
                   [base : C]
                   [list  : (List A)] . [lists : (List B) ... B])
                  (if (or (empty? list) (ormap empty? lists))
                      base
                      (apply func (apply list-foldr func base (tail list)
                                         (map tail lists))
                             (head list) (map head lists)))]))

;; similar to list foldl function
(: list-foldl : 
   (All (A C B ...) 
        (case-lambda ((C A -> C) C (List A) -> C)
                     ((C A B ... B -> C) C (List A) (List B) ... B -> C))))
(define list-foldl
  (pcase-lambda: (A C B ...) 
                 [([func : (C A -> C)]
                   [base : C]
                   [list  : (List A)])
                  (if (empty? list)
                      base
                      (list-foldl func (func base (head list)) (tail list)))]
                 [([func : (C A B ... B -> C)]
                   [base : C]
                   [list  : (List A)] . [lists : (List B) ... B])
                  (if (or (empty? list) (ormap empty? lists))
                      base
                      (apply list-foldl func
                             (apply func base (head list) (map head lists))
                             (tail list) (map tail lists)))]))

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

;; Similar to list filter function
(: remove : (All (A) ((A -> Boolean) (List A) -> (List A))))
(define (remove func ral)
  (if (empty? ral)
      empty
      (let ([head (head ral)]
            [tail (tail ral)])
        (if (func head)
            (remove func tail)
            (cons head (remove func tail))))))

;; Similar to list reverse function
(: reverse : (All (A) ((List A) -> (List A))))
(define (reverse ral)
  (: local-reverse : (All (A) ((List A) (List A) -> (List A))))
  (define (local-reverse ral accum)
    (if (empty? ral)
        accum
        (local-reverse (tail ral) (cons (head ral) accum))))
  (local-reverse ral empty))

;; Similar to build-list function of racket list
(: build-list : (All (A) (Natural (Natural -> A) -> (List A))))
(define (build-list size func)
  (let: loop : (List A) ([n : Natural size] [accum : (List A) empty])
        (if (zero? n)
            accum 
            (loop (sub1 n) (cons (func (sub1 n)) accum)))))

;; Similar to make-list function of racket list
(: make-list : (All (A) (Natural A -> (List A))))
(define (make-list size elem)
  (let: loop : (List A) ([n : Natural size] [accum : (List A) empty])
        (if (zero? n)
            accum 
            (loop (sub1 n) (cons elem accum)))))


;; similar to list andmap function
(: list-andmap : 
   (All (A B ...) 
        (case-lambda ((A -> Boolean) (List A) -> Boolean)
                     ((A B ... B -> Boolean) (List A) (List B) ... B -> Boolean))))
(define list-andmap
  (pcase-lambda: (A B ... ) 
                 [([func : (A -> Boolean)]
                   [list  : (List A)])
                  (or (empty? list)
                      (and (func (head list))
                           (list-andmap func (tail list))))]
                 [([func : (A B ... B -> Boolean)]
                   [list  : (List A)] . [lists : (List B) ... B])
                  (or (empty? list) (ormap empty? lists)
                      (and (apply func (head list) (map head lists))
                           (apply list-andmap func (tail list) 
                                  (map tail lists))))]))


;; similar to list ormap function
(: list-ormap : 
   (All (A B ...) 
        (case-lambda ((A -> Boolean) (List A) -> Boolean)
                     ((A B ... B -> Boolean) (List A) (List B) ... B -> Boolean))))
(define list-ormap
  (pcase-lambda: (A B ... ) 
                 [([func : (A -> Boolean)]
                   [list  : (List A)])
                  (and (not (empty? list))
                       (or (func (head list))
                           (list-ormap func (tail list))))]
                 [([func : (A B ... B -> Boolean)]
                   [list  : (List A)] . [lists : (List B) ... B])
                  (and (not (or (empty? list) (ormap empty? lists)))
                       (or (apply func (head list) (map head lists))
                           (apply list-ormap func (tail list) 
                                  (map tail lists))))]))



(: list-second : (All (A) (List A) -> A))
(define (list-second ls) (list-ref ls 1))

(: list-third : (All (A) (List A) -> A))
(define (list-third ls) (list-ref ls 2))

(: list-fourth : (All (A) (List A) -> A))
(define (list-fourth ls) (list-ref ls 3))

(: list-fifth : (All (A) (List A) -> A))
(define (list-fifth ls) (list-ref ls 4))

(: list-sixth : (All (A) (List A) -> A))
(define (list-sixth ls) (list-ref ls 5))

(: list-seventh : (All (A) (List A) -> A))
(define (list-seventh ls) (list-ref ls 6))

(: list-eighth : (All (A) (List A) -> A))
(define (list-eighth ls) (list-ref ls 7))

(: list-ninth : (All (A) (List A) -> A))
(define (list-ninth ls) (list-ref ls 8))

(: list-tenth : (All (A) (List A) -> A))
(define (list-tenth ls) (list-ref ls 9))

(: list-last : (All (A) (List A) -> A))
(define (list-last ls) (list-ref ls (sub1 (list-length ls))))