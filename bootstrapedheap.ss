#lang typed-scheme

(provide empty? insert find-min/max delete-min/max empty
         merge sorted-list bootstrapped-heap BSHeap)

(require (prefix-in bh: "binomialheap.ss")
         scheme/match)

(define-struct: Mt ())

(define-struct: (A) Heap ([elem : A]
                          [heap : (bh:BinomialHeap (Heap A))]))

(define-type-alias (Heaps A) (U Mt (Heap A)))

(define-struct: (A) BSHeap ([comparer : (A A -> Boolean)]
                            [heap : (Heaps A)]))


(define empty (make-Mt))

(: empty? : (All (A) ((BSHeap A) -> Boolean)))
(define (empty? bsheap)
  (let ([hp (BSHeap-heap bsheap)])
    (if (Mt? hp) #t (bh:empty? (Heap-heap hp)))))


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
    [else (let ([elem1 (Heap-elem heap1)]
                [elem2 (Heap-elem heap2)]
                [p1 (Heap-heap heap1)]
                [p2 (Heap-heap heap2)]) 
            (if (func elem1 elem2)
                (make-Heap elem1 (bh:insert heap2 p1))
                (make-Heap elem2 (bh:insert heap1 p2))))]))

(: insert : (All (A) (A (BSHeap A) -> (BSHeap A))))
(define (insert elem bsheap)
  (let ([func (BSHeap-comparer bsheap)]
        [inheap (BSHeap-heap bsheap)])
    (: comp : ((Heap A) (Heap A) -> Boolean))
    (define (comp h1 h2)
      (cond
        [(Mt? h1) #f]
        [(Mt? h2) #f]
        [else (func (Heap-elem h1) (Heap-elem h2))]))
    (make-BSHeap func 
                 (merge-help (make-Heap elem 
                                        (ann ((inst bh:binomialheap (Heap A)) 
                                              comp)
                                             (bh:BinomialHeap (Heap A))))
                             inheap func))))


(: find-min/max : (All (A) ((BSHeap A) -> A)))
(define (find-min/max bsheap)
  (let ([heap (BSHeap-heap bsheap)])
    (if (Mt? heap)
        (error "Heap is empty" 'find-min/max)
        (Heap-elem heap))))

(: delete-min/max : (All (A) ((BSHeap A) -> (BSHeap A))))
(define (delete-min/max bsheap)
  (let ([heap (BSHeap-heap bsheap)]
        [func (BSHeap-comparer bsheap)])
    (if (Mt? heap)
        (error "Heap is empty" 'delete-min/max)
        (let ([bheap (Heap-heap heap)])
          (if (bh:empty? bheap)
              bsheap
              (let ([min-heap (bh:find-min/max bheap)]
                    [del (bh:delete-min/max bheap)])
                (make-BSHeap func 
                             (make-Heap (Heap-elem min-heap) 
                                        (bh:merge (Heap-heap min-heap) 
                                                  del)))))))))

(: bootstrapped-heap : (All (A) ((A A -> Boolean) A * -> (BSHeap A))))
(define (bootstrapped-heap func . lst)
  (: comp : ((Heaps A) (Heaps A) -> Boolean))
  (define (comp h1 h2)
    (cond
      [(Mt? h1) #f]
      [(Mt? h2) #f]
      [else (func (Heap-elem h1) (Heap-elem h2))]))
  (foldl (inst insert A)
         ((inst make-BSHeap A) func (ann (make-Mt) (Heaps A)))
         lst))

(: sorted-list : (All (A) ((BSHeap A) -> (Listof A))))
(define (sorted-list bsheap)
  (let ([heap (BSHeap-heap bsheap)])
    (cond 
      [(Mt? heap) null]
      [(bh:empty? (Heap-heap heap)) (list (Heap-elem heap))]
      [else (cons (find-min/max bsheap) 
                  (sorted-list (delete-min/max bsheap)))])))