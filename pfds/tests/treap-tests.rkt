#lang typed/racket
(require pfds/treap)
(require typed/test-engine/racket-tests)

(: str-less-than? : (String String -> Boolean))
(define (str-less-than? a b)
  (string<=? a b))

(check-expect (find-min/max (treap < 1 2 3 4)) 1)
(check-expect (find-min/max (treap < 1 2 3 0)) 0)
(check-expect (find-min/max (treap < 1 2 -3 4)) -3)
(check-error (find-min/max (delete-min/max (treap < 1))) 
             "find-min/max: given treap is empty")

(check-expect ((inst sort Integer Integer)
               (treap->list (delete-min/max (treap <= 1 2 3 4))) <)
              (list 2 3 4))
(check-expect ((inst sort Integer Integer)
               (treap->list (delete-min/max (treap <= 1 2 3 0))) <) 
              (list 1 2 3))
(check-expect ((inst sort Integer Integer)
               (treap->list (delete-min/max (treap <= 1 2 -3 4))) <)
              (list 1 2 4))
(check-error (delete-min/max (delete-min/max (treap <= 1))) 
             "delete-min/max: given treap is empty")

(check-expect (treap->list (delete-min/max (treap <= 1))) (list))
(check-expect ((inst sort Integer Integer)
               (treap->list (delete-min/max (treap <= 1 -2 -3 -4))) <)
              (list -3 -2 1))

(check-expect ((inst sort Integer Integer)
               (treap->list ((inst insert Integer) 10 (treap <= 1 -2 -3 -4))) <)
              (list -4 -3 -2 1 10))

(check-expect ((inst sort Integer Integer)
               (treap->list (insert -10 (treap <= 1 20 -3 -4))) <)
              (list -10 -4 -3 1 20))

(check-expect ((inst sort Integer Integer)
               (treap->list (insert -1 (treap <= -3 -4))) <)
              (list -4 -3 -1))

;;(check-expect (treap->list (merge (treap <= 2 3 -10)
;;                                  (treap <= 1 -2 -3 -4)))
;;              (list -10 -4 -3 -2 1 2 3))
;; 
;;(check-expect (treap->list (merge (delete-min/max (treap <= -1 5))
;;                                  (treap <= 1 -2 -3 -4)))
;;              (list -4 -3 -2 1 5))
;; 
;;(check-expect (treap->list (merge (treap <= 1 -2 -3 -4)
;;                                  (delete-min/max (treap <= -1 5))))
;;              (list -4 -3 -2 1 5))

(define int-list (build-list 100 (λ: ([x : Integer]) x)))

(define int-list1 (build-list 100 (λ: ([x : Integer]) (+ 100 x))))

;(check-expect (treap->list (merge (apply treap <= int-list)
;                                  (apply treap <= int-list1)))
;              (append int-list int-list1))

(check-expect ((inst sort Integer Integer)
               (treap->list (apply treap <= int-list)) <)
              int-list)

(check-expect ((inst sort Integer Integer)
               (treap->list (apply treap > int-list)) >)
              (reverse int-list))
(check-expect (empty? (treap > 1 2 3 4)) #f)

(check-expect (empty? (treap >)) #t)

(check-expect (fold + 0 (treap < 1 1 1 10 1 15)) 29)
(check-expect ((inst sort Integer Integer)
               (treap->list (map < add1 (treap < 10 4 5 14 29 15))) <)
              (list 5 6 11 15 16 30))
(check-expect (fold + 0 (treap > 1)) 1)
(check-expect ((inst sort Integer Integer)
               (treap->list (filter even? (treap < 10 4 5 14 29 15))) <)
              (list 4 10 14))
(check-expect ((inst sort Integer Integer)
               (treap->list (remove odd? (treap < 10 4 5 14 29 15))) <)
              (list 4 10 14))
(check-expect ((inst sort Integer Integer)
               (treap->list (remove even? (treap < 10 4 5 14 29 15))) <)
              (list 5 15 29))
(check-expect ((inst sort Integer Integer)
               (treap->list (filter odd? (treap < 10 4 5 14 29 15))) <)
              (list 5 15 29))

(check-expect (ormap odd? (treap < 10 4 5 14 29 15)) #t)
(check-expect (ormap even? (treap < 5 29 15)) #f)
(check-expect (andmap odd? (treap < 5 29 15)) #t)
(check-expect (andmap odd? (treap < 5 29 14)) #f)

;;; contains?
(check-expect (contains? 'x ((inst treap Symbol) symbol<?)) #f)
(check-expect (contains? 'x (treap symbol<? 'x)) #t)
(check-expect (contains? 'x (treap symbol<? 'a 'b 'c 'd)) #f)
(check-expect (contains? 4 (treap < 1 2 3 4 5 6)) #t)

;;; treap/priority
(check-expect (empty? ((inst treap/priority Symbol) symbol<?)) #t)
(check-expect (empty? (treap/priority symbol<? '(a . 2) '(b . 6) '(c . 1))) #f)
(check-expect (root (treap/priority symbol<? '(a . 2) '(b . 6) '(c . 1))) 'c)
(check-expect (contains? 'a (treap/priority symbol<? '(a . 2) '(b . 6) '(c . 1))) #t)
(check-expect (contains? 'b (treap/priority symbol<? '(a . 2) '(b . 6) '(c . 1))) #t)
(check-expect (contains? 'c (treap/priority symbol<? '(a . 2) '(b . 6) '(c . 1))) #t)

;;; insert/priority
(check-expect (empty? ((inst insert/priority Integer) 4 2 (treap <))) #f)
(check-expect (root ((inst insert/priority Integer) 4 2 (treap <))) 4)
(check-expect (root (insert/priority 4 2 (treap/priority < '(6 . 1)))) 6)
(check-expect (contains? 6 (insert/priority 4 2 ((inst treap/priority Integer) < '(6 . 1)))) #t)
(check-expect (contains? 4 (insert/priority 4 2 ((inst treap/priority Integer) < '(6 . 1)))) #t)
(check-expect (contains? 2 (insert/priority 4 2 ((inst treap/priority Integer) < '(6 . 1)))) #f)

;;; root
(check-expect (root (treap/priority symbol<? '(a . 2) '(b . 6) '(c . 1))) 'c)
(check-expect (root (treap/priority symbol<? '(a . 2))) 'a)

;;; root/priority
(check-expect (root/priority (treap/priority symbol<? '(a . 2) '(b . 6) '(c . 1))) 1)
(check-expect (root/priority (treap/priority symbol<? '(a . 2))) 2)

;;; delete-root
(check-expect (empty? (delete-root (treap < 6))) #t)
(check-expect (contains? 3 (delete-root (treap/priority < '(4 . 5) '(3 . 2) '(6 . 1)))) #t)
(check-expect (contains? 4 (delete-root (treap/priority < '(4 . 5) '(3 . 2) '(6 . 1)))) #t)
(check-expect (contains? 6 (delete-root (treap/priority < '(4 . 5) '(3 . 2) '(6 . 1)))) #f)
(check-expect (root (delete-root (treap/priority < '(4 . 5) '(3 . 2) '(6 . 1)))) 3)

(test)
