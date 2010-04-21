#lang typed-scheme

(provide empty? insert find-min/max delete-min/max empty
         merge sorted-list bootstrapped-heap BSHeap)

(require (prefix-in bh: "skewbinomialheap.ss")
         scheme/match)

(define-struct: Mt ())

(define-struct: (A) IntHeap ([elem : A]
                             [heap : (bh:BinomialHeap (IntHeap A))]))

(define-type-alias (Heaps A) (U Mt (IntHeap A)))

(define-struct: (A) BSHeap ([comparer : (A A -> Boolean)]
                            [heap : (Heaps A)]))

(define-type-alias (Heap A) (BSHeap A))

(define empty (make-Mt))

(: empty? : (All (A) ((BSHeap A) -> Boolean)))
(define (empty? bsheap)
  (let ([hp (BSHeap-heap bsheap)])
    (if (Mt? hp) #t (bh:empty? (IntHeap-heap hp)))))


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
                (make-IntHeap elem1 (bh:insert heap2 p1))
                (make-IntHeap elem2 (bh:insert heap1 p2))))]))

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
                                        (ann ((inst bh:binomialheap (IntHeap A)) 
                                              comp)
                                             (bh:BinomialHeap (IntHeap A))))
                             inheap func))))


(: find-min/max : (All (A) ((BSHeap A) -> A)))
(define (find-min/max bsheap)
  (let ([heap (BSHeap-heap bsheap)])
    (if (Mt? heap)
        (error 'find-min/max "Given heap is empty")
        (IntHeap-elem heap))))

(: delete-min/max : (All (A) ((BSHeap A) -> (BSHeap A))))
(define (delete-min/max bsheap)
  (let ([heap (BSHeap-heap bsheap)]
        [func (BSHeap-comparer bsheap)])
    (if (Mt? heap)
        (error 'delete-min/max "Given heap is empty")
        (let ([bheap (IntHeap-heap heap)])
          (if (bh:empty? bheap)
              ((inst make-BSHeap A) func (ann (make-Mt) (Heaps A)))
              (let ([min-heap (bh:find-min/max bheap)]
                    [del (bh:delete-min/max bheap)])
                (make-BSHeap func 
                             (make-IntHeap (IntHeap-elem min-heap) 
                                        (bh:merge (IntHeap-heap min-heap) 
                                                  del)))))))))

(: bootstrapped-heap : (All (A) ((A A -> Boolean) A * -> (BSHeap A))))
(define (bootstrapped-heap func . lst)
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
      [(bh:empty? (IntHeap-heap heap)) (list (IntHeap-elem heap))]
      [else (cons (find-min/max bsheap) 
                  (sorted-list (delete-min/max bsheap)))])))
