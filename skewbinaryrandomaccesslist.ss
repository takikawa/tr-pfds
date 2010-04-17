#lang typed-scheme

(provide ralist ralist->list empty? kons
         empty head tail lookup update drop list-length RAList)

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

(: kons : (All (A) (A (RAList A) -> (RAList A))))
(define (kons elem sralist)
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
      (error 'head "Given list is empty")
      (let ([fst (Root-fst (car sralist))])
        (if (Leaf? fst) 
            (Leaf-fst fst)
            (Node-fst fst)))))


(: tail : (All (A) ((RAList A) -> (RAList A))))
(define (tail sralist)
  (if (null? sralist)
      (error 'tail "Given list is empty")
      (let* ([fst (Root-fst (car sralist))]
             [wgt (arithmetic-shift (getWeight (car sralist)) -1)])
        (if (Leaf? fst) 
            (cdr sralist) 
            (list* (make-Root wgt (Node-lft fst))
                   (make-Root wgt (Node-rgt fst))
                   (cdr sralist))))))

(: tree-lookup : (All (A) (Integer (Tree A) Integer -> A)))
(define (tree-lookup wgt tre pos)
  (let ([new-wgt (arithmetic-shift wgt -1)]
        [pos0? (zero? pos)])
    (cond
      [(and (Leaf? tre) pos0?) (Leaf-fst tre)]
      [(Node? tre) (tl-help new-wgt tre pos pos0?)]
      [else (error 'lookup "Given index out of bounds")])))


(: tl-help : (All (A) (Integer (Node A) Integer Boolean -> A)))
(define (tl-help new-wgt tre pos pos0?)
  (cond
    [pos0? (Node-fst tre)]
    [(<= pos new-wgt)
     (tree-lookup new-wgt (Node-lft tre) (sub1 pos))]
    [else (tree-lookup new-wgt (Node-rgt tre) (- pos 1 new-wgt))]))

(: tree-update : (All (A) (Integer (Tree A) Integer A -> (Tree A))))
(define (tree-update wgt tre pos elem)
  (let ([new-wgt (arithmetic-shift wgt -1)]
        [pos0? (zero? pos)])
    (cond
      [(and (Leaf? tre) pos0?) (make-Leaf elem)]
      [(Node? tre) (tu-help new-wgt tre pos pos0? elem)]
      [else (error 'update "Given index out of bounds")])))


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


(: lookup : (All (A) (Integer (RAList A) -> A)))
(define (lookup pos sralist)
  (cond
    [(null? sralist) (error 'lookup "Given index out of bounds")]
    [(< pos (getWeight (car sralist)))
     (tree-lookup (getWeight (car sralist)) (Root-fst (car sralist)) pos)]
    [else (lookup (- pos (getWeight (car sralist))) (cdr sralist))]))


(: update : (All (A) (Integer (RAList A) A -> (RAList A))))
(define (update pos sralist elem)
  (cond
    [(null? sralist) (error 'update "Given index out of bounds")]
    [(< pos (getWeight (car sralist)))
     (cons (make-Root (getWeight (car sralist)) 
                      (tree-update (getWeight (car sralist))
                                   (Root-fst (car sralist)) pos elem)) 
           (cdr sralist))]
    [else (cons (car sralist)
                (update (- pos (getWeight (car sralist)))
                        (cdr sralist)
                        elem))]))

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
      [else (error 'drop "Given index out of bounds")])))


(: drop : (All (A) (Integer (RAList A) -> (RAList A))))
(define (drop pos ralist)
  (cond
    [(zero? pos) ralist]
    [(null? ralist) (error 'drop "Given index out of bounds")]
    [else (drop-helper (car ralist) (cdr ralist) pos)]))

(: drop-helper : (All (A) ((Root A) (RAList A) Integer -> (RAList A))))
(define (drop-helper root rest pos)
  (let ([size (Root-weight root)]
        [tree (Root-fst root)])
  (if (< pos size)
      (tree-drop size tree pos rest)
      (drop (- pos size) rest))))

(: list-length : (All (A) ((RAList A) -> Integer)))
(define (list-length ralist)
  (: int-length : (All (A) ((RAList A) Integer -> Integer)))
  (define (int-length int-ralist accum)
    (if (null? int-ralist)
        accum
        (int-length (tail int-ralist) (add1 accum))))
  (int-length ralist 0))

(: ralist->list : (All (A) ((RAList A) -> (Listof A))))
(define (ralist->list ralist)
  (if (empty? ralist)
      null
      (cons (head ralist) (ralist->list (tail ralist)))))

(: ralist : (All (A) (A * -> (RAList A))))
(define (ralist . lst)
  (foldr (inst kons A) null lst))
