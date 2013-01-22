#lang scribble/manual

@(require "helper.rkt")
@(require (for-label data/ralist/binary))

@(define evaluate (make-base-eval))
@(evaluate '(require typed/racket))
@(evaluate '(require data/ralist/binary))

@title[#:tag "bral"]{Binary Random Access List}

@defmodule[data/ralist/binary]

Random Access Lists are list data structures that provide array-like lookup 
and update operations. They have been implemented as a framework of binary 
numerical representation using complete binary leaf trees. It has a worst 
case running time of @bold{@italic{O(log(n))}} for the operations
@scheme[cons], @scheme[first], @scheme[rest], @scheme[list-ref] and
@scheme[list-set].

@defform[(List A)]{A binary random access list of type @racket[A].}

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


@defproc[(length [ral (List A)]) Integer]{
Function @scheme[length] takes a list and gives the number of 
elements in in the given list. 

@examples[#:eval evaluate

(length (list 1 2 3 4 5 6))

(length empty)
]}

@defproc[(reverse [list (List A)]) (List A)]{
Function @scheme[reverse] takes a list and returns a reversed list. 

@examples[#:eval evaluate

(->list (reverse (list 1 2 3 4 5 6)))
]}


@defproc[(map [func (A B ... B -> C)] 
              [lst1 (List A)]
              [lst2 (List B)] ...) (List A)]{
Function @scheme[map] is similar to @|racket-map| for lists.
@examples[#:eval evaluate

(->list (map add1 (list 1 2 3 4 5 6)))

(->list (map * (list 1 2 3 4 5 6) (list 1 2 3 4 5 6)))
]

In the above example, @scheme[(map add1 (list 1 2 3 4 5 6))] adds 1 to
each element of the given list and returns @scheme[(list 2 3 4 5 6 7)].
@scheme[(map * (list 1 2 3 4 5 6) (list 1 2 3 4 5 6))] multiplies
corresponding elements in the two lists
and returns the list @scheme[(list 1 4 9 16 25 36)].}


@defproc[(foldl [func (C A B ... B -> C)]
                 [init C]
                 [lst1 (List A)]
                 [lst2 (List B)] ...) C]{
Function @scheme[foldl] is similar to @|racket-foldl|.
@margin-note{@scheme[foldl] currently does not produce correct results when the 
             given function is non-commutative.}

@examples[#:eval evaluate

(foldl + 0 (list 1 2 3 4 5 6))

(foldl * 1 (list 1 2 3 4 5 6) (list 1 2 3 4 5 6))
]}


@defproc[(foldr [func (C A B ... B -> C)] 
                 [init C] 
                 [lst1 (List A)] 
                 [lst2 (List B)] ...) C]{
Function @scheme[foldr] is similar to @|racket-foldr|. 
@margin-note{@scheme[foldr] currently does not produce correct results when the 
             given function is non-commutative.}

@examples[#:eval evaluate

(foldr + 0 (list 1 2 3 4 5 6))

(foldr * 1 (list 1 2 3 4 5 6) (list 1 2 3 4 5 6))
]}


@defproc[(andmap [func (A B ... B -> Boolean)]
                 [lst1 (List A)]
                 [lst2 (List B)] ...) Boolean]{
Function @scheme[andmap] is similar to @|racket-andmap|.

@examples[#:eval evaluate

(andmap even? (list 1 2 3 4 5 6))

(andmap odd? (list 1 2 3 4 5 6))

(andmap positive? (list 1 2 3 4 5 6))

(andmap negative? (list -1 -2))
]}


@defproc[(ormap [func (A B ... B -> Boolean)]
                [lst1 (List A)]
                [lst2 (List B)] ...) Boolean]{
Function @scheme[ormap] is similar to @|racket-ormap|.

@examples[#:eval evaluate

(ormap even? (list 1 2 3 4 5 6))

(ormap odd? (list 1 2 3 4 5 6))

(ormap positive? (list -1 -2 3 4 -5 6))

(ormap negative? (list 1 -2))
]}

@defproc[(build-list [size Natural]
                     [func (Natural -> A)])
                     (List A)]{
Function @scheme[build-list] is similar to @|racket-build-list|.
@examples[#:eval evaluate

(->list (build-list 5 (λ:([x : Integer]) (add1 x))))

(->list (build-list 5 (λ:([x : Integer]) (* x x))))

]}

@defproc[(make-list [size Natural]
                    [func A])
                    (List A)]{
Function @scheme[make-list] is similar to @|racket-make-list|.
@examples[#:eval evaluate

(->list (make-list 5 10))

(->list (make-list 5 'sym))

]}

@defproc[(filter [pred (A -> Boolean)] [lst (List A)]) (List A)]{
Function @scheme[filter] is similar to @|racket-filter|. 
@examples[#:eval evaluate

(define lst (list 1 2 3 4 5 6))

(->list (filter (λ:([x : Integer]) (> x 5)) lst))

(->list (filter (λ:([x : Integer]) (< x 5)) lst))

(->list (filter (λ:([x : Integer]) (<= x 4)) lst))
]}

@defproc[(remove [pred (A -> Boolean)] [lst (List A)]) (List A)]{
Function @scheme[remove] is similar to @|racket-filter|
but @scheme[remove] removes the elements which match the predicate.
@examples[#:eval evaluate

(->list (remove (λ:([x : Integer]) (> x 5)) (list 1 2 3 4 5 6)))

(->list (remove (λ:([x : Integer]) (< x 5)) (list 1 2 3 4 5 6)))

(->list (remove (λ:([x : Integer]) (<= x 4)) (list 1 2 3 4 5 6)))
]}

@defproc[(second [lst (List A)]) A]{
Function @scheme[second] returns the second element of the list.

@examples[#:eval evaluate

(second (list 1 2 3 4 5 6 7 8 9 10))
]}

@defproc[(third [lst (List A)]) A]{
Function @scheme[third] returns the third element of the list.

@examples[#:eval evaluate

(third (list 1 2 3 4 5 6 7 8 9 10))
]}

@defproc[(fourth [lst (List A)]) A]{
Function @scheme[fourth] returns the fourth element of the list.

@examples[#:eval evaluate

(fourth (list 1 2 3 4 5 6 7 8 9 10))
]}

@defproc[(fifth [lst (List A)]) A]{
Function @scheme[fifth] returns the fifth element of the list.

@examples[#:eval evaluate

(fifth (list 1 2 3 4 5 6 7 8 9 10))
]}

@defproc[(sixth [lst (List A)]) A]{
Function @scheme[sixth] returns the sixth element of the list.

@examples[#:eval evaluate

(sixth (list 1 2 3 4 5 6 7 8 9 10))
]}

@defproc[(seventh [lst (List A)]) A]{
Function @scheme[seventh] returns the seventh element of the list.

@examples[#:eval evaluate

(seventh (list 1 2 3 4 5 6 7 8 9 10))
]}

@defproc[(eighth [lst (List A)]) A]{
Function @scheme[eighth] returns the eighth element of the list.

@examples[#:eval evaluate

(eighth (list 1 2 3 4 5 6 7 8 9 10))
]}

@defproc[(ninth [lst (List A)]) A]{
Function @scheme[ninth] returns the ninth element of the list.

@examples[#:eval evaluate

(ninth (list 1 2 3 4 5 6 7 8 9 10))
]}

@defproc[(tenth [lst (List A)]) A]{
Function @scheme[tenth] returns the tenth element of the list.

@examples[#:eval evaluate

(tenth (list 1 2 3 4 5 6 7 8 9 10 11))
]}

@defproc[(last [lst (List A)]) A]{
Function @scheme[last] returns the last element of the list.

@examples[#:eval evaluate

(last (list 1 2 3 4 5 6 7 8 9 10 11))
(last (list 1 2 3 4 5))
]}

@(close-eval evaluate)
