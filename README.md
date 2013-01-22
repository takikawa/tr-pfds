Functional Data Structures for Typed Racket
===========================================

This library provides several functional data structures based on the work
of Chris Okasaki and Phil Bagwell.

The original library was implemented by Hari Prashanth.

How to use
----------

Use `raco` to link this repository as a Racket collection.
Here are step-by-step instructions:

* `git clone git://github.com/takikawa/tr-pfds.git`
* `cd tr-pfds/data`
* `raco link .`
* `raco setup data`

This will link the `tr-pfds` folder as a collection called `tr-pfds`.
Then you can require, for example, the Bankers Deque by using
`(require data/deque/bankers)`.

Data structures
---------------

The following data structures are implemented:

*  Deques
   +  Bankers Deque   `data/deque/bankers`
   +  Implicit Deque  `data/deque/implicit`
   +  Real-Time Deque `data/deque/real-time`
*  Heaps
   +  Binomial Heap      `data/heap/binomial`
   +  Skew Binomial Heap `data/heap/skew-binomial`
   +  Leftist Heap       `data/heap/leftist`
   +  Splay Heap         `data/heap/splay`
   +  Pairing Heap       `data/heap/pairing`
   +  Lazy Pairing Heap  `data/heap/lazy-pairing`
   +  Bootstrapped Heap  `data/heap/bootstrapped`
* Queues
   +  Bankers Queue       `data/queue/bankers`
   +  Physicist's Queue   `data/queue/physicists`
   +  Hood-Melville Queue `data/queue/hood-melville`
   +  Implicit Queue      `data/queue/implicit`
   +  Real-Time Queue     `data/queue/real-time`
*  Random Access Lists
   +  Binary Random Access List      `data/ralist/binary`
   +  Skew Binary Random Access List `data/ralist/skew`
*  Catenable List   `data/catenable-list`
*  VList            `data/vlist`
*  Streams          `data/stream`
*  Red-Black Trees  `data/red-black-tree`
*  Tries            `data/trie`
*  Treap            `data/treap`
