#lang typed/racket

(provide treap treap/priority Treap treap->list empty? contains? insert delete size find-min/max
         delete delete-min/max insert/priority root root/priority delete-root fold filter remove
         build-treap
         (rename-out [treap-map map] [treap-andmap andmap]
                     [treap-ormap ormap]))

(struct: (A) Node
         ([elem  : A]
          [left  : (Tree A)]
          [right : (Tree A)]
          [prio  : Real]))

(define-type (Tree A) (U Null (Node A)))

(define-type (Func A) (A A -> Boolean))

(struct: (A) Treap
         ([comparer : (Func A)]
          [tree     : (Tree A)]
          [size     : Integer]))

(define empty null)

;; Checks for the empty treap
(: empty? : (All (A) ((Treap A) -> Boolean)))
(define (empty? treap)
  (null? (Treap-tree treap)))

;; Checks if the given heap contains a specific element
(: contains? (All (A) (A (Treap A) -> Boolean)))
(define (contains? elem treap)
  (define comp (Treap-comparer treap))
  (let helper ([tree (Treap-tree treap)])
    (if (null? tree)
        #f
        (let* ([node-elem (Node-elem tree)]
               [lt (comp elem node-elem)]
               [gt (comp node-elem elem)])
          (cond
            [(not (or lt gt)) #t]
            [lt (helper (Node-left tree))]
            [else (helper (Node-right tree))])))))

;; Returns the root element of the given treap. 
(: root : (All (A) ((Treap A) -> A)))
(define (root treap)
  (let ([tree (Treap-tree treap)])
    (if (null? tree)
        (error 'root "given treap is empty")
        (Node-elem tree))))

;; Returns the root priority of the given treap. 
(: root/priority : (All (A) ((Treap A) -> Real)))
(define (root/priority treap)
  (let ([tree (Treap-tree treap)])
    (if (null? tree)
        (error 'root "given treap is empty")
        (Node-prio tree))))

;; inserts the given element into the treap with the given priority
(: insert/priority : (All (A) (A Real (Treap A) -> (Treap A))))
(define (insert/priority elem priority treap)
  (let ([comp (Treap-comparer treap)]
        [tree (Treap-tree treap)])
    (Treap comp
           (insert-helper elem comp tree priority)
           (add1 (Treap-size treap)))))

;; inserts the given element into the treap
(: insert : (All (A) (A (Treap A) -> (Treap A))))
(define (insert elem treap)
  (insert/priority elem (random) treap))

;(: xor : Boolean Boolean -> Boolean)
(define-syntax-rule (xor l r)
  (or (and l r) (and (not l) (not r))))

;; A helper function fot the insert. Works on the tree maintained insisde 
;; a treap.
(: insert-helper : (All (A) (A (Func A) (Tree A) Real -> (Node A))))
(define (insert-helper elem comp tree prioity)
  (cond
    [(null? tree) (Node elem null null prioity)]
    [else
     (let* ([val (Node-elem tree)]
            [left (Node-left tree)]
            [right (Node-right tree)]
            [prio (Node-prio tree)]
            [lt (comp elem val)]
            [gt (comp val elem)])
       (cond
         ;[(xor lt gt) tree] ;; If uncommented, the elements of tree/treap 
                             ;; will not be duplicated 
         [lt   (let ([t (insert-helper elem comp left prioity)])
                 (rotate (Node-elem t) (Node-prio t) val prio 
                         (Node-left t) (Node-right t) right))]
         [else (let ([t (insert-helper elem comp right prioity)])
                 (rotate val prio (Node-elem t) 
                         (Node-prio t) left (Node-left t) (Node-right t)))]))]))


;(: rotate : (All (A) (A Real A Real (Tree A) (Tree A) (Tree A) -> (Node A))))
(define-syntax-rule (rotate val1 prio1 val2 prio2 t1 t2 t3)
  (if (< prio1 prio2)
      (Node val1 t1 (Node val2 t2 t3 prio2) prio1)
      (Node val2 (Node val1 t1 t2 prio1) t3 prio2)))

;; Returns the min/max element of the given treap.
(: find-min/max : (All (A) ((Treap A) -> A)))
(define (find-min/max treap)
  (: local : (Tree A) -> A)
  (define (local tree)
    (let: loop : A ([tree : (Tree A) tree])
          (if (null? tree)
              (error 'find-min/max "given treap is empty")
              (with-handlers ([exn:fail? (lambda (error?)
                                           (Node-elem tree))])
                (loop (Node-left tree))))))
  (local (Treap-tree treap)))

;; Gives the size of the given treap.
(: size : (All (A) ((Treap A) -> Integer)))
(define (size treap)
  (Treap-size treap))

;; Deletes the given element from the given treap.
(: delete : (All (A) (A (Treap A) -> (Treap A))))
(define (delete elem treap)
  (let ([comparer (Treap-comparer treap)])
    (Treap comparer
           (delete-helper elem comparer (Treap-tree treap))
           (sub1 (Treap-size treap)))))

;; Deletes the min or max element from the given treap.
(: delete-min/max : (All (A) (Treap A) -> (Treap A)))
(define (delete-min/max treap)
  (if (empty? treap)
      (error 'delete-min/max "given treap is empty")
      (delete (find-min/max treap) treap)))

;; Helper function for the delete function. Operates on the tree from the 
;; treap(given to the delete function).
(: delete-helper : (All (A) (A (A A -> Boolean) (Tree A) -> (Tree A))))
(define (delete-helper elem comp tree)
  (if (null? tree)
      (error 'delete "given treap is empty")
      (let* ([node-elem (Node-elem tree)]
             [lt (comp elem node-elem)]
             [gt (comp node-elem elem)])
        (cond
          [(xor lt gt) (delete-root tree)]
          [lt (Node node-elem
                    (delete-helper elem comp (Node-left tree))
                    (Node-right tree)
                    (Node-prio tree))]
          [else (Node node-elem
                      (Node-left tree)
                      (delete-helper elem comp (Node-right tree))
                      (Node-prio tree))]))))

;; Actual delete operationtakes place in this function.
(: delete-root : (All (A) (Node A) -> (Tree A)))
(define (delete-root tree)
  (let ([left (Node-left tree)]
        [right (Node-right tree)])
    (cond
      [(null? left) right]
      [(null? right) left]
      [else
       (let ([lprio (Node-prio left)]
             [rprio (Node-prio right)]
             [lelem (Node-elem left)]
             [tree-elem (Node-elem tree)]
             [tree-prio (Node-prio tree)])
       (if (< lprio rprio) 
           (Node lelem 
                 (Node-left left)
                 (delete-root (Node tree-elem (Node-right left) 
                                    right tree-prio))
                 lprio)
           (Node (Node-elem right) 
                 (delete-root (Node tree-elem left 
                                    (Node-left right) tree-prio))
                 (Node-right right) 
                 rprio)))])))



;; Constructor function for the treap data structure.
(: treap : (All (A) (A A -> Boolean) A * -> (Treap A)))
(define (treap comp . list)
  (foldl (inst insert A) ((inst Treap A) comp null 0) list))

;; Constructor function for the treap data structure with priorities.
(: treap/priority : (All (A) (A A -> Boolean) (Pairof A Real) * -> (Treap A)))
(define (treap/priority comp . list)
  (foldl (λ ([p : (Pairof A Real)] [treap : (Treap A)])
           (insert/priority (car p) (cdr p) treap))
         ((inst Treap A) comp null 0) list))

;; Creates a list of elements from the given treap.
(: treap->list : (All (A) (Treap A) -> (Listof A)))
(define (treap->list treap)
  (: helper : (Tree A) -> (Listof A))
  (define (helper tree)
    (if (null? tree)
        null
        (cons (Node-elem tree) (append (helper (Node-left tree))
                                       (helper (Node-right tree))))))
  (helper (Treap-tree treap)))


;; similar to list map function. apply is expensive so using case-lambda
;; in order to saperate the more common case
(: treap-map : 
   (All (A C B ...) 
        (case-lambda 
          ((C C -> Boolean) (A -> C) (Treap A) -> (Treap C))
          ((C C -> Boolean)
           (A B ... B -> C) (Treap A) (Treap B) ... B -> (Treap C)))))
(define treap-map
  (pcase-lambda: (A C B ...)
                 [([comp : (C C -> Boolean)]
                   [func : (A -> C)]
                   [treap : (Treap A)])
                  (map-single comp func treap)]
                 [([comp : (C C -> Boolean)]
                   [func : (A B ... B -> C)]
                   [treap : (Treap A)] . [treaps : (Treap B) ... B])
                  (apply map-multiple
                         ((inst Treap C) comp empty 0)
                         func treap treaps)]))


(: map-single : (All (A C) ((C C -> Boolean) (A -> C) (Treap A) -> (Treap C))))
(define (map-single comp func treap)
  (: helper : (Tree A) -> (Tree C))
  (define (helper tree)
    (if (null? tree)
        empty
        (Node (func   (Node-elem tree)) 
              (helper (Node-left tree))
              (helper (Node-right tree))
              (Node-prio tree))))
  (Treap comp (helper (Treap-tree treap)) (Treap-size treap)))


(: delete-help : (All (A) (Treap A) -> (Treap A)))
(define (delete-help treap)
  (delete (root treap) treap))

(: map-multiple :
   (All (A C B ...)
        ((Treap C) (A B ... B -> C) (Treap A) (Treap B) ... B -> (Treap C))))
(define (map-multiple accum func treap . treaps)
  (if (or (empty? treap) (ormap empty? treaps))
      accum
      (apply map-multiple
             (insert (apply func (root treap) (map root treaps))
                     accum)
             func
             (delete-help treap)
             (map delete-help treaps))))


;; similar to list foldr or foldl
(: fold : 
   (All (A C B ...) 
        (case-lambda ((C A -> C) C (Treap A) -> C)
                     ((C A B ... B -> C) C (Treap A) (Treap B) ... B -> C))))
(define fold
  (pcase-lambda: (A C B ...) 
                 [([func : (C A -> C)]
                   [base : C]
                   [treap  : (Treap A)])
                  (if (empty? treap)
                      base
                      (let ([root (root treap)])
                        (fold func (func base root)
                              (delete root treap))))]
                 [([func : (C A B ... B -> C)]
                   [base : C]
                   [treap  : (Treap A)] . [treaps : (Treap B) ... B])
                  (if (or (empty? treap) (ormap empty? treaps))
                      base
                      (apply fold 
                             func 
                             (apply func base (root treap)
                                    (map root treaps))
                             (delete-help treap)
                             (map delete-help treaps)))]))

;; similar to list filter function
(: filter : (All (A) ((A -> Boolean) (Treap A) -> (Treap A))))
(define (filter func treap)
  (: inner : (A -> Boolean) (Treap A) (Treap A) -> (Treap A))
  (define (inner func treap accum)
    (if (empty? treap)
        accum
        (let* ([head (find-min/max treap)]
               [tail (delete head treap)])
          (if (func head)
              (inner func tail (insert head accum))
              (inner func tail accum)))))
  (inner func treap ((inst Treap A) (Treap-comparer treap) empty 0)))

;; similar to list filter function
(: remove : (All (A) ((A -> Boolean) (Treap A) -> (Treap A))))
(define (remove func treap)
  (: inner : (A -> Boolean) (Treap A) (Treap A) -> (Treap A))
  (define (inner func treap accum)
    (if (empty? treap)
        accum
        (let* ([head (find-min/max treap)]
               [tail (delete head treap)])
          (if (func head)
              (inner func tail accum)
              (inner func tail (insert head accum))))))
  (inner func treap ((inst Treap A) (Treap-comparer treap) empty 0)))


;; Similar to build-list
(: build-treap : (All (A) (Natural (Natural -> A) (A A -> Boolean) -> (Treap A))))
(define (build-treap size func comparer)
  (let: loop : (Treap A) ([n : Natural size])
        (if (zero? n)
            ((inst Treap A) comparer empty 0)
            (let ([nsub1 (sub1 n)])
              (insert (func nsub1) (loop nsub1))))))


;; similar to list andmap function
(: treap-andmap : 
   (All (A B ...) 
        (case-lambda ((A -> Boolean) (Treap A) -> Boolean)
                     ((A B ... B -> Boolean) (Treap A) (Treap B) ... B 
                                             -> Boolean))))
(define treap-andmap
  (pcase-lambda: (A B ... ) 
                 [([func  : (A -> Boolean)]
                   [treap : (Treap A)])
                  (or (empty? treap)
                      (and (func (root treap))
                           (treap-andmap func (delete-help treap))))]
                 [([func  : (A B ... B -> Boolean)]
                   [treap : (Treap A)] . [treaps : (Treap B) ... B])
                  (or (empty? treap) (ormap empty? treaps)
                      (and (apply func (root treap) 
                                  (map root treaps))
                           (apply treap-andmap func (delete-help treap) 
                                  (map delete-help treaps))))]))

;; Similar to ormap
(: treap-ormap : 
   (All (A B ...) 
        (case-lambda ((A -> Boolean) (Treap A) -> Boolean)
                     ((A B ... B -> Boolean) (Treap A) (Treap B) ... B 
                                             -> Boolean))))
(define treap-ormap
  (pcase-lambda: (A B ... ) 
                 [([func  : (A -> Boolean)]
                   [treap : (Treap A)])
                  (and (not (empty? treap))
                       (or (func (root treap))
                           (treap-ormap func (delete-help treap))))]
                 [([func  : (A B ... B -> Boolean)]
                   [treap : (Treap A)] . [treaps : (Treap B) ... B])
                  (and (not (or (empty? treap) (ormap empty? treaps)))
                       (or (apply func (root treap) 
                                  (map root treaps))
                           (apply treap-ormap func (delete-help treap) 
                                  (map delete-help treaps))))]))
