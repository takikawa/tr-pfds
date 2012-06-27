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
* `cd tr-pfds`
* `raco link .`

This will link the `tr-pfds` folder as a collection called `tr-pfds`.
Then you can require, for example, the Bankers Deque by using
`(require tr-pfds/deque/bankers)`.

Data structures
---------------

The following data structures are implemented:

*  Deques
   +  Bankers Deque   `deque/bankers`
   +  Implicit Deque  `deque/implicit`
   +  Real-Time Deque `deque/real-time`
*  Heaps
   +  Binomial Heap      `heap/binomial`
   +  Skew Binomial Heap `heap/skew-binomial`
   +  Leftist Heap       `heap/leftist`
   +  Splay Heap         `heap/splay`
   +  Pairing Heap       `heap/pairing`
   +  Lazy Pairing Heap  `heap/lazy-pairing`
   +  Bootstrapped Heap  `heap/bootstrapped`
*  Random Access Lists
   +  Binary Random Access List      `ralist/binary`
   +  Skew Binary Random Access List `ralist/skew`
*  Catenable List   `catenable-list`
*  VList            `vlist`
*  Streams          `stream`
*  Red-Black Trees  `red-black-tree`
*  Tries            `trie`
*  Sets             `set`
*  Treap            `treap`
