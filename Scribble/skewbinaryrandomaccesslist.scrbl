#lang scribble/manual
@(require (for-label "../skewbinaryrandomaccesslist.ss"))

@(require scribble/eval)

@(define evaluate (make-base-eval))
@(evaluate '(require typed/scheme))
@(evaluate '(require "../skewbinaryrandomaccesslist.ss"))

@title{Skew Binary Random Access List}

Random Access Lists are list data structures that provide array-like lookup and
update operations. Skew Binary Random Access Lists are implemented using skew
binary numbers. It provides a worst case running time of @bold{@italic{O(1)}} 
for the operations @scheme[kons], @scheme[head] and @scheme[tail] and
@bold{@italic{O(log(n))}} for the operations @scheme[lookup]
and @scheme[update].

@;section{Skew Binary Random Access List Constructor and Operations}

@defproc[(ralist [a A] ...) (RAList A)]{
Function ralist creates a Skew Binary Random Access List with the given 
inputs. 
@examples[#:eval evaluate

(ralist 1 2 3 4 5 6)
]

In the above example, @scheme[(ralist 1 2 3 4 5 6)] gives a Skew Binary Random 
Access List which is similar to lists has efficient lookup and update
operations.}

@defthing[empty (RAList Nothing)]{
A empty ralist.}

@defproc[(empty? [ral (RAList A)]) Boolean]{
Function @scheme[empty?] takes a Skew Binary Random Access List checks 
if the given ralist is empty. 
@examples[#:eval evaluate

(empty? (ralist 1 2 3 4 5 6))

(empty? empty)
]}


@defproc[(kons [a A] [ral (RAList A)]) (RAList A)]{
Function @scheme[kons] takes an element and a ralist and adds the given 
element to the front of the given list. 
@examples[#:eval evaluate

(kons 10 (ralist 1 2 3 4 5 6))
]

In the above example, @scheme[(kons 10 (ralist 1 2 3 4 5 6))] 
returns a @scheme[(ralist 10 1 2 3 4 5 6)].}


@defproc[(head [ral (RAList A)]) A]{
Function @scheme[head] takes a ralist and returns the first element
of the given ralist. 
@examples[#:eval evaluate

(head (ralist 1 2 3 4 5 6))
(head empty)
]}


@defproc[(tail [ral (RAList A)]) (RAList A)]{
Function @scheme[tail] takes a ralist and returns a ralist without 
the first element of the given ralist. 
@examples[#:eval evaluate

(tail (ralist 1 2 3 4 5 6))
(tail empty)
]

In the above example, @scheme[(tail (ralist 1 2 3 4 5 6))] returns 
the @scheme[(ralist 2 3 4 5 6)].}


@defproc[(lookup [index Integer] [ral (RAList A)]) A]{
Function @scheme[lookup] takes an integer(say n) and a ralist and gives
the nth element of the given ralist


@examples[#:eval evaluate

(lookup 0 (ralist 1 2 3 4 5 6))
(lookup 3 (ralist 1 2 3 4 5 6))
(lookup 10 (ralist 1 2 3 4 5 6))
]}


@defproc[(update [index Integer] [ral (RAList A)] [newval A]) (RAList A)]{
Function @scheme[update] takes an integer(say n), ralist and a new
element. And updates the nth element of the ralist with the new element.


@examples[#:eval evaluate

(update 3 (ralist 1 2 3 4 5 6) 10)

(ralist->list (update 3 (ralist 1 2 3 4 5 6) 10))

(update 6 (ralist 1 2 3 4 5 6) 10)
]

In the above example, @scheme[(update 3 (ralist 1 2 3 4 5 6) 10)] returns
@scheme[(ralist 1 2 3 10 5 6)],
@scheme[(update 6 (ralist 1 2 3 4 5 6) 10)] throws an error since there are
only six elements in the list and it is trying to update seventh element.}


@defproc[(ralist->list [ral (RAList A)]) (Listof A)]{
Function @scheme[ralist->list] takes a ralist and returns a list
of elements which are in the same order as in the ralist. 
@examples[#:eval evaluate

(ralist->list (ralist 1 2 3 4 5 6))
(ralist->list empty)
]}

@defproc[(drop [num Integer] [ral (RAList A)]) (RAList A)]{
Function @scheme[drop] takes a ralist and an integer(say n) and drops 
the first n elements of the input ralist and returns the rest of the list. 

@examples[#:eval evaluate

(drop 3 (ralist 1 2 3 4 5 6))

(drop 0 (ralist 1 2 3 4 5 6))

(drop 10 (ralist 1 2 3 4 5 6))
]

In the above example, @scheme[(drop 3 (ralist 1 2 3 4 5 6) 3)] returns 
@scheme[(ralist 4 5 6)]. @scheme[(drop 0 (ralist 1 2 3 4 5 6))] returns the
@scheme[(ralist 1 2 3 4 5 6)]. If the given n is larger than the number of 
elements in the ralist, then it throws an error.}



@defproc[(list-length [ral (RAList A)]) Integer]{
Function @scheme[list-length] takes a ralist and gives the number of 
elements in in the given ralist. 

@examples[#:eval evaluate

(list-length (ralist 1 2 3 4 5 6))
(list-length (ralist 1 2 3))
(list-length empty)
]}
