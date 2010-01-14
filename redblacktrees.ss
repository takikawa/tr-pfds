#lang typed-scheme

(define-type-alias Red 'red)
(define-type-alias Black 'black)
(define-type-alias Color (U Red Black))

(define-struct: (A) RBNode ([color : Color]
                            [left : (Tree A)]
                            [elem : A]
                            [right : (Tree A)]))
(define-struct: EmptyNode ([color : Black]))
(define-type-alias Tree (All (A) (U EmptyNode (RBNode A))))
(define-struct: (A) RBTree ([comparer : (A A -> Boolean)]
                            [tree : (Tree A)]))

(define empty (make-EmptyNode 'black))

(: member? : (All (A) (A (RBTree A) -> Boolean)))
(define (member? key rbtree)
  (let ([func (RBTree-comparer rbtree)]
        [tre (RBTree-tree rbtree)])
    (cond
      [(EmptyNode? tre) #f]
      [(and (func (RBNode-elem tre) key) (func key (RBNode-elem tre))) #t]
      [(func key (RBNode-elem tre)) (member? key (make-RBTree func (RBNode-left tre)))]
      [else (member? key (make-RBTree func (RBNode-right tre)))])))

(: elem : (All (A) ((Tree A) -> A)))
(define (elem tree)
  (if (EmptyNode? tree)
      (error "Empty Tree" 'elem)
      (RBNode-elem tree)))

(: color : (All (A) ((Tree A) -> Color)))
(define (color tree)
  (if (EmptyNode? tree)
      'black
      (RBNode-color tree)))

(: left-color : (All (A) ((Tree A) -> Color)))
(define (left-color tree)
  (if (EmptyNode? tree)
      'black
      (color (RBNode-left tree))))

(: rgt-color : (All (A) ((Tree A) -> Color)))
(define (rgt-color tree)
  (if (EmptyNode? tree)
      'black
      (color (RBNode-right tree))))

(: left : (All (A) ((Tree A) -> (Tree A))))
(define (left tree)
  (if (EmptyNode? tree)
      (error "Tree empty" 'left)
      (RBNode-left tree)))

(: right : (All (A) ((Tree A) -> (Tree A))))
(define (right tree)
  (if (EmptyNode? tree)
      (error "Tree empty" 'right)
      (RBNode-right tree)))

(: Red? : (Color -> Boolean))
(define (Red? color)
  (eq? color 'red))

(: Black? : (Color -> Boolean))
(define (Black? color)
  (not (Red? color)))

(: balance : (All (A) ((Tree A) -> (Tree A))))
(define (balance tree)
  (if (EmptyNode? tree) 
      tree 
      (balance-helper tree)))

(: balance-helper : (All (A) ((RBNode A) -> (Tree A))))
(define (balance-helper tree)
  (let* ([tree-color (color tree)]
         [tree-black? (Black? tree-color)]
         [lft (RBNode-left tree)]
         [rgt (RBNode-right tree)]
         [val (RBNode-elem tree)]
         [left-red? (Red? (color lft))]
         [right-red? (Red? (color rgt))])
  (cond
    [(and tree-black? left-red? (Red? (left-color lft)))
     (let ([l-l (left lft)])
       (make-RBNode 'red
                    (make-RBNode 'black (left l-l) (elem l-l) (right l-l))
                    (elem lft)
                    (make-RBNode 'black (right lft) val rgt)))]
    [(and tree-black? left-red? (Red? (rgt-color lft)))
     (let ([r-l (right lft)])
       (make-RBNode 'red
                    (make-RBNode 'black (left lft) (elem lft) (left r-l))
                    (elem r-l)
                    (make-RBNode 'black (right r-l) val rgt)))]
    [(and tree-black? right-red? (Red? (left-color rgt)))
     (let ([l-r (left rgt)])
       (make-RBNode 'red
                    (make-RBNode 'black lft val (left l-r))
                    (elem l-r)
                    (make-RBNode 'black (right l-r) (elem rgt) (right rgt))))]
    [(and tree-black? right-red? (Red? (rgt-color rgt)))
     (let ([r-r (right rgt)])
       (make-RBNode 'red
                    (make-RBNode 'black lft val (left rgt))
                    (elem rgt)
                    (make-RBNode 'black (left r-r) (elem r-r) (right r-r))))]
    [else tree])))

(: insert : (All (A) (A (RBTree A) -> (RBTree A))))
(define (insert elem tree)
  (make-RBTree (RBTree-comparer tree) 
               (make-black (ins elem 
                                (RBTree-tree tree) 
                                (RBTree-comparer tree)))))

(: make-black : (All (A) ((Tree A) -> (Tree A))))
(define (make-black tre)
  (if (EmptyNode? tre)
      tre
      (make-RBNode 'black (RBNode-left tre) (RBNode-elem tre) (RBNode-right tre))))

(: make-red : (All (A) ((Tree A) -> (Tree A))))
(define (make-red tre)
  (if (EmptyNode? tre)
      tre
      (make-RBNode 'red (RBNode-left tre) (RBNode-elem tre) (RBNode-right tre))))

(: ins : (All (A) (A (Tree A) (A A -> Boolean) -> (Tree A))))
(define (ins elem tree func)
  (cond
    [(EmptyNode? tree) (make-RBNode 'red empty elem empty)]
    [(and (func elem (RBNode-elem tree)) (func (RBNode-elem tree) elem)) tree]
    [(func elem (RBNode-elem tree)) (balance (make-RBNode (RBNode-color tree)
                                                          (ins elem (RBNode-left tree) func)
                                                          (RBNode-elem tree)
                                                          (RBNode-right tree)))]
    [else (balance (make-RBNode (RBNode-color tree)
                                (RBNode-left tree)
                                (RBNode-elem tree)
                                (ins elem (RBNode-right tree) func)))]))

(: delete : (All (A) (A (RBTree A) -> (RBTree A))))
(define (delete key rbtree)
  (let ([func (RBTree-comparer rbtree)]
        [tree (RBTree-tree rbtree)])
    (make-RBTree func (delete-helper key tree func))))
    
(: delete-helper : (All (A) (A (Tree A) (A A -> Boolean) -> (Tree A))))
(define (delete-helper key tre func)
  (let: ([del-lft : (All (A) ((Tree A) A (Tree A) -> (Tree A)))
                  (lambda (lft x rgt)
                    (if (Black? (color lft))
                        (bal-lft (delete-helper key lft func) x rgt)
                        (make-RBNode 'red (delete-helper key lft func) x rgt)))]
         [del-rgt : (All (A) ((Tree A) A (Tree A) -> (Tree A)))
                  (lambda (lft x rgt)
                    (if (Black? (color rgt))
                        (bal-rgt lft x (delete-helper key rgt func))
                        (make-RBNode 'red lft x (delete-helper key rgt func))))])
    (cond
      [(EmptyNode? tre) (error "Given key not found in the Tree " 'delete)]
      [(and (func (RBNode-elem tre) key) (func key (RBNode-elem tre))) 
       (append (RBNode-left tre) (RBNode-right tre))]
      [(func key (RBNode-elem tre)) 
       (del-lft (RBNode-left tre) 
                (RBNode-elem tre) 
                (RBNode-right tre))]
      [else (del-rgt (RBNode-left tre) 
                     (RBNode-elem tre) 
                     (RBNode-right tre))])))

(: bal-lft : (All (A) ((Tree A) A (Tree A) -> (Tree A))))
(define (bal-lft lft x rgt)
  (cond
    [(Red? (color lft)) (make-RBNode 'red (make-black lft) x rgt)]
    [(Black? (color rgt)) (balance (make-RBNode 'black lft x (make-red rgt)))]
    [(and (Red? (color rgt)) (Black? (color (left rgt)))) 
     (make-RBNode 'red (make-RBNode 'black lft x (left (left rgt))) 
                  (elem (left rgt)) (balance (make-RBNode 'black 
                                                          (right (left rgt)) 
                                                          (elem rgt) (sub1 (right rgt)))))]
    [else (make-RBNode 'black lft x rgt)]))

(: bal-rgt : (All (A) ((Tree A) A (Tree A) -> (Tree A))))
(define (bal-rgt lft x rgt)
  (cond
    [(Red? (color rgt)) (make-RBNode 'red lft x (make-black rgt))]
    [(Black? (color lft)) (balance (make-RBNode 'black (make-red lft) x rgt))]
    [(and (Red? (color lft)) (Black? (color (right lft)))) 
     (make-RBNode 'red 
                  (balance (make-RBNode 'black 
                                        (sub1 (left lft))
                                        (elem lft)
                                        (left (right lft))))
                  (elem (right lft))
                  (make-RBNode 'black (right (right lft)) x rgt))]
    [else (make-RBNode 'black lft x rgt)]))

(: sub1 : (All (A) ((Tree A) -> (Tree A))))
(define (sub1 tree)
  (cond 
    [(EmptyNode? tree) tree] 
    [(Black? (color tree)) 
     (make-RBNode 'red (RBNode-left tree) (RBNode-elem tree) (RBNode-right tree))]
    [else (error "Invariaance violation" 'sub1)]))
      
(: append : (All (A) ((Tree A) (Tree A) -> (Tree A))))
(define (append tree1 tree2)
  (cond
    [(EmptyNode? tree1) tree2]
    [(EmptyNode? tree2) tree1]
    [(and (Red? (color tree1)) (Red? (color tree2))) (appendRR tree1 tree2)]
    [(and (Black? (color tree1)) (Black? (color tree2))) (appendBB tree1 tree2)]
    [(Red? (color tree2)) (make-RBNode 'red (append tree1 (RBNode-left tree2)) 
                                       (RBNode-elem tree2) (RBNode-right tree2))]
    [else (make-RBNode 'red (RBNode-left tree1) (RBNode-elem tree1) 
                       (append (RBNode-right tree1) tree2))]))

(: appendRR : (All (A) ((RBNode A) (RBNode A) -> (Tree A))))
(define (appendRR node1 node2)
  (let ([bc (append (RBNode-right node1) (RBNode-left node2))])
    (if (and (RBNode? bc) (Red? (color bc)))
        (make-RBNode 'red 
                     (make-RBNode 'red (RBNode-left node1) (RBNode-elem node1) (RBNode-left bc))
                     (RBNode-elem bc)
                     (make-RBNode 'red (RBNode-right bc) (RBNode-elem node2) (RBNode-right node2)))
        (make-RBNode 'red (RBNode-left node1) (RBNode-elem node1) 
                     (make-RBNode 'red bc (RBNode-elem node2) (RBNode-right node2))))))

(: appendBB : (All (A) ((RBNode A) (RBNode A) -> (Tree A))))
(define (appendBB node1 node2)
  (let ([bc (append (RBNode-right node1) (RBNode-left node2))])
    (if (and (RBNode? bc) (Red? (color bc)))
        (make-RBNode 'red 
                     (make-RBNode 'red (RBNode-left node1) (RBNode-elem node1) (RBNode-left bc))
                     (RBNode-elem bc)
                     (make-RBNode 'red (RBNode-right bc) (RBNode-elem node2) (RBNode-right node2)))
        (bal-lft (RBNode-left node1) (RBNode-elem node1) 
                  (make-RBNode 'black bc (RBNode-elem node2) (RBNode-right node2))))))

(: rbtree : (All (A) ((A A -> Boolean) (Listof A) -> (RBTree A))))
(define (rbtree func lst)
  (foldl (inst insert A) 
         (make-RBTree func (make-RBNode 'black empty (car lst) empty)) 
         (cdr lst)))