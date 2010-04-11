#lang typed-scheme

(provide RBTree member? delete insert redblacktree 
         redblacktree->list root delete-root empty?)
(require scheme/match)
(define-struct: Red ())
(define-struct: Black ())
(define-type-alias Color (U Red Black))

(define-struct: (A) RBNode ([color : Color]
                            [left : (Tree A)]
                            [elem : A]
                            [right : (Tree A)]))
(define-struct: Mt ([color : Black]))
(define-type-alias Tree (All (A) (U Mt (RBNode A))))
(define-struct: (A) RBTree ([comparer : (A A -> Boolean)]
                            [tree : (Tree A)]))
(define black (make-Black))
(define red (make-Red))
(define empty (make-Mt black))

(: empty? : (All (A) ((RBTree A) -> Boolean)))
(define (empty? redblacktree)
  (Mt? (RBTree-tree redblacktree)))

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
  (if (Mt? tre) #f (member-help key tre func)))

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
  (if (Mt? tree)
      (error "Given tree is empty :" 'root)
      (RBNode-elem tree)))

(: root : (All (A) ((RBTree A) -> A)))
(define (root tree)
  (elem (RBTree-tree tree)))

(: balance : (All (A) ((RBTree A) -> (RBTree A))))
(define (balance tree)
  (make-RBTree (RBTree-comparer tree) 
               (balance-helper (RBTree-tree tree))))

(: balance-helper : (All (A) ((Tree A) -> (Tree A))))
(define (balance-helper tree)
  (match tree
    [(struct RBNode 
             ((struct Black ()) 
              (struct RBNode 
                      ((struct Red ()) 
                       (struct RBNode ((struct Red ()) a x b)) y c)) z d))
     (make-RBNode red (make-RBNode black a x b) y (make-RBNode black c z d))]
    [(struct RBNode 
             ((struct Black ()) 
              (struct RBNode 
                      ((struct Red ()) 
                       a x (struct RBNode ((struct Red ()) b y c)))) z d))
     (make-RBNode red (make-RBNode black a x b) y (make-RBNode black c z d))]
    [(struct RBNode 
             ((struct Black ()) 
              a x (struct RBNode 
                          ((struct Red ()) 
                           (struct RBNode ((struct Red ()) b y c)) z d))))
     (make-RBNode red (make-RBNode black a x b) y (make-RBNode black c z d))]
    [(struct RBNode 
             ((struct Black ()) 
              a x (struct RBNode 
                          ((struct Red ()) 
                           b y (struct RBNode ((struct Red ()) c z d))))))
     (make-RBNode red (make-RBNode black a x b) y (make-RBNode black c z d))]
    [else tree]))


(: color : (All (A) ((Tree A) -> Color)))
(define (color tree)
  (if (Mt? tree)
      black
      (RBNode-color tree)))


(: insert : (All (A) (A (RBTree A) -> (RBTree A))))
(define (insert elem tree)
  (let ([func (RBTree-comparer tree)])
    (make-RBTree func (make-black (ins elem (RBTree-tree tree) func)))))


(: ins : (All (A) (A (Tree A) (A A -> Boolean) -> (Tree A))))
(define (ins elem tree func)
  (if (Mt? tree) 
      (make-RBNode red empty elem empty)
      (ins-helper elem tree func)))

(: ins-helper : (All (A) (A (RBNode A) (A A -> Boolean) -> (Tree A))))
(define (ins-helper elem tree func)
  (let* ([nod-elem (RBNode-elem tree)]
         [left-cmp (func elem nod-elem)]
         [rgt-cmp (func nod-elem elem)]
         [left (RBNode-left tree)]
         [right (RBNode-right tree)]
         [color (RBNode-color tree)])
  (cond
    [(and left-cmp rgt-cmp) tree]
    [left-cmp 
     (balance-helper 
      (make-RBNode color (ins elem left func) nod-elem right))]
    [else 
     (balance-helper 
      (make-RBNode color left nod-elem (ins elem right func)))])))


(: make-black : (All (A) ((Tree A) -> (Tree A))))
(define (make-black tre)
  (if (Mt? tre) tre (make-RBNode black 
                                 (RBNode-left tre) 
                                 (RBNode-elem tre) 
                                 (RBNode-right tre))))

(: delete-root : (All (A) ((RBTree A) -> (RBTree A))))
(define (delete-root redblacktree)
  (if (empty? redblacktree)
      (error "Given tree is empty :" 'delete-root)
      (delete (root redblacktree) redblacktree)))

(: delete : (All (A) (A (RBTree A) -> (RBTree A))))
(define (delete key redblacktree)
  (let ([func (RBTree-comparer redblacktree)]
        [tree (RBTree-tree redblacktree)])
    (make-RBTree func (delete-helper key tree func))))
    
(: delete-helper : (All (A) (A (Tree A) (A A -> Boolean) -> (Tree A))))
(define (delete-helper key tre func)
  (if (Mt? tre)
      (error "Given key not found in the Tree :" 'delete)
      (del-help key tre func)))

(: del-help : (All (A) (A (RBNode A) (A A -> Boolean) -> (Tree A))))
(define (del-help key tre func)
  (: del-lft : (All (A) ((Tree A) A (Tree A) -> (Tree A))))
  (define (del-lft lft x rgt)
    (if (Black? (color lft))
        (bal-lft (delete-helper key lft func) x rgt)
        (make-RBNode red (delete-helper key lft func) x rgt)))
  (: del-rgt : (All (A) ((Tree A) A (Tree A) -> (Tree A))))
  (define (del-rgt lft x rgt)
    (if (Black? (color rgt))
        (bal-rgt lft x (delete-helper key rgt func))
        (make-RBNode red lft x (delete-helper key rgt func))))
  (let ([root (RBNode-elem tre)]
        [left (RBNode-left tre)]
        [right (RBNode-right tre)])
    (cond
      [(func key root)
       (if (func root key) 
           (append left right)
           (del-lft left root right))]
      [(func root key)
       (del-rgt left root right)]
      [else (append left right)])))

(: make-red : (All (A) ((Tree A) -> (Tree A))))
(define (make-red tre)
  (if (Mt? tre)
      tre
      (make-RBNode red 
                   (RBNode-left tre) 
                   (RBNode-elem tre) 
                   (RBNode-right tre))))

(: left : (All (A) ((Tree A) -> (Tree A))))
(define (left tree)
  (if (Mt? tree)
      (error "Tree empty" 'left)
      (RBNode-left tree)))

(: right : (All (A) ((Tree A) -> (Tree A))))
(define (right tree)
  (if (Mt? tree)
      (error "Tree empty" 'right)
      (RBNode-right tree)))

(: bal-lft : (All (A) ((Tree A) A (Tree A) -> (Tree A))))
(define (bal-lft lft x rgt)
  (cond
    [(Red? (color lft)) 
     (make-RBNode red (make-black lft) x rgt)]
    [(Black? (color rgt)) 
     (balance-helper (make-RBNode black lft x (make-red rgt)))]
    [(and (Red? (color rgt)) (Black? (color (left rgt))))
     (make-RBNode red (make-RBNode black lft x (left (left rgt))) 
                  (elem (left rgt)) 
                  (balance-helper (make-RBNode black 
                                               (right (left rgt)) 
                                               (elem rgt) 
                                               (sub1 (right rgt)))))]
    [else (make-RBNode black lft x rgt)]))

(: bal-rgt : (All (A) ((Tree A) A (Tree A) -> (Tree A))))
(define (bal-rgt lft x rgt)
  (cond
    [(Red? (color rgt)) 
     (make-RBNode red lft x (make-black rgt))]
    [(Black? (color lft)) 
     (balance-helper (make-RBNode black (make-red lft) x rgt))]
    [(and (Red? (color lft)) (Black? (color (right lft)))) 
     (make-RBNode red 
                  (balance-helper (make-RBNode black 
                                               (sub1 (left lft))
                                               (elem lft)
                                               (left (right lft))))
                  (elem (right lft))
                  (make-RBNode black (right (right lft)) x rgt))]
    [else (make-RBNode black lft x rgt)]))

(: sub1 : (All (A) ((Tree A) -> (Tree A))))
(define (sub1 tree)
  (cond 
    [(Mt? tree) tree] 
    [(Black? (color tree)) 
     (make-RBNode red 
                  (RBNode-left tree) 
                  (RBNode-elem tree) 
                  (RBNode-right tree))]
    [else (error "Invariaance violation" 'sub1)]))
      
(: append : (All (A) ((Tree A) (Tree A) -> (Tree A))))
(define (append tree1 tree2)
  (let ([t1-color (color tree1)]
        [t2-color (color tree2)])
    (cond
      [(Mt? tree1) tree2]
      [(Mt? tree2) tree1]
      [(and (Red? t1-color) (Red? t2-color)) (appendRR tree1 tree2)]
      [(and (Black? t1-color) (Black? t2-color)) (appendBB tree1 tree2)]
      [(Red? t2-color) (make-RBNode red (append tree1 (RBNode-left tree2)) 
                                    (RBNode-elem tree2) (RBNode-right tree2))]
      [else (make-RBNode red (RBNode-left tree1) (RBNode-elem tree1)
                         (append (RBNode-right tree1) tree2))])))
  
(: appendRR : (All (A) ((RBNode A) (RBNode A) -> (Tree A))))
(define (appendRR node1 node2)
  (let ([bc (append (RBNode-right node1) (RBNode-left node2))])
    (if (and (RBNode? bc) (Red? (color bc)))
        (make-RBNode red 
                     (make-RBNode red
                                  (RBNode-left node1) 
                                  (RBNode-elem node1) 
                                  (RBNode-left bc))
                     (RBNode-elem bc)
                     (make-RBNode red 
                                  (RBNode-right bc) 
                                  (RBNode-elem node2) 
                                  (RBNode-right node2)))
        (make-RBNode red 
                     (RBNode-left node1) 
                     (RBNode-elem node1) 
                     (make-RBNode red bc 
                                  (RBNode-elem node2) 
                                  (RBNode-right node2))))))

(: appendBB : (All (A) ((RBNode A) (RBNode A) -> (Tree A))))
(define (appendBB node1 node2)
  (let ([bc (append (RBNode-right node1) (RBNode-left node2))])
    (if (and (RBNode? bc) (Red? (color bc)))
        (make-RBNode red 
                     (make-RBNode red 
                                  (RBNode-left node1) 
                                  (RBNode-elem node1) 
                                  (RBNode-left bc))
                     (RBNode-elem bc)
                     (make-RBNode red 
                                  (RBNode-right bc) 
                                  (RBNode-elem node2) 
                                  (RBNode-right node2)))
        (bal-lft (RBNode-left node1) 
                 (RBNode-elem node1) 
                 (make-RBNode black bc 
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
  (foldl (inst insert A) ((inst make-RBTree A) func empty) lst))