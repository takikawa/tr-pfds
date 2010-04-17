#lang typed-scheme

(provide lookup bind make-trie trie Trie tries)

(require scheme/match)
(define-type-alias (Key A) (Listof A))

(define-struct: Mt ())
(define-struct: (A) Some ([elem : A]))

(define-type-alias (Option A) (U Mt (Some A)))

(define-struct: (K V) Trie ([opt : (Option V)]
                            [map : (HashTable K (Trie K V))]))

(: empty : (All (K V) (-> (Trie K V))))
(define (empty) 
  (make-Trie (make-Mt) 
             (ann (make-immutable-hash null) (HashTable K (Trie K V)))))

(: lookup : (All (K V) ((Key K) (Trie K V) -> V)))
(define (lookup keys map)
  (if (null? keys)
      (let ([opt (Trie-opt map)])
        (if (Mt? opt)
            (error 'lookup "Given key not found in the trie")
            (Some-elem opt)))
      (let ([fst (car keys)]
            [hash (Trie-map map)])
        (with-handlers
            ([exn:fail? (lambda (error?) 
                          (error 'lookup "Given key not found in the trie"))])
          (lookup (cdr keys) (hash-ref hash fst))))))

(: bind : (All (K V) ((Key K) V (Trie K V) -> (Trie K V))))
(define (bind lok v map)
  (let ([hash (Trie-map map)]
        [fst (car lok)]
        [rst (cdr lok)]
        [opt (Trie-opt map)])
    (make-Trie opt (hash-set hash fst 
                             (ann (with-handlers 
                                      ([exn:fail? 
                                        (lambda (error?) (build v rst))])
                                    (bind rst v (hash-ref hash fst)))
                                  (Trie K V))))))

(: build : (All (K V) (V (Listof K) -> (Trie K V))))
(define (build val lstk)
  (if (null? lstk)
      (make-Trie (make-Some val) 
                 (ann (make-immutable-hash null) 
                      (HashTable K (Trie K V))))
      (make-Trie (make-Mt) 
                 (make-immutable-hash 
                  (list (cons (car lstk) (build val (cdr lstk))))))))

(: make-trie : (All (K) ((Listof (Listof K)) -> (Trie K Integer))))
(define (make-trie lst)
  (trie (ann (empty) (Trie K Integer))
        (get-vals lst)
        lst))

(: get-vals : (All (K) ((Listof (Listof K)) -> (Listof Integer))))
(define (get-vals lst)
  (: local : (All (K) (Integer (Listof (Listof K)) -> (Listof Integer))))
  (define (local ctr lstk)
    (if (null? (cdr lstk))
        (cons ctr null)
        (cons ctr (local (add1 ctr) (cdr lstk)))))
  (local 1 lst))

;; While creating the tree, 
;; if   (hash-ref hash k) throws an error, 
;; then it means that that there is no entry for k. So build a new
;;      Trie for rest of the key and create an entry for k. 
;; else go deeper into the trie searching for the rest of the key.

(: trie : 
   (All (K V) ((Trie K V) (Listof V) (Listof (Listof K)) -> (Trie K V))))
(define (trie tri lstv lstk)
  (match (list lstv lstk)
    [(list null null) tri]
    [(list (cons v vs) (cons (cons k ks) rstk))
      (let* ([hash (Trie-map tri)]
             [tree (ann (with-handlers ([exn:fail? (lambda (error?) 
                                                     (build v ks))])
                          (go-deep (hash-ref hash k) ks v)) 
                        (Trie K V))])
        (trie (make-Trie (Trie-opt tri) (hash-set hash k tree))
              vs rstk))]))

(: tries : 
   (All (K V) ((Listof V) (Listof (Listof K)) -> (Trie K V))))
(define (tries lstv lstk)
  (trie (ann (empty) (Trie K V)) lstv lstk))

;; Uses the same trick as previous one does
(: go-deep : (All (K V) ((Trie K V) (Listof K) V -> (Trie K V))))
(define (go-deep tri lstk val)
  (if (null? lstk)
      (make-Trie (make-Some val) (Trie-map tri))
      (let* ([hash (Trie-map tri)]
             [k (car lstk)]
             [ks (cdr lstk)]
             [trie (ann (with-handlers
                            ([exn:fail? (lambda (error?) (build val ks))])
                          (go-deep (hash-ref hash k) ks val))
                        (Trie K V))])
        (make-Trie (Trie-opt tri) (hash-set hash k trie)))))
