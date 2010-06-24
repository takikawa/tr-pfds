#lang typed/scheme

(require "../redblacktrees.ss")
(require typed/test-engine/scheme-tests)

;; NOTE:
;; Rebalancing used in Okasaki version of Red Black Trees is slightly
;; different from that of popular version. 
;; As a consequence of this difference,
;; - Okasaki version is easy to implement.
;; - There is a difference in ordering of elements. For example, in the 
;;   test below, popular version would give (list 2 3 4 1 5). Because 
;;   redblacktree->list  takes the root element in the red-black tree and 
;;   populates it in a list and then deletes the root element. When it 
;;   deletes the root node, balancing is done, since the balancing differs 
;;   in Okasaki version, 4 becomes the root of the tree instead of 3 which
;;   is the case in the popular version.

(check-expect (redblacktree->list (redblacktree < 1 2 3 4 5))
              (list 2 4 3 1 5))
(check-expect (root (redblacktree < 1 2 3 4 5 6 7)) 4)
(check-expect (root (redblacktree < 1 2 3 4 5)) 2)
(define lst (build-list 100 (λ: ([x : Integer]) x)))
(check-expect ((inst sort Integer Integer) (redblacktree->list (apply redblacktree < lst))  <) lst)
(check-expect (root (delete 2 (redblacktree < 1 2 3 4 5))) 4)
(check-expect (root (delete-root (redblacktree < 1 2 3 4 5))) 4)
(check-expect (member? 5 (redblacktree < 1 2 3 4 5)) #t)
(check-expect (member? 5 (redblacktree > 1 2 3 4 5)) #t)
(check-expect (member? 50 (redblacktree > 1 2 3 4 5)) #f)
(check-expect (member? 50 (redblacktree < 1 2 3 4 5)) #f)
(check-expect (member? 1 (redblacktree > 1 2 3 4 5)) #t)
(check-expect (member? 2 (redblacktree > 1 2 3 4 5)) #t)
(check-expect (member? 95 (apply redblacktree < lst)) #t)
(check-expect (empty? (delete-root (redblacktree < 1))) #t)
(check-expect (empty? (redblacktree < 1)) #f)

(check-error (root (delete-root (redblacktree < 1)))
             "root: given tree is empty")
(check-error (delete 1 (delete-root (redblacktree < 1))) 
             "delete: given key not found in the tree")

(check-error (delete-root (delete-root (redblacktree < 1))) 
             "delete-root: given tree is empty")
(test)
