#lang scribble/manual
@(defmodule "../skewbinaryrandomaccesslist.ss")
@(require (for-label "../skewbinaryrandomaccesslist.ss"))

@(require scribble/eval)

@(define evaluate (make-base-eval))
@(evaluate '(require typed/scheme))
@(evaluate '(require "../skewbinaryrandomaccesslist.ss"))

@title{Skew Binary Random Access List}

Random Access Lists are list data structures that provide array-like lookup and
update operations. Skew Binary Random Access Lists are implemented using skew
binary numbers. It provides a worst case running time of @bold{@italic{O(1)}} 
for the operations @scheme[cons], @scheme[first] and @scheme[rest] and
@bold{@italic{O(log(n))}} for the operations @scheme[list-ref]
and @scheme[list-set].

@;section{Skew Binary Random Access List Constructor and Operations}

@defproc[(list [a A] ...) (List A)]{
Function list creates a Skew Binary Random Access List with the given 
inputs. 
@examples[#:eval evaluate

(list 1 2 3 4 5 6)
]

In the above example, @scheme[(list 1 2 3 4 5 6)] gives a Skew Binary Random 
Access List which is similar to lists and has efficient lookup and update
operations.}

@defthing[empty (List Nothing)]{
A empty list.}

@defproc[(empty? [ral (List A)]) Boolean]{
Function @scheme[empty?] takes a Skew Binary Random Access List checks 
if the given list is empty. 
@examples[#:eval evaluate

(empty? (list 1 2 3 4 5 6))

(empty? empty)
]}


@defproc[(cons [a A] [ral (List A)]) (List A)]{
Function @scheme[cons] takes an element and a list and adds the given 
element to the front of the given list. 
@examples[#:eval evaluate

(cons 10 (list 1 2 3 4 5 6))
]

In the above example, @scheme[(cons 10 (list 1 2 3 4 5 6))] 
returns a @scheme[(list 10 1 2 3 4 5 6)].}


@defproc[(first [ral (List A)]) A]{
Function @scheme[first] takes a list and returns the first element
of the given list. 
@examples[#:eval evaluate

(first (list 1 2 3 4 5 6))
(first empty)
]}


@defproc[(rest [ral (List A)]) (List A)]{
Function @scheme[rest] takes a list and returns a list without 
the first element of the given list. 
@examples[#:eval evaluate

(rest (list 1 2 3 4 5 6))
(rest empty)
]

In the above example, @scheme[(rest (list 1 2 3 4 5 6))] returns 
the @scheme[(list 2 3 4 5 6)].}


@defproc[(list-ref [ral (List A)] [index Integer]) A]{
Function @scheme[list-ref] takes a list and an index(say n) and gives
the nth element of the given list.


@examples[#:eval evaluate

(list-ref (list 1 2 3 4 5 6) 0)
(list-ref (list 1 2 3 4 5 6) 3)
(list-ref (list 1 2 3 4 5 6) 10)
]}


@defproc[(list-set [ral (List A)] [index Integer] [newval A]) (List A)]{
Function @scheme[list-set] takes a list, an index(say n) and a new
element and updates the nth element of the list with the new element.


@examples[#:eval evaluate

(->list (list-set (list 1 2 3 4 5 6) 3 10))

(->list (list-set (list 1 2 3 4 5 6) 6 10))
]

In the above example, @scheme[(list-set (list 1 2 3 4 5 6) 3 10)] returns
@scheme[(list 1 2 3 10 5 6)],
@scheme[(list-set (list 1 2 3 4 5 6) 6 10)] throws an error since there are
only six elements in the list and it is trying to update seventh element.}


@defproc[(->list [ral (List A)]) (Listof A)]{
Function @scheme[->list] takes a list and returns a list
of elements which are in the same order as in the list. 
@examples[#:eval evaluate

(->list (list 1 2 3 4 5 6))
(->list empty)
]}

@defproc[(drop [num Integer] [ral (List A)]) (List A)]{
Function @scheme[drop] takes a list and an integer(say n) and drops 
the first n elements of the input list and returns the rest of the list. 

@examples[#:eval evaluate

(drop 3 (list 1 2 3 4 5 6))

(drop 0 (list 1 2 3 4 5 6))

(drop 10 (list 1 2 3 4 5 6))
]

In the above example, @scheme[(drop 3 (list 1 2 3 4 5 6) 3)] returns 
@scheme[(list 4 5 6)]. @scheme[(drop 0 (list 1 2 3 4 5 6))] returns the
@scheme[(list 1 2 3 4 5 6)]. If the given n is larger than the number of 
elements in the list, then it throws an error.}



@defproc[(list-length [ral (List A)]) Integer]{
Function @scheme[list-length] takes a list and gives the number of 
elements in in the given list. 

@examples[#:eval evaluate

(list-length (list 1 2 3 4 5 6))
(list-length (list 1 2 3))
(list-length empty)
]}

@(close-eval evaluate)
