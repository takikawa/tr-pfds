#lang setup/infotab
(define name "Library of Functional Data Structures in Typed Racket")
(define blurb
  '("A library of purely functional data structures in Typed Racket.
Data structures in the library are based on Chris Okasaki's book,
Purely Functional Data Structures and
work by Phil Bagwell and others"))
(define primary-file (list "queue/bankers/main.rkt"
                           "queue/bootstrapped/main.rkt"
                           "queue/hood-melville/main.rkt"
                           "queue/implicit/main.rkt"
                           "queue/physicists/main.rkt"
                           "queue/real-time/main.rkt"
                           "deque/bankers/main.rkt"
                           "deque/implicit/main.rkt"
                           "deque/real-time/main.rkt"
                           "ralist/binary/main.rkt"
                           "ralist/skew/main.rkt"
                           "heap/binomial/main.rkt"
                           "heap/bootstrapped/main.rkt"
                           "heap/lazy-pairing/main.rkt"
                           "heap/leftist/main.rkt"
                           "heap/pairing/main.rkt"
                           "heap/skew-binomial/main.rkt"
                           "heap/splay/main.rkt"
                           "catenable-list/main.rkt"
                           "red-black-trees/main.rkt"
                           "vlist/main.rkt"
                           "stream/streams.rkt"
                           "set/main.rkt"
                           "trie/main.rkt"
                           "treap/main.rkt"))
(define categories '(datastructures))
(define can-be-loaded-with 'all)
(define release-notes
  (list '(ul (li "Updated to Racket 5.2.1"))))
(define version "2.0")
(define scribblings '(("scribblings/functional-data-structures.scrbl" (multi-page))))
