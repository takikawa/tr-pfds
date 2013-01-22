#lang setup/infotab

;; Planet 2
(define deps '())

(define name "Library of Functional Data Structures in Typed Racket")
(define blurb
  '("A library of purely functional data structures in Typed Racket.
Data structures in the library are based on Chris Okasaki's book,
Purely Functional Data Structures and
work by Phil Bagwell and others"))
(define primary-file (list "queue/bankers.rkt"
                           "queue/bootstrapped.rkt"
                           "queue/hood-melville.rkt"
                           "queue/implicit.rkt"
                           "queue/physicists.rkt"
                           "queue/real-time.rkt"
                           "deque/bankers.rkt"
                           "deque/implicit.rkt"
                           "deque/real-time.rkt"
                           "ralist/binary.rkt"
                           "ralist/skew.rkt"
                           "heap/binomial.rkt"
                           "heap/bootstrapped.rkt"
                           "heap/lazy-pairing.rkt"
                           "heap/leftist.rkt"
                           "heap/pairing.rkt"
                           "heap/skew-binomial.rkt"
                           "heap/splay.rkt"
                           "catenable-list.rkt"
                           "red-black-trees.rkt"
                           "vlist.rkt"
                           "stream/streams.rkt"
                           "set.rkt"
                           "trie.rkt"
                           "treap.rkt"))
(define categories '(datastructures))
(define can-be-loaded-with 'all)
(define release-notes
  (list '(ul (li "Updated to Racket 5.3.1"))))
(define version "2.0")
(define scribblings '(("scribblings/functional-data-structures.scrbl" (multi-page))))
