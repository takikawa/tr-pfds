#lang scribble/manual

@title{Red-Black Trees}

Red-Black Tree is a binary search tree in which every node is colored either 
red or black. The red black trees follow two balance invariants
@itemlist{@item{No red node has a red child.}} 
@itemlist{@item{Every path from root to an empty node has the same 
                number of black nodes.}}
The above two invarients help in balancing the tree.
All the operations @italic{member? insert delete} have worst case running 
time of @bold{@italic{O(log(n))}}


@section{Red-Black Trees Construction and Operations}

@subsection{redblacktree}
The function @scheme[redblacktree] creates a Red-Black Tree with the
given inputs. For example,
@schememod[
typed-scheme
(require "redblacktrees.ss")

(redblacktree < 1 2 3 4 5)
]

In the above example, the red black tree obtained will have 2 as its root
and < as the comparison function.

@subsection{empty?}
The function @scheme[empty?] checks if the given red black tree is empty 
or not. For example,
@schememod[
typed-scheme
(require "redblacktrees.ss")

(define rbtree (redblacktree < 1 2 3 4 5 6))

]

In the above example, @scheme[(empty? rbtree)] returns @scheme[#f] and 
@scheme[(empty? (redblacktree <))] returns @scheme[#t].


@subsection{insert}
The function @scheme[insert] takes an element and a red black tree and inserts 
the given element into the red black tree. For example
@schememod[
typed-scheme
(require "redblacktrees.ss")

(define rbtree (redblacktree < 1 2 3 4 5 6))

(define new-rbtree (insert 10 rbtree))
]

In the above example, insert adds the element 10 to the rbtree.


@subsection{root}
The function @scheme[root] takes a red black tree and returns the root of the
given tree. For example
@schememod[
typed-scheme
(require "redblacktrees.ss")

(define rbtree (redblacktree < 1 2 3 4 5))

(root rbtree)
]

In the above example, @scheme[(root rbtree)], returns 2 which is the root
of the given tree.

@subsection{member?}
The function @scheme[member?] takes an element and a red black tree and 
checks if the given element is a member of the tree or not. For example
@schememod[
typed-scheme
(require "redblacktrees.ss")

(define rbtree (redblacktree < 1 2 3 4 5 6))

(member? 5 rbtree)
(member? 10 rbtree)
]

In the above example, @scheme[(member? 5 rbtree)], gives @scheme[#t] and
@scheme[(member? 10 rbtree)] gives @scheme[#f].


@subsection{delete-root}
The function @scheme[delete-root] takes a red black tree and deletes the root
element of the given tree. For example
@schememod[
typed-scheme
(require "redblacktrees.ss")

(define rbtree (redblacktree < 1 2 3 4 5))

(delete-root rbtree)
]

In the above example, @scheme[(delete-root rbtree)], delete the root of 
@scheme[rbtree] which is two in the above example. 

@subsection{delete}
The function @scheme[delete] takes an element and red black tree and deletes 
the given element in the tree if the element is in the tree else throws 
an error. For example
@schememod[
typed-scheme
(require "redblacktrees.ss")

(define rbtree (redblacktree < 1 2 3 4 5 6))

(delete 5 rbtree)
]

In the above example, @scheme[(delete 5 rbtree)], deletes 5 in @scheme[rbtree]. 


@subsection{redblacktree->list}
The function @scheme[redblacktree->list] takes a red black tree and returns a 
list of all the elements in the given red black tree. 
For example
@schememod[
typed-scheme
(require "redblacktrees.ss")

(define rbtree (redblacktree > 1 2 3 4 5))

(redblacktree->list rbtree)
]

In the above example, @scheme[(redblacktree->list rbtree)], returns the list
@scheme[(list 2 4 3 1 5)].