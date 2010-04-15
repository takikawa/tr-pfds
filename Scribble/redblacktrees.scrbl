#lang scribble/manual

@(require scribble/eval)

@(define evaluate (make-base-eval))
@(evaluate '(require typed/scheme))
@(evaluate '(require "../redblacktrees.ss"))

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
given inputs. 
@examples[#:eval evaluate

(redblacktree < 1 2 3 4 5)
]

In the above example, the red black tree obtained will have 2 as its root
and < as the comparison function.

@subsection{empty?}
The function @scheme[empty?] checks if the given red black tree is empty 
or not. 
@examples[#:eval evaluate

(empty? (redblacktree < 1 2 3 4 5 6))
(empty? (redblacktree <))
]


@subsection{insert}
The function @scheme[insert] takes an element and a red black tree and inserts 
the given element into the red black tree. 
@examples[#:eval evaluate

(insert 10 (redblacktree < 1 2 3 4 5 6))
]

In the above example, insert adds the 10 to
@scheme[(redblacktree < 1 2 3 4 5 6)].


@subsection{root}
The function @scheme[root] takes a red black tree and returns the root of the
given tree. 
@examples[#:eval evaluate

(root (redblacktree < 1 2 3 4 5 6))
(root (redblacktree <))
]

In the above example, @scheme[(root (redblacktree < 1 2 3 4 5 6))], returns 2 
which is the root of @scheme[(redblacktree < 1 2 3 4 5 6)].

@subsection{member?}
The function @scheme[member?] takes an element and a red black tree and 
checks if the given element is a member of the tree or not. 
@examples[#:eval evaluate

(member? 5 (redblacktree < 1 2 3 4 5 6))
(member? 10 (redblacktree < 1 2 3 4 5 6))
]

@subsection{delete-root}
The function @scheme[delete-root] takes a red black tree and deletes the root
element of the given tree. 
@examples[#:eval evaluate

(delete-root (redblacktree < 1 2 3 4 5 6))
(delete-root (redblacktree <))
]

In the above example, @scheme[(delete-root rbtree)], delete the root of 
@scheme[(redblacktree < 1 2 3 4 5 6)] which happens to be 2 in this tree. 

@subsection{delete}
The function @scheme[delete] takes an element and red black tree and deletes 
the given element in the tree if the element is in the tree else throws 
an error. 
@examples[#:eval evaluate

(delete 5 (redblacktree < 1 2 3 4 5 6))

(delete 10 (redblacktree < 1 2 3 4 5 6))
]

In the above example, @scheme[(delete 5 (redblacktree < 1 2 3 4 5 6))], 
deletes 5 in @scheme[(redblacktree < 1 2 3 4 5 6)]. 


@subsection{redblacktree->list}
The function @scheme[redblacktree->list] takes a red black tree and returns a 
list of all the elements in the given red black tree. 

@examples[#:eval evaluate

(define rbtree (redblacktree > 1 2 3 4 5))

(redblacktree->list rbtree)
]