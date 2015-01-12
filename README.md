Functional Data Structures for Typed Racket
===========================================

This library provides several functional data structures based on the work
of Chris Okasaki and Phil Bagwell. The documentation is available online
[here](http://pkg-build.racket-lang.org/doc/functional-data-structures/index.html).

The original library was implemented by Hari Prashanth.

How to install
--------------

Use one of:

* `raco pkg install pfds`

or

* `git clone git://github.com/takikawa/tr-pfds.git`
* `raco pkg install tr-pfds/`

On Racket v5.3.1 or older, use `raco` to link this repository as
a Racket collection. Here are step-by-step instructions:

* `git clone git://github.com/takikawa/tr-pfds.git`
* `cd tr-pfds/pfds`
* `raco link .`
* `raco setup pfds`

This will link the `pfds` folder as a collection called `pfds`.
Then you can require, for example, the Bankers Deque by using
`(require pfds/deque/bankers)`.

Data structures
---------------

The following data structures are implemented:

*  Deques
   +  Bankers Deque   `pfds/deque/bankers`
   +  Implicit Deque  `pfds/deque/implicit`
   +  Real-Time Deque `pfds/deque/real-time`
*  Heaps
   +  Binomial Heap      `pfds/heap/binomial`
   +  Skew Binomial Heap `pfds/heap/skew-binomial`
   +  Leftist Heap       `pfds/heap/leftist`
   +  Splay Heap         `pfds/heap/splay`
   +  Pairing Heap       `pfds/heap/pairing`
   +  Lazy Pairing Heap  `pfds/heap/lazy-pairing`
   +  Bootstrapped Heap  `pfds/heap/bootstrapped`
* Queues
   +  Bankers Queue       `pfds/queue/bankers`
   +  Physicist's Queue   `pfds/queue/physicists`
   +  Hood-Melville Queue `pfds/queue/hood-melville`
   +  Implicit Queue      `pfds/queue/implicit`
   +  Real-Time Queue     `pfds/queue/real-time`
*  Random Access Lists
   +  Binary Random Access List      `pfds/ralist/binary`
   +  Skew Binary Random Access List `pfds/ralist/skew`
*  Catenable List   `pfds/catenable-list`
*  VList            `pfds/vlist`
*  Streams          `pfds/stream`
*  Red-Black Trees  `pfds/red-black-tree`
*  Tries            `pfds/trie`
*  Treap            `pfds/treap`
