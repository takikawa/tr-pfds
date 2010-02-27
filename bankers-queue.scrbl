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

@subsection[#:tag "Realtime Queue"]{Realtime Queue}
@subsection[#:tag "Realtime Deque"]{Realtime Deque}
@subsection[#:tag "Bootstrapped Queue"]{Bootstrapped Queue}
@subsection[#:tag "Binary Random Access List"]{Binary Random Access List}
@subsection[#:tag "Skew Binary Random Access List"]{Skew Binary Random Access List}
@subsection[#:tag "Catenable List"]{Catenable List}
@subsection[#:tag "VList"]{VList}
@subsection[#:tag "VHash List"]{VHash List}
@subsection[#:tag "Binomial Heap"]{Binomial Heap}
@subsection[#:tag "Skew Binomial Heap"]{Skew Binomial Heap}
@subsection[#:tag "Leftist Heap"]{Leftist Heap}
@subsection[#:tag "Splay Heap"]{Splay Heap}
@subsection[#:tag "Pairing Heap"]{Pairing Heap}
@subsection[#:tag "Lazy Pairing Heap"]{Lazy Pairing Heap}
@subsection[#:tag "Bootstrapped Heap"]{Bootstrapped Heap}
@subsection[#:tag "Unbalanced Set"]{Unbalanced Set}
@subsection[#:tag "Red Black Trees"]{Red Black Trees}
@subsection[#:tag "Tries"]{Tries}