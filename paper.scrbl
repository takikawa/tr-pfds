#lang scribble/sigplan
@(require (except-in scribble/manual cite) scriblib/autobib
          scribble/core
          "bib.rkt")
@title{Functional Data Structures in Typed Scheme}

@(authorinfo "Hari Prashanth K R"
             "Northeastern University"
             "krhari@ccs.neu.edu")

@(authorinfo "Sam Tobin-Hochstadt"
             "Northeastern University"
             "samth@ccs.neu.edu")

@;{@(authorinfo "Matthias Felleisen"
             "Northeastern University"
             "matthias@ccs.neu.edu")}

@(define (lpara . items)
   (make-element (make-style "paragraph" '(exact-chars))
                 items))

@abstract{
Scheme provides excellent base language support for programming in a
functional style, but little in the way of library support.  In this
paper, we present a comprehensive library of functional data
structures, drawing from several sources.  We have implemented the
library in Typed Scheme, a typed variant of PLT Scheme, allowing us to
maintain the type invariants of the original definitions.}

@include-section["intro.scrbl"]

@include-section["ts.scrbl"]

@section{Introduction to Functional Data Structures}

This section introduces the functional data structures that are
implemented in this work. It includes several variants of Queues, 
Deques or Double-Ended Queues, Heaps or Priority Queues, Lists, Tries, 
Hash-Lists, Red-Black Trees etc. All these data structures are polymorphic.

@subsection{Queues}
Queues are simple First In First Out (FIFO) data structures. Several 
variants of queues are implemented. Each variant that is
implemented is discussed below. All the queue variants
implement the the queue interface and have the type @scheme[(Queue A)]. 
Functions of the queue interface are as follows.

@(itemlist 
  @item{@italic{queue} : @scheme[(∀ (A) (A * -> (Queue A)))] 
         @para{The Queue constructor function. Constructs a queue from 
         the given elements. In the @scheme[queue] signature,  
         @scheme[All] is a type constructor used for polymorphic 
                functions. @scheme[->] is the delimiter which separates inputs 
                and the output of a function. The above signature implies that
                the function takes zero or more elements of type @scheme[A]
                and gives a queue of type @scheme[(Queue A)]}}
  @item{@italic{enqueue} : @scheme[(∀ (A) (A (Queue A) -> (Queue A)))]
         @para{Inserts the given element into the queue.}}
  @item{@italic{head} : @scheme[(∀ (A) ((Queue A) -> A))]
         @para{Returns the first element in the queue.}}
  @item{@italic{tail} : @scheme[(∀ (A) ((Queue A) -> (Queue A)))]
         @para{Removes the first element from the given queue.}})

@(require scribble/eval)
@(define evaluate (make-base-eval))
@(evaluate '(require typed/scheme))
@(evaluate '(require "bankers-queue.ss"))
@examples[#:eval evaluate
(define que (queue -1 0 1 2 3 4))

que

(head que)

(head (tail que))

(head (enqueue 10 que))
]

@;(close-eval evaluate)

@lpara{Banker's Queue}
A Banker’s Queue is a amortized queue obtained using a method of amortization 
called the Banker's method. The Banker's Queue combines the techniques of lazy 
evaluation and memoization to obtain good amortized running times. The Banker’s
Queue implementation internally uses the Stream data structure 
(Streams are similar to lazy lists. Stream data  
structure is discussed below.) to achieve lazy evaluation. The Banker's Queue 
provides a 
amortized running time of O(1) for the operations @scheme[head], @scheme[tail]
and @scheme[enqueue].

@lpara{Physicist's Queue}
A Physicist's queue is a amortized queue obtained using a method of amortization 
called the Physicist's method. The Physicist's Queue uses the techniques of lazy 
evaluation and memoization to achieve excellent amortized running times for 
its operations. The only drawback of the Physicist's method is that it is much 
more complicated than the Banker's method. The Physicist's Queues provide 
an amortized running time of O(1) for the operations @scheme[head], 
@scheme[tail] and @scheme[enqueue].


@lpara{Real-Time Queue}
The Real-Time Queue eliminates the amortization in the Banker's Queue to 
produce the 
worst-case queues. The Real-Time Queues employ lazy evaluation and a technique 
called Scheduling. In @italic{scheduling}, the lazy components are forced 
systematically 
such that no suspension takes more than O(1) time to execute. 
This systematic method of
forcing the suspensions ensures good asymptotic worst-case running time for
the operations on the data structure. Real-Time Queues have a 
worst-case running time of O(1) for the operations @scheme[head], 
@scheme[tail] and @scheme[enqueue].


@lpara{Implicit Queue}
Implicit Queue is a queue data structure obtained by applying a technique 
called Implicit Recursive 
Slowdown @cite[oka]. Implicit Recursive Slowdown combines laziness with a 
technique 
called Recursive Slow-down @cite[kaplan-tarjan] developed by Kaplan and Tarjan. 
An advantage of
this technique is that it is simpler than @italic{recursive slow-down}. And 
the disadvantage of this technique is that the data structure gives a amortized
running time. It provides a amortized running time of O(1) for the operations
@scheme[head], @scheme[tail] and @scheme[enqueue].


@lpara{Bootstrapped Queue}
The technique of bootstrapping refers to situations where 
problems whose solutions require solutions to simpler instances of the same
problem. Bootstrapped Queue is a queue data structure which is developed using 
a bootstrapping technique called Structural Decomposition. In Structural 
Decomposition, an implementation that can handle data up to a certain bounded 
size is taken to implement a data structure which can handle data of unbounded
size. The data structure gives a worst-case running time of O(1) for the
operation @scheme[head] and O(log*(n)) for @scheme[tail] and @scheme[enqueue].
Bootstrapped Queue uses Real-Time Queue for bootstrapping.


@lpara{Hood-Melville Queue}
The Hood-Melville Queue is similar to the Real-Time Queues in many ways. But the
implementation of the Hood-Melville Queue is much more complicated than the 
Real-Time Queue implementation. The Hood-Melville Queue uses a technique 
called Global Rebuilding to achieve 
good worst-case running times. @italic{Global Rebuilding} is a technique for
eliminating
the amortization from batched rebuilding. In @italic{batched rebuilding}, 
rebalancing of
a data structure is done in batches (after a set of update operations). In 
@italic{global rebuilding}, rebalancing is done incrementally, a few steps
of rebalancing
per normal operation on the data structure. The data structure gives a 
worst-case running time of O(1) for the operations @scheme[head], 
@scheme[tail] and @scheme[enqueue].


@subsection{Deque}
Double-ended queues are also known as the Deques. The difference between the 
queues and the
deques lies in the fact that the elements of a deque can be inserted and deleted 
from its either end. Several variants of the deque are implemented
in this work and each one is discussed below. All the deque data 
structures implement the deque interface and have the type @scheme[(Deque A)]. 
The deque interface has following functions 

@(itemlist 
  @item{@italic{deque} : @scheme[(∀ (A) (A * -> (Deque A)))] 
         @para{Deque constructor function. Constructs a double ended 
         queue from the given elements.}}
  @item{@italic{enqueue} : @scheme[(∀ (A) (A (Deque A) -> (Deque A)))] 
         @para{Inserts the given element to the rear end of the 
         deque.}}
  @item{@italic{enqueue-front} : @scheme[(∀ (A) (A (Deque A) -> (Deque A)))]
         @para{Inserts the given element to the front-end of 
         the deque.}}
  @item{@italic{head} : @scheme[(∀ (A) ((Deque A) -> A))]
         @para{Returns the first element from the front-end of the 
         deque.}}
  @item{@italic{last} : @scheme[(∀ (A) ((Deque A) -> A))]
         @para{Returns the first element from the rear-end of the deque.}}
  @item{@italic{tail} : @scheme[(∀ (A) ((Deque A) -> (Deque A)))]
         @para{Removes the first element from the front-end of the
         given queue.}}
  @item{@italic{init} : @scheme[(∀ (A) ((Deque A) -> (Deque A)))]
         @para{Removes the first element from the rear-end of the
         given queue.}})


@(evaluate '(require "bankers-deque.ss"))
@examples[#:eval evaluate
(deque -1 1 3 4 5 6)

(define dque (deque -1 0 1 2 3 4))

(head dque)

(last dque)

(head (enqueue-front 10 dque))

(last (enqueue 20 dque))

(head (tail dque))

(last (init dque))
]


@lpara{Banker's Deque}
The Banker's Deques are amortized double ended queues. The Banker's Deque uses 
the Banker's method and employs the techniques used in the Banker's Queues 
to achieve a amortized running time of O(1) for the operations @scheme[head], 
@scheme[tail], @scheme[last],
@scheme[init], @scheme[enqueue-front] and @scheme[enqueue].


@lpara{Implicit Deque}
Technique used by Implicit Deques are same as that used in Implicit Queues i.e.
Implicit Recursive Slowdown. Implicit Deque provides a 
amortized running time of O(1) for the operations @scheme[head], 
@scheme[tail], @scheme[last],
@scheme[init], @scheme[enqueue-front] and @scheme[enqueue].


@lpara{Real-Time Deque}
The Real-Time Deques eliminate the amortization in the Banker's Deque to 
produce worst-case deques. The Real-Time Deques employ the same techniques
employed by the Real-Time Queues to ensure 
good worst-case running time of O(1) for the operations @scheme[head], 
@scheme[tail], @scheme[last],
@scheme[init], @scheme[enqueue-front] and @scheme[enqueue].


@subsection{Heaps}
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
  @item{@italic{heap} : @scheme[(∀ (A) ((A A -> Bool) A * -> (Heap A)))]
         @para{Heap constructor function. Constructs a heap from the 
         given elements and the comparison function.}}
  @item{@italic{find-min/max} : @scheme[(∀ (A) ((Heap A) -> A))]
         @para{Returns the min or max element of the given
         heap.}}
  @item{@italic{delete-min/max} : @scheme[(∀ (A) ((Heap A) -> (Heap A)))]
         @para{Deletes the min or max element of the given 
         heap.}}
  @item{@italic{insert} : @scheme[(∀ (A) (A (Heap A) -> (Heap A)))]
         @para{Inserts an element into the heap.}}
  @item{@italic{merge} : @scheme[(∀ (A) ((Heap A) (Heap A) -> (Heap A)))]
         @para{Merges the two given heaps.}})


@(evaluate '(require "binomialheap.ss"))
@examples[#:eval evaluate
(heap < 1 2 3 4 5 -1)

(define hep (heap < 1 2 3 4 5 -1))

(find-min/max hep)

(find-min/max (delete-min/max hep))

(define new-hep (heap < -2 -3 -4 -5))

(find-min/max (merge hep new-hep))
]


@lpara{Binomial Heap}
A Binomial Heap is a heap-ordered, binomial tree. The Binomial Heaps support 
quick 
and efficient merge operation. This fast merging in the Binomial Heap can be 
achieved because of its special tree structure. The Binomial Heap provides a 
worst-case running time of O(log(n)) for the operations @scheme[insert], 
@scheme[find-min/max], 
@scheme[delete-min/max] and @scheme[merge].


@lpara{Leftist Heap}
The Leftist heaps are heap-ordered binary trees that satisfy the leftist 
property. 
Each node in the tree is assigned a value usually called a rank or a s-value. 
The value represents the length of its rightmost path from the node in question
to the nearest leaf. According to leftist property, right descendant of each 
node has a lower rank or s-value. As a consequence of the leftist property, 
the right spine of any node is always the shortest path to a leaf node. 
The Leftist Heaps provide a worst-case running time of O(log(n)) for the 
operations
@scheme[insert], @scheme[delete-min/max] and @scheme[merge] and a worst-case
running time of O(1) for 
@scheme[find-min/max].

@lpara{Pairing Heap}
A Pairing Heap is a type of heap which has a very simple implementation and has 
extremely good amortized performance in practice. But it has been proved that 
its very difficult to come up with exact asymptotic running time of this data
structure. The Pairing Heaps are represented either as a empty heap or a pair 
of an
element of the heap and a list of pairing heaps. The Pairing Heaps provide a 
worst-case running time of O(1) for the operations @scheme[insert], 
@scheme[find-min/max] and @scheme[merge]. 
And @scheme[delete-min/max] has a amortized running time of O(log(n)).

@lpara{Splay Heap}
The Splay Heaps are very similar to the balanced binary search trees. 
The difference 
between the two data structures lies in the fact that the Splay Heaps do not 
maintain any explicit balance information. Instead every operation on a splay 
heap restructures the tree with some simple transformations that increase the
balance of the tree. Because of the restructuring on every operation, the 
worst-case running time of all the operations is O(n). But it can be easily 
shown that the amortized running time of is O(log(n)) for the 
operations @scheme[insert], @scheme[find-min/max], 
@scheme[delete-min/max] and @scheme[merge].

@lpara{Skew Binomial Heap}
The Skew Binomial Heaps are similar to the Binomial Heaps. The only difference 
between the 
two is that they both have different representations. The Skew Binomial
Heaps have a hybrid numerical representation for heaps which is based on 
the skew binary numbers. The Skew binary number representation is used since 
incrementing a skew binary number is quick and simple. But since the skew binary
numbers have a complicated addition, the merge operation is based on the 
ordinary binary
numbers itself. The Skew Binomial Heaps provide a worst-case running time of 
O(log(n)) for the operations @scheme[find-min/max], @scheme[delete-min/max] 
and @scheme[merge]. And a 
worst-case running time of O(1) for the @scheme[insert] operation.

@lpara{Lazy Pairing Heap}
The Lazy Pairing Heaps are same as normal pairing heaps except for the fact that 
Lazy Pairing Heaps use lazy evaluation and hence are lazy in nature.
The lazy evaluation has been used in this data structure so that the Pairing 
Heap can
adapte to cope with the persistence efficiently. Analysis of the Lazy Pairing
Heap to 
obtain an exact asymptotic running time is as difficult as that for the 
Pairing Heaps. The Lazy 
Pairing Heaps provide a worst-case running time of O(1) for the operations 
@scheme[insert], @scheme[find-min/max], and @scheme[merge]. And 
the @scheme[delete-min/max] operation has a amortized
running time of O(log(n)).

@lpara{Bootstrapped Heap}
The Bootstrapped Heaps use a technique of bootstrapping called the Structural
Abstraction. In @italic{structural abstraction}, the data structure 
abstracts over a less efficient heap implementation to get a better running 
time. This makes the Bootstrapped Heaps to have very efficient merge operation. 
The Bootstrapped Heaps provide a worst-case running time of O(1) for the 
@scheme[insert], 
@scheme[find-min/max] and @scheme[merge] operations and a worst-case running
time of O(log(n)) for 
@scheme[delete-min/max] operation. Our implementation of Bootstrapped Heap 
abstracts 
over the Skew Binomial Heaps.

@subsection{Lists}
Lists are similar to Scheme's list data structure. Catenable List, VList and 
Streams are the variants of list data structure that are implemented in
this work. The variants implemented is explained below. They all 
implement functions to insert elements into the list, delete elements, peek
elements from the list data structure. 

@subsubsection{Random Access List}
The Random Access Lists are list data structure with efficient 
array-like random access operations. The random access operation include lookup
and update operations. All random access list variants have the type 
@scheme[(RAList A)] and implement the Random Access List interface which 
include the following functions.
@(itemlist 
  @item{@italic{list} : @scheme[(∀ (A) (A * -> (RAList A)))]
         @para{Random Access List constructor function. Constructs 
         a random access list from the given elements.}}
  @item{@italic{head} : @scheme[(∀ (A) ((RAList A) -> A))]
         @para{Returns the first element of the given random access
         list.}}
  @item{@italic{tail} : @scheme[(∀ (A) ((RAList A) -> (RAList A)))]
         @para{Deletes the first element of the given random access 
         list and returns the rest of the list.}}
  @item{@italic{lookup} : @scheme[(∀ (A) (Integer (RAList A) -> A))]
         @para{Returns the element at a given location in the 
         random access list.}}
  @item{@italic{update} : 
         @schemeblock[(∀ (A) (Integer (RAList A) A -> 
                                        (RAList A)))]
         @para{Updates the element at a given location in the 
         random access list with a new element.}}
  @item{@italic{cons} : @scheme[(∀ (A) (A (RAList A) -> (RAList A)))]
         @para{Inserts a given element into the random access list.}})


@(evaluate '(require "binaryrandomaccesslist1.ss"))
@examples[#:eval evaluate
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
Random Access List. It has a worst-case running time of O(log(n)) for the 
operations @scheme[cons], 
@scheme[head], @scheme[tail], @scheme[lookup] and @scheme[update]. 

@lpara{Skew Binary Random Access List}
Binary Random Access Lists which are implemented using a numerical 
representation based on skew binary numbers are known as Skew Binary Random
Access Lists. This representation of the data structure helps to improve the
running times of some operations on the data structure. Skew Binary Random 
Access List provides a worst-case running time of O(1) for the operations 
@scheme[cons], @scheme[head] and @scheme[tail] and 
worst-case running time of O(log(n)) for @scheme[lookup] 
and @scheme[update] operations.

@subsubsection{Catenable List}
The Catenable List is a list data structure with efficient append operation. 
They use the bootstrapping technique of @italic{structural abstraction} to 
achieve efficient append operation. The Catenable Lists have the type 
@scheme[(CList A)] and they abstract over the Real-Time Queues
to realize
an amortized running time of O(1) for the following operations
except for @scheme[clist].

@(itemlist 
  @item{@italic{clist} : @scheme[(∀ (A) (A * -> (CList A)))] 
         @para{Catenable List constructor function. Constructs 
               a catenable list from the given elements.}}
  @item{@italic{head} : @scheme[(∀ (A) ((CList A) -> A))]
         @para{Returns the first element of the given catenable list.}}
  @item{@italic{tail} : @scheme[(∀ (A) ((CList A) ->
                                                   (CList A)))]
         @para{Deletes the first element of the given catenable list and 
               returns the rest of the list.}}
  @item{@italic{kons} : @scheme[(∀ (A) (A (CList A) -> 
                                                 (CList A)))]
         @para{Inserts a given element to the front of the catenable 
               list.}}
  @item{@italic{kons-rear} : @scheme[(∀ (A) (A (CList A) -> 
                                                      (CList A)))]
         @para{Inserts a given element to the rear end of the
               catenable list.}}
  @item{@italic{append} : @scheme[(∀ (A) ((CList A) 
                                                 (CList A) -> 
                                                      (CList A)))]
         @para{Appends a catenable list to the end of another 
               catenable list.}})


@(evaluate '(require "catenablelist.ss"))
@examples[#:eval evaluate
(clist -1 0 1 2 3 4)

(define cal (clist -1 0 1 2 3 4))

(head cal)

(head (tail cal))

(head (kons 50 cal))

(kons-rear 50 cal)

(define new-cal (clist 10 20 30))

(head (append new-cal cal))
]


@subsubsection{VList}
A VList is a data structure very similar to normal Scheme list but most of the 
corresponding operations of the VList are significantly faster compared to the
list 
operations. The VList combines the extensibility of the linked list with the 
random 
access of arrays. The indexing and length operations of the VList have a 
worst-case 
running time of O(1) and O(lg N) respectively as against 
O(N) for lists. The paper Fast Functional Lists, Hash-Lists, vlists and Variable
Length Arrays by Phil Bagwell @cite[bagwell-lists] describes the VLists. 
Our VList implementation internally uses Binary Random Access List. 
The VLists have the type 
@scheme[(VList A)] and provides all the functions that list provides. 
Some of them are listed below.

@(itemlist 
  @item{@italic{vlist} : @scheme[(∀ (A) (A * -> (VList A)))] 
         @para{VList constructor function. Constructs 
               a VList from the given elements.}}
  @item{@italic{first} : @scheme[(∀ (A) ((VList A) -> A))]
         @para{Returns the first element of the given vlist.}}
  @item{@italic{last} : @scheme[(∀ (A) ((VList A) -> A))]
         @para{Returns the last element of the given vlist.}}
  @item{@italic{rest} : @scheme[(∀ (A) ((VList A) -> (VList A)))]
         @para{Deletes the first element of the given vlist and 
               returns the rest of the list.}}
  @item{@italic{vcons} : @scheme[(∀ (A) (A (VList A) -> (VList A)))]
         @para{Inserts the given element to the front of the vlist.}}
  @item{@italic{get} : @scheme[(∀ (A) (Integer (VList A) -> A))]
         @para{Gets the element at the given index in the vlist.}})

@(evaluate '(require "vlist.ss"))
@examples[#:eval evaluate
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

@subsubsection{Streams}
The Streams are simply lazy lists. They are similar to the ordinary lists 
and they
provide the same functionality. The Streams being lazy is the only difference. 
Streams are used in many data structures to achieve lazy evaluation. Since
each suspension comes with a little
overhead, Streams are used only when there is a good enough reason to do so. It 
has the type @scheme[(Stream A)].

@subsection{Hash-Lists}
A Hash List is similar to a association list. The Hash-List implemented here is 
simply a modified VList structure. The modified VList structure contains
two portions - the data and the hash table. Both the portions have to grow for
the hash-list to grow. The running time provided by the Hash-Lists for the 
operations insert
and lookup times are very close to the standard chained hash tables. 
Hash-List has been described in @cite[bagwell-lists]. The Hash-Lists provide functions to 
insert, delete, lookup elements of the hash-list.

@subsection{Tries}
A Trie is a data structure which takes advantage of the structure of aggregate 
types to achieve good running times for its operations. The Tries are also
known as the Digital Search Trees. In this implementation, a trie is a multiway
tree
with each node of the multiway tree carrying data of base type of the aggregate
type. The Tries implement functions to lookup and insert
data. The Tries provide faster lookups than hash tables.

@subsection{Red-Black Trees}
A Red-Black Tree is a binary search tree in which every node is colored either 
red or black. The Red-Black Trees follow the following two balance invariants

@(itemlist
@item{No red node has a red child.}
@item{Every path from root to an empty node has the same 
      number of black nodes.})

The above two invariants together guarantee that the longest possible path with
alternating black and red nodes, is no more then twice as long as the shortest 
possible path, the one with black nodes only. This balancing helps in achieving 
good running times for the tree operations. The operations (explained below) 
@scheme[member?], @scheme[insert] 
and @scheme[delete] have worst-case running time of O(log(n)). 
@;{
It has the type 
@scheme[(RedBlackTree A)]. Following are the functions implemented by the 
Red-Black Tree data structure

@(itemlist 
  @item{@italic{redblacktree} : 
         @schemeblock[(∀ (A) ((A A -> Boolean) A * -> 
                                          (RedBlackTree A)))] 
         The Red-Black Tree constructor function. Constructs 
         a red-black tree from the given elements and the
         comparison function.}
  @item{@italic{insert} : @schemeblock[(∀ (A) (A (RedBlackTree A) -> 
                                                   (RedBlackTree A)))] 
         @para{Inserts a given element into the red-black tree.}}
  @item{@italic{root} : @scheme[(∀ (A) ((RedBlackTree A) -> A))] 
         @para{Returns the root element of the given red-black tree.}}
  @item{@italic{member?} : @schemeblock[(∀ (A) (A (RedBlackTree A) -> Boolean))] 
         Checks if the given element is a member of the 
         red-black tree.}
  @item{@italic{delete} : @schemeblock[(∀ (A) (A (RedBlackTree A) -> 
                                                   (RedBlackTree A)))] 
         @para{Deletes the given element from the given red-black 
         tree.}})

@(evaluate '(require "redblacktrees.ss"))
@examples[#:eval evaluate
(define rbt (redblacktree < -1 3 4 5 6))

rbt

(root rbt)

(member? 10 (insert 10 rbt))

(root rbt)

(root (delete (root rbt) rbt))

]
}

@;(require scribble/core)
@section{Benchmarks}
@;{(make-table @(make-style 'centered
                          (list @(make-table-columns (list plain plain))))
             (list (list @(make-paragraph @(make-style 'boxed null) "bench1") 
                         @(make-paragraph @(make-style 'boxed null) "bench2")) 
                   (list @(make-paragraph @(make-style 'boxed null) "bench3") 
                         @(make-paragraph @(make-style 'boxed null) "bench4"))))}
Here is the comparison of the time taken by lists to perform some queue 
operations with the time taken by the Banker's Queue. All the below mentioned 
times are CPU times required to obtain the result. It includes CPU time spent
on garbage collection too. And the time is in milliseconds.
@;para{For the @scheme[head] operation}
@para{For 1000 elements}
@para{@scheme[head] : Lists : 0. Banker's Queue : 0.}
@para{@scheme[tail] : Lists : 0. Banker's Queue : 0.}
@para{For 10000 elements}
@para{@scheme[head] : Lists : 0. Banker's Queue : 0.}
@para{@scheme[tail] : Lists : 0. Banker's Queue : 0.}
@para{For 100000 elements}
@para{@scheme[head] : Lists : 0. Banker's Queue : 0.}
@para{@scheme[tail] : Lists : 3. Banker's Queue : 0.}
@para{For 1000000 elements}
@para{@scheme[head] : Lists : 177. Banker's Queue : 0.}
@para{@scheme[tail] : Lists : 192. Banker's Queue : 0.}
Following is the time taken by the Binomial Heaps to perform some of its 
operations. 
@para{For 1000 elements}
@para{@scheme[find-min/max] : 0.}
@para{@scheme[delete-min/max] : 0.}
@para{@scheme[merge] : 0.}
@para{For 10000 elements}
@para{@scheme[find-min/max] : 0.}
@para{@scheme[delete-min/max] : 0.}
@para{@scheme[merge] : 0.}
@para{For 100000 elements}
@para{@scheme[find-min/max] : 0.}
@para{@scheme[delete-min/max] : 0.}
@para{@scheme[merge] : 0.}
@para{For 1000000 elements}
@para{@scheme[find-min/max] : 0.}
@para{@scheme[delete-min/max] : 2.}
@para{@scheme[merge] : 0.}

@section{Experience with Typed Scheme}
@subsection{Benefits of Typed Scheme}
Several nice features of Typed Scheme together made programming in Typed Scheme 
quiet enjoyable. Firstly, the type error messages in Typed Scheme are very 
clear and easy 
to understand. Exact locations in the code are blamed by the type checker in 
case of type errors. This makes it very easy to debug the type errors. 
@para{Typed Scheme has a very intuitive syntax. 
      For example, the infix operator 
@scheme[->] which is used to write the type of a function. To the left of 
@scheme[->] goes the types of inputs to the function and to its right is the
type of the function's output. Kleene star or Kleene operator, @scheme[*] is 
used to indicate zero or more elements. @scheme[All] or @scheme[∀] is the 
type constructor used by the polymorphic functions etc.} 
@para{Typed Scheme comes with a pretty good test engine which makes it 
      pretty easy to test the code.}

@;(evaluate '(require typed/test-engine/scheme-tests))
@;(evaluate '(require "bankers-queue1.ss"))
@schememod[typed/scheme
           (require typed/test-engine/scheme-tests)
           (require "bankers-queue.ss")
           
           (check-expect (head (queue 4 5 2 3)) 4)
           
           (check-expect (tail (queue 4 5 2 3)) 
                               (queue 5 2 3))]
Above examples illustrate how the tests are written.

@para{Documentation and help manual of PLT Scheme
      in general and Typed Scheme in particular is very well 
      documented and quiet easy to follow and understand.}

@subsection{Disadvantages of Typed Scheme}
Even though overall experience with Typed Scheme was nice, there were
things in Typed Scheme that could bother a programmer.
For instance, it is currently not possible to correctly 
implement Scheme functions such as foldr and foldl because of the 
limitations imposed by Typed Scheme's type system on
variable-arity functions.
@para{The Typed Scheme's type system does not allow polymorphic non-uniform 
      recursive 
      datatype definitions. Because of this limitation, many definitions had
      to be first converted to uniform recursive datatypes before being 
      implemented. For instance, the following definition of Seq 
      structure @cite[oka] is not possible in Typed Scheme.}
      @schemeblock[(define-struct: (A) Seq 
                     ([elem : A] [recur : (Seq (Pair A A))]))
                                                ]
      @para{It has to be converted to not have such a polymorphic recursion 
      before one could continue. Following definition is the converted 
      version of the above definition}
      
      @schemeblock[
                 (define-struct: (A) Elem ([elem : A]))                 
                 (define-struct: (A) Pare 
                   ([pair : (Pair (EP A) (EP A))]))                 
                 (define-type-alias (EP A) 
                   (U (Elem A) (Pare A)))                       
                 (define-struct: (A) Seq
                   ([elem  : (EP A)] [recur : (Seq A)]))]

@para{Typed Scheme treats type @scheme[Integer] and 
@scheme[Exact-Positive-Integer] to be different in some 
cases. For example,}
@schemeblock[(vector-append (vector -1 2) (vector 1 2))]
@para{results in the following error}
@para{@schemeerror{Type Checker: Polymorphic function vector-append 
                   could not be applied to arguments:}}
@para{@schemeerror{Domain: (Vectorof a) *}}
@para{@schemeerror{Arguments: (Vectorof Integer) (Vectorof 
                   Exact-Positive-Integer)}}
@para{This behavior was quiet unexpected.}
@;{item{Even though Typed Scheme test engine is pretty good, there are couple 
        of draw backs in it. For example,
        @schememod[typed/scheme
                   (require "bankers-queue.ss")
                   (require typed/test-engine/scheme-tests)
                   (check-expect (tail (queue 1 2 3)) 
                                 (queue 2 3))]
        @para{The above test fails saying that the two given queues are 
              different even though the contents of the queues are same. In 
              order to get around with this limitation of the test engine and
              test the programs, for each data structure, we had to implement a
              function which converts the data structure into a list. For
              example, all queue data structures have the function 
              @scheme[queue->list].}}}
@para{Whenever a union of polymorphic types is to be given a alias, 
      Typed Scheme 
      allows the programmer to do so by providing the function 
      @italic{define-type-alias}. But when errors are thrown, or the alias is
      to be displayed, Typed Scheme displays the union of original two types
      instead of displaying the alias name. This made the types confusingly 
      long many times. For example,}
@;(evaluate '(require typed/scheme))
@schemeblock[
(define-struct: (A) Type1 ([elem : A]))           
(define-struct: Mt ())  
(define-type-alias (Union A) 
   (U (Type1 A) Mt))
(: id : (∀ (A) (A Integer -> (Union A))))
(define (id elem int)
  (if (> int 5) (make-Type1 elem) (make-Mt)))]

@(evaluate '(require typed/scheme))
@(evaluate '(require "test1.ss"))
@interaction[#:eval evaluate
                 (id 5 1)]

@section{Comparison with Other Implementations}
The implementation of the data structures are very faithful to the original
implementations of Purly Functional Data Structures by @citet[oka]
and VLists and others by  @citet[bagwell-trie bagwell-lists]. 
@para{We added more functions to the data structures to make
them much more useful. For example, to each data structure we added a function
to convert the data structure into a list.}
@(evaluate '(require "bankers-queue.ss"))
@examples[#:eval evaluate
                 (queue->list (queue 1 2 3 4 5 6 -4))]
@para{We added function to delete elements from the 
      @italic{Red-Black Trees}
      which was missing in the original implementation}
@para{All the heap constructor functions take a comparison function of the 
      type @scheme[(A A -> Boolean)] as their first argument followed by the 
      elements for the data structure. This implementation of this feature 
      is slightly different in the original work.}
Except for these changes/additions, the implementation is 
structurally similar the original work.


@section{Conclusion}
                                   
@gen-bib[]