#lang typed-scheme

(define-struct: Mt ())
(define-struct: (A) Tree ([elem : A]
                          [heaps : (Listof (Heap A))]))

(define-type-alias (Heap A) (U Mt (Tree A)))

(define-struct: (A) PairingHeap ([comparer : (A A -> Boolean)]
                                 [heap : (Heap A)]))

(define empty (make-Mt))

(: merge-pairs : (All (A) ((Listof (Heap A)) (A A -> Boolean) -> (Heap A))))
(define (merge-pairs lst comparer)
  (cond
    [(null? lst) empty]
    [(null? (cdr lst)) (car lst)]
    [else (in-merge (in-merge (car lst) (cadr lst) comparer) 
                    (merge-pairs (cddr lst) comparer) 
                    comparer)]))

(: is-empty? : (All (A) ((PairingHeap A) -> Boolean)))
(define (is-empty? lheap)
  (Mt? (PairingHeap-heap lheap)))


(: insert : (All (A) (A (PairingHeap A) -> (PairingHeap A))))
(define (insert elem lheap)
  (let ([comparer (PairingHeap-comparer lheap)])
    (make-PairingHeap comparer
                      (in-merge (make-Tree elem null) 
                                (PairingHeap-heap lheap)
                                comparer))))

(: merge : (All (A) ((PairingHeap A) (PairingHeap A) -> (PairingHeap A))))
(define (merge heap1 heap2)
  (let ([comparer (PairingHeap-comparer heap1)])
    (make-PairingHeap comparer
                      (in-merge (PairingHeap-heap heap1) 
                                (PairingHeap-heap heap2) 
                                comparer))))

(: in-merge : 
   (All (A) ((Heap A) (Heap A) (A A -> Boolean) -> (Heap A))))
(define (in-merge heap1 heap2 comparer)
  (cond
    [(Mt? heap2) heap1]
    [(Mt? heap1) heap2]
    [else (in-merge-helper heap1 heap2 comparer)]))

(: in-merge-helper : 
   (All (A) ((Tree A) (Tree A) (A A -> Boolean) -> (Heap A))))
(define (in-merge-helper tree1 tree2 comparer)
  (let ([tr1-elm (Tree-elem tree1)]
        [tr2-elm (Tree-elem tree2)]
        [tr1-heaps (Tree-heaps tree1)]
        [tr2-heaps (Tree-heaps tree2)])
    (if (comparer tr1-elm tr2-elm)
        (make-Tree tr1-elm (cons tree2 tr1-heaps))
        (make-Tree tr2-elm (cons tree1 tr2-heaps)))))

(: find-min : (All (A) ((PairingHeap A) -> A)))
(define (find-min lheap)
  (let ([heap (PairingHeap-heap lheap)]
        [comparer (PairingHeap-comparer lheap)])
    (if (Mt? heap)
        (error "Heap is empty :" 'find-min)
        (Tree-elem heap))))

(: delete-min : (All (A) ((PairingHeap A) -> (PairingHeap A))))
(define (delete-min lheap)
  (let ([heap (PairingHeap-heap lheap)]
        [comparer (PairingHeap-comparer lheap)])
    (if (Mt? heap)
        (error "Heap is empty :" 'delete-min)
        (make-PairingHeap comparer
                          (merge-pairs (Tree-heaps heap) comparer)))))

(: get-sorted-list : (All (A) ((PairingHeap A) -> (Listof A))))
(define (get-sorted-list lheap)
  (: helper : (All (A) ((PairingHeap A) (Listof A) -> (Listof A))))
  (define (helper inheap lst)
    (let ([heap (PairingHeap-heap inheap)])
      (if (Mt? heap)
          lst
          (helper (delete-min inheap) (cons (find-min inheap) lst)))))
  (helper lheap null))

(: pairingheap : (All (A) ((Listof A) (A A -> Boolean) -> (PairingHeap A))))
(define (pairingheap lst comparer)
  (if (null? lst)
      (error "At least one element expected in the input list" 'leftistheap)
      (foldl (inst insert A) 
             (make-PairingHeap comparer 
                               (make-Tree (car lst) null))
             (cdr lst))))