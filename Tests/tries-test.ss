#lang typed-scheme
(require "../tries.ss")
(require typed/test-engine/scheme-tests)

(check-expect
 (lookup (string->list "Hari")
         (bind (string->list "JP") 5 
               (make-trie 
                (map string->list 
                     (list "Hari Prashanth" "Hari" "Hari " "K R H P")))))
 2)

(check-expect
 (lookup (string->list "Hari") 
         (tries
          (list 1 2 3 4 5) 
          (map string->list (list "Hari" "Prashanth" "K R" "KRHP" "K R H P"))))
 1)

(check-expect
 (lookup (string->list "Prashanth") 
         (tries
          (list 1 2 3 4 5) 
          (map string->list (list "Hari" "Prashanth" "K R" "KRHP" "K R H P"))))
 2)

(check-expect
 (lookup (string->list "KRHP") 
         (tries
          (list 1 2 3 4 5) 
          (map string->list (list "Hari" "Prashanth" "K R" "KRHP" "K R H P"))))
 4)

(check-expect
 (lookup (string->list "K R H P") 
         (tries
          (list 1 2 3 4 5) 
          (map string->list (list "Hari" "Prashanth" "K R" "KRHP" "K R H P"))))
 5)

(check-expect
 (lookup (string->list "K R") 
         (tries
          (list 1 2 3 4 5) 
          (map string->list (list "Hari" "Prashanth" "K R" "KRHP" "K R H P"))))
 3)

(check-expect
 (lookup (string->list "Hari Prashanth") 
         (tries
          (list 1 2 3 4) 
          (map string->list (list "Hari Prashanth" "K R" "KRHP" "K R H P"))))
 1)

(check-expect
 (lookup (string->list "Hari ") 
         (tries
          (list 1 2 3 4) 
          (map string->list (list "Hari Prashanth" "Hari" "Hari " "K R H P"))))
 3)


(check-expect
 (lookup (string->list "HariKRH") 
         (bind (string->list "HariKRH") 5 
               (tries
                (list 1 2 3 4) 
                (map string->list 
                     (list "Hari Prashanth" "Hari" "Hari " "K R H P")))))
 5)
 
(check-expect
 (lookup (string->list "JP") 
         (bind (string->list "JP") 5 
               (tries
                (list 1 2 3 4) 
                (map string->list 
                     (list "Hari Prashanth" "Hari" "Hari " "K R H P")))))
 5)

(check-error
 (lookup (string->list "Hari123") 
         (bind (string->list "JP") 5 
               (tries
                (list 1 2 3 4) 
                (map string->list 
                     (list "Hari Prashanth" "Hari" "Hari " "K R H P")))))
 "lookup: given key not found in the trie")

(check-error
 (lookup (string->list "Har") 
         (bind (string->list "JP") 5 
               (tries
                (list 1 2 3 4) 
                (map string->list 
                     (list "Hari Prashanth" "Hari" "Hari " "K R H P")))))
 "lookup: given key not found in the trie")

(test)
