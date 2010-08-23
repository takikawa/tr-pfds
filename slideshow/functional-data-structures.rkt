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


;(slide
; #:title "Outline"
; (item #:bullet custom-bullet "Motivation") 
; (item #:bullet custom-bullet "Typed Racket in a Nutshell") 
; (item #:bullet custom-bullet "Purely Functional Data Structures")
; (item #:bullet custom-bullet "Benchmarks")
; (item #:bullet custom-bullet "Conclusion"))
;
;
;(slide
; #:title "Outline"
; (item #:bullet sel-bul "Motivation") 
; (item #:bullet custom-bullet "Typed Racket in a Nutshell") 
; (item #:bullet custom-bullet "Purely Functional Data Structures")
; (item #:bullet custom-bullet "Benchmarks")
; (item #:bullet custom-bullet "Conclusion"))


(slide
 #:title "Motivation"
 (item #:bullet invis-bul "Typed Racket has very few data structures")
 'next
 (subitem #:bullet invis-bul "Lists")
 ; (subitem #:bullet invis-bul (code '(1 2 3 4)))
 'next
 (subitem #:bullet invis-bul "Vectors")
 'next
 ; (subitem #:bullet invis-bul (code #, (tt "#(1 2 3 4)")))
 (subitem #:bullet invis-bul "Hash Tables")
 ; (subitem #:bullet invis-bul (code #, (tt "#hash((\"a\" . 1) (\"b\" . 2))")))
 'next
 (code code:blank)
 (item #:bullet invis-bul "Practical use of Typed Racket"))



(slide
 #:title "Outline"
 (item #:bullet custom-bullet "Motivation") 
 (item #:bullet sel-bul "Typed Racket in a Nutshell") 
 (item #:bullet custom-bullet "Purely Functional Data Structures")
 (item #:bullet custom-bullet "Benchmarks")
 (item #:bullet custom-bullet "Typed Racket Evaluation")
 (item #:bullet custom-bullet "Conclusion"))

;(slide
; (t "Typed Racket in a Nutshell"))

;(slide
; #:title "Typed Racket in a Nutshell"
; (t "What is Typed Racket"))

(slide
 #:title "Function definition in Racket"
 (t "")
 (code
  #, (tt "#lang") racket
  code:blank
  (code:comment "Computes the length of a given list of elements")
  (code:comment "length : list-of-elems -> natural")
  (define (length list)
    (if (null? list)
        0
        (add1 (length (cdr list)))))))

(current-keyword-list (list "typed/racket" "->" ":"))
(current-keyword-color "red")

(slide
 #:title "Function definition in Typed Racket"
 (t "")
 (code
  #, (tt "#lang") typed/racket
  code:blank
  (code:comment "Computes the length of a given list of integers")
  (: length : (Listof Integer) -> Natural) 
  (define (length list)
    (if (null? list)
        0
        (add1 (length (cdr list)))))))

(current-keyword-list (list))

(current-keyword-list (list "All" "A"))

(slide
 #:title "Function definition in Typed Racket"
 (t "")
 (code
  #, (tt "#lang") typed/racket
  code:blank
  (code:comment "Computes the length of a given list of elements")
  (: length : (All (A) ((Listof A) -> Natural))) 
  (define (length list)
    (if (null? list)
        0
        (add1 (length (cdr list)))))))

(slide
 #:title "Data definition in Racket"
 (t "")
 (code
  #, (tt "#lang") racket
  code:blank
  (code:comment "Data definition of tree of integers    ")
  code:blank
  (code:comment "A Tree is one of")
  (code:comment "- null")
  (code:comment "- BTree")
  code:blank
  (define-struct BTree
    (left
     elem
     right))
  code:blank
  (code:comment "left and right are of type Tree")
  (code:comment "elem is an Integer")))


(current-keyword-list (list "U" "define-type" "define-struct:"))

(slide
 #:title "Data definition in Typed Racket"
 (t "")
 (code
  #, (tt "#lang") typed/racket
  code:blank
  (code:comment "Data definition of tree of integers    ")
  code:blank
  (define-type Tree (U Null BTree))
  code:blank
  code:blank
  (define-struct: BTree
    ([left  : Tree]
     [elem  : Integer]
     [right : Tree]))
  code:blank
  code:blank))


(current-keyword-list (list "A"))

(slide
 #:title "Data definition in Typed Racket"
 (t "")
 (code
  #, (tt "#lang") typed/racket
  code:blank
  (code:comment "Polymorphic definition of Tree")
  code:blank
  (define-type (Tree A) (U Null (BTree A)))
  code:blank
  code:blank
  (define-struct: (A) BTree
    ([left  : (Tree A)]
     [elem  : A]
     [right : (Tree A)]))
  code:blank
  code:blank))

(current-keyword-list (list))

(slide
 #:title "Outline"
 (item #:bullet custom-bullet "Motivation")
 (item #:bullet custom-bullet "Typed Racket in a Nutshell") 
 (item #:bullet sel-bul "Purely Functional Data Structures")
 (item #:bullet custom-bullet "Benchmarks")
 (item #:bullet custom-bullet "Typed Racket Evaluation")
 (item #:bullet custom-bullet "Conclusion"))


;(slide
; (t "Purely Functional Data Structures"))


(define destructive-update
  (ht-append 0.0
             (ht-append 25.0
                        (text "e" null 25 0)
                        (arrow 35 0))
             (ht-append 0.0
                        (bitmap "per1.jpg")
                        (ht-append 25.0 
                                   (text "⇒" null 45 0)
                                   (bitmap "des-up.jpg")))))
(define update
  (pin-over
   (ghost destructive-update) 0 0
   (ht-append 0.0
              (ht-append 25.0
                         (text "e" null 25 0)
                         (arrow 35 0))
              (bitmap "per1.jpg"))))

(define non-destructive-update 
  (pin-over
   (ghost destructive-update) 0 0
   (ht-append 0.0
              (ht-append 25.0
                         (text "e" null 25 0)
                         (arrow 35 0))
              (ht-append 0.0
                         (bitmap "per1.jpg")
                         (ht-append 25.0 
                                    (text "⇒" null 45 0)
                                    (bitmap "per3.png"))))))

(slide
 #:title "Destructive and Non-destructive update"
 'alts
 (list (list update)
       (list destructive-update
             (t "Destructive update"))
       (list non-destructive-update
             (t "Non-destructive update"))))

(define-exec-code (pict-id runnable-id string-id)
  #, (tt "#lang") typed/racket
  (require "stream.rkt")
  code:blank
  (stream-map (lambda: ([x : Integer]) (/ x 0)) 
              (stream 1 2 3)))




;(current-keyword-list (list "Promise"))

(define bankers (bitmap "bankers.png"))

(current-font-size 25)
(define enqueue
  (code
   (: enqueue : (All (A) (A (Queue A) -> (Queue A))))
   (define (enqueue elem que)
     (if (null? (Queue-front que))
         (Queue (reverse (cons elem (Queue-rear que))) null)
         (Queue (Queue-front que) (cons elem (Queue-rear que)))))))

(current-keyword-list (list "Promise" "cdr" "reverse" "front"))

(define dequeue
  (code
   (: dequeue : (All (A) ((Queue A) -> (Queue A))))
   (define (dequeue que)
     (let ([front (cdr (Queue-front que))]
           [rear  (Queue-rear que)])
       (if (null? front)
           (Queue (reverse rear) null)
           (Queue front rear))))))

(current-font-size 30)

(define stream
  (code (define-type (Stream A) 
          (Pair A (Promise (Stream A))))))


(current-keyword-list (list "accum" "delay"))
(current-font-size 25)
(define incr-rev
  (code code:blank
        (: rotate : 
           (All (A) ((Stream A) (Listof A) (Stream A) -> (Stream A))))
        code:blank
        (define (rotate front rear accum)
          (if (empty-stream? front)
              (stream-cons (car rear) accum)
              (stream-cons (stream-car front)
                           (rotate (stream-cdr front) 
                                   (cdr rear) 
                                   (stream-cons (car rear) accum)))))))

(current-keyword-list (list "stream-reverse"))

(define check
  (code (: check : 
           (All (A) (Stream A) Integer (Stream A) Integer -> (Queue A)))
        code:blank
        (define (check front lenf rear lenr)
          (if (>= lenf lenr)
              (make-Queue front lenf rear lenr)
              (make-Queue (stream-append front (stream-reverse rear))
                          (+ lenf lenr) null 0)))))

(define else
  (code 
   code:blank
   code:blank
   code:blank
   code:blank
   code:blank
   code:blank
   (make-Queue (stream-append front (stream-reverse rear)) 
               (+ lenf lenr) null 0)))

(current-font-size 30)

(current-keyword-list (list "Promise"))
(slide
 #:title "Functional Queue"
 (blank 10)
 'alts
 (list (list (code
              (define-struct: (A) Queue
                ([front : (Listof A)]
                 [rear  : (Listof A)]))
              code:blank
              code:blank)
             'next
             bankers)))

(define for-loop
  (code
   (for ([id (in-range 100)])
     (dequeue q))))

(slide
 #:title "Functional Queue"
 (blank 10)
 'alts
 (list (list dequeue)
       (list (item #:align 'center #:bullet invis-bul "Queue " (code q))
             (bitmap "whylazy.png")             
             (blank 10)
             for-loop)))

(current-font-size 30)

(slide
 #:title "Banker's Queue [Okasaki 1998]"
 (blank 10)
 'alts
 (list (list (subitem #:bullet invis-bul 
                      "Lazy evaluation solves this problem") 
             'next
             'alts
             (list
              (list (code
                     code:blank
                     code:blank
                     (: val : (Promise Exact-Rational))
                     code:blank
                     (define val (delay (/ 5 0)))))
              (list 
               (subitem #:bullet invis-bul "Streams")
               stream)
              (list
               'alts
               (list 
                (list
                 (code
                  code:blank
                  (define-struct: (A) Queue
                    ([front : (Stream A)]
                     [lenf  : Integer]
                     [rear  : (Stream A)]
                     [lenr  : Integer]))
                  code:blank)
                 (subitem #:align 'center #:bullet invis-bul "Invariant " (code lenf >= lenr)))
                (list check)
                (list else)
                (list 
                 (vc-append 
                  16 (subitem #:bullet invis-bul
                              (new-text "Amortized running time of O(1) for the operations"))
                  (subitem #:bullet invis-bul
                           (hc-append (code enqueue)
                                      (new-text ", ")
                                      (code dequeue)
                                      (new-text "  and  ") 
                                      (code head)))))))))))


(slide
 #:title "Real-Time Queues [Hood & Melville 81]"
 ;(item #:bullet invis-bul "")
 ;(code code:blank)
 'next
 (item #:bullet invis-bul "Eliminating amortization by Scheduling")
 (blank 10)
 'next
 'alts
 (list (list bankers
             (item #:align 'center #:bullet invis-bul 
                   "Banker's Queue -" (code reverse) 
                   " is a forced completely"))
       (list incr-rev
             (blank 10)
             (t "Incremental reversing"))
       (list (vc-append 16 
                        (subitem #:bullet invis-bul
                                 (new-text "Worst-case running time of O(1) for the operations"))
                        (subitem #:bullet invis-bul
                                 (hc-append (code enqueue)
                                            (new-text ", ")
                                            (code dequeue) 
                                            (new-text "  and  ") 
                                            (code head)))))))


(current-keyword-list null)

(define final (bitmap "final.png"))
(define final-ghost (ghost final))
(define list0
  (pin-over final-ghost 50 0 (bitmap "list0.png")))
(define list1
  (pin-over final-ghost 50 0 (bitmap "list3.png")))
(define list2
  (pin-over final-ghost 50 0 (bitmap "list83.png")))
(define list3
  (pin-over final-ghost 50 0 (bitmap "list783.png")))
(define list4
  (pin-over final-ghost 50 0 (bitmap "list1783.png")))
(define list5
  (pin-over final-ghost 50 0 (bitmap "list41783.png")))

(slide
 #:title "Binary Random Access Lists [Okasaki 1998]"
 (blank 15)
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
                                       - (cons elem List)
                                       code:blank))
             'next
             (subitem #:bullet invis-bul (code cons) " corresponds to increment")
             (subitem #:bullet invis-bul (code cdr) " corresponds to decrement")
             (subitem #:bullet invis-bul (code append) " corresponds to addition"))
       (list 'alts
             (list (list 'alts
                         (list
                          (list (code (define-type (RAList A) (Listof (Digit A))))
                                'next     
                                (code (define-type (Digit A) (U Zero (One A)))))
                          (list (code (define-struct: Zero ()))
                                'next 
                                (code (define-struct: (A) One ([fst  : (Tree A)]))))
                          (list (code (define-type (Tree A) (U (Leaf A) (Node A))))
                                'next
                                (code (define-struct: (A) Leaf ([fst : A])))
                                'next
                                (code (define-struct: (A) Node 
                                        ([size  : Integer]
                                         [left  : (Tree A)] 
                                         [right : (Tree A)]))))))
                   (list (code (define-type (RAList A) (Listof (Digit A))))
                         list0)
                   (list (code (define-type (RAList A) (Listof (Digit A))))
                         list1)
                   (list (code (define-type (RAList A) (Listof (Digit A))))
                         list2)
                   (list (code (define-type (RAList A) (Listof (Digit A))))
                         list3)
                   (list (code (define-type (RAList A) (Listof (Digit A))))
                         list4)
                   (list (code (define-type (RAList A) (Listof (Digit A))))
                         list5)
                   (list (code (define-type (RAList A) (Listof (Digit A))))
                         final))
             'next
             (blank 10)
             (vc-append 
              16 
              (subitem #:bullet invis-bul
                       "Worst-case running time of O(log n) for the operations ")
              (subitem #:bullet invis-bul
                       (code cons) ", " (code car) ", " (code cdr) ", " (code lookup) " and "
                       (code update))))))
;             (subitem #:bullet invis-bul 
;                      " cons, car, cdr, lookup and update"))))

(define vlist
  (code
   (define-struct: (A) Base 
     ([previous : (U Null (Base A))]
      [elems    : (RAList A)]))
   code:blank
   code:blank
   (define-struct: (A) VList 
     ([offset : Natural]
      [base   : (Base A)]
      [size   : Natural]))))

(slide
 #:title "VLists [Bagwell 2002]"
 'alts
 (list (list vlist)
       (list (item #:bullet invis-bul "List with one element - 6")
             (code code:blank)
             (bitmap "VList1.png"))
       (list (item #:bullet invis-bul (code cons) " 5 and 4 to the previous list")
             (code code:blank)
             (bitmap "VList2.png"))
       (list (item #:bullet invis-bul (code cons) " 3 and 2 to the previous list")
             (code code:blank) 
             (bitmap "VList.png"))
       (list (item #:bullet invis-bul (code cdr) " of the previous list")
             (code code:blank) 
             (bitmap "VList3.png"))
       (list
        (item #:bullet invis-bul 
              "Random access takes O(1) average and O(log n) in worst-case."))))


(slide
 #:title "Our library"
 'alts
 (list 
  (list
   (item #:bullet invis-bul "Library has 30 data structures which include")
   (subitem #:bullet invis-bul "Variants of Queues")
   (subitem #:bullet invis-bul "Variants of Deques")
   (subitem #:bullet invis-bul "Variants of Heaps")
   (subitem #:bullet invis-bul "Variants of Lists")
   (subitem #:bullet invis-bul "Red-Black Trees")
   (subitem #:bullet invis-bul "Tries")
   (subitem #:bullet invis-bul "Sets")
   (subitem #:bullet invis-bul "Hash Lists"))
  (list 
   (item #:bullet invis-bul "Library has 30 data structures")
   'next
   (item #:bullet invis-bul "Data structures have several utility functions")
   'next
   (item #:bullet invis-bul "Our implementations follows the original work"))))

(slide
 #:title "Outline"
 (item #:bullet custom-bullet "Motivation")
 (item #:bullet custom-bullet "Typed Racket in a Nutshell")
 (item #:bullet custom-bullet "Purely Functional Data Structures")
 (item #:bullet sel-bul "Benchmarks")
 (item #:bullet custom-bullet "Typed Racket Evaluation")
 (item #:bullet custom-bullet "Conclusion"))

(define enqueue-benchmark (bitmap "enqueue.png"))
(define dequeue-benchmark 
  (pin-over (ghost enqueue-benchmark) 0 0 
            (bitmap "dequeue.png")))

(slide
 #:title "Benchmarks"
 'alts
 (list (list enqueue-benchmark
             (code (foldl enqueue que list-of-100000-elems)))
       (list dequeue-benchmark)
       (list (bitmap "insert.png"))
       (list (bitmap "find.png"))
       (list (bitmap "delete.png"))))

(current-font-size 25)
(define bq
  (code 
   type 'a Queue = int * 'a Stream * int * 'a Stream
   code:blank
   code:blank
   (define-struct: (A) Queue
     ([lenf  : Integer]
      [front : (Stream A)]
      [lenr  : Integer]
      [rear  : (Stream A)]))))

(define pq
  (code
   type 'a Queue = 'a list * int * 'a list susp * int * 'a list
   code:blank
   code:blank
   (define-struct: (A) Queue 
     ([pref  : (Listof A)]
      [lenf  : Integer]
      [front : (Promise (Listof A))]
      [lenr  : Integer]
      [rear  : (Listof A)]))))
(current-font-size 30)

(slide
 #:title "Outline"
 (item #:bullet custom-bullet "Motivation")
 (item #:bullet custom-bullet "Typed Racket in a Nutshell")
 (item #:bullet custom-bullet "Purely Functional Data Structures")
 (item #:bullet custom-bullet "Benchmarks")
 (item #:bullet sel-bul "Typed Racket Evaluation")
 (item #:bullet custom-bullet "Conclusion"))

(slide
 #:title "ML to Typed Racket"
 (item #:bullet invis-bul "ML idioms can be easily ported to Typed Racket")
 'next
 'alts
 (list (list bq)
       (list pq)))

(define optimizer
  (bitmap "optimizer.png"))

(slide
 #:title "Optimizer in Typed Racket"
 'alts
 (list (list
        (item #:bullet invis-bul "Optimizer based on type information"))
       (list optimizer)))

(define poly-rec
  (code
   (define-type (Seq A) (Pair A (Seq (Pair A A))))))

(define regular
  (code
   (define-type (EP A)  (U A (Pair (EP A) (EP A))))
   (define-type (Seq A) (Pair (EP A) (Seq A)))))

(slide
 #:title "Polymorphic recursion"
 'alts
 (list (list poly-rec
             (blank 20)
             (t "Non-uniform type"))
       (list regular
             (blank 20)
             (t "Uniform type"))))
;       (list regular
;             (blank 20)
;             (code
;              (de
;              (cons 1 (cons 1 2)))

(slide
 #:title "Conclusion"
 (item #:bullet invis-bul "Typed Racket is useful for real-world software.")
 (item #:bullet invis-bul "Functional data structures in Typed Racket are useful and performant.")
 (item #:bullet invis-bul "A comprehensive library of data structures is now available."))
; (item #:bullet invis-bul 
;       "Benchmarks that we obtained looks very promising and we feel that functional data structures can be good alternatives to more traditional ones and their imperative counterparts."))

(current-font-size 35)
(define thank-you
  (t "Thank you..."))
(current-font-size 30)
(slide
 thank-you
 (t "Library is available for download from")
 (t "http://planet.racket-lang.org/"))
