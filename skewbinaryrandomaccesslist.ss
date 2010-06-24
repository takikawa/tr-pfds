#lang typed/scheme
(require (prefix-in sh: scheme/base))
(provide list ->list empty? cons empty head tail
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

(define empty null)

(: empty? : (All (A) ((List A) -> Boolean)))
(define (empty? sralist)
  (null? sralist))

(: getWeight : (All (A) ((Root A) -> Integer)))
(define (getWeight root)
  (Root-weight root))

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

(: head : (All (A) ((List A) -> A)))
(define (head sralist)
  (if (null? sralist) 
      (error 'head "given list is empty")
      (let ([fst (Root-fst (car sralist))])
        (if (Leaf? fst) 
            (Leaf-fst fst)
            (Node-fst fst)))))


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


(: list-ref : (All (A) ((List A) Integer -> A)))
(define (list-ref sralist pos)
  (cond
    [(null? sralist) (error 'list-ref "given index out of bounds")]
    [(< pos (getWeight (car sralist)))
     (tree-lookup (getWeight (car sralist)) (Root-fst (car sralist)) pos)]
    [else (list-ref (cdr sralist) (- pos (getWeight (car sralist))))]))


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

(: list-length : (All (A) ((List A) -> Integer)))
(define (list-length ralist)
  (: int-length : (All (A) ((List A) Integer -> Integer)))
  (define (int-length int-ralist accum)
    (if (null? int-ralist)
        accum
        (int-length (tail int-ralist) (add1 accum))))
  (int-length ralist 0))


(: ramap : (All (A C B ...) 
                ((A B ... B -> C) (List A) (List B) ... B -> (List C))))
(define (ramap func lst . lsts)
  (: in-map : (All (A C B ...) 
                   ((List C) (A B ... B -> C) (List A) (List B) ... B -> 
                             (List C))))
  (define (in-map accum func lst . lsts)
    (if (or (empty? lst) (ormap empty? lsts))
        accum
        (apply in-map 
               (cons (apply func (head lst) (map head lsts)) accum)
               func 
               (tail lst)
               (map tail lsts))))
  (apply in-map empty func lst lsts))


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


(: ->list : (All (A) ((List A) -> (Listof A))))
(define (->list ralist)
  (if (empty? ralist)
      null
      (sh:cons (head ralist) (->list (tail ralist)))))

(: list : (All (A) (A * -> (List A))))
(define (list . lst)
  (foldr (inst cons  A) null lst))

(define first* head)
(define rest* tail)