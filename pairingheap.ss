#lang typed-scheme

(provide (rename-out [heap-map map]) fold  filter remove Heap empty?
         heap merge insert find-min/max delete-min/max sorted-list)

(define-struct: Mt ())
(define-struct: (A) Tree ([elem : A]
                          [heaps : (Listof (IntHeap A))]))

(define-type-alias (IntHeap A) (U Mt (Tree A)))

(define-struct: (A) PairingHeap ([comparer : (A A -> Boolean)]
                                 [heap : (IntHeap A)]))

(define-type-alias (Heap A) (PairingHeap A))
  
(define empty (make-Mt))

(: merge-pairs : (All (A) ((Listof (IntHeap A)) (A A -> Boolean) -> (IntHeap A))))
(define (merge-pairs lst comparer)
  (cond
    [(null? lst) empty]
    [(null? (cdr lst)) (car lst)]
    [else (in-merge (in-merge (car lst) (cadr lst) comparer) 
                    (merge-pairs (cddr lst) comparer) 
                    comparer)]))

(: empty? : (All (A) ((PairingHeap A) -> Boolean)))
(define (empty? pheap)
  (Mt? (PairingHeap-heap pheap)))


(: insert : (All (A) (A (PairingHeap A) -> (PairingHeap A))))
(define (insert elem pheap)
  (let ([comparer (PairingHeap-comparer pheap)])
    (make-PairingHeap comparer
                      (in-merge (make-Tree elem null) 
                                (PairingHeap-heap pheap)
                                comparer))))

(: merge : (All (A) ((PairingHeap A) (PairingHeap A) -> (PairingHeap A))))
(define (merge heap1 heap2)
  (let ([comparer (PairingHeap-comparer heap1)])
    (make-PairingHeap comparer
                      (in-merge (PairingHeap-heap heap1) 
                                (PairingHeap-heap heap2) 
                                comparer))))

(: in-merge : 
   (All (A) ((IntHeap A) (IntHeap A) (A A -> Boolean) -> (IntHeap A))))
(define (in-merge heap1 heap2 comparer)
  (cond
    [(Mt? heap2) heap1]
    [(Mt? heap1) heap2]
    [else (in-merge-helper heap1 heap2 comparer)]))

(: in-merge-helper : 
   (All (A) ((Tree A) (Tree A) (A A -> Boolean) -> (IntHeap A))))
(define (in-merge-helper tree1 tree2 comparer)
  (let ([tr1-elm (Tree-elem tree1)]
        [tr2-elm (Tree-elem tree2)]
        [tr1-heaps (Tree-heaps tree1)]
        [tr2-heaps (Tree-heaps tree2)])
    (if (comparer tr1-elm tr2-elm)
        (make-Tree tr1-elm (cons tree2 tr1-heaps))
        (make-Tree tr2-elm (cons tree1 tr2-heaps)))))

(: find-min/max : (All (A) ((PairingHeap A) -> A)))
(define (find-min/max pheap)
  (let ([heap (PairingHeap-heap pheap)]
        [comparer (PairingHeap-comparer pheap)])
    (if (Mt? heap)
        (error 'find-min/max "given heap is empty")
        (Tree-elem heap))))

(: delete-min/max  : (All (A) ((PairingHeap A) -> (PairingHeap A))))
(define (delete-min/max pheap)
  (let ([heap (PairingHeap-heap pheap)]
        [comparer (PairingHeap-comparer pheap)])
    (if (Mt? heap)
        (error 'delete-min/max "given heap is empty")
        (make-PairingHeap comparer
                          (merge-pairs (Tree-heaps heap) comparer)))))


(: heap-map : (All (A C B ...) ((C C -> Boolean) (A B ... B -> C) (Heap A) (Heap B) ... B -> (Heap C))))
(define (heap-map comp func fst . rst)
  (: in-map : (All (A C B ...) ((Heap C) (A B ... B -> C) (Heap A) (Heap B) ... B -> (Heap C))))
  (define (in-map accum func fst . rst)
    (if (or (empty? fst) (ormap empty? rst))
        accum
        (apply in-map
               (insert (apply func (find-min/max fst) (map find-min/max rst)) accum)
               func
               (delete-min/max fst) 
               (map delete-min/max rst))))
  (apply in-map ((inst make-PairingHeap C) comp (make-Mt)) func fst rst))


(: filter : (All (A) ((A -> Boolean) (Heap A) -> (Heap A))))
(define (filter func hep)
  (: inner : (All (A) ((A -> Boolean) (Heap A) (Heap A) -> (Heap A))))
  (define (inner func hep accum)
    (if (empty? hep)
        accum
        (let ([head (find-min/max hep)]
              [tail (delete-min/max hep)])
          (if (func head)
              (inner func tail (insert head accum))
              (inner func tail accum)))))
  (inner func hep ((inst make-PairingHeap A)
                   (PairingHeap-comparer hep)
                   (make-Mt))))


(: remove : (All (A) ((A -> Boolean) (Heap A) -> (Heap A))))
(define (remove func hep)
  (: inner : (All (A) ((A -> Boolean) (Heap A) (Heap A) -> (Heap A))))
  (define (inner func hep accum)
    (if (empty? hep)
        accum
        (let ([head (find-min/max hep)]
              [tail (delete-min/max hep)])
          (if (func head)
              (inner func tail accum)
              (inner func tail (insert head accum))))))
  (inner func hep ((inst make-PairingHeap A)
                   (PairingHeap-comparer hep)
                   (make-Mt))))


(: sorted-list : (All (A) ((PairingHeap A) -> (Listof A))))
(define (sorted-list pheap)
  (if (Mt? (PairingHeap-heap pheap))
      null
      (cons (find-min/max pheap) (sorted-list (delete-min/max pheap)))))

(: heap : (All (A) ((A A -> Boolean) A * -> (PairingHeap A))))
(define (heap comparer . lst)
  (let ([first ((inst make-PairingHeap A) comparer (make-Mt))])
    (foldl (inst insert A) first lst)))

(: fold : (All (A C B ...)
               ((C A B ... B -> C) C (Heap A) (Heap B) ... B -> C)))
(define (fold func base hep . heps)
  (if (or (empty? hep) (ormap empty? heps))
      base
      (apply fold 
             func 
             (apply func base (find-min/max hep) (map find-min/max heps))
             (delete-min/max hep)
             (map delete-min/max heps))))
