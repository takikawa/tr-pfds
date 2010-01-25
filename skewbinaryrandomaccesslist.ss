#lang typed-scheme

(provide skew-ralist skew-ralist->list empty? ralist-cons
         empty head tail lookup update drop)

(define-struct: (A) Leaf ([fst : A]))
(define-struct: (A) Node ([fst : A]
                          [lft : (Tree A)] 
                          [rgt : (Tree A)]))
(define-type-alias Tree (All (A) (U (Leaf A) (Node A))))
(define-struct: (A) Root ([weight : Integer]
                          [fst  : (Tree A)]))

(define-type-alias RAList (All (A) (Listof (Root A))))

(define empty null)

(: empty? : (All (A) ((RAList A) -> Boolean)))
(define (empty? sralist)
  (null? sralist))

(: getWeight : (All (A) ((Root A) -> Integer)))
(define (getWeight root)
  (Root-weight root))

(: ralist-cons : (All (A) (A (RAList A) -> (RAList A))))
(define (ralist-cons elem sralist)
  (if (or (null? sralist) (null? (cdr sralist)))
      (cons (make-Root 1 (make-Leaf elem)) sralist)
      (let ([wgt1 (getWeight (car sralist))]
            [wgt2 (getWeight (car (cdr sralist)))])
        (if (eq? wgt1 wgt2)
            (cons (make-Root (+ 1 wgt1 wgt2) 
                             (make-Node elem 
                                        (Root-fst (car sralist)) 
                                        (Root-fst (car (cdr sralist)))))
                  (cdr (cdr sralist)))
            (cons (make-Root 1 (make-Leaf elem)) sralist)))))

(: head : (All (A) ((RAList A) -> A)))
(define (head sralist)
  (if (null? sralist) 
      (error "List is empty :" 'head)
      (let ([fst (Root-fst (car sralist))])
        (if (Leaf? fst) 
            (Leaf-fst fst)
            (Node-fst fst)))))


(: tail : (All (A) ((RAList A) -> (RAList A))))
(define (tail sralist)
  (if (null? sralist)
      (error "List is empty :" 'tail)
      (let* ([fst (Root-fst (car sralist))]
             [wgt (arithmetic-shift (getWeight (car sralist)) -1)])
        (if (Leaf? fst) 
            (cdr sralist) 
            (list* (make-Root wgt (Node-lft fst))
                   (make-Root wgt (Node-rgt fst))
                   (cdr sralist))))))

(: tree-lookup : (All (A) (Integer (Tree A) Integer -> A)))
(define (tree-lookup wgt tre pos)
  (let: ([new-wgt : Integer (arithmetic-shift wgt -1)])
        (cond
          [(and (Leaf? tre) (eq? pos 0)) (Leaf-fst tre)]
          [(and (Node? tre) (eq? pos 0)) (Node-fst tre)]
          [(and (Node? tre) (<= pos new-wgt))
           (tree-lookup new-wgt (Node-lft tre) (sub1 pos))]
          [(Node? tre) (tree-lookup new-wgt (Node-rgt tre) (- pos 1 new-wgt))]
          [else (error "Index out of bound :" 'tree-lookup)])))


(: tree-update : (All (A) (Integer (Tree A) Integer A -> (Tree A))))
(define (tree-update wgt tre pos elem)
  (let: ([new-wgt : Integer (arithmetic-shift wgt -1)])
        (cond
          [(and (Leaf? tre) (eq? pos 0)) (make-Leaf elem)]
          [(and (Node? tre) (eq? pos 0)) (make-Node elem (Node-lft tre) (Node-rgt tre))]
          [(and (Node? tre) (<= pos new-wgt))
           (make-Node (Node-fst tre) (tree-update new-wgt (Node-lft tre) (sub1 pos) elem) 
                      (Node-rgt tre))]
          [(Node? tre)
           (make-Node (Node-fst tre) (Node-lft tre) 
                      (tree-update new-wgt (Node-rgt tre) (- pos 1 new-wgt) elem))]
          [else (error "Index out of bound :" 'tree-lookup)])))


(: lookup : (All (A) ((RAList A) Integer -> A)))
(define (lookup sralist pos)
  (cond
    [(null? sralist) (error "Index out of bound :" 'lookup)]
    [(< pos (getWeight (car sralist)))
     (tree-lookup (getWeight (car sralist)) (Root-fst (car sralist)) pos)]
    [else (lookup (cdr sralist) (- pos (getWeight (car sralist))))]))


(: update : (All (A) ((RAList A) Integer A -> (RAList A))))
(define (update sralist pos elem)
  (cond
    [(null? sralist) (error "Index out of bound :" 'update)]
    [(< pos (getWeight (car sralist)))
     (cons (make-Root (getWeight (car sralist)) 
                      (tree-update (getWeight (car sralist))
                                   (Root-fst (car sralist)) pos elem)) 
           (cdr sralist))]
    [else (cons (car sralist)
                (update (cdr sralist)
                        (- pos (getWeight (car sralist))) elem))]))

(: tree-drop : (All (A) (Integer (Tree A) Integer (RAList A) -> (RAList A))))
(define (tree-drop size tre pos ralist)
  (let ([newsize (arithmetic-shift size -1)])
    (cond 
      [(zero? pos) (cons (make-Root size tre) ralist)]
      [(and (Leaf? tre) (= pos 1)) ralist]
      [(and (Node? tre) (<= pos newsize)) 
       (tree-drop newsize 
                  (Node-lft tre) (- pos 1) 
                  (cons (make-Root newsize (Node-rgt tre)) ralist))]
      [(and (Node? tre) (> pos newsize)) 
       (tree-drop newsize 
                  (Node-rgt tre) (- pos 1 newsize) 
                  ralist)]
      [else (error "Index out of bound :" 'tree-drop)])))


(: drop : (All (A) ((RAList A) Integer -> (RAList A))))
(define (drop ralist pos)
  (cond
    [(zero? pos) ralist]
    [(null? ralist) (error "Index out of bound :" 'drop)]
    [else (drop-helper (car ralist) (cdr ralist) pos)]))

(: drop-helper : (All (A) ((Root A) (RAList A) Integer -> (RAList A))))
(define (drop-helper root rest pos)
  (let ([size (Root-weight root)]
        [tree (Root-fst root)])
  (if (< pos size)
      (tree-drop size tree pos rest)
      (drop rest (- pos size)))))

(: skew-ralist->list : (All (A) ((RAList A) -> (Listof A))))
(define (skew-ralist->list ralist)
  (if (empty? ralist)
      null
      (cons (head ralist) (skew-ralist->list (tail ralist)))))

(: skew-ralist : (All (A) ((Listof A) -> (RAList A))))
(define (skew-ralist lst)
  (foldr (inst ralist-cons A) null lst))