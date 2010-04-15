#lang scribble/manual

@(require scribble/eval)

@(define evaluate (make-base-eval))
@(evaluate '(require typed/scheme))
@(evaluate '(require "../vlist.ss"))

@(require (for-label (only-in scheme
                              map foldr foldl filter)))


@title{VList}

A VList is a data structure very similar to noraml Scheme List but the 
corresponding operations are significantly faster for most of the List
operations. Indexing and length operations have a running time of 
@bold{@italic{O(1)}} and @bold{@italic{O(lg N)}} respectively compared to 
@bold{@italic{O(N)}} in lists. The data structure has been described in the 
paper @italic{Fast Functional Lists, Hash-Lists, vlists and 
              Variable Length Arrays} by  Phil Bagwell.
VLists implementation internally uses @secref["bral"].

@section{VList Construction and Operations}

@subsection{vlist}
The function @scheme[vlist] creates a vlist with the given inputs. 

@examples[#:eval evaluate

(vlist 1 2 3 4 5 6)
]

In the above example, the vlist obtained will have 1 as its first element.


@subsection{empty}
An empty vlist

@subsection{empty?}
The function @scheme[empty?] checks if the given vlist is empty or not.

@examples[#:eval evaluate

(empty? (vlist 1 2 3 4 5 6))

(empty? empty)
]

@subsection{vcons}
The function @scheme[vcons] takes an element and a vlist and adds 
the given element to the vlist. 
@examples[#:eval evaluate

(vcons 10 (vlist 1 2 3 4 5 6))
]

In the above example, @scheme[vcons] adds the element 10 to 
@scheme[(vlist 1 2 3 4 5 6)] and returns @scheme[(vlist 10 1 2 3 4 5 6)].

@subsection{first}
The function @scheme[first] takes a vlist and gives the first element 
of the given vlist if vlist is not empty else throws an error. 

@examples[#:eval evaluate

(first (vlist 1 2 3 4 5 6))

(first empty)
]

@subsection{last}
The function @scheme[last] takes a vlist and gives the last element in the
vlist if vlist is not empty else throws an error. 
@examples[#:eval evaluate

(last (vlist 1 2 3 4 5 6))

(last empty)
]

@subsection{rest}
The function @scheme[rest] takes a vlist and returns a vlist without the 
first element if the given vlist is not empty. Else throws an error. 

@examples[#:eval evaluate

(rest (vlist 1 2 3 4 5 6))

(rest empty)
]

In the above example, @scheme[(rest (vlist 1 2 3 4 5 6))], removes the head
and returns @scheme[(vlist 2 3 4 5 6)].


@subsection{get}
The function @scheme[get] takes an integer(say n) and a vlist and gives
the nth element of the given vlist


@examples[#:eval evaluate

(get 0 (vlist 1 2 3 4 5 6))
(get 3 (vlist 1 2 3 4 5 6))
(get 10 (vlist 1 2 3 4 5 6))
]


@subsection{size}
The function @scheme[size] takes a vlist and gives the number of elements in 
the given vlist. 

@examples[#:eval evaluate

(size (vlist 1 2 3 4 5 6))
(size empty)
]


@subsection{vlist->list}
The function @scheme[vlist->list] takes a vlist and returns a normal
scheme list. 
@examples[#:eval evaluate

(vlist->list (vlist 1 2 3 4 5 6))
(vlist->list empty)
]


@subsection{vreverse}
The function @scheme[vreverse] takes a vlist and returns a reverses vlist. 

@examples[#:eval evaluate

(vreverse (vlist 1 2 3 4 5 6))
]

In the above example, @scheme[(vreverse (vlist 1 2 3 4 5 6))], returns the 
reversed vlist @scheme[(vlist 6 5 4 3 2 1)].


@subsection{vmap}
The function @scheme[vmap] is same as @scheme[map] except that 
@scheme[vmap] works on vlists. 
@examples[#:eval evaluate

(vmap add1 (vlist 1 2 3 4 5 6))

(vmap * (vlist 1 2 3 4 5 6) (vlist 1 2 3 4 5 6))
]

In the above example, @scheme[(vmap add1 (vlist 1 2 3 4 5 6))] adds 1 to
each element of the given vlist and returns @scheme[(vlist 2 3 4 5 6 7)].
@scheme[(vmap * (vlist 1 2 3 4 5 6) (vlist 1 2 3 4 5 6))] multiplies 
corresponding elements in the two vlists 
and returns the vlist @scheme[(vlist 1 4 9 16 25 36)].


@subsection{vfoldl}
The function @scheme[vfoldl] is same as @scheme[foldl] except that 
@scheme[vfoldl] works on vlists.
@margin-note{vfoldl currently does not produce correct results when the 
             given function is non-commutative.}

@examples[#:eval evaluate

(vfoldl + 0 (vlist 1 2 3 4 5 6))

(vfoldl * 1 (vlist 1 2 3 4 5 6) (vlist 1 2 3 4 5 6))
]


@subsection{vfoldr}
The function @scheme[vfoldr] is same as @scheme[foldr] except that 
@scheme[vfoldr] works on vlists. 
@margin-note{vfoldr currently does not produce correct results when the 
             given function is non-commutative.}

@examples[#:eval evaluate

(vfoldr + 0 (vlist 1 2 3 4 5 6))

(vfoldr * 1 (vlist 1 2 3 4 5 6) (vlist 1 2 3 4 5 6))
]

@subsection{vfilter}
The function @scheme[vfilter] is same as @scheme[filter] except that 
@scheme[vfilter] works on vlists. 
@examples[#:eval evaluate

(define vlst (vlist 1 2 3 4 5 6))

(vfilter (λ:([x : Integer]) (> x 5)) vlst)

(vfilter (λ:([x : Integer]) (< x 5)) vlst)

(vfilter (λ:([x : Integer]) (<= x 4)) vlst)
]

In the above example, 
@itemlist{@item{@scheme[(vfilter (λ:([x : Integer]) (> x 5)) vlst)]
gives @scheme[(vlist 6)].}}
@itemlist{@item{@scheme[(vfilter (λ:([x : Integer]) (< x 5)) vlst)] gives
@scheme[(vlist 1 2 3 4)].}}
@itemlist{@item{@scheme[(vfilter (λ:([x : Integer]) (<= x 4)) vlst)] gives
@scheme[(vlist 1 2 3 4)].}}