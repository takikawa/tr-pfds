#lang typed-scheme

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

(: isTreEmpty? : (All (A) ((Tree A) -> Boolean)))
(define (isTreEmpty? tre)
  (eq? empty-tree tre))


(: null? : (All (A) ((RAList A) -> Boolean)))
(define (null? ralist)
  (Null-RaList? ralist))

(: lst-size : (All (A) ((RAList A) -> Integer)))
(define (lst-size ralist)
  (if (Null-RaList? ralist)
      0
      (Root-size ralist)))

(: ralist-cons : (All (A) (A (RAList A) -> (RAList A))))
(define (ralist-cons elem ralist)
  (cond
    [(Null-RaList? ralist) (make-Root One (make-Leaf elem) ralist)]
    [(eq? (lst-size ralist) (lst-size (Root-rst ralist)))
     (make-Root (+ One (lst-size ralist) (lst-size (Root-rst ralist)))
                (make-Node elem (Root-fst ralist) (get-fst (Root-rst ralist)))
                (get-rst (Root-rst ralist)))]
    [else (make-Root One (make-Leaf elem) ralist)]))

(: get-fst : (All (A) ((RAList A) -> (Tree A))))
(define (get-fst ralist )
  (if (Null-RaList? ralist)
      (error "Cannot access first" 'ralist-cons)
      (Root-fst ralist)))


(: get-rst : (All (A) ((RAList A) -> (RAList A))))
(define (get-rst ralist )
  (if (Null-RaList? ralist)
      (error "Cannot access rest" 'ralist-cons)
      (Root-rst ralist)))


(: head : (All (A) ((RAList A) -> A)))
(define (head ralist)
  (if (Null-RaList? ralist) 
      (error "List is empty" 'head)
      (let ([fst (Root-fst ralist)])
        (if (Leaf? fst) 
            (Leaf-fst fst)
            (Node-fst fst)))))


(: tail : (All (A) ((RAList A) -> (RAList A))))
(define (tail ralist)
  (if (Null-RaList? ralist) 
      (error "List is empty" 'tail)
    (let: ([fst : (Tree A) (Root-fst ralist)]
           [size : Integer (arithmetic-shift (Root-size ralist) -1)])
      (if (Leaf? fst) 
          (Root-rst ralist) 
          (make-Root size (Node-lft fst) (make-Root size (Node-rgt fst) (Root-rst ralist)))))))

(: tree-lookup : (All (A) (Integer (Tree A) Integer -> A)))
(define (tree-lookup size tre pos)
  (let: ([newsize : Integer (arithmetic-shift size -1)])
        (cond
          [(and (Leaf? tre) (eq? pos 0)) (Leaf-fst tre)]
          [(and (Node? tre) (eq? pos 0)) (Node-fst tre)]
          [(and (Node? tre) (<= pos newsize))
           (tree-lookup newsize (Node-lft tre) (- pos 1))]
          [(Node? tre) (tree-lookup newsize (Node-rgt tre) (- pos 1 newsize))]
          [else (error "Index out of bound" 'tree-lookup)])))


(: tree-update : (All (A) (Integer (Tree A) Integer A -> (Tree A))))
(define (tree-update size tre pos elem)
  (let: ([newsize : Integer (arithmetic-shift size -1)])
        (cond
          [(and (Leaf? tre) (eq? pos 0)) (make-Leaf elem)]
          [(and (Node? tre) (eq? pos 0)) (make-Node elem (Node-lft tre) (Node-rgt tre))]
          [(and (Node? tre) (<= pos newsize))
           (make-Node (Node-fst tre) 
                      (tree-update newsize (Node-lft tre) (- pos 1) elem) (Node-rgt tre))]
          [(Node? tre)
           (make-Node (Node-fst tre) (Node-lft tre) 
                      (tree-update newsize (Node-rgt tre) (- pos 1 newsize) elem))]
          [else (error "Index out of bound" 'tree-lookup)])))


(: lookup : (All (A) ((RAList A) Integer -> A)))
(define (lookup ralist pos)
  (cond
    [(Null-RaList? ralist) (error "Index out of bound" 'lookup)]
    [(< pos (Root-size ralist)) (tree-lookup (Root-size ralist) (Root-fst ralist) pos)]
    [else (lookup (Root-rst ralist) (- pos (Root-size ralist)))]))


(: update : (All (A) ((RAList A) Integer A -> (RAList A))))
(define (update ralist pos elem)
  (cond
    [(Null-RaList? ralist) (error "List is empty" 'update)]
    [(< pos (Root-size ralist)) 
     (make-Root (Root-size ralist) 
                  (tree-update (Root-size ralist) 
                               (Root-fst ralist) pos elem) 
                  (Root-rst ralist))]
    [else (make-Root (Root-size ralist) 
                       (Root-fst ralist) 
                       (update (Root-rst ralist) 
                               (- pos (Root-size ralist)) elem))]))

(: tree-drop : (All (A) (Integer (Tree A) Integer (RAList A) -> (RAList A))))
(define (tree-drop size tre pos ralist)
  (let ([newsize (round (/ size 2))]) 
    (cond 
      [(zero? pos) (make-Root size tre ralist)]
      [(and (Leaf? tre) (eq? pos 1)) ralist]
      [(and (Node? tre) (<= pos newsize)) 
       (tree-drop newsize 
                  (Node-lft tre) (- pos 1) 
                  (make-Root newsize (Node-rgt tre) ralist))]
      [(and (Node? tre) (> pos newsize)) 
       (tree-drop newsize 
                  (Node-rgt tre) (- pos 1 newsize) 
                  ralist)]
      [else (error "Index out of bound" 'tree-drop)])))


(: drop : (All (A) ((RAList A) Integer -> (RAList A))))
(define (drop ralist pos)
  (cond
    [(zero? pos) ralist]
    [(and (Root? ralist) (< pos (Root-size ralist))) 
     (tree-drop (Root-size ralist) (Root-fst ralist) pos (Root-rst ralist))]
    [(and (Root? ralist) (>= pos (Root-size ralist))) 
     (drop  (Root-rst ralist) (- pos (Root-size ralist)))]
    [else (error "Index out of bound" 'drop)]))
    


(: ralist : (All (A) ((Listof A) -> (RAList A))))
(define (ralist lst)
  (foldr (inst ralist-cons A) null-ralist lst))