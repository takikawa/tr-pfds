#lang typed/scheme

(provide (rename-out [heap-map map]) fold  filter remove
         empty? insert find-min/max delete-min/max empty
         merge sorted-list heap BSHeap Heap)

(require (prefix-in ph: "pairingheap.ss")
         scheme/match)

(define-struct: Mt ())

(define-struct: (A) IntHeap ([elem : A]
                             [heap : (ph:Heap (IntHeap A))]))

(define-type-alias (Heaps A) (U Mt (IntHeap A)))

(define-struct: (A) BSHeap ([comparer : (A A -> Boolean)]
                            [heap : (Heaps A)]))

(define-type-alias (Heap A) (BSHeap A))

(define empty (make-Mt))

(: empty? : (All (A) ((BSHeap A) -> Boolean)))
(define (empty? bsheap)
  (let ([hp (BSHeap-heap bsheap)])
    (if (Mt? hp) #t (ph:empty? (IntHeap-heap hp)))))


(: merge : (All (A) ((BSHeap A) (BSHeap A) -> (BSHeap A))))
(define (merge heap1 heap2)
  (let ([func (BSHeap-comparer heap1)]
        [inheap1 (BSHeap-heap heap1)]
        [inheap2 (BSHeap-heap heap2)])
    (make-BSHeap func (merge-help inheap1 inheap2 func))))

(: merge-help : (All (A) ((Heaps A) (Heaps A) (A A -> Boolean) -> (Heaps A))))
(define (merge-help heap1 heap2 func)
  (cond
    [(Mt? heap1) heap2]
    [(Mt? heap2) heap1]
    [else (let ([elem1 (IntHeap-elem heap1)]
                [elem2 (IntHeap-elem heap2)]
                [p1 (IntHeap-heap heap1)]
                [p2 (IntHeap-heap heap2)]) 
            (if (func elem1 elem2)
                (make-IntHeap elem1 (ph:insert heap2 p1))
                (make-IntHeap elem2 (ph:insert heap1 p2))))]))

(: insert : (All (A) (A (BSHeap A) -> (BSHeap A))))
(define (insert elem bsheap)
  (let ([func (BSHeap-comparer bsheap)]
        [inheap (BSHeap-heap bsheap)])
    (: comp : ((IntHeap A) (IntHeap A) -> Boolean))
    (define (comp h1 h2)
      (cond
        [(Mt? h1) #f]
        [(Mt? h2) #f]
        [else (func (IntHeap-elem h1) (IntHeap-elem h2))]))
    (make-BSHeap func 
                 (merge-help (make-IntHeap elem 
                                        (ann ((inst ph:heap (IntHeap A)) 
                                              comp)
                                             (ph:Heap (IntHeap A))))
                             inheap func))))


(: find-min/max : (All (A) ((BSHeap A) -> A)))
(define (find-min/max bsheap)
  (let ([heap (BSHeap-heap bsheap)])
    (if (Mt? heap)
        (error 'find-min/max "given heap is empty")
        (IntHeap-elem heap))))

(: delete-min/max : (All (A) ((BSHeap A) -> (BSHeap A))))
(define (delete-min/max bsheap)
  (let ([heap (BSHeap-heap bsheap)]
        [func (BSHeap-comparer bsheap)])
    (if (Mt? heap)
        (error 'delete-min/max "given heap is empty")
        (let ([bheap (IntHeap-heap heap)])
          (if (ph:empty? bheap)
              ((inst make-BSHeap A) func (ann (make-Mt) (Heaps A)))
              (let ([min-heap (ph:find-min/max bheap)]
                    [del (ph:delete-min/max bheap)])
                (make-BSHeap func 
                             (make-IntHeap (IntHeap-elem min-heap) 
                                        (ph:merge (IntHeap-heap min-heap) 
                                                  del)))))))))

(: heap : (All (A) ((A A -> Boolean) A * -> (BSHeap A))))
(define (heap func . lst)
  (: comp : ((Heaps A) (Heaps A) -> Boolean))
  (define (comp h1 h2)
    (cond
      [(Mt? h1) #f]
      [(Mt? h2) #f]
      [else (func (IntHeap-elem h1) (IntHeap-elem h2))]))
  (foldl (inst insert A)
         ((inst make-BSHeap A) func (ann (make-Mt) (Heaps A)))
         lst))

(: sorted-list : (All (A) ((BSHeap A) -> (Listof A))))
(define (sorted-list bsheap)
  (let ([heap (BSHeap-heap bsheap)])
    (cond 
      [(Mt? heap) null]
      [(ph:empty? (IntHeap-heap heap)) (list (IntHeap-elem heap))]
      [else (cons (find-min/max bsheap) 
                  (sorted-list (delete-min/max bsheap)))])))


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
  (apply in-map ((inst make-BSHeap C) comp empty) func fst rst))


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
  (inner func hep ((inst make-BSHeap A) (BSHeap-comparer hep) empty)))


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
  (inner func hep ((inst make-BSHeap A) (BSHeap-comparer hep) empty)))

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
