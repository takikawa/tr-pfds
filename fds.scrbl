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
In order to avoid confusion with the FIFO queues, priority queues are also known
as the Heaps. A Heap is similar to a sortable collection. But the difference is
that the comparison function is fixed when a heap is created. There are two
requirements that a tree must meet in order for it to be called a heap.
@(itemlist 
  @item{Shape Requirement - All its levels must be full except possibly
        the last level where only rightmost leaves may be missing.}
  @item{Parental Dominance Requirement - Key at each node is greater than or
        equal (max-heap) OR less than or equal (min-heap) to the keys at its 
        children. A tree satisfying this property is said to be heap-ordered.})
Several variants of the heap have been implemented and each one is 
discussed below.
All the variants have the type @scheme[(Heap A)] and implement the following
functions of the heap interface.

@(itemlist 
  @item{@italic{heap} : @scheme[(∀ (A) ((A A → Bool) A * → (Heap A)))]
         @para{Heap constructor function. Constructs a heap from the 
         given elements and the comparison function.}}
  @item{@italic{find-min/max} : @scheme[(∀ (A) ((Heap A) → A))]
         @para{Returns the min or max element of the given
         heap.}}
  @item{@italic{delete-min/max} : @scheme[(∀ (A) ((Heap A) → (Heap A)))]
         @para{Deletes the min or max element of the given 
         heap.}}
  @item{@italic{insert} : @scheme[(∀ (A) (A (Heap A) → (Heap A)))]
         @para{Inserts an element into the heap.}}
  @item{@italic{merge} : @scheme[(∀ (A) ((Heap A) (Heap A) → (Heap A)))]
         @para{Merges the two given heaps.}})


@(evaluate '(require "binomialheap.ss"))
@interaction[#:eval evaluate
(heap < 1 2 3 4 5 -1)

(define hep (heap < 1 2 3 4 5 -1))

(find-min/max hep)

(find-min/max (delete-min/max hep))

(define new-hep (heap < -2 -3 -4 -5))

(find-min/max (merge hep new-hep))
]


@lpara{Binomial Heap}
A Binomial Heap@cite[vuillemin brown] is a heap-ordered, binomial tree.
The Binomial Heaps support quick 
and efficient merge operation. This fast merging in the Binomial Heap can be 
achieved because of its special tree structure. The Binomial Heap provides a 
worst-case running time of @Ologn for the operations @scheme[insert], 
@scheme[find-min/max], 
@scheme[delete-min/max] and @scheme[merge].


@lpara{Leftist Heap}
The Leftist heaps@cite[crane] are heap-ordered binary trees that satisfy
the leftist property. 
Each node in the tree is assigned a value usually called a rank or a s-value. 
The value represents the length of its rightmost path from the node in question
to the nearest leaf. According to leftist property, right descendant of each 
node has a lower rank or s-value. As a consequence of the leftist property, 
the right spine of any node is always the shortest path to a leaf node. 
The Leftist Heaps provide a worst-case running time of @Ologn for the 
operations
@scheme[insert], @scheme[delete-min/max] and @scheme[merge] and a worst-case
running time of @O1 for 
@scheme[find-min/max].

@lpara{Pairing Heap}
A Pairing Heap@cite[pairing] is a type of heap which has a very simple
implementation and has 
extremely good amortized performance in practice. But it has been proved that 
its very difficult to come up with exact asymptotic running time of this data
structure. The Pairing Heaps are represented either as a empty heap or a pair 
of an
element of the heap and a list of pairing heaps. The Pairing Heaps provide a 
worst-case running time of @O1 for the operations @scheme[insert], 
@scheme[find-min/max] and @scheme[merge]. 
And @scheme[delete-min/max] has a amortized running time of @|Ologn|.

@lpara{Splay Heap}
The Splay Heaps@cite[sla] are very similar to the balanced binary search trees. 
The difference 
between the two data structures lies in the fact that the Splay Heaps do not 
maintain any explicit balance information. Instead every operation on a splay 
heap restructures the tree with some simple transformations that increase the
balance of the tree. Because of the restructuring on every operation, the 
worst-case running time of all the operations is @|On|. But it can be easily 
shown that the amortized running time of is @Ologn for the 
operations @scheme[insert], @scheme[find-min/max], 
@scheme[delete-min/max] and @scheme[merge].

@lpara{Skew Binomial Heap}
The Skew Binomial Heaps are similar to the Binomial Heaps. The only difference 
between the 
two is that they both have different representations. The Skew Binomial
Heaps have a hybrid numerical representation for heaps which is based on 
the skew binary numbers @cite[skew]. The Skew binary number representation is 
used since 
incrementing a skew binary number is quick and simple. But since the skew binary
numbers have a complicated addition, the merge operation is based on the 
ordinary binary
numbers itself. The Skew Binomial Heaps provide a worst-case running time of 
@Ologn for the operations @scheme[find-min/max], @scheme[delete-min/max] 
and @scheme[merge]. And a 
worst-case running time of @O1 for the @scheme[insert] operation.

@lpara{Lazy Pairing Heap}
The Lazy Pairing Heaps@cite[oka] are same as pairing heaps@cite[pairing] except 
that the Lazy Pairing Heaps use lazy evaluation and are lazy in nature.
The lazy evaluation has been used in this data structure so that the Pairing 
Heap can
adapt to cope with the persistence efficiently. Analysis of the Lazy Pairing
Heap to 
obtain an exact asymptotic running time is as difficult as that for the 
Pairing Heaps. The Lazy 
Pairing Heaps provide a worst-case running time of @O1 for the operations 
@scheme[insert], @scheme[find-min/max], and @scheme[merge]. And 
the @scheme[delete-min/max] operation has a amortized
running time of @|Ologn|.

@lpara{Bootstrapped Heap}
The Bootstrapped Heaps@cite[oka] use a technique of bootstrapping called the 
Structural Abstraction@cite[oka]. In @italic{structural abstraction}, the 
data structure 
abstracts over a less efficient heap implementation to get a better running 
time. This makes the Bootstrapped Heaps to have very efficient merge operation. 
The Bootstrapped Heaps provide a worst-case running time of @O1 for the 
@scheme[insert], 
@scheme[find-min/max] and @scheme[merge] operations and a worst-case running
time of @Ologn for 
@scheme[delete-min/max] operation. Our implementation of Bootstrapped Heap 
abstracts 
over the Skew Binomial Heaps.

@section{Lists}
Lists are similar to Scheme's list data structure. Catenable List, VList and 
Streams are the variants of list data structure that are implemented in
this work. The variants implemented is explained below. They all 
implement functions to insert elements into the list, delete elements, peek
elements from the list data structure. 

@subsection{Random Access List}
The Random Access Lists are list data structures with efficient 
array-like random access operations. The random access operation include lookup
and update operations. All random access list variants have the type 
@scheme[(RAList A)] and implement the Random Access List interface which 
include the following functions.
@(itemlist 
  @item{@italic{list} : @scheme[(∀ (A) A * → (RAList A))]
         @para{Random Access List constructor function. Constructs 
         a random access list from the given elements.}}
  @item{@italic{head} : @scheme[(∀ (A) (RAList A) → A)]
         @para{Returns the first element of the given random access
         list.}}
  @item{@italic{tail} : @scheme[(∀ (A) (RAList A) → (RAList A))]
         @para{Deletes the first element of the given random access 
         list and returns the rest of the list.}}
  @item{@italic{lookup} : @scheme[(∀ (A) Int (RAList A) → A)]
         @para{Returns the element at a given location in the 
         random access list.}}
  @item{@italic{update} : @scheme[(∀ (A) Int (RAList A) A → (RAList A))]
         @para{Updates the element at a given location in the 
         random access list with a new element.}}
  @item{@italic{cons} : @scheme[(∀ (A) A (RAList A) → (RAList A))]
         @para{Inserts a given element into the random access list.}})


@(evaluate '(require "binaryrandomaccesslist1.ss"))
@interaction[#:eval evaluate
(define lst (list 1 2 3 4 -5 -6))

lst

(head lst)

(head (tail lst))

(lookup 3 lst)

(lookup 3 (update 3 lst 20))

(head (cons 50 lst))
]

@lpara{Binary Random Access List}
Random Access Lists implemented as a framework of binary numerical 
representation using complete binary leaf trees are known as Binary 
Random Access Lists@cite[oka]. It has a worst-case running time of @Ologn for the 
operations @scheme[cons], 
@scheme[head], @scheme[tail], @scheme[lookup] and @scheme[update]. 

@lpara{Skew Binary Random Access List}
Binary Random Access Lists which are implemented using a numerical 
representation based on skew binary numbers are known as Skew Binary Random
Access Lists@cite[oka]. This representation of the data structure helps to improve the
running times of some operations on the data structure. Skew Binary Random 
Access List provides a worst-case running time of @O1 for the operations 
@scheme[cons], @scheme[head] and @scheme[tail] and 
worst-case running time of @Ologn for @scheme[lookup] 
and @scheme[update] operations.

@subsection{Catenable List}
The Catenable List is a list data structure with efficient append operation. 
They use the bootstrapping technique of 
@italic{structural abstraction}@cite[oka] to 
achieve efficient append operation. The Catenable Lists have the 
type @scheme[(CList A)] and they abstract over the Real-Time Queues
to realize
an amortized running time of @O1 for the following operations
except for @scheme[clist].

@(itemlist 
  @item{@italic{clist} : @scheme[(∀ (A) A * → (CList A))] 
         @para{Catenable List constructor function. Constructs 
               a catenable list from the given elements.}}
  @item{@italic{head} : @scheme[(∀ (A) (CList A) → A)]
         @para{Returns the first element of the given catenable list.}}
  @item{@italic{tail} : @scheme[(∀ (A) (CList A) → (CList A))]
         @para{Deletes the first element of the given catenable list and 
               returns the rest of the list.}}
  @item{@italic{kons} : @scheme[(∀ (A) A (CList A) → (CList A))]
         @para{Inserts a given element to the front of the catenable 
               list.}}
  @item{@italic{kons-rear} : @scheme[(∀ (A) A (CList A) → (CList A))]
         @para{Inserts a given element to the rear end of the
               catenable list.}}
  @item{@italic{append} : @scheme[(∀ (A) (CList A) * → (CList A))]
         @para{Appends several catenable lists together.}})


@(evaluate '(require "catenablelist.ss"))
@interaction[#:eval evaluate
(clist -1 0 1 2 3 4)

(define cal (clist -1 0 1 2 3 4))

(head cal)

(head (tail cal))

(head (kons 50 cal))

(kons-rear 50 cal)

(define new-cal (clist 10 20 30))

(head (append new-cal cal))
]


@subsection{VList}
A VList@cite[bagwell-lists] is a data structure very similar to normal Scheme
list but most of the 
corresponding operations of the VList are significantly faster compared to the
list 
operations. The VList combines the extensibility of the linked list with the 
random 
access of arrays. The indexing and length operations of the VList have a 
worst-case 
running time of @O1 and @Ologn respectively as against 
@On for lists. The paper Fast Functional Lists, Hash-Lists, vlists and Variable
Length Arrays by Phil Bagwell @cite[bagwell-lists] describes the VLists. 
Our VList implementation internally uses Binary Random Access List. 
The VLists have the type 
@scheme[(VList A)] and provides all the functions that list provides. 
Some of them are listed below.

@(itemlist 
  @item{@italic{vlist} : @scheme[(∀ (A) (A * → (VList A)))] 
         @para{VList constructor function. Constructs 
               a VList from the given elements.}}
  @item{@italic{first} : @scheme[(∀ (A) ((VList A) → A))]
         @para{Returns the first element of the given vlist.}}
  @item{@italic{last} : @scheme[(∀ (A) ((VList A) → A))]
         @para{Returns the last element of the given vlist.}}
  @item{@italic{rest} : @scheme[(∀ (A) ((VList A) → (VList A)))]
         @para{Deletes the first element of the given vlist and 
               returns the rest of the list.}}
  @item{@italic{vcons} : @scheme[(∀ (A) (A (VList A) → (VList A)))]
         @para{Inserts the given element to the front of the vlist.}}
  @item{@italic{get} : @scheme[(∀ (A) (Int (VList A) → A))]
         @para{Gets the element at the given index in the vlist.}})

@(evaluate '(require "vlist.ss"))
@interaction[#:eval evaluate
(define vlst (vlist -1 1 3 4 5))

vlst

(first vlst)

(first (rest vlst))

(last vlst)

(size vlst)

(first (vcons 50 vlst))

(get 3 vlst)

(first (vreverse vlst))

(first (vmap add1 vlst))
]

@subsection[#:tag "stream"]{Streams}
The Streams@cite[oka] are simply lazy lists. They are similar to the 
ordinary lists and they
provide the same functionality. The Streams being lazy is the only difference. 
Streams are used in many data structures to achieve lazy evaluation. Since
each suspension comes with a little
overhead, Streams are used only when there is a good enough reason to do so. It 
has the type @scheme[(Stream A)].

@section{Hash-Lists}
A Hash List is similar to a association list. The Hash-List implemented here is 
simply a modified VList structure. The modified VList structure contains
two portions - the data and the hash table. Both the portions have to grow for
the hash-list to grow. The running time provided by the Hash-Lists for the 
operations insert
and lookup times are very close to the standard chained hash tables. 
Hash-List has been described in @cite[bagwell-lists]. The Hash-Lists provide 
functions to insert, delete, lookup elements of the hash-list.

@section{Tries}
A Trie is a data structure which takes advantage of the structure of aggregate 
types to achieve good running times for its operations@cite[oka]. The Tries are also
known as the Digital Search Trees. In this implementation, a trie is a multiway
tree
with each node of the multiway tree carrying data of base type of the aggregate
type. The Tries implement functions to lookup and insert
data. The Tries provide faster lookups than hash tables.

@section{Red-Black Trees}
A Red-Black Tree is a binary search tree in which every node is colored either 
red or black. The Red-Black Trees follow the following two balance invariants

@(itemlist
@item{No red node has a red child.}
@item{Every path from root to an empty node has the same 
      number of black nodes.})

The above two invariants together guarantee that the longest possible path with
alternating black and red nodes, is no more then twice as long as the shortest 
possible path, the one with black nodes only. This balancing helps in achieving 
good running times for the tree operations. Our implementation is based
on@cite[oka-red-black]. The operations 
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

