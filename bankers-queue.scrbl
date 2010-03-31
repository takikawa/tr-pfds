#lang scribble/manual

@begin[(require (for-label typed-scheme))]

@title[#:tag "top"]{@bold{Functional Data Structures} in Typed Scheme}
All the data structures below, are influenced by the works of 
@italic{Chris Okasaki, Phil Bagwell} and those that are discussed
in the book @italic{Purely Functional Data Structures} by Chris Okasaki.
And the data structures have been entirely implemented in Typed Scheme.
@author[@link["http://www.ccs.neu.edu/home/krhari"]{Hari Prashanth K R}]

@section[#:tag "Functional Data Structures"]{Functional Data Structures}

@subsection[#:tag "Streams"]{Streams}
Streams are nothing but lazy lists. They are similar to ordinary
lists and they provide the same functions that lists provide. The 
difference between Streams and lists is that they are in nature and 
each cell of a Stream is suspended is forced only when required. Streams 
have been used in some of the below mentioned data structures. Since
each suspention comes with a little overhead, Streams should be used
only when there is a good enough reason to do so.

@subsection[#:tag "Bankers Queue"]{Bankers Queue}
Amortized queues obtained by Bankers method. Provides a amortized
running time of @bold{@italic{O(1)}} for @italic{head, tail and enqueue}
operations. Uses lazy evaluation and memoization for getting this 
amortized running time.

@subsection[#:tag "Bankers Deque"]{Bankers Deque}
Amortized double ended queues also known as deque is obtained by Bankers 
method. Provides amortized running time of @bold{@italic{O(1)}} for the 
operations @italic{head, tail, last, init, enqueue-rear and enqueue}.
Uses lazy evaluation and memoization for getting the amortized running time.

@subsection[#:tag "Physists Queue"]{Physists Queue}
Amortized queues obtained by Physicist's method. Provides a amortized
running time of @bold{@italic{O(1)}} for @italic{head, tail and enqueue}
operations. Uses lazy evaluation and memoization for getting this 
amortized running time.

@subsection[#:tag "Implicit Queue"]{Implicit Queue}
Queues obtained by applying the technique called 
@italic{Implicit Recursive Slowdown}. Provides a amortized
running time of @bold{@italic{O(1)}} for the operations
@italic{head, tail and enqueue}. Implicit Recursive Slowdown combines 
laziness and technique of called Recursive Slow-Down developed by 
@italic{Kaplan and Tarjan} in their paper 
@italic{Persistant Lists with Catenation via Recursive Slow-Down}.

@subsection[#:tag "Implicit Deque"]{Implicit Deque}
Deques obtained by applying @italic{Implicit Recursive Slowdown}. 
Provides amortized running time of @bold{@italic{O(1)}} for the 
operations @italic{head, tail, last, init, enqueue-rear and enqueue}.
Implicit Recursive Slowdown combines 
laziness and technique called Recursive Slow-Down developed by 
@italic{Kaplan and Tarjan} in their paper 
@italic{Persistant Lists with Catenation via Recursive Slow-Down}.

@subsection[#:tag "Real-Time Queue"]{Real-Time Queue}
Real-Time Queues eliminate the amortization by employing a technique 
called @italic{Scheduling}. The data structure gives a worst case 
running time of @bold{@italic{O(1)}} for the operations 
@italic{head, tail and enqueue}.

@subsection[#:tag "Hood Melville Queue"]{Hood Melville Queue}
Similar to Real-Time Queues in many ways. But the implementation is
much more complicated than Real-Time Queue. Uses a technique called 
@italic{Global Rebuilding}. The data structure gives a worst case 
running time of @bold{@italic{O(1)}} for the operations 
@italic{head, tail and enqueue}.

@subsection[#:tag "Real-Time Deque"]{Real-Time Deque}
Real-Time Deques eliminate the amortization by using two 
techniques @italic{Scheduling} and a variant of Global Rebuilding 
called @italic{Lazy Rebuilding}. The data structure gives a worst 
case running time of @bold{@italic{O(1)}} for the operations 
@italic{head, tail, last, init, enqueue-rear and enqueue}.

@subsection[#:tag "Bootstrapped Queue"]{Bootstrapped Queue}
Bootstrapped Queue use a structural bootstrapping technique called 
@italic{Structural Decomposition}. The data structure gives a worst 
case running time of @bold{@italic{O(1)}} for the operation 
@italic{head} and @bold{@italic{O(log*(n))}} for 
@italic{tail and enqueue}.

@subsection[#:tag "Binary Random Access List"]{Binary Random Access List}
Random Access Lists are list data structures that provide array-like lookup and
update operations. They have been implemented as a framework of binary 
numerical representation using complete binary leaf trees. It has a worst 
case running time of @bold{@italic{O(log(n))}} for all the operations
@italic{cons, head, tail, lookup and update}

@subsection[#:tag "Skew Binary Random Access List"]{Skew Binary 
                                                    Random Access List}
Random Access Lists implemented using skew binary numbers. It provides a 
worst case running time of @bold{@italic{O(1)}} for the operations
@italic{cons, head and tail} and @bold{@italic{O(log(n))}} for 
the operations @italic{lookup and update}

@subsection[#:tag "Catenable List"]{Catenable List}
These are nothing but lists with efficient catenation. They use 
a data-structural bootstrapping technique called 
@italic{Structural Abstraction}. The data structure internally use 
Real Time Queues to realize an amortized running time of @bold{@italic{O(1)}}
for the operations @italic{head, tail, kons, kons-rear}

@subsection[#:tag "VList"]{VList}
A VList is a data structure very similar to noraml Scheme List but the 
corresponding operations are significantly faster than most of the List
operations. Indexing and length operations have a running time of 
@bold{@italic{O(1)}} and @bold{@italic{O(lg N)}} respectively compared to 
@bold{@italic{O(N)}} in lists. The data structure has been described in the 
paper @italic{Fast Functional Lists, Hash-Lists, Deques and 
              Variable Length Arrays} by  Phil Bagwell.
                                                       
@subsection[#:tag "Hash List"]{VHash List}
A Hash List is a modified VList. Along with data it maintains a hash table.
Hence each time the hash-list grows, both the data area and the hash table
grow by the same factor. The data structure has been described in the 
paper @italic{Fast Functional Lists, Hash-Lists, Deques and 
              Variable Length Arrays} by  Phil Bagwell.

@subsection[#:tag "Binomial Heap"]{Binomial Heap}
Binomial Heaps are nothing but mergeable priority queues. To avoid the
confusion with FIFO queues, they are referred as heaps. Heaps are similar
to the sortable collections but the difference is that comparison function
is fixed when the heap is created. Binomial heaps are heap-ordered, binomial
trees. A tree is heap-ordered if it maintains min-heap or max-heap property.

@subsection[#:tag "Skew Binomial Heap"]{Skew Binomial Heap}
@subsection[#:tag "Leftist Heap"]{Leftist Heap}
@subsection[#:tag "Splay Heap"]{Splay Heap}
@subsection[#:tag "Pairing Heap"]{Pairing Heap}
@subsection[#:tag "Lazy Pairing Heap"]{Lazy Pairing Heap}
@subsection[#:tag "Bootstrapped Heap"]{Bootstrapped Heap}
@subsection[#:tag "Unbalanced Set"]{Unbalanced Set}
@subsection[#:tag "Red Black Trees"]{Red Black Trees}
@subsection[#:tag "Tries"]{Tries}