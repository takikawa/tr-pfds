#lang typed/racket

(require (prefix-in sh: scheme/base))

(provide filter remove List reverse
         empty empty? list-length cons head tail 
         (rename-out [first* first] [rest* rest] [list-map map] 
                     [list-foldr foldr] [list-foldl foldl]) 
         list-ref list-set drop ->list list
         (rename-out [list-ormap ormap] [list-andmap andmap]
                     [list-second second] [list-third third] 
                     [list-fourth fourth] [list-fifth fifth] 
                     [list-sixth sixth] [list-seventh seventh] 
                     [list-eighth eighth] [list-ninth ninth] 
                     [list-tenth tenth] [list-last last]
                     [list-length length]) build-list make-list)

(struct: (A) Leaf ([first : A]))

(struct: (A) Node ([first : A]
                   [left : (Tree A)] 
                   [right : (Tree A)]))

(define-type (Tree A) (U (Leaf A) (Node A)))

(struct: (A) Root ([size : Integer]
                   [first  : (Tree A)]
                   [rst  : (RAList A)]))

(define-type (RAList A) (U Null (Root A)))
(define-type (List A) (RAList A))

(define empty-tree (Leaf null))


;; An empty list
(define empty null)

;; Checks for empty list
(: empty? : (All (A) ((RAList A) -> Boolean)))
(define (empty? list)
  (null? list))

;; Returns the length of the list
(: list-length : (All (A) ((RAList A) -> Integer)))
(define (list-length list)
  (if (null? list) 0 (+ (Root-size list) (list-length (Root-rst list)))))

;; Similar to list cons function
(: cons : (All (A) (A (RAList A) -> (RAList A))))
(define (cons elem list)
  (if (null? list) 
      (Root 1 (Leaf elem) list)
      (let* ([rst (Root-rst list)]
             [lsize (list-length list)]
             [rst-size (list-length rst)])
        (if (eq? lsize rst-size)
            (Root (+ 1 lsize rst-size)
                  (Node elem (Root-first list) (first rst))
                  (rest rst))
            (Root 1 (Leaf elem) list)))))

;; Helper for cons
(: first : (All (A) ((RAList A) -> (Tree A))))
(define (first list )
  (if (null? list)
      (error 'cons "given list is empty") ;; Should never come
      (Root-first list)))

;; Helper for cons
(: rest : (All (A) ((RAList A) -> (RAList A))))
(define (rest list)
  (if (null? list)
      (error 'cons "given list is empty") ;; Should never come here
      (Root-rst list)))

;; Similar to list car function
(: head : (All (A) ((RAList A) -> A)))
(define (head list)
  (if (null? list) 
      (error 'head "given list is empty")
      (let ([first (Root-first list)])
        (if (Leaf? first) 
            (Leaf-first first)
            (Node-first first)))))

;; Similar to list cdr function
(: tail : (All (A) ((RAList A) -> (RAList A))))
(define (tail list)
  (if (null? list) 
      (error 'tail "given list is empty")
      (let ([first (Root-first list)]
            [rst (Root-rst list)]
            [size (arithmetic-shift (Root-size list) -1)])
        (if (Leaf? first) 
            rst 
            (Root size (Node-left first) (Root size (Node-right first) rst))))))


;; Helpers for list-ref
(: tree-lookup : (All (A) (Integer (Tree A) Integer -> A)))
(define (tree-lookup size tre pos)
  (let ([pos-zero? (zero? pos)])
    (cond 
      [(and (Leaf? tre) pos-zero?) (Leaf-first tre)]
      [(Node? tre) (tree-lookup-help size tre pos pos-zero?)]
      [else (error 'list-ref "given index out of bound")])))

(: tree-lookup-help : (All (A) (Integer (Node A) Integer Boolean -> A)))
(define (tree-lookup-help size tre pos pos-zero?)
  (let ([newsize (arithmetic-shift size -1)])
    (cond
      [pos-zero? (Node-first tre)]
      [(<= pos newsize) (tree-lookup newsize (Node-left tre) (- pos 1))]
      [else (tree-lookup newsize (Node-right tre) (- pos 1 newsize))])))

;; Helpers for list-set
(: tree-update : (All (A) (Integer (Tree A) Integer A -> (Tree A))))
(define (tree-update size tre pos elem)
  (let ([newsize (arithmetic-shift size -1)]
        [pos-zero? (zero? pos)])
    (cond
      [(and (Leaf? tre) pos-zero?) (Leaf elem)]
      [(Node? tre) (tree-update-helper newsize tre pos elem pos-zero?)]
      [else (error 'list-set "given index out of bound")])))

(: tree-update-helper : 
   (All (A) (Integer (Node A) Integer A Boolean -> (Tree A))))
(define (tree-update-helper newsize tre pos elem pos-zero?)
  (let ([left (Node-left tre)]
        [right (Node-right tre)]
        [first (Node-first tre)])
    (cond
      [(eq? pos 0) (Node elem left right)]
      [(<= pos newsize)
       (Node first (tree-update newsize left (- pos 1) elem) right)]
      [else (Node first left 
                  (tree-update newsize right (- pos 1 newsize) elem))])))

;; Similar to list list-ref function
(: list-ref : (All (A) ((RAList A) Integer -> A)))
(define (list-ref list pos)
  (if (null? list) 
      (error 'list-ref "given index out of bound")
      (let ([size (Root-size list)])
        (if (< pos size) 
            (tree-lookup size (Root-first list) pos)
            (list-ref (Root-rst list) (- pos size))))))

;; Similar to list list-set function
(: list-set : (All (A) ((RAList A) Integer A -> (RAList A))))
(define (list-set list pos elem)
  (if (null? list) 
      (error 'list-set "given index out of bound")
      (let ([size (Root-size list)]
            [first (Root-first list)]
            [rst (Root-rst list)])
        (if (< pos size)
            (Root size (tree-update size first pos elem) rst)
            (Root size first (list-set rst (- pos size) elem))))))

;; Helpers for drop
(: tree-drop : (All (A) (Integer (Tree A) Integer (RAList A) -> (RAList A))))
(define (tree-drop size tre pos list)
  (cond 
    [(zero? pos) (Root size tre list)]
    [(and (Leaf? tre) (= pos 1)) list]
    [(Node? tre) (tree-drop-help size tre pos list)]
    [else (error 'drop "not enough elements to drop")]))

(: tree-drop-help : 
   (All (A) (Integer (Node A) Integer (RAList A) -> (RAList A))))
(define (tree-drop-help size tre pos list)
  (let ([newsize (arithmetic-shift size -1)]
        [left (Node-left tre)]
        [right (Node-right tre)])
    (if (<= pos newsize)
        (tree-drop newsize left (sub1 pos) 
                   (Root newsize right list))
        (tree-drop newsize right (- pos 1 newsize) list))))

;; Similar to list drop function
(: drop : (All (A) (Integer (RAList A) -> (RAList A))))
(define (drop pos list)
  (cond
    [(zero? pos) list]
    [(Root? list) (drop-help list pos)]
    [else (error 'drop "not enough elements to drop")]))

(: drop-help : (All (A) ((Root A) Integer -> (RAList A))))
(define (drop-help list pos)
  (let ([size (Root-size list)]
        [first (Root-first list)]
        [rst (Root-rst list)])
    (if (< pos size)
        (tree-drop size first pos rst)
        (drop (- pos size) rst))))

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
                            (apply list-map
                                   func 
                                   (tail list)
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
                      (func (list-foldr func base (tail list)) (head list)))]
                 [([func : (C A B ... B -> C)]
                   [base : C]
                   [list  : (List A)] . [lists : (List B) ... B])
                  (if (or (empty? list) (ormap empty? lists))
                      base
                      (apply func (apply list-foldr 
                                         func 
                                         base
                                         (tail list)
                                         (map tail lists))
                             (head list)
                             (map head lists)))]))

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
                      (apply list-foldl 
                             func 
                             (apply func base (head list) (map head lists))
                             (tail list)
                             (map tail lists)))]))

;; Convers the random access list to normal list
(: ->list : (All (A) ((RAList A) -> (Listof A))))
(define (->list list)
  (if (empty? list)
      null
      (sh:cons (head list) (->list (tail list)))))

;; list constructor
(: list : (All (A) (A * -> (RAList A))))
(define (list . rst)
  (foldr (inst cons A) empty rst))

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