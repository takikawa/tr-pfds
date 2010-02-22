#lang typed-scheme

(provide empty lookup bind build make-trie trie Trie)

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
            (error "Key not found :" 'lookup)
            (Some-elem opt)))
      (let ([fst (car keys)]
            [hash (Trie-map map)])
        (with-handlers ([exn:fail? (lambda (error?) 
                                     (error "Key not found :" 'lookup))])
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

;; While creating the tree, (hash-ref hash fst-el) if throws error, build a new
;; Trie for rest of the key go deeper into the trie
(: trie : 
   (All (K V) ((Trie K V) (Listof V) (Listof (Listof K)) -> (Trie K V))))
(define (trie tri lstv lstk)
  (if (or (null? lstv) (null? lstk))
      tri
      (let* ([fstv (car lstv)]
             [rstv (cdr lstv)]
             [fstk (car lstk)]
             [rstk (cdr lstk)]
             [rst-fstk (cdr fstk)]
             [fst-el (car fstk)]
             [hash (Trie-map tri)]
             [opt (Trie-opt tri)]
             [tree (ann (with-handlers ([exn:fail? (lambda (error?) 
                                                     (build fstv rst-fstk))])
                          (go-deep (hash-ref hash fst-el) rst-fstk fstv)) 
                        (Trie K V))])
        (trie (make-Trie opt (hash-set hash fst-el tree)) rstv rstk))))

;; Uses the same trick as previous one does
(: go-deep : (All (K V) ((Trie K V) (Listof K) V -> (Trie K V))))
(define (go-deep tri lstk val)
  (if (null? lstk)
      (make-Trie (make-Some val) (Trie-map tri))
      (let* ([hash (Trie-map tri)]
             [opt (Trie-opt tri)]
             [fstk (car lstk)]
             [rstk (cdr lstk)]
             [key-in (hash-has-key? hash fstk)]
             [trie (ann (with-handlers 
                            ([exn:fail? (lambda (error?) (build val rstk))])
                          (go-deep (hash-ref hash fstk) rstk val))
                        (Trie K V))])
        (make-Trie opt (hash-set hash fstk trie)))))

(lookup (string->list "Hari")
        (bind (string->list "JP") 5 
              (make-trie 
               (map string->list 
                    (list "Hari Prashanth" "Hari" "Hari " "K R H P")))))

(trie (ann (empty) (Trie Char Integer)) 
             (list 1 2) 
             (map string->list (list "K R" "K R H P")))

(lookup (string->list "Hari") 
        (trie 
         (ann (empty) (Trie Char Integer)) 
         (list 1 2 3 4 5) 
         (map string->list (list "Hari" "Prashanth" "K R" "KRHP" "K R H P"))))

(lookup (string->list "Prashanth") 
        (trie 
         (ann (empty) (Trie Char Integer)) 
         (list 1 2 3 4 5) 
         (map string->list (list "Hari" "Prashanth" "K R" "KRHP" "K R H P"))))

(lookup (string->list "KRHP") 
        (trie 
         (ann (empty) (Trie Char Integer)) 
         (list 1 2 3 4 5) 
         (map string->list (list "Hari" "Prashanth" "K R" "KRHP" "K R H P"))))

(lookup (string->list "K R H P") 
        (trie 
         (ann (empty) (Trie Char Integer)) 
         (list 1 2 3 4 5) 
         (map string->list (list "Hari" "Prashanth" "K R" "KRHP" "K R H P"))))

(lookup (string->list "K R") 
        (trie 
         (ann (empty) (Trie Char Integer)) 
         (list 1 2 3 4 5) 
         (map string->list (list "Hari" "Prashanth" "K R" "KRHP" "K R H P"))))

(lookup (string->list "Hari Prashanth") 
        (trie 
         (ann (empty) (Trie Char Integer)) 
         (list 1 2 3 4) 
         (map string->list (list "Hari Prashanth" "K R" "KRHP" "K R H P"))))

(lookup (string->list "Hari") 
        (trie 
         (ann (empty) (Trie Char Integer)) 
         (list 1 2 3 4) 
         (map string->list (list "Hari Prashanth" "Hari" "Hari " "K R H P"))))


(lookup (string->list "HariKRH") 
        (bind (string->list "HariKRH") 5 
              (trie 
               (ann (empty) (Trie Char Integer)) 
               (list 1 2 3 4) 
               (map string->list 
                    (list "Hari Prashanth" "Hari" "Hari " "K R H P")))))

(lookup (string->list "JP") 
        (bind (string->list "JP") 5 
              (trie 
               (ann (empty) (Trie Char Integer)) 
               (list 1 2 3 4) 
               (map string->list 
                    (list "Hari Prashanth" "Hari" "Hari " "K R H P")))))