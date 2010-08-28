#lang typed/racket #:optimize

(provide member? delete insert redblacktree
         redblacktree->list root delete-root empty? RedBlackTree
         (rename-out [rb-map map]) fold filter remove)

(require scheme/match)

(define-type Color (U 'red 'black))

(struct: (A) RBNode ([color : Color]
                     [left : (Tree A)]
                     [elem : A]
                     [right : (Tree A)]))

(define-type (Tree A) (U Null (RBNode A)))

(struct: (A) RBTree ([comparer : (A A -> Boolean)]
                     [tree : (Tree A)]))

(define-type (RedBlackTree A) (RBTree A))

(define black 'black)
(define red 'red)
(define empty null)

(: empty? : (All (A) ((RBTree A) -> Boolean)))
(define (empty? redblacktree)
  (null? (RBTree-tree redblacktree)))

(: xor : Boolean Boolean -> Boolean)
(define (xor l r)
  (or (and l r) (and (not l) (not r))))

(: member? : (All (A) (A (RBTree A) -> Boolean)))
(define (member? key redblacktree)
  (let ([func (RBTree-comparer redblacktree)]
        [tre (RBTree-tree redblacktree)])
    (helper key tre func)))

(: helper : (All (A) (A (Tree A) (A A -> Boolean) -> Boolean)))
(define (helper key tre func)
  (if (null? tre) #f (member-help key tre func)))

(: member-help : (All (A) (A (RBNode A) (A A -> Boolean) -> Boolean)))
(define (member-help key tre func)
  (let* ([root (RBNode-elem tre)]
         [lt (func key root)]
         [gt (func root key)]
         [equl (xor lt gt)])
    (cond
      [equl #t]
      [lt (helper key (RBNode-left tre) func)]
      [else (helper key (RBNode-right tre) func)])))

(: elem : (All (A) ((Tree A) -> A)))
(define (elem tree)
  (if (null? tree)
      (error 'root "given tree is empty")
      (RBNode-elem tree)))

(: root : (All (A) ((RBTree A) -> A)))
(define (root tree)
  (elem (RBTree-tree tree)))

(: balance : (All (A) ((RBTree A) -> (RBTree A))))
(define (balance tree)
  (RBTree (RBTree-comparer tree) 
          (balance-helper (RBTree-tree tree))))

(: balance-helper : (All (A) ((Tree A) -> (Tree A))))
(define (balance-helper tree)
  (match tree
    [(struct RBNode 
       ('black (struct RBNode ('red (struct RBNode ('red a x b)) y c)) z d))
     (RBNode red (RBNode black a x b) y (RBNode black c z d))]
    [(struct RBNode 
       ('black (struct RBNode ('red a x (struct RBNode ('red b y c)))) z d))
     (RBNode red (RBNode black a x b) y (RBNode black c z d))]
    [(struct RBNode 
       ('black a x (struct RBNode ('red (struct RBNode ('red b y c)) z d))))
     (RBNode red (RBNode black a x b) y (RBNode black c z d))]
    [(struct RBNode 
       ('black a x (struct RBNode ('red b y (struct RBNode ('red c z d))))))
     (RBNode red (RBNode black a x b) y (RBNode black c z d))]
    [else tree]))


(: color : (All (A) ((Tree A) -> Color)))
(define (color tree)
  (if (null? tree)
      black
      (RBNode-color tree)))


(: insert : (All (A) (A (RBTree A) -> (RBTree A))))
(define (insert elem tree)
  (let ([func (RBTree-comparer tree)])
    (RBTree func (rake-black (ins elem (RBTree-tree tree) func)))))


(: ins : (All (A) (A (Tree A) (A A -> Boolean) -> (Tree A))))
(define (ins elem tree func)
  (if (null? tree) 
      (RBNode red empty elem empty)
      (ins-helper elem tree func)))

(: ins-helper : (All (A) (A (RBNode A) (A A -> Boolean) -> (Tree A))))
(define (ins-helper elem tree func)
  (let* ([nod-elem (RBNode-elem tree)]
         [left-cmp (func elem nod-elem)]
         [right-cmp (func nod-elem elem)]
         [left (RBNode-left tree)]
         [right (RBNode-right tree)]
         [color (RBNode-color tree)])
    (cond
      [(and left-cmp right-cmp) tree]
      [left-cmp 
       (balance-helper (RBNode color (ins elem left func) nod-elem right))]
      [else 
       (balance-helper (RBNode color left nod-elem (ins elem right func)))])))


(: rake-black : (All (A) ((Tree A) -> (Tree A))))
(define (rake-black tre)
  (if (null? tre) tre 
      (RBNode black (RBNode-left tre) (RBNode-elem tre) (RBNode-right tre))))

(: delete-root : (All (A) ((RBTree A) -> (RBTree A))))
(define (delete-root redblacktree)
  (if (empty? redblacktree)
      (error 'delete-root "given tree is empty")
      (delete (root redblacktree) redblacktree)))

(: delete : (All (A) (A (RBTree A) -> (RBTree A))))
(define (delete key redblacktree)
  (let ([func (RBTree-comparer redblacktree)]
        [tree (RBTree-tree redblacktree)])
    (RBTree func (delete-helper key tree func))))

(: delete-helper : (All (A) (A (Tree A) (A A -> Boolean) -> (Tree A))))
(define (delete-helper key tre func)
  (if (null? tre)
      (error 'delete "given key not found in the tree")
      (del-help key tre func)))

(: del-help : (All (A) (A (RBNode A) (A A -> Boolean) -> (Tree A))))
(define (del-help key tre func)
  (: del-left : (All (A) ((Tree A) A (Tree A) -> (Tree A))))
  (define (del-left left x right)
    (if (symbol=? (color left) 'black)
        (bal-left (delete-helper key left func) x right)
        (RBNode red (delete-helper key left func) x right)))
  (: del-right : (All (A) ((Tree A) A (Tree A) -> (Tree A))))
  (define (del-right left x right)
    (if (symbol=? 'black (color right))
        (bal-right left x (delete-helper key right func))
        (RBNode red left x (delete-helper key right func))))
  (let ([root (RBNode-elem tre)]
        [left (RBNode-left tre)]
        [right (RBNode-right tre)])
    (cond
      [(func key root)
       (if (func root key) (append left right) (del-left left root right))]
      [(func root key) (del-right left root right)]
      [else (append left right)])))

(: rake-red : (All (A) ((Tree A) -> (Tree A))))
(define (rake-red tre)
  (if (null? tre)
      tre
      (RBNode red 
              (RBNode-left tre) 
              (RBNode-elem tre) 
              (RBNode-right tre))))

(: get-left : (All (A) ((Tree A) -> (Tree A))))
(define (get-left tree)
  (if (null? tree)
      (error "Tree empty" 'left)
      (RBNode-left tree)))

(: get-right : (All (A) ((Tree A) -> (Tree A))))
(define (get-right tree)
  (if (null? tree)
      (error "Tree empty" 'right)
      (RBNode-right tree)))

(: bal-left : (All (A) ((Tree A) A (Tree A) -> (Tree A))))
(define (bal-left left x right)
  (cond
    [(symbol=? 'red (color left)) 
     (RBNode red (rake-black left) x right)]
    [(symbol=? 'black (color right)) 
     (balance-helper (RBNode black left x (rake-red right)))]
    [(and (symbol=? 'red (color right)) (symbol=? 'black (color (get-left right))))
     (RBNode red (RBNode black left x (get-left (get-left right))) 
             (elem (get-left right)) 
             (balance-helper (RBNode black 
                                     (get-right (get-left right)) 
                                     (elem right) 
                                     (sub1 (get-right right)))))]
    [else (RBNode black left x right)]))

(: bal-right : (All (A) ((Tree A) A (Tree A) -> (Tree A))))
(define (bal-right left x right)
  (cond
    [(symbol=? 'red (color right)) 
     (RBNode red left x (rake-black right))]
    [(symbol=? 'black (color left)) 
     (balance-helper (RBNode black (rake-red left) x right))]
    [(and (symbol=? 'red (color left)) 
          (symbol=? 'black (color (get-right left)))) 
     (RBNode red (balance-helper (RBNode black 
                                         (sub1 (get-left left))
                                         (elem left)
                                         (get-left (get-right left))))
             (elem (get-right left))
             (RBNode black (get-right (get-right left)) x right))]
    [else (RBNode black left x right)]))

(: sub1 : (All (A) ((Tree A) -> (Tree A))))
(define (sub1 tree)
  (cond 
    [(null? tree) tree] 
    [(symbol=? 'black (color tree)) 
     (RBNode red 
             (RBNode-left tree) 
             (RBNode-elem tree) 
             (RBNode-right tree))]
    [else (error "Invariaance violation" 'sub1)]))

(: append : (All (A) ((Tree A) (Tree A) -> (Tree A))))
(define (append tree1 tree2)
  (let ([t1-color (color tree1)]
        [t2-color (color tree2)])
    (cond
      [(null? tree1) tree2]
      [(null? tree2) tree1]
      [(and (symbol=? 'red t1-color) (symbol=? 'red t2-color)) (appendRR tree1 tree2)]
      [(and (symbol=? 'black t1-color) (symbol=? 'black t2-color)) (appendBB tree1 tree2)]
      [(symbol=? 'red t2-color) (RBNode red (append tree1 (RBNode-left tree2)) 
                                        (RBNode-elem tree2) (RBNode-right tree2))]
      [else (RBNode red (RBNode-left tree1) (RBNode-elem tree1)
                    (append (RBNode-right tree1) tree2))])))

(: appendRR : (All (A) ((RBNode A) (RBNode A) -> (Tree A))))
(define (appendRR node1 node2)
  (let ([bc (append (RBNode-right node1) (RBNode-left node2))])
    (if (and (RBNode? bc) (symbol=? 'red (color bc)))
        (RBNode red 
                (RBNode red
                        (RBNode-left node1) 
                        (RBNode-elem node1) 
                        (RBNode-left bc))
                (RBNode-elem bc)
                (RBNode red 
                        (RBNode-right bc) 
                        (RBNode-elem node2) 
                        (RBNode-right node2)))
        (RBNode red 
                (RBNode-left node1) 
                (RBNode-elem node1) 
                (RBNode red bc 
                        (RBNode-elem node2) 
                        (RBNode-right node2))))))

(: appendBB : (All (A) ((RBNode A) (RBNode A) -> (Tree A))))
(define (appendBB node1 node2)
  (let ([bc (append (RBNode-right node1) (RBNode-left node2))])
    (if (and (RBNode? bc) (symbol=? 'red (color bc)))
        (RBNode red 
                (RBNode red 
                        (RBNode-left node1) 
                        (RBNode-elem node1) 
                        (RBNode-left bc))
                (RBNode-elem bc)
                (RBNode red 
                        (RBNode-right bc) 
                        (RBNode-elem node2) 
                        (RBNode-right node2)))
        (bal-left (RBNode-left node1) 
                  (RBNode-elem node1) 
                  (RBNode black bc 
                          (RBNode-elem node2) 
                          (RBNode-right node2))))))

(: redblacktree->list : (All (A) ((RBTree A) -> (Listof A))))
(define (redblacktree->list redblacktree)
  (if (empty? redblacktree)
      null
      (let ([root (elem (RBTree-tree redblacktree))])
        (cons root (redblacktree->list (delete root redblacktree))))))

(: redblacktree : (All (A) ((A A -> Boolean) A * -> (RBTree A))))
(define (redblacktree func . lst)
  (foldl (inst insert A) ((inst RBTree A) func empty) lst))


;; similar to list map function. apply is expensive so using case-lambda
;; in order to saperate the more common case
(: rb-map : 
   (All (A C B ...) 
        (case-lambda 
          ((C C -> Boolean) (A -> C) (RBTree A) -> (RBTree C))
          ((C C -> Boolean)
           (A B ... B -> C) (RBTree A) (RBTree B) ... B -> (RBTree C)))))
(define rb-map
  (pcase-lambda: (A C B ...)
                 [([comp : (C C -> Boolean)]
                   [func : (A -> C)]
                   [heap : (RBTree A)])
                  (map-single ((inst RBTree C) comp empty) func heap)]
                 [([comp : (C C -> Boolean)]
                   [func : (A B ... B -> C)]
                   [heap : (RBTree A)] . [heaps : (RBTree B) ... B])
                  (apply map-multiple
                         ((inst RBTree C) comp empty)
                         func heap heaps)]))


(: map-single : (All (A C) ((RBTree C) (A -> C) (RBTree A) -> (RBTree C))))
(define (map-single accum func heap)
  (if (empty? heap)
      accum
      (map-single (insert (func (root heap)) accum)
                  func
                  (delete-root heap))))

(: map-multiple : 
   (All (A C B ...) 
        ((RBTree C) (A B ... B -> C) (RBTree A) (RBTree B) ... B -> (RBTree C))))
(define (map-multiple accum func heap . heaps)
  (if (or (empty? heap) (ormap empty? heaps))
      accum
      (apply map-multiple
             (insert (apply func
                            (root heap)
                            (map root heaps))
                     accum)
             func 
             (delete-root heap)
             (map delete-root heaps))))


;; similar to list foldr or foldl
(: fold : 
   (All (A C B ...) 
        (case-lambda ((C A -> C) C (RBTree A) -> C)
                     ((C A B ... B -> C) C (RBTree A) (RBTree B) ... B -> C))))
(define fold
  (pcase-lambda: (A C B ...) 
                 [([func : (C A -> C)]
                   [base : C]
                   [heap  : (RBTree A)])
                  (if (empty? heap)
                      base
                      (fold func (func base (root heap))
                            (delete-root heap)))]
                 [([func : (C A B ... B -> C)]
                   [base : C]
                   [heap  : (RBTree A)] . [heaps : (RBTree B) ... B])
                  (if (or (empty? heap) (ormap empty? heaps))
                      base
                      (apply fold 
                             func 
                             (apply func base (root heap)
                                    (map root heaps))
                             (delete-root heap)
                             (map delete-root heaps)))]))


;; similar to list filter function
(: filter : (All (A) ((A -> Boolean) (RBTree A) -> (RBTree A))))
(define (filter func hep)
  (: inner : (All (A) ((A -> Boolean) (RBTree A) (RBTree A) -> (RBTree A))))
  (define (inner func hep accum)
    (if (empty? hep)
        accum
        (let ([head (root hep)]
              [tail (delete-root hep)])
          (if (func head)
              (inner func tail (insert head accum))
              (inner func tail accum)))))
  (inner func hep ((inst RBTree A) (RBTree-comparer hep) empty)))

;; similar to list remove function
(: remove : (All (A) ((A -> Boolean) (RBTree A) -> (RBTree A))))
(define (remove func hep)
  (: inner : (All (A) ((A -> Boolean) (RBTree A) (RBTree A) -> (RBTree A))))
  (define (inner func hep accum)
    (if (empty? hep)
        accum
        (let ([head (root hep)]
              [tail (delete-root hep)])
          (if (func head)
              (inner func tail accum)
              (inner func tail (insert head accum))))))
  (inner func hep ((inst RBTree A) (RBTree-comparer hep) empty)))
