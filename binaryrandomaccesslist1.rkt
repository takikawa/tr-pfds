#lang typed/scheme
(require (prefix-in sh: scheme/base))
(provide empty empty? list-length cons 
         head tail (rename-out [first* first] [rest* rest]) list-ref list-set drop ->list list)

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

(define empty (make-Null-RaList))

(define One 1)
(define Zero 0)

(: empty? : (All (A) ((RAList A) -> Boolean)))
(define (empty? list)
  (Null-RaList? list))

(: list-length : (All (A) ((RAList A) -> Integer)))
(define (list-length list)
  (if (Null-RaList? list)
      0
      (+ (Root-size list) (list-length (Root-rst list)))))

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

(: first : (All (A) ((RAList A) -> (Tree A))))
(define (first list )
  (if (Null-RaList? list)
      (error 'cons "given list is empty")
      (Root-fst list)))


(: rest : (All (A) ((RAList A) -> (RAList A))))
(define (rest list)
  (if (Null-RaList? list)
      (error 'rest "given list is empty")
      (Root-rst list)))


(: head : (All (A) ((RAList A) -> A)))
(define (head list)
  (if (Null-RaList? list) 
      (error 'head "given list is empty")
      (let ([fst (Root-fst list)])
        (if (Leaf? fst) 
            (Leaf-fst fst)
            (Node-fst fst)))))


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

(: tree-lookup : (All (A) (Integer (Tree A) Integer -> A)))
(define (tree-lookup size tre pos)
  (let ([pos-zero? (zero? pos)])
    (cond 
      [(and (Leaf? tre) pos-zero?) (Leaf-fst tre)]
      [(Node? tre) (tree-lookup-help size tre pos pos-zero?)]
      [else (error 'lookup "given index out of bound")])))

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
      [else (error 'update "given index out of bound")])))

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
    
(: list-ref : (All (A) ((RAList A) Integer -> A)))
(define (list-ref list pos)
  (if (Null-RaList? list) 
      (error 'list-ref "given index out of bound")
      (let ([size (Root-size list)])
        (if (< pos size) 
            (tree-lookup size (Root-fst list) pos)
            (list-ref (Root-rst list) (- pos size))))))


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
    
(: ->list : (All (A) ((RAList A) -> (Listof A))))
(define (->list list)
  (if (empty? list)
      null
      (sh:cons (head list) (->list (tail list)))))

(: list : (All (A) (A * -> (RAList A))))
(define (list . rst)
  (foldr (inst cons A) empty rst))

(define first* head)
(define rest* tail)

;#lang typed-scheme
;
;(provide empty empty? list-length kons 
;         head tail lookup update drop ralist->list ralist)
;
;(define-struct: (A) Leaf ([fst : A]))
;(define-struct: (A) Node ([fst : A]
;                          [lft : (Tree A)] 
;                          [rgt : (Tree A)]))
;(define-type-alias Tree (All (A) (U (Leaf A) (Node A))))
;(define-struct: (A) Root ([size : Integer]
;                          [fst  : (Tree A)]
;                          [rst  : (RAList A)]))
;
;(define-type-alias RAList (All (A) (U Null-RaList (Root A))))
;
;(define empty-tree (make-Leaf null))
;
;(define-struct: Null-RaList ())
;
;(define empty (make-Null-RaList))
;
;(define One 1)
;(define Zero 0)
;
;(: empty? : (All (A) ((RAList A) -> Boolean)))
;(define (empty? ralist)
;  (Null-RaList? ralist))
;
;(: list-length : (All (A) ((RAList A) -> Integer)))
;(define (list-length ralist)
;  (if (Null-RaList? ralist)
;      0
;      (+ (Root-size ralist) (list-length (Root-rst ralist)))))
;
;(: kons : (All (A) (A (RAList A) -> (RAList A))))
;(define (kons elem ralist)
;  (if (Null-RaList? ralist) 
;      (make-Root One (make-Leaf elem) ralist)
;      (let* ([rst (Root-rst ralist)]
;             [lsize (list-length ralist)]
;             [rst-size (list-length rst)])
;        (if (eq? lsize rst-size)
;            (make-Root (+ One lsize rst-size)
;                       (make-Node elem (Root-fst ralist) (first rst))
;                       (rest rst))
;            (make-Root One (make-Leaf elem) ralist)))))
;
;(: first : (All (A) ((RAList A) -> (Tree A))))
;(define (first ralist )
;  (if (Null-RaList? ralist)
;      (error 'kons "given list is empty")
;      (Root-fst ralist)))
;
;
;(: rest : (All (A) ((RAList A) -> (RAList A))))
;(define (rest ralist )
;  (if (Null-RaList? ralist)
;      (error 'rest "given list is empty")
;      (Root-rst ralist)))
;
;
;(: head : (All (A) ((RAList A) -> A)))
;(define (head ralist)
;  (if (Null-RaList? ralist) 
;      (error 'head "given list is empty")
;      (let ([fst (Root-fst ralist)])
;        (if (Leaf? fst) 
;            (Leaf-fst fst)
;            (Node-fst fst)))))
;
;
;(: tail : (All (A) ((RAList A) -> (RAList A))))
;(define (tail ralist)
;  (if (Null-RaList? ralist) 
;      (error 'tail "given list is empty")
;    (let ([fst (Root-fst ralist)]
;          [rst (Root-rst ralist)]
;          [size (arithmetic-shift (Root-size ralist) -1)])
;      (if (Leaf? fst) 
;          rst 
;          (make-Root size (Node-lft fst) 
;                     (make-Root size (Node-rgt fst) rst))))))
;
;(: tree-lookup : (All (A) (Integer (Tree A) Integer -> A)))
;(define (tree-lookup size tre pos)
;  (let ([pos-zero? (zero? pos)])
;    (cond 
;      [(and (Leaf? tre) pos-zero?) (Leaf-fst tre)]
;      [(Node? tre) (tree-lookup-help size tre pos pos-zero?)]
;      [else (error 'lookup "given index out of bound")])))
;
;(: tree-lookup-help : (All (A) (Integer (Node A) Integer Boolean -> A)))
;(define (tree-lookup-help size tre pos pos-zero?)
;  (let ([newsize (arithmetic-shift size -1)])
;    (cond
;      [pos-zero? (Node-fst tre)]
;      [(<= pos newsize) (tree-lookup newsize (Node-lft tre) (- pos 1))]
;      [else (tree-lookup newsize (Node-rgt tre) (- pos 1 newsize))])))
;
;
;(: tree-update : (All (A) (Integer (Tree A) Integer A -> (Tree A))))
;(define (tree-update size tre pos elem)
;  (let ([newsize (arithmetic-shift size -1)]
;        [pos-zero? (zero? pos)])
;    (cond
;      [(and (Leaf? tre) pos-zero?) (make-Leaf elem)]
;      [(Node? tre) (tree-update-helper newsize tre pos elem pos-zero?)]
;      [else (error 'update "given index out of bound")])))
;
;(: tree-update-helper : 
;   (All (A) (Integer (Node A) Integer A Boolean -> (Tree A))))
;(define (tree-update-helper newsize tre pos elem pos-zero?)
;  (let ([left (Node-lft tre)]
;        [right (Node-rgt tre)]
;        [first (Node-fst tre)])
;    (cond
;      [(eq? pos 0) (make-Node elem left right)]
;      [(<= pos newsize)
;       (make-Node first (tree-update newsize left (- pos 1) elem) right)]
;      [else (make-Node first left 
;                       (tree-update newsize right (- pos 1 newsize) elem))])))
;    
;(: lookup : (All (A) (Integer (RAList A) -> A)))
;(define (lookup pos ralist)
;  (if (Null-RaList? ralist) 
;      (error 'lookup "given index out of bound")
;      (let ([size (Root-size ralist)])
;        (if (< pos size) 
;            (tree-lookup size (Root-fst ralist) pos)
;            (lookup (- pos size) (Root-rst ralist))))))
;
;
;(: update : (All (A) (Integer (RAList A) A -> (RAList A))))
;(define (update pos ralist elem)
;  (if (Null-RaList? ralist) 
;      (error 'update "given index out of bound")
;      (let ([size (Root-size ralist)]
;            [fst (Root-fst ralist)]
;            [rst (Root-rst ralist)])
;        (if (< pos size)
;            (make-Root size (tree-update size fst pos elem) rst)
;            (make-Root size fst (update (- pos size) rst elem))))))
;
;(: tree-drop : (All (A) (Integer (Tree A) Integer (RAList A) -> (RAList A))))
;(define (tree-drop size tre pos ralist)
;  (cond 
;    [(zero? pos) (make-Root size tre ralist)]
;    [(and (Leaf? tre) (= pos 1)) ralist]
;    [(Node? tre) (tree-drop-help size tre pos ralist)]
;    [else (error 'drop "Not enough elements to drop")]))
;
;(: tree-drop-help : 
;   (All (A) (Integer (Node A) Integer (RAList A) -> (RAList A))))
;(define (tree-drop-help size tre pos ralist)
;  (let ([newsize (arithmetic-shift size -1)]
;        [left (Node-lft tre)]
;        [right (Node-rgt tre)])
;    (if (<= pos newsize)
;        (tree-drop newsize left (sub1 pos) 
;                   (make-Root newsize right ralist))
;        (tree-drop newsize right (- pos 1 newsize) ralist))))
;
;(: drop : (All (A) (Integer (RAList A) -> (RAList A))))
;(define (drop pos ralist)
;  (cond
;    [(zero? pos) ralist]
;    [(Root? ralist) (drop-help ralist pos)]
;    [else (error 'drop "Not enough elements to drop")]))
;
;(: drop-help : (All (A) ((Root A) Integer -> (RAList A))))
;(define (drop-help ralist pos)
;  (let ([size (Root-size ralist)]
;        [fst (Root-fst ralist)]
;        [rst (Root-rst ralist)])
;    (if (< pos size)
;        (tree-drop size fst pos rst)
;        (drop (- pos size) rst))))
;    
;(: ralist->list : (All (A) ((RAList A) -> (Listof A))))
;(define (ralist->list ralist)
;  (if (empty? ralist)
;      null
;      (cons (head ralist) (ralist->list (tail ralist)))))
;
;(: ralist : (All (A) (A * -> (RAList A))))
;(define (ralist . rst)
;  (foldr (inst kons A) empty rst))