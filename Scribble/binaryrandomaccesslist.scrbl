#lang scribble/manual
@(defmodule "../binaryrandomaccesslist.ss")
@(require (for-label "../binaryrandomaccesslist.ss"))

@(require scribble/eval)

@(define evaluate (make-base-eval))
@(evaluate '(require typed/scheme))
@(evaluate '(require "../binaryrandomaccesslist.ss"))

@title[#:tag "bral"]{Binary Random Access List}

Random Access Lists are list data structures that provide array-like lookup 
and update operations. They have been implemented as a framework of binary 
numerical representation using complete binary leaf trees. It has a worst 
case running time of @bold{@italic{O(log(n))}} for the operations
@scheme[cons], @scheme[first], @scheme[rest], @scheme[list-ref] and
@scheme[list-set].

@;section{Binary Random Access List Constructor and Operations}

@defproc[(list [a A] ...) (List A)]{
Function @scheme[list] creates a Binary Random Access List with the given 
inputs.
@examples[#:eval evaluate

(list 1 2 3 4 5 6)
]

In the above example, @scheme[(list 1 2 3 4 5 6)] gives a Binary Random 
Access List which is similar to lists but comes with efficient list-ref and 
list-set operations.}

@defthing[empty (List Nothing)]{
A empty random access list}

@defproc[(empty? [ral (List A)]) Boolean]{
Function @scheme[empty?] takes a Binary Random Access List checks if the 
given list is empty.   
@examples[#:eval evaluate

(empty? (list 1 2 3))

(empty? empty)
]}

@defproc[(cons [a A] [ral (List A)]) (List A)]{
Function @scheme[cons] takes an element and a list and adds the given 
element to the front of the given list.   
@examples[#:eval evaluate

(cons 10 (list 5 3 5 6))
]

In the above example, @scheme[(cons 10 (list 5 3 5 6))] returns 
@scheme[(list 10 5 3 5 6)].
}

@defproc[(first [ral (List A)]) A]{
Function @scheme[first] takes a list and returns the first element
of the given list if its not empty else throws an error.   
@examples[#:eval evaluate

(first (list 5 3 5 6))

(first empty)
]}



@defproc[(rest [ral (List A)]) (List A)]{
Function @scheme[rest] takes a list and returns the given list but
without its first element if the given list is not empty. If it is empty,
@scheme[rest] throws an error
@examples[#:eval evaluate

(rest (list 1 2 3 4 5 6))

(rest empty)
]

In the above example, @scheme[(rest ral)] returns the rest of the given 
list, @scheme[(list 2 3 4 5 6)].
}

@defproc[(list-ref [ral (List A)] [index Integer]) A]{
Function @scheme[list-ref] takes an integer(say n) and a list and gives
the nth element of the given list. If the given n is larger than the size 
of the list, @scheme[list-ref] throws an error.
  
@examples[#:eval evaluate

(list-ref (list 12 5 3 2 15 23) 4)

(list-ref (list 12 5 3 2 15 23) 10)

]}


@defproc[(list-set [ral (List A)] [index Integer] [newval A]) (List A)]{
Function @scheme[list-set] takes an integer(say n), list and a new
element. And updates the nth element of the list with the new element.

  
@examples[#:eval evaluate

(list-set (list 1 2 3 4 5 6) 2 10)

(list-set (list 1 2 3 4 5 6) 10 15)
]

In the above example, @scheme[(list-set (list 1 2 3 4 5 6) 2 10)] returns 
@scheme[(list 1 2 10 4 5 6)] and 
@scheme[(list-set (list 1 2 3 4 5 6) 10 15)] throws an error.
}

@defproc[(->list [ral (List A)]) (Listof A)]{
Function @scheme[->list] takes a list and returns a list
of elements which are in the same order as in the list.   
@examples[#:eval evaluate

(define ral (list 1 2 3 4 5 6))

(->list ral)
]

In the above example, @scheme[(->list ral)] returns
@scheme[(list 1 2 3 4 5 6)].
}

@defproc[(drop [ral (List A)] [num Integer]) (List A)]{
Function @scheme[drop] takes a list and an integer(say n) and drops 
the first n elements of the input list and returns the rest of the list. 
  
@examples[#:eval evaluate

(drop 3 (list 1 2 3 4 5 6))

(drop 10 (list 1 2 3 4 5 6))
]

In the above example, @scheme[(drop 3 (list 1 2 3 4 5 6))] returns the 
list @scheme[(list 4 5 6)]. @scheme[(drop 10 (list 1 2 3 4 5 6))]
throws an error since 10 is larger than the number of 
elements in the list.
}


@defproc[(list-length [ral (List A)]) Integer]{
Function @scheme[list-length] takes a list and gives the number of 
elements in in the given list. 
  
@examples[#:eval evaluate

(list-length (list 1 2 3 4 5 6))

(list-length empty)
]}
