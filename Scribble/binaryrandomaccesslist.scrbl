#lang scribble/manual

@(require scribble/eval)

@(define evaluate (make-base-eval))
@(evaluate '(require typed/scheme))
@(evaluate '(require "../binaryrandomaccesslist.ss"))

@title[#:tag "bral"]{Binary Random Access List}

Random Access Lists are list data structures that provide array-like lookup 
and update operations. They have been implemented as a framework of binary 
numerical representation using complete binary leaf trees. It has a worst 
case running time of @bold{@italic{O(log(n))}} for the operations
@italic{kons, head, tail, lookup and update}.

@;section{Binary Random Access List Constructor and Operations}

@defproc[(ralist [a A] ...) (RAList A)]{
The function ralist creates a Binary Random Access List with the given 
inputs.
@examples[#:eval evaluate

(ralist 1 2 3 4 5 6)
]

In the above example, @scheme[(ralist 1 2 3 4 5 6)] gives a Binary Random 
Access List which is similar to lists but comes with efficient lookup and 
update operations.}

@defform/none[empty]{
A empty random access list}

@defproc[(empty? [ral (RAList A)]) Boolean]{
The function @scheme[empty?] takes a Binary Random Access List checks if the 
given ralist is empty.   
@examples[#:eval evaluate

(empty? (ralist 1 2 3))

(empty? empty)
]}

@defproc[(kons [a A] [ral (RAList A)]) (RAList A)]{
The function @scheme[kons] takes an element and a ralist and adds the given 
element to the front of the given list.   
@examples[#:eval evaluate

(kons 10 (ralist 5 3 5 6))
]

In the above example, @scheme[(kons 10 (ralist 5 3 5 6))] returns 
@scheme[(ralist 10 5 3 5 6)].
}

@defproc[(head [ral (RAList A)]) A]{
The function @scheme[head] takes a ralist and returns the first element
of the given ralist if its not empty else throws an error.   
@examples[#:eval evaluate

(head (ralist 5 3 5 6))

(head empty)
]}



@defproc[(tail [ral (RAList A)]) (RAList A)]{
The function @scheme[tail] takes a ralist and returns the given ralist but
without its first element if the given ralist is not empty. If it is empty,
@scheme[tail] throws an error
@examples[#:eval evaluate

(tail (ralist 1 2 3 4 5 6))

(tail empty)
]

In the above example, @scheme[(tail ral)] returns the rest of the given 
ralist, @scheme[(ralist 2 3 4 5 6)].
}

@defproc[(lookup [index Integer] [ral (RAList A)]) A]{
The function @scheme[lookup] takes an integer(say n) and a ralist and gives
the nth element of the given ralist. If the given n is larger than the size 
of the list, @scheme[lookup] throws an error.
  
@examples[#:eval evaluate

(lookup 4 (ralist 12 5 3 2 15 23))

(lookup 10 (ralist 12 5 3 2 15 23))

]}


@defproc[(update [index Integer] [ral (RAList A)] [newval A]) (RAList A)]{
The function @scheme[update] takes an integer(say n), ralist and a new
element. And updates the nth element of the ralist with the new element.

  
@examples[#:eval evaluate

(update 2 (ralist 1 2 3 4 5 6) 10)

(update 10 (ralist 1 2 3 4 5 6) 15)
]

In the above example, @scheme[(update 2 (ralist 1 2 3 4 5 6) 10)] returns 
@scheme[(ralist 1 2 10 4 5 6)] and 
@scheme[(update 10 (ralist 1 2 3 4 5 6) 15)] throws an error.
}

@defproc[(ralist->list [ral (RAList A)]) (Listof A)]{
The function @scheme[ralist->list] takes a ralist and returns a list
of elements which are in the same order as in the ralist.   
@examples[#:eval evaluate

(define ral (ralist 1 2 3 4 5 6))

(ralist->list ral)
]

In the above example, @scheme[(ralist->list ral)] returns
@scheme[(ralist 1 2 3 4 5 6)].
}

@defproc[(drop [ral (RAList A)] [num Integer]) (RAList A)]{
The function @scheme[drop] takes a ralist and an integer(say n) and drops 
the first n elements of the input ralist and returns the rest of the list. 
  
@examples[#:eval evaluate

(drop (ralist 1 2 3 4 5 6) 3)

(drop (ralist 1 2 3 4 5 6) 10)
]

In the above example, @scheme[(drop (ralist 1 2 3 4 5 6) 3)] returns the 
ralist @scheme[(ralist 4 5 6)]. @scheme[(drop (ralist 1 2 3 4 5 6) 10)] 
throws an error since 10 is larger than the number of 
elements in the ralist.
}


@defproc[(list-length [ral (RAList A)]) Integer]{
The function @scheme[list-length] takes a ralist and gives the number of 
elements in in the given ralist. 
  
@examples[#:eval evaluate

(list-length (ralist 1 2 3 4 5 6))

(list-length empty)
]}
