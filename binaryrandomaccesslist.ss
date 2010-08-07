#lang typed/scheme
(require (prefix-in sh: scheme/base))
(provide filter remove
         empty empty? list-length cons head tail 
         (rename-out [first* first] [rest* rest] [ramap map] 
                     [rafoldr foldr] [rafoldl foldl]) 
         list-ref list-set drop ->list list)

(define-struct: (A) Leaf ([fst : A]))
(define-struct: (A) Node ([fst : A]
                          [lft : (Tree A)] 
                          [rgt : (Tree A)]))
(define-type-alias Tree (All (A) (U (Leaf A) (Node A))))
(define-struct: (A) Root ([size : Integer]
                          [fst  : (Tree A)]
                          [rst  : (RAList A)]))

(define-type-alias RAList (All (A) (U Null-RaList (Root A))))
(define-type-alias List (All (A) (RAList A)))

(define empty-tree (make-Leaf null))

(define-struct: Null-RaList ())

;; An empty list
(define empty (make-Null-RaList))

(define One 1)
(define Zero 0)

;; Checks for empty list
(: empty? : (All (A) ((RAList A) -> Boolean)))
(define (empty? list)
  (Null-RaList? list))

;; Returns the length of the list
(: list-length : (All (A) ((RAList A) -> Integer)))
(define (list-length list)
  (if (Null-RaList? list)
      0
      (+ (Root-size list) (list-length (Root-rst list)))))

;; Similar to list cons function
(: cons : (All (A) (A (RAList A) -> (RAList A))))
(define (cons elem list)
  (if (Null-RaList? list) 
      (make-Root One (make-Leaf elem) list)
      (let* ([rst (Root-rst list)]
             [lsize (list-length list)]
             [rst-size (list-length rst)])
        (if (eq? lsize rst-size)
            (make-Root (+ One lsize rst-size)
                       (make-Node elem (Root-fst list) (first rst))
                       (rest rst))
            (make-Root One (make-Leaf elem) list)))))

;; Helper for cons
(: first : (All (A) ((RAList A) -> (Tree A))))
(define (first list )
  (if (Null-RaList? list)
      (error 'cons "given list is empty") ;; Should never come
      (Root-fst list)))

;; Helper for cons
(: rest : (All (A) ((RAList A) -> (RAList A))))
(define (rest list)
  (if (Null-RaList? list)
      (error 'cons "given list is empty") ;; Should never come here
      (Root-rst list)))

;; Similar to list car function
(: head : (All (A) ((RAList A) -> A)))
(define (head list)
  (if (Null-RaList? list) 
      (error 'head "given list is empty")
      (let ([fst (Root-fst list)])
        (if (Leaf? fst) 
            (Leaf-fst fst)
            (Node-fst fst)))))

;; Similar to list cdr function
(: tail : (All (A) ((RAList A) -> (RAList A))))
(define (tail list)
  (if (Null-RaList? list) 
      (error 'tail "given list is empty")
    (let ([fst (Root-fst list)]
          [rst (Root-rst list)]
          [size (arithmetic-shift (Root-size list) -1)])
      (if (Leaf? fst) 
          rst 
          (make-Root size (Node-lft fst) 
                     (make-Root size (Node-rgt fst) rst))))))


;; Helpers for list-ref
(: tree-lookup : (All (A) (Integer (Tree A) Integer -> A)))
(define (tree-lookup size tre pos)
  (let ([pos-zero? (zero? pos)])
    (cond 
      [(and (Leaf? tre) pos-zero?) (Leaf-fst tre)]
      [(Node? tre) (tree-lookup-help size tre pos pos-zero?)]
      [else (error 'list-ref "given index out of bound")])))

(: tree-lookup-help : (All (A) (Integer (Node A) Integer Boolean -> A)))
(define (tree-lookup-help size tre pos pos-zero?)
  (let ([newsize (arithmetic-shift size -1)])
    (cond
      [pos-zero? (Node-fst tre)]
      [(<= pos newsize) (tree-lookup newsize (Node-lft tre) (- pos 1))]
      [else (tree-lookup newsize (Node-rgt tre) (- pos 1 newsize))])))

;; Helpers for list-set
(: tree-update : (All (A) (Integer (Tree A) Integer A -> (Tree A))))
(define (tree-update size tre pos elem)
  (let ([newsize (arithmetic-shift size -1)]
        [pos-zero? (zero? pos)])
    (cond
      [(and (Leaf? tre) pos-zero?) (make-Leaf elem)]
      [(Node? tre) (tree-update-helper newsize tre pos elem pos-zero?)]
      [else (error 'list-set "given index out of bound")])))

(: tree-update-helper : 
   (All (A) (Integer (Node A) Integer A Boolean -> (Tree A))))
(define (tree-update-helper newsize tre pos elem pos-zero?)
  (let ([left (Node-lft tre)]
        [right (Node-rgt tre)]
        [first (Node-fst tre)])
    (cond
      [(eq? pos 0) (make-Node elem left right)]
      [(<= pos newsize)
       (make-Node first (tree-update newsize left (- pos 1) elem) right)]
      [else (make-Node first left 
                       (tree-update newsize right (- pos 1 newsize) elem))])))

;; Similar to list list-ref function
(: list-ref : (All (A) ((RAList A) Integer -> A)))
(define (list-ref list pos)
  (if (Null-RaList? list) 
      (error 'list-ref "given index out of bound")
      (let ([size (Root-size list)])
        (if (< pos size) 
            (tree-lookup size (Root-fst list) pos)
            (list-ref (Root-rst list) (- pos size))))))

;; Similar to list list-set function
(: list-set : (All (A) ((RAList A) Integer A -> (RAList A))))
(define (list-set list pos elem)
  (if (Null-RaList? list) 
      (error 'list-set "given index out of bound")
      (let ([size (Root-size list)]
            [fst (Root-fst list)]
            [rst (Root-rst list)])
        (if (< pos size)
            (make-Root size (tree-update size fst pos elem) rst)
            (make-Root size fst (list-set rst (- pos size) elem))))))

;; Helpers for drop
(: tree-drop : (All (A) (Integer (Tree A) Integer (RAList A) -> (RAList A))))
(define (tree-drop size tre pos list)
  (cond 
    [(zero? pos) (make-Root size tre list)]
    [(and (Leaf? tre) (= pos 1)) list]
    [(Node? tre) (tree-drop-help size tre pos list)]
    [else (error 'drop "Not enough elements to drop")]))

(: tree-drop-help : 
   (All (A) (Integer (Node A) Integer (RAList A) -> (RAList A))))
(define (tree-drop-help size tre pos list)
  (let ([newsize (arithmetic-shift size -1)]
        [left (Node-lft tre)]
        [right (Node-rgt tre)])
    (if (<= pos newsize)
        (tree-drop newsize left (sub1 pos) 
                   (make-Root newsize right list))
        (tree-drop newsize right (- pos 1 newsize) list))))

;; Similar to list drop function
(: drop : (All (A) (Integer (RAList A) -> (RAList A))))
(define (drop pos list)
  (cond
    [(zero? pos) list]
    [(Root? list) (drop-help list pos)]
    [else (error 'drop "Not enough elements to drop")]))

(: drop-help : (All (A) ((Root A) Integer -> (RAList A))))
(define (drop-help list pos)
  (let ([size (Root-size list)]
        [fst (Root-fst list)]
        [rst (Root-rst list)])
    (if (< pos size)
        (tree-drop size fst pos rst)
        (drop (- pos size) rst))))

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
