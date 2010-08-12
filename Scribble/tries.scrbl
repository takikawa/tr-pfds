#lang scribble/manual
@(defmodule "../tries.ss")
@(require (for-label "../tries.ss"))
@(require scribble/eval)

@(define evaluate (make-base-eval))
@(evaluate '(require typed/scheme))
@(evaluate '(require "../tries.ss"))

@title{Tries}

A Trie (also known as a Digital Search Tree) is a data structure
which takes advantage of the structure of aggregate types to achieve
good running times for its operations. Our implementation 
provides Tries in which the keys are lists of the element
type; this is sufficient for representing many aggregate data 
structures. In our implementation, each trie is a multiway tree with each
node of the multiway tree carrying data of base element type. Tries
provide @racket[lookup] and @racket[insert] operations with better 
asymptotic running times than hash tables. This data structure is very 
useful when used for an aggregate type like strings.



@;section{Red-Black Trees Construction and Operations}

@defproc[(tries [values (Listof V)] [keys (Listof (Listof K))]) (Trie K V)]{
Function 
@scheme[tries] creates a trie with each value assigned to the list 
in keys at the corresponding location. 
@examples[#:eval evaluate

(tries (list 1 2 3 4 5) 
       (map string->list (list "abc" "xyz" "abcfg" "abxyz" "xyz12")))
]

In the above example, "abc" will have the value 1, "xyz" will get 2 
and so on.}


@defproc[(trie [keys (Listof (Listof K))]) (Trie K Integer)]{
Function 
@scheme[trie] creates a trie by assigning a integer value to each list 
in keys. 
@examples[#:eval evaluate

(trie (map string->list (list "abc" "xyz" "abcfg" "abxyz" "xyz12")))
]

In the above example, "abc" will have the value 1, "xyz" will get 2 
and so on.}


@defproc[(insert [values (Listof V)] [keys (Listof (Listof K))] [trie (Trie K V)]) (Trie K V)]{
Inserts multiple keys into the trie. 
@examples[#:eval evaluate

(insert (list 4 5) 
        (map string->list (list "abcfg" "abxyz"))
        (tries (list 1 2) 
               (map string->list (list "abc" "xyz"))))
]

In the above example, "abcfg" will have the value 4, "abxyz" will get 5}


@defproc[(bind [key (Listof K)] [value V] [trie (Trie K V)]) (Trie K V)]{
Inserts a key into the trie. 
@examples[#:eval evaluate

(bind (string->list "abcfg") 3
      (tries (list 1 2) 
             (map string->list (list "abc" "xyz"))))
]}



@defproc[(lookup [key (Listof K)] [trie (Trie K V)]) V]{
Looks for the given key. If found, the value corresponding to the key is 
returned. Else throws an error.
@examples[#:eval evaluate

(lookup (string->list "abcde")
        (tries (list 1 2 3 4)  
               (map string->list (list "123" "abc" "xyz" "abcde"))))
                                                                    
(lookup (string->list "abc")
        (tries (list 1 2 3 4)  
               (map string->list (list "123" "abc" "xyz" "abcde"))))
                                                                    
(lookup (string->list "abcd")
        (tries (list 1 2 3 4)  
               (map string->list (list "123" "abc" "xyz" "abcde"))))
]}