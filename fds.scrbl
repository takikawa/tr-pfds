#lang scribble/sigplan
@(require (except-in scribble/manual cite) scriblib/autobib
          scribble/core scribble/eval
          scriblib/footnote
          "bib.rkt" "utils.rkt"
          scribble/latex-properties)

@title{An Introduction to Functional Data Structures}

Purely functional data structures, like all data structures, come in
many varieties.  For this work, we have selected a  variety that
provide different APIs and performance characteristics.  They include
several variants of queues, double-ended queues (or deques), priority queues 
(or heaps), lists, hash lists, tries, red-black trees, and
streams. All of the implemented data structures are polymorphic in
their element type.

The following subsections describe each of these data structures, many
with a number of different implementations with distinct performance
characteristics.  Each subsection introduces the data structure,
specifies its API, provides examples, and then discusses each
implementation variant and their performance characteristics.  

@section{Queues} 

@emph{Queues} are simple ``First In First Out'' (FIFO) data
structures. We have implemented a wide variety of queues, each with
the interface given below. Each queue implementation provides a
polymorphic type @racket[(Queue A)], as well as the following
functions:

@(itemlist
  @item{@italic{queue} : @scheme[(∀ (A) A * → (Queue A))]
    @para{Constructs a queue with
      the given elements in order. In the @scheme[queue] type signature,  
      @scheme[∀] is a type constructor used for polymorphic types, binding
      the given type variables, here @racket[A].
      The function type constructor @scheme[→] is written infix between arguments and results.
       The annotation @racket[*] in the
      function type specifies that @racket[queue] accepts arbitrarily
      many elements of type @racket[A], producing a queue of type
      @scheme[(Queue A)].}}
  @item{@italic{enqueue} : @scheme[(∀ (A) A (Queue A) → (Queue A))]
    @para{Inserts the given element (the first argument) into the
      given queue (the second argument), producing a new queue.}}
  @item{@italic{head} : @scheme[(∀ (A) (Queue A) → A)]
    @para{Returns the first element in the queue.  The queue is unchanged.}}
  @item{@italic{tail} : @scheme[(∀ (A) (Queue A) → (Queue A))]
    @para{Removes the first element from the given queue, producing a
      new queue.}})

@(evaluate '(require typed/scheme))
@(evaluate '(require "bankers-queue.ss"))
@interaction[#:eval evaluate
(define que (queue -1 0 1 2 3 4))

que

(head que)

(head (tail que))

(head (enqueue 10 que))
]

@;(close-eval evaluate)

@lpara{Banker's Queues} 
The Banker’s Queues@cite[oka] are amortized queues obtained using a method
of amortization called the Banker's method. The Banker's Queue
combines the techniques of lazy evaluation and memoization to obtain
good amortized running times. The Banker’s Queue implementation
internally uses streams (see @secref["stream"]) to achieve lazy
evaluation. The Banker's Queue provides a amortized running time of
@O1 for the operations @scheme[head], @scheme[tail] and
@scheme[enqueue].

@lpara{Physicist's Queue}
The Physicist's Queue@cite[oka] is a amortized queue obtained using a
method of amortization called the Physicist's method. The Physicist's
Queue also uses the techniques of lazy evaluation and memoization to
achieve excellent amortized running times for its operations. The only
drawback of the Physicist's method is that it is much more complicated
than the Banker's method. The Physicist's Queue provides an amortized
running time of @O1 for the operations @scheme[head], @scheme[tail]
and @scheme[enqueue].


@lpara{Real-Time Queue} Real-Time Queues eliminate the amortization of
the Banker's and Physicist's Queues to produce a queue with excellent
worst-case as well as amortized running times.  Real-Time Queues
employ lazy evaluation and a technique called
@italic{scheduling}@cite[oka] where lazy components are forced
systematically so that no suspension takes more than constant time to
execute, assuring ensures good asymptotic worst-case running time for
the operations on the data structure. Real-Time Queues have an @O1
worst-case running time for the operations @scheme[head],
@scheme[tail] and @scheme[enqueue].


@lpara{Implicit Queue} Implicit Queues are a queue data structure
implemented by applying a technique called @italic{implicit recursive
slowdown}@cite[oka]. Implicit recursive slowdown combines laziness
with a technique called @italic{recursive slowdown} developed by
@citet[kaplan-tarjan].  This technique is
simpler than pure recursive slow-down, but with the disadvantage of
amortized bounds on the running
time. Implicit Queues provide an amortized running time of @O1 for the operations
@scheme[head], @scheme[tail] and @scheme[enqueue].


@lpara{Bootstrapped Queue}
The technique of @italic{bootstrapping} is applicable to 
problems whose solutions require solutions to simpler instances of the same
problem. Bootstrapped Queues are a queue data structure developed using 
a bootstrapping technique called \italic{structural decomposition}@cite[oka]. 
In structural decomposition, an implementation that can handle data up to a certain bounded 
size is used to implement a data structure which can handle data of unbounded
size. Bootstrapped Queues give a worst-case running time of @O1 for the
operation @scheme[head] and @|Olog*n|@note{@log*n is at
most 5 for all feasible queue lengths.} for @scheme[tail] and @scheme[enqueue].
Our implementation of Bootstrapped Queues uses Real-Time Queues for bootstrapping.


@lpara{Hood-Melville Queue} Hood-Melville Queues are similar to the
Real-Time Queues in many ways, but use a different and more complex
technique, called @italic{global rebuilding}, to eliminate
amortization from the complexity analysis.  In global rebuilding,
rebalancing is done incrementally, a few steps of rebalancing per
normal operation on the data structure. Hood-Melville Queues have 
worst-case running times of @O1 for the operations @scheme[head],
@scheme[tail] and @scheme[enqueue].


@section{Deque} Double-ended queues are also known as
@italic{deques}. The difference between the queues and the deques lies
is that new elements of a deque can be inserted and deleted from
either end. We have implemented several deque variants, each discussed
below. All the deque data structures implement following interface and
have the type @scheme[(Deque A)].

@(itemlist 
  @item{@italic{deque} : @scheme[(∀ (A) A * → (Deque A))] 
         @para{Constructs a double ended queue from the given elements
  in order.}}
  @item{@italic{enqueue} : @scheme[(∀ (A) A (Deque A) → (Deque A))] 
         @para{Inserts the given element to the rear of the 
         deque.}}
  @item{@italic{enqueue-front} : @scheme[(∀ (A) A (Deque A) → (Deque A))]
         @para{Inserts the given element to the front of 
         the deque.}}
  @item{@italic{head} : @scheme[(∀ (A) (Deque A) → A)]
         @para{Returns the first element from the front of the 
         deque.}}
  @item{@italic{last} : @scheme[(∀ (A) (Deque A) → A)]
         @para{Returns the first element from the rear of the deque.}}
  @item{@italic{tail} : @scheme[(∀ (A) (Deque A) → (Deque A))]
         @para{Removes the first element from the front of the
         given deque, producing a new deque.}}
  @item{@italic{init} : @scheme[(∀ (A) (Deque A) → (Deque A))]
         @para{Removes the first element from the rear of the
         given deque, producing a new deque.}})


@(evaluate '(require "bankers-deque.ss"))
@interaction[#:eval evaluate
(define dque (deque -1 0 1 2 3 4))

dque
(head dque)

(last dque)

(head (enqueue-front 10 dque))

(last (enqueue 20 dque))

(head (tail dque))

(last (init dque))
]


@lpara{Banker's Deque}
The Banker's Deque is an amortized deque. The Banker's Deque uses 
the Banker's method and employs the same techniques used in the Banker's Queues 
to achieve amortized running times of @O1 for the operations @scheme[head], 
@scheme[tail], @scheme[last],
@scheme[init], @scheme[enqueue-front] and @scheme[enqueue].


@lpara{Implicit Deque}
The techniques used by Implicit Deques are same as that used in Implicit Queues i.e.
Implicit Recursive Slowdown. Implicit Deque provides @O1
amortized running times for the operations @scheme[head], 
@scheme[tail], @scheme[last],
@scheme[init], @scheme[enqueue-front] and @scheme[enqueue].


@lpara{Real-Time Deque}
The Real-Time Deques eliminate the amortization in the Banker's Deque to 
produce deques with good worst-case behavior. The Real-Time Deques employ the same techniques
employed by the Real-Time Queues to provide
worst-case running time of @O1 for the operations @scheme[head], 
@scheme[tail], @scheme[last],
@scheme[init], @scheme[enqueue-front] and @scheme[enqueue].


@section{Heaps}
In order to avoid confusion with FIFO queues, priority queues are also known
as @italic{heaps}. A heap is similar to a sortable collection,
implemented as a tree, with a
comparison function fixed at creation time. There are two
requirements that a tree must meet in order for it to be a heap:
@(itemlist 
  @item{Shape Requirement - All its levels must be full except (possibly)
        the last level where only rightmost leaves may be missing.}
  @item{Parental Dominance Requirement - The key at each node must greater than or
        equal (max-heap) OR less than or equal (min-heap) to the keys at its 
        children. A tree satisfying this property is said to be
	@italic{heap-ordered}.})
Below, we present several heap variants.
Each variant has the type @scheme[(Heap A)] and implements the following
interface:

@(itemlist 
  @item{@italic{heap} : @scheme[(∀ (A) (A A → Bool) A * → (Heap A))]
         @para{Constructs a heap from the 
         given elements and comparison function.}}
  @item{@italic{find-min/max} : @scheme[(∀ (A) (Heap A) → A)]
         @para{Returns the min or max element of the given
         heap.}}
  @item{@italic{delete-min/max} : @scheme[(∀ (A) (Heap A) → (Heap A))]
         @para{Deletes the min or max element of the given 
         heap.}}
  @item{@italic{insert} : @scheme[(∀ (A) A (Heap A) → (Heap A))]
         @para{Inserts an element into the heap.}}
  @item{@italic{merge} : @scheme[(∀ (A) (Heap A) (Heap A) → (Heap A))]
         @para{Merges the two given heaps.}})


@(evaluate '(require "binomialheap.ss"))
@interaction[#:eval evaluate
(define hep (heap < 1 2 3 4 5 -1))
hep
(find-min/max hep)

(find-min/max (delete-min/max hep))

(define new-hep (heap < -2 -3 -4 -5))

(find-min/max (merge hep new-hep))
]


@lpara{Binomial Heap} A Binomial Heap@cite[vuillemin brown] is a
heap-ordered binomial tree.  Binomial Heaps support a fast
@racket[merge] operation using a special tree structure. Binomial
Heaps provide a worst-case running time of @Ologn for the operations
@scheme[insert], @scheme[find-min/max], @scheme[delete-min/max] and
@scheme[merge].


@lpara{Leftist Heap}
Leftist Heaps@cite[crane] are heap-ordered binary trees that satisfy
the @italic{leftist property}. 
Each node in the tree is assigned a value called a @italic{rank}. 
The rank represents the length of its rightmost path from the node in question
to the nearest leaf. The leftist property requires that right descendant of each 
node has a lower rank than the node itself. As a consequence of the leftist property, 
the right spine of any node is always the shortest path to a leaf node. 
The Leftist Heaps provide a worst-case running time of @Ologn for the 
operations
@scheme[insert], @scheme[delete-min/max] and @scheme[merge] and a worst-case
running time of @O1 for 
@scheme[find-min/max].

@lpara{Pairing Heap}
Pairing Heaps@cite[pairing] are a type of heap which have a very simple
implementation and  
extremely good amortized performance in practice. However, it has proved 
 very difficult to come up with exact asymptotic running time for
 operations on Pairing Heaps. Pairing Heaps are represented either as a empty heap or a pair 
of an
element and a list of pairing heaps. Pairing Heaps provide a 
worst-case running time of @O1 for the operations @scheme[insert], 
@scheme[find-min/max] and @scheme[merge], and an amortized running time of @|Ologn|
for @scheme[delete-min/max].

@lpara{Splay Heap}
Splay Heaps@cite[sla] are very similar to balanced binary search trees. 
The difference 
between the two is that  Splay Heaps do not 
maintain explicit balance information. Instead, every operation on a splay 
heap restructures the tree with simple transformations that increase the
balance. Because of the restructuring on every operation, the 
worst-case running time of all operations is @|On|. However,
 the amortized running time of the operations @scheme[insert], @scheme[find-min/max], 
@scheme[delete-min/max] and @scheme[merge]
 is @|Ologn|.

@lpara{Skew Binomial Heap} Skew Binomial Heaps are similar to Binomial
Heaps, but with a hybrid numerical representation for heaps which is
based on the @italic{skew binary numbers}@cite[skew]. The kkew binary number
representation is used since incrementing skew binary numbers is
quick and simple. Since the skew binary numbers have a complicated
addition, the @racket[merge] operation is based on the ordinary binary numbers
itself. Skew Binomial Heaps provide a worst-case running time of
@Ologn for the operations @scheme[find-min/max],
@scheme[delete-min/max] and @scheme[merge], and a worst-case running
time of @O1 for the @scheme[insert] operation.

@lpara{Lazy Pairing Heap}
Lazy Pairing Heaps@cite[oka] are similar to pairing heaps as described
above, except 
that Lazy Pairing Heaps use lazy evaluation.
Lazy evaluation is used in this data structure so that the Pairing 
Heap can
cope with persistence efficiently. Analysis of Lazy Pairing
Heaps to 
obtain exact asymptotic running times is difficult, as it is for
Pairing Heaps. Lazy 
Pairing Heaps provide a worst-case running time of @O1 for the operations 
@scheme[insert], @scheme[find-min/max], and @scheme[merge], and an amortized
running time of @|Ologn|
for the @scheme[delete-min/max] operation.

@lpara{Bootstrapped Heap} Bootstrapped Heaps@cite[oka] use a technique
of bootstrapping called @italic{structural abstraction}@cite[oka],
where one data structure abstracts over a less efficient data
structure to get better running times.  Bootstrapped Heaps provide a
worst-case running time of @O1 for the @scheme[insert],
@scheme[find-min/max] and @scheme[merge] operations and a worst-case
running time of @Ologn for @scheme[delete-min/max] operation. Our
implementation of Bootstrapped Heap abstracts over Skew Binomial
Heaps.

@section{Lists}
Lists are a fundamental data structure in Scheme.  However, while
singly-linked lists have the advantages of simplicity and efficency
for some operations, many others are quite expensive.  Other data
structures can efficently implement the operations of Scheme's lists,
while providing other efficent operations as well.
We implement Random Access Lists, Catenable Lists, VLists and Streams.
Each implemented variant is explained below.  All variants provide the
type @racket[(List A)], and the following interface, which is extended
for each implementation:
@(itemlist 
  @item{@italic{list} : @scheme[(∀ (A) A * → (List A))]
         @para{Constructs a list from the given elements,
	 in order.}}
  @item{@italic{cons} : @scheme[(∀ (A) A (List A) → (List A))]
         @para{Adds a given element into the front of a list.}}
  @item{@italic{first} : @scheme[(∀ (A) (List A) → A)]
         @para{Returns the first element of the given 
         list.}}
  @item{@italic{rest} : @scheme[(∀ (A) (List A) → (List A))]
         @para{Produces a new list without the first element.}}
)

@subsection{Random Access List}
Random Access Lists are lists with efficient 
array-like random access operations. These include @racket[list-ref]
and @racket[list-set] (a functional analogue of @racket[vector-set!]).
Random Access Lists extend the basic list interface with the following operations:
@(itemlist 
  @item{@italic{list-ref} : @scheme[(∀ (A) (List A) Integer → A)]
         @para{Returns the element at a given location in the 
          list.}}
  @item{@italic{list-set} : @scheme[(∀ (A) (List A) Integer A → (List A))]
         @para{Updates the element at a given location in the 
         list with a new element.}}
)

@(evaluate '(require "binaryrandomaccesslist1.ss"))
@interaction[#:eval evaluate
(define lst (list 1 2 3 4 -5 -6))

lst

(first lst)

(first (rest lst))

(list-ref lst 3)

(list-ref (list-set lst 3 20) 3)

(first (cons 50 lst))
]

@lpara{Binary Random Access List} Binary Random Access Lists are
implemented as using the framework of binary numerical representation
using complete binary leaf trees@cite[oka]. They have worst-case
running times of @Ologn for the operations @scheme[cons],
@scheme[first], @scheme[rest], @scheme[list-ref] and @scheme[list-set].

@lpara{Skew Binary Random Access List}
Skew Binary Random Access Lists are similar to Binary Random Access
Lists, but use the skew binary number representation, improving the
running times of some operations. Skew Binary Random 
Access Lists provide worst-case running times of @O1 for the operations 
@scheme[cons], @scheme[head] and @scheme[tail] and 
worst-case running times of @Ologn for @scheme[list-ref] 
and @scheme[list-set] operations.

@subsection{Catenable List}
Catenable Lists are a list data structure with an efficient append
operation, achived using the bootstrapping technique of 
@italic{structural abstraction}@cite[oka]. Catenable Lists are
abstracted over Real-Time Queues, and have an amortized running time
of @O1 for the basic list operations as well as the following:

@(itemlist 
  @item{@italic{cons-to-end} : @scheme[(∀ (A) A (List A) → (List A))]
         @para{Inserts a given element to the rear end of the
               list.}}
  @item{@italic{append} : @scheme[(∀ (A) (List A) * → (List A))]
         @para{Appends several lists together.}})


@(evaluate '(require "catenablelist.ss"))
@interaction[#:eval evaluate
(define cal (list -1 0 1 2 3 4))
cal
(first cal)

(first (rest cal))

(first (cons 50 cal))

(cons-to-end 50 cal)

(define new-cal (list 10 20 30))

(head (append new-cal cal))
]


@subsection{VList}
VLists@cite[bagwell-lists] are a data structure very similar to normal Scheme
lists, but with efficent versions of many operations that are much
slower on standard lists. VLists combine the extensibility of  linked lists with the 
fast random 
access capability of arrays. The indexing and length operations of  VLists have a 
worst-case 
running time of @O1 and @Ologn respectively, compared to 
@On for lists. 
Our VList implementation is built internally on Binary Random Access Lists. 
VLists provide the standard list API given above, along with many
other operations, some of which are given here.

@(itemlist 
  @item{@italic{last} : @scheme[(∀ (A) (List A) → A)]
         @para{Returns the last element of the given list.}}
  @item{@italic{list-ref} : @scheme[(∀ (A) (List A) Integer → A)]
         @para{Gets the element at the given index in the list.}})

@(evaluate '(require "vlist.ss"))
@interaction[#:eval evaluate
(define vlst (list -1 1 3 4 5))

vlst

(first vlst)

(first (rest vlst))

(last vlst)

(length vlst)

(first (cons 50 vlst))

(list-ref vlst 3)

(first (reverse vlst))

(first (map add1 vlst))
]

@subsection[#:tag "stream"]{Streams}
Streams@cite[oka] are simply lazy lists. They are similar to the 
ordinary lists and they
provide the same functionality and API.
Streams are used in many of the foregoing data structures to achieve lazy evaluation. 
Streams do not change the asymptotic performance of any list operations, but introduce overhead at each suspension. Since streams have distinct evaluation behavior, they are given a distinct type, @scheme[(Stream A)].

@section{Hash Lists} Hash Lists@cite[bagwell-lists] are similar to
association lists, here implemented using a modified VList structure. The
modified VList contains two portions---the data and the hash
table. Both the portions grow as the hash-list grows. The running time
for Hash Lists operations such as @racket[insert], @racket[delete],
and @racket[lookup] are very close to those for standard chained hash
tables.

@section{Tries} A Trie (also known as a Digital Search Tree) is a data
structure which takes advantage of the structure of aggregate types to
achieve good running times for its operations@cite[oka]. Our
implementation provides Tries in which the keys are lists of the
element type; this is sufficient for representing many aggregate data
structures.  In our implementation, each trie is a multiway tree with
each node of the multiway tree carrying data of base element type.
Tries provide @racket[lookup] and @racket[insert] operations with
better asymptotic running times than hash tables.

@section{Red-Black Trees} Red-Black Trees are a classic data
 structure, consisting of a binary search tree in which every node is
 colored either red or black, according to the following
 two balance invariants:

@(itemlist
@item{no red node has a red child, and}
@item{every path from root to an empty node has the same 
      number of black nodes.})

The above two invariants together guarantee that the longest possible path with
alternating black and red nodes, is no more then twice as long as the shortest 
possible path, the one with black nodes only. This balancing helps in achieving 
good running times for the tree operations. Our implementation is based
on one by @citet[oka-red-black]. The operations 
@scheme[member?], @scheme[insert] and @scheme[delete], which respectively 
checks membership, inserts and deletes elements from the tree, have worst-case
running time of @|Ologn|. 
@;{
It has the type 
@scheme[(RedBlackTree A)]. 
Following are the functions implemented by the Red-Black Tree data structure

@(itemlist 
  @item{@italic{redblacktree} : 
         @schemeblock[(∀ (A) ((A A → Boolean) A * → 
                                          (RedBlackTree A)))] 
         The Red-Black Tree constructor function. Constructs 
         a red-black tree from the given elements and the
         comparison function.}
  @item{@italic{insert} : @schemeblock[(∀ (A) (A (RedBlackTree A) → 
                                                   (RedBlackTree A)))] 
         @para{Inserts a given element into the red-black tree.}}
  @item{@italic{root} : @scheme[(∀ (A) ((RedBlackTree A) → A))] 
         @para{Returns the root element of the given red-black tree.}}
  @item{@italic{member?} : @schemeblock[(∀ (A) (A (RedBlackTree A) → Boolean))] 
         Checks if the given element is a member of the 
         red-black tree.}
  @item{@italic{delete} : @schemeblock[(∀ (A) (A (RedBlackTree A) → 
                                                   (RedBlackTree A)))] 
         @para{Deletes the given element from the given red-black 
         tree.}})

@(evaluate '(require "redblacktrees.ss"))
@interaction[#:eval evaluate
(define rbt (redblacktree < -1 3 4 5 6))

rbt

(root rbt)

(member? 10 (insert 10 rbt))

(root rbt)

(root (delete (root rbt) rbt))

]
}


