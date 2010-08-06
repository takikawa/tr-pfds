#lang slideshow

;(require unstable/gui/slideshow)

(current-font-size 30)
;(current-titlet (lambda (s)
;                  (colorize (text s (current-main-font) 40)
;                            (current-title-color))))
;(set-title-h! 10.0)
(current-main-font 'roman)

(current-title-color "Blue")

(slide
 #:title "Functional Data Structures for Typed Racket"
 (t "Hari Prashanth and Sam Tobin-Hochstadt")
 (t "Northeastern University"))

(define custom-bullet1 (colorize (arrowhead 22 (* 2 pi)) "LightSkyBlue"))
(define custom-bullet (colorize (arrowhead 22 (* 2 pi)) "DarkGreen"))
(define sel-bul (colorize (arrowhead 22 (* 2 pi)) "DarkRed"))

(define invis-bul (text ""))

(define sel-bul1 
  (pin-over (colorize (arrowhead 22 (* 2 pi)) "SteelBlue") 
            8 0 
            custom-bullet))


(define (new-text str)
  (text str 'roman 30 0))
(require slideshow/code)


(slide
 #:title "Outline"
 (item #:bullet custom-bullet "Motivation") 
 (item #:bullet custom-bullet "Typed Racket in a Nutshell") 
 (item #:bullet custom-bullet "Purely Functional Data Structures")
 (item #:bullet custom-bullet "Benchmarks")
 (item #:bullet custom-bullet "Conclusion"))


(slide
 #:title "Outline"
 (item #:bullet sel-bul "Motivation") 
 (item #:bullet custom-bullet "Typed Racket in a Nutshell") 
 (item #:bullet custom-bullet "Purely Functional Data Structures")
 (item #:bullet custom-bullet "Benchmarks")
 (item #:bullet custom-bullet "Conclusion"))


(slide
 #:title "Motivation"
 (item #:bullet invis-bul "The data structures in Typed Racket were very few in number")
 'next
 (subitem #:bullet invis-bul "Lists")
 'next
 'alts
 (list (list (subitem #:bullet invis-bul "Vectors"))
       (list (subitem #:bullet invis-bul "Vectors")
             (subitem #:bullet invis-bul "Hash Tables")))
 'next
 (code code:blank)
 (item #:bullet invis-bul "Practical use of Typed Racket"))



(slide
 #:title "Outline"
 (item #:bullet custom-bullet "Motivation") 
 (item #:bullet sel-bul "Typed Racket in a Nutshell") 
 (item #:bullet custom-bullet "Purely Functional Data Structures")
 (item #:bullet custom-bullet "Benchmarks")
 (item #:bullet custom-bullet "Conclusion"))

(slide
 (t "Typed Racket in a Nutshell"))

;(slide
; #:title "Typed Racket in a Nutshell"
; (t "What is Typed Racket"))

(slide
 #:title "Typed Racket in a Nutshell"
 (code
  #, (tt "#lang") racket
  code:blank
  (code:comment "Computes the length of a given list of elements")
  (code:comment "length : list-of-elems -> integer")
  (define (length list)
    (if (null? list)
        0
        (add1 (length (cdr list)))))))

(current-keyword-list (list "typed/racket" "->" ":"))
(current-keyword-color "red")

(slide
 #:title "Typed Racket in a Nutshell"
 (code
  #, (tt "#lang") typed/racket
  code:blank
  (code:comment "Computes the length of a given list of integers")
  (: length : (Listof Integer) -> Integer) 
  (define (length list)
    (if (null? list)
        0
        (add1 (length (cdr list)))))))

(current-keyword-list (list))

(current-keyword-list (list "All" "A"))

(slide
 #:title "Typed Racket in a Nutshell"
 (code
  #, (tt "#lang") typed/racket
  code:blank
  (code:comment "Computes the length of a given list of elements")
  (: length : (All (A) ((Listof A) -> Integer))) 
  (define (length list)
    (if (null? list)
        0
        (add1 (length (cdr list)))))))

(slide
 #:title "Typed Racket in a Nutshell"
 (code
  #, (tt "#lang") racket
  code:blank
  (code:comment "Data definition of tree of integers")
  code:blank
  (define-struct BTree
    (ltree
     elem
     rtree))
  code:blank
  (code:comment "A Tree is one of")
  (code:comment "- null")
  (code:comment "- BTree")
  (code:comment "ltree and rtree are of type Tree")
  (code:comment "elem is an Integer")))


(current-keyword-list (list "U" "define-type" "define-struct:"))

(slide
 #:title "Typed Racket in a Nutshell"
 (code
  #, (tt "#lang") typed/racket
  code:blank
  (code:comment "Data definition of tree of integers")
  code:blank
  (define-struct: BTree
    ([ltree : Tree]
     [elem  : Integer]
     [rtree : Tree]))
  code:blank
  code:blank
  (define-type Tree (U Null BTree))
  code:blank
  code:blank))


(current-keyword-list (list "A"))

(slide
 #:title "Typed Racket in a Nutshell"
 (code
  #, (tt "#lang") typed/racket
  code:blank
  (code:comment "Polymorphic definition of Tree")
  code:blank
  (define-struct: (A) BTree
    ([ltree : (Tree A)]
     [elem  : A]
     [rtree : (Tree A)]))
  code:blank
  code:blank
  (define-type (Tree A) (U Null (BTree A)))
  code:blank
  code:blank))

(current-keyword-list (list))

(slide
 #:title "Outline"
 (item #:bullet custom-bullet "Motivation")
 (item #:bullet custom-bullet "Typed Racket in a Nutshell") 
 (item #:bullet sel-bul "Purely Functional Data Structures")
 (item #:bullet custom-bullet "Benchmarks")
 (item #:bullet custom-bullet "Conclusion"))


(slide
 (t "Purely Functional Data Structures"))

(slide
 #:title "Purely Functional Data Structures"
 ;(item #:bullet invis-bul "Persistent data structures")
 'alts
 (list (list (ht-append 0.0
                        (ht-append 25.0
                                   (text "e" null 25 0)
                                   (arrow 35 0))
                        (bitmap "per1.png")))
       (list (ht-append 0.0
                        (ht-append 25.0
                                   (text "e" null 25 0)
                                   (arrow 35 0))
                        (ht-append 0.0
                                   (bitmap "per1.png")
                                   (ht-append 25.0 
                                              (text "⇒" null 45 0)
                                              (bitmap "des-up.png"))))
             (t "Destructive update"))
       (list (ht-append 0.0
                        (ht-append 25.0
                                   (text "e" null 25 0)
                                   (arrow 35 0))
                        (ht-append 0.0
                                   (bitmap "per1.png")
                                   (ht-append 25.0 
                                              (text "⇒" null 45 0)
                                              (bitmap "per2.png"))))
             (t "Non-destructive update"))))

(define-exec-code (pict-id runnable-id string-id)
  #, (tt "#lang") typed/racket
  (require "stream.rkt")
  code:blank
  (stream-map (lambda: ([x : Integer]) (/ x 0)) 
              (stream 1 2 3)))




(current-keyword-list (list "Promise"))


(slide
 #:title "Banker's Queue"
 (item #:bullet invis-bul "Okasaki 1998")
 'alts
 (list (list (code
              (define-struct: (A) Queue
                ([front : (Listof A)]
                 [rear  : (Listof A)]))
              code:blank
              code:blank)
             'next
             (bitmap "bankers.png"))
       (list (bitmap "whylazy.png")
             (t "Queue q")
             (blank 10)
             (subitem #:bullet invis-bul 
                      (hc-append 2 
                                 (new-text  "Calling ")
                                 (code dequeue)
                                 (new-text " on q reverses the rear list"))))
;       (list 
;             'next
;             (subitem #:bullet invis-bul 
;                      (code
;                       code:blank
;                       (: lazy : (Promise Exact-Rational))
;                       (define lazy
;                         (delay (/ 5 0))))))
;       (list (subitem #:bullet invis-bul "Streams or lazy lists")
;             (code code:blank)
;             'next
;             pict-id)
       (list (subitem #:bullet invis-bul 
                      "Lazy evaluation with memoization solves of this problem") 
             'next
             'alts
             (list
              (list (code
                       code:blank
                       (: lazy : (Promise Exact-Rational))
                       (define lazy
                         (delay (/ 5 0)))))
              (list 
               (subitem #:bullet invis-bul "Streams or lazy lists")
               (code code:blank)
               'next
               (code 
                (define-struct: (A) Queue
                  ([front : (Stream A)]
                   [lenf  : Integer]
                   [rear  : (Stream A)]
                   [lenr  : Integer]))
                code:blank)
               'next
               (vc-append 16 
                          (subitem #:bullet invis-bul
                                   (hc-append 10
                                              (new-text "Amortized runing time of O(1) for the operations") 
                                              (code enqueue)))
                          (subitem #:bullet invis-bul
                                   (hc-append (code dequeue) 
                                              (new-text "  and  ") 
                                              (code head)))))))))
       

(current-keyword-list (list "accum" "delay"))

(slide
 #:title "Real-Time Queues"
 (item #:bullet invis-bul "Hood & Melville. 81")
 (code code:blank)
 'next
 (item #:bullet invis-bul "Eliminating Amortization")
 'next
 (subitem #:bullet invis-bul "Scheduling")
 'next
 'alts
 (list (list (bitmap "bankers.png")
             (t "Banker's Queue - reverse is a monolithic function"))
;       (list (code code:blank
;                   code:blank
;                   (define-struct: (A) Queue
;                     ([front : (Listof A)]
;                      [rear  : (Listof A)]))))
       (list (code code:blank
                   (define (rev front rear accum)
                     (cons (car front)
                           (delay (rev (cdr front)
                                       (cdr rear)
                                       (cons (car rear) accum))))))
             (blank 10)
             (t "Incremental reversing"))
       (list (subitem #:bullet invis-bul
                      (vc-append 16 
                        (subitem #:bullet invis-bul
                                 (hc-append 10
                                            (new-text "Worst-case running time of O(1) for the operations") 
                                            (code enqueue)))
                        (subitem #:bullet invis-bul
                                 (hc-append (code dequeue) 
                                            (new-text "  and  ") 
                                            (code head))))))))


(current-keyword-list null)

(slide
 #:title "Binary Random Access Lists"
 (item #:bullet invis-bul "Okasaki 1998")
 (item #:bullet invis-bul "Numerical Representations")
 'alts
 (list (list (item #:bullet invis-bul (code
                                       code:blank
                                       Nat is one of 
                                       - 0 
                                       - (add1 Nat)))
             (item #:bullet invis-bul (code
                                       code:blank
                                       List is one of 
                                       - null 
                                       - (cons elem List))))
       (list (subitem #:bullet invis-bul (hc-append 2 (code cons) 
                                                    (text " corresponds to increment"
                                                          'roman 30 0)))
             (subitem #:bullet invis-bul (hc-append 2 (code cdr) 
                                                    (text " corresponds to decrement"
                                                          'roman 30 0)))
             (subitem #:bullet invis-bul (hc-append 2 (code append) 
                                                    (text " corresponds to addition"
                                                          'roman 30 0))))
       (list (item #:bullet invis-bul "Binary Numbers")
             'next 
             (bitmap "bin-ran.png")
             'next
             (vc-append 
              16 
              (subitem #:bullet invis-bul
                       (hc-append 10
                                  (new-text "Worst-case running time of O(log n) for the operations ")))
              (subitem #:bullet invis-bul
                       (hc-append 10 
                                  (code cons) 
                                  (new-text ",")
                                  (code car) 
                                  (new-text ",")
                                  (code cdr) 
                                  (new-text ",")
                                  (code lookup) 
                                  (new-text ",")
                                  (new-text " and ") 
                                  (code update)))))))
;             (subitem #:bullet invis-bul 
;                      " cons, car, cdr, lookup and update"))))



(slide
 #:title "VLists"
 (item #:bullet invis-bul "Bagwell 2002")
 'next
 'alts
 (list (list (item #:bullet invis-bul "List with one element - 6")
             (code code:blank)
             (bitmap "VList1.png"))
       (list (item #:bullet invis-bul "Cons 5 and 4 to the previous list")
             (code code:blank)
             (bitmap "VList2.png"))
       (list (item #:bullet invis-bul "Cons 3 and 2 to the previous list")
             (code code:blank) 
             (bitmap "VList.png"))
       (list (item #:bullet invis-bul "cdr of the previous list")
             (code code:blank) 
             (bitmap "VList3.png"))
       (list (item #:bullet invis-bul "Hash lists are based on the same structure") 
             (bitmap "Hash.png"))
       (list
        (item #:bullet invis-bul 
              "Random access takes O(1) average and O(log n) in worst-case."))))


(slide
 #:title "Purely Functional Data Structures"
 (item #:bullet invis-bul "Library has 30 data structures which include")
 'alts
 (list (list (item "Variants of Queues")
             (subitem #:bullet invis-bul "Banker's Queue")
             (subitem #:bullet invis-bul "Physicist's Queue")
             (subitem #:bullet invis-bul "Implicit Queue")
             (subitem #:bullet invis-bul "Real-Time Queue")
             (subitem #:bullet invis-bul "Bootstrapped Queue")
             (subitem #:bullet invis-bul "Hood-Melville Queue"))
       (list (item "Variants of Deques")
             (subitem #:bullet invis-bul "Banker's Deque")
             (subitem #:bullet invis-bul "Implicit Deque")
             (subitem #:bullet invis-bul "Real-Time Deque"))
       (list (item "Variants of Heaps")
             (subitem #:bullet invis-bul "Binomial Heap")
             (subitem #:bullet invis-bul "Skew Binomial Heap")
             (subitem #:bullet invis-bul "Leftist Heap")
             (subitem #:bullet invis-bul "Splay Heap")
             (subitem #:bullet invis-bul "Bootstrapped Heap")
             (subitem #:bullet invis-bul "Pairing Heap")
             (subitem #:bullet invis-bul "Lazy Pairing Heap"))
       (list (item "Variants of Lists")
             (subitem #:bullet invis-bul "Binary Random Access List")
             (subitem #:bullet invis-bul "Skew Binary Random Access List")
             (subitem #:bullet invis-bul "Catenable List")
             (subitem #:bullet invis-bul "VList"))
       (list (item "Some other data structures")
             (subitem #:bullet invis-bul "Red-Black Trees")
             (subitem #:bullet invis-bul "Tries")
             (subitem #:bullet invis-bul "Unbalanced Sets"))
       (list (subitem #:bullet invis-bul "Variants of Queues") 
             (subitem #:bullet invis-bul "Variants of Deques") 
             (subitem #:bullet invis-bul "Variants of Heaps")
             (subitem #:bullet invis-bul "Variants of Lists")
             (subitem #:bullet invis-bul "Some other data structures") 
             (item #:bullet invis-bul "Each data structure comes with several utility functions"))))
(slide
 #:title "Outline" 
 (item #:bullet custom-bullet "Motivation")
 (item #:bullet custom-bullet "Typed Racket in a Nutshell")
 (item #:bullet custom-bullet "Purely Functional Data Structures")
 (item #:bullet sel-bul "Benchmarks")
 (item #:bullet custom-bullet "Conclusion"))


(slide
 #:title "Benchmarks"
 'alts
 (list (list (bitmap "enqueue.png"))
       (list (bitmap "dequeue.png"))
       (list (bitmap "insert.png"))
       (list (bitmap "find.png"))
       (list (bitmap "delete.png"))))

(slide
 #:title "Conclusion"
 (item #:bullet invis-bul 
       "Benchmarks that we obtained looks very promising and we feel that functional data structures can be good alternatives to more traditional ones and their imperative counterparts."))

(slide
 (t "Questions???"))


(slide
 (t "Thank you..."))
 

;       (list (bitmap "Hash.png"))
;       (list
;        (item #:bullet invis-bul "VLists")
;        (item #:bullet invis-bul "Hash-Lists"))))


;             (subitem #:bullet invis-bul "Binary Random Access Lists")
;             (subitem #:bullet invis-bul "Binomial Heaps")
;             'next
;             (item #:bullet invis-bul "Skew Binary Numbers")
;             'next
;             (subitem #:bullet invis-bul "Skew Binary Random Access List")
;             (subitem #:bullet invis-bul "Skew Binomial Heap"))))


;(slide
; #:title "Purely Functional Data Structures"
; ;(t #;:bullet #;custom-bullet "Amortized analysis for functional data structures")
; 'next
; (item #:bullet invis-bul "Lazy evaluation")
; 'next
; 'alts
; (list (list (subitem #:bullet invis-bul 
;                      (code
;                       code:blank
;                       code:blank
;                       (: fun : (Integer -> (Promise Exact-Rational)))
;                       (define (fun int)
;                         (delay (/ int 0))))))
;       (list (subitem #:bullet invis-bul "Streams or lazy lists")
;             'next
;             pict-id)
;       (list (subitem #:bullet invis-bul "Streams or lazy lists") 
;             (subitem #:bullet invis-bul "Banker's Queue")
;             'next
;             (subitem #:bullet invis-bul "Physicist's Queue")
;             'next
;             (subitem #:bullet invis-bul "Lazy Binomial Heap")
;             (subitem #:bullet invis-bul "Lazy Pairing Heap"))))
;
;(define bt1 (bitmap "Heap1.png"))
;(define bt2 (bitmap "Heap2.png"))
;(define bt3 (bitmap "Heap3.png"))
;
;; (list (list (subitem #:bullet invis-bul "Scheduling")
;;             'next
;;             (subitem #:bullet invis-bul "Real-Time Queues"))
;;       (list (ht-append 10.0 bt1 (arrow 20 0) bt2 (arrow 20 0) bt3))
;;       (list (item #:bullet invis-bul "Scheduling")
;;             (subitem #:bullet invis-bul "Real-Time Queues")
;;             (item #:bullet invis-bul "Lazy Rebuilding")
;;             'next
;;             (subitem #:bullet invis-bul "Banker's Deques")
;;             (subitem #:bullet invis-bul "Real-Time Deques"))))
;
;
;
;(slide
; #:title "Purely Functional Data Structures"
; (t "Data-structural Bootstrapping")
; 'alts
; (list (list (code 
;              (define-struct: (A) Queue
;                ([front : (Listof A)]
;                 [rear  : (Listof A)]))))
;       (list (code
;              (define-type (Queue A) (Listof A))
;              code:blank
;              (define head car)
;              (define tail cdr)
;              code:blank
;              (: enqueue : (All (A) (A (Queue A) -> (Queue A))))
;              (define (enqueue elem que) 
;                (append que (list elem)))))
;       (list (item #:bullet invis-bul "Structural Decomposition")
;             'next
;             (subitem #:bullet invis-bul "Bootstrapped Queue")
;             'next
;             (item #:bullet invis-bul "Structural Abstraction")
;             'next
;             (subitem #:bullet invis-bul "Catenable List")
;             (subitem #:bullet invis-bul "Bootstrapped Heap"))))
;
;
;
;
;;(slide
;; #:title "Benchmarks"
;; (bitmap "Screenshot1.png"))
;
;(slide
; #:title "Benchmarks")
;
;
;
;;(require scribble/eval)
;;(define evaluate (make-base-eval))
;;(evaluate '(require typed/racket))
;;(evaluate '(require "../stream.ss"))
;;(require racket/sandbox)
;;(define base-module-eval
;;  (make-evaluator 'typed/racket
;;                  #:requires (list "stream.ss")
;;                  ;'(define (f) later)
;;                  '(define (f) (stream-map (lambda: ([x : Integer]) (/ x 0)) 
;;                                           (stream 1 2 3)))))
;
;;(require scribble/eval)
;;(define evaluate (make-base-eval))
;;(evaluate '(require typed/scheme))
;;(evaluate '(require "stream.ss"))