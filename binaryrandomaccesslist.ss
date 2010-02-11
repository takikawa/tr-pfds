#lang typed-scheme

(provide null-ralist empty? list-size ralist-cons 
         head tail lookup update drop ralist->list ralist)

(define-struct: (A) Leaf ([fst : A]))
(define-struct: (A) Node ([fst : A]
                          [lft : (Tree A)] 
                          [rgt : (Tree A)]))
(define-type-alias Tree (All (A) (U (Leaf A) (Node A))))
(define-struct: (A) Root ([size : Integer]
                          [fst  : (Tree A)]
                          [rst  : (RAList A)]))

(define-type-alias RAList (All (A) (U Null-RaList (Root A))))

(define empty-tree (make-Leaf null))

(define-struct: Null-RaList ([Null : Any]))

(define null-ralist (make-Null-RaList ""))

(define One 1)
(define Zero 0)

;(: isTreEmpty? : (All (A) ((Tree A) -> Boolean)))
;(define (isTreEmpty? tre)
;  (equal? empty-tree tre))


(: empty? : (All (A) ((RAList A) -> Boolean)))
(define (empty? ralist)
  (Null-RaList? ralist))

(: list-size : (All (A) ((RAList A) -> Integer)))
(define (list-size ralist)
  (if (Null-RaList? ralist)
      0
      (Root-size ralist)))

(: ralist-cons : (All (A) (A (RAList A) -> (RAList A))))
(define (ralist-cons elem ralist)
  (if (Null-RaList? ralist) 
      (make-Root One (make-Leaf elem) ralist)
      (let* ([rst (Root-rst ralist)]
             [lsize (list-size ralist)]
             [rst-size (list-size rst)])
        (if (eq? lsize rst-size)
            (make-Root (+ One lsize rst-size)
                       (make-Node elem (Root-fst ralist) (first rst))
                       (rest rst))
            (make-Root One (make-Leaf elem) ralist)))))

(: first : (All (A) ((RAList A) -> (Tree A))))
(define (first ralist )
  (if (Null-RaList? ralist)
      (error "List is empty :" 'ralist-cons)
      (Root-fst ralist)))


(: rest : (All (A) ((RAList A) -> (RAList A))))
(define (rest ralist )
  (if (Null-RaList? ralist)
      (error "Cannot access rest :" 'ralist-cons)
      (Root-rst ralist)))


(: head : (All (A) ((RAList A) -> A)))
(define (head ralist)
  (if (Null-RaList? ralist) 
      (error "List is empty :" 'head)
      (let ([fst (Root-fst ralist)])
        (if (Leaf? fst) 
            (Leaf-fst fst)
            (Node-fst fst)))))


(: tail : (All (A) ((RAList A) -> (RAList A))))
(define (tail ralist)
  (if (Null-RaList? ralist) 
      (error "List is empty" 'tail)
    (let ([fst (Root-fst ralist)]
          [rst (Root-rst ralist)]
          [size (arithmetic-shift (Root-size ralist) -1)])
      (if (Leaf? fst) 
          rst 
          (make-Root size (Node-lft fst) 
                     (make-Root size (Node-rgt fst) rst))))))

(: tree-lookup : (All (A) (Integer (Tree A) Integer -> A)))
(define (tree-lookup size tre pos)
  (let ([pos-zero? (zero? pos)])
    (cond 
      [(and (Leaf? tre) pos-zero?) (Leaf-fst tre)]
      [(Node? tre) (tree-lookup-help size tre pos pos-zero?)]
      [else (error "Index out of bound :" 'lookup)])))

(: tree-lookup-help : (All (A) (Integer (Node A) Integer Boolean -> A)))
(define (tree-lookup-help size tre pos pos-zero?)
  (let ([newsize (arithmetic-shift size -1)])
    (cond
      [pos-zero? (Node-fst tre)]
      [(<= pos newsize) (tree-lookup newsize (Node-lft tre) (- pos 1))]
      [else (tree-lookup newsize (Node-rgt tre) (- pos 1 newsize))])))


(: tree-update : (All (A) (Integer (Tree A) Integer A -> (Tree A))))
(define (tree-update size tre pos elem)
  (let ([newsize (arithmetic-shift size -1)]
        [pos-zero? (zero? pos)])
    (cond
      [(and (Leaf? tre) pos-zero?) (make-Leaf elem)]
      [(Node? tre) (tree-update-helper newsize tre pos elem pos-zero?)]
      [else (error "Index out of bound :" 'update)])))

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
    
(: lookup : (All (A) ((RAList A) Integer -> A)))
(define (lookup ralist pos)
  (if (Null-RaList? ralist) 
      (error "Index out of bound :" 'lookup)
      (let ([size (Root-size ralist)])
        (if (< pos size) 
            (tree-lookup size (Root-fst ralist) pos)
            (lookup (Root-rst ralist) (- pos size))))))


(: update : (All (A) ((RAList A) Integer A -> (RAList A))))
(define (update ralist pos elem)
  (if (Null-RaList? ralist) 
      (error "Index out of bound :" 'update) 
      (let ([size (Root-size ralist)]
            [fst (Root-fst ralist)]
            [rst (Root-rst ralist)])
        (if (< pos size)
            (make-Root size (tree-update size fst pos elem) rst)
            (make-Root size fst (update rst (- pos size) elem))))))

(: tree-drop : (All (A) (Integer (Tree A) Integer (RAList A) -> (RAList A))))
(define (tree-drop size tre pos ralist)
  (cond 
    [(zero? pos) (make-Root size tre ralist)]
    [(and (Leaf? tre) (= pos 1)) ralist]
    [(Node? tre) (tree-drop-help size tre pos ralist)]
    [else (error "Index out of bound :" 'drop)]))

(: tree-drop-help : 
   (All (A) (Integer (Node A) Integer (RAList A) -> (RAList A))))
(define (tree-drop-help size tre pos ralist)
  (let ([newsize (arithmetic-shift size -1)]
        [left (Node-lft tre)]
        [right (Node-rgt tre)])
    (if (<= pos newsize)
        (tree-drop newsize left (sub1 pos) 
                   (make-Root newsize right ralist))
        (tree-drop newsize right (- pos 1 newsize) ralist))))

(: drop : (All (A) ((RAList A) Integer -> (RAList A))))
(define (drop ralist pos)
  (cond
    [(zero? pos) ralist]
    [(Root? ralist) (drop-help ralist pos)]
    [else (error "Index out of bound :" 'drop)]))

(: drop-help : (All (A) ((Root A) Integer -> (RAList A))))
(define (drop-help ralist pos)
  (let ([size (Root-size ralist)]
        [fst (Root-fst ralist)]
        [rst (Root-rst ralist)])
    (if (< pos size)
        (tree-drop size fst pos rst)
        (drop  rst (- pos size)))))
    
(: ralist->list : (All (A) ((RAList A) -> (Listof A))))
(define (ralist->list ralist)
  (if (empty? ralist)
      null
      (cons (head ralist) (ralist->list (tail ralist)))))

(: ralist : (All (A) (A * -> (RAList A))))
(define (ralist . rst)
  (if (null? rst)
      null-ralist
      (foldr (inst ralist-cons A) null-ralist rst)))