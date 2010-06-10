#lang racket

(require scriblib/autobib)

(provide (all-defined-out))

(define-cite cite citet gen-bib)

(define oka
  (make-bib #:title "Purely Functional Data Structures"
            #:is-book? #t
            #:author "Chris Okasaki"
            #:location (book-location #:publisher "Cambridge University Press")
            #:date "1998"))
(define bagwell-lists
  (make-bib #:title "Fast Functional Lists, Hash-Lists, Deques and Variable Length Arrays"
            #:is-book? #f
            #:author "Phil Bagwell"
            #:location "In Implementation of Functional Languages, 14th International Workshop"
            #:date "2002"))
(define bagwell-trie
  (make-bib  #:title "Fast And Space Efficient Trie Searches"
             #:is-book? #f
             #:author "Phil Bagwell"
             #:location "Technical report, 2000/334, Ecole Polytechnique  F´ed´erale de Lausanne"
             #:date "2000"))
(define kaplan-tarjan
  (make-bib #:title "Persistent lists with catenation via recursive slow-down"
            #:is-book? #f
            #:author "Haim Kaplan and Robert E. Tarjan"
            #:location "Proceedings of the twenty-seventh annual ACM symposium on Theory of computing"
            #:date "1995"))
(define oka-red-black
  (make-bib #:title "Red-Black Trees in Functional Setting"
            #:is-book? #f
            #:author "Chris Okasaki"
            #:location "Journal Functional Programming"
            #:date "1999"))
(define finger
  (make-bib #:title "Finger trees: a simple general-purpose data structure"
            #:is-book? #f
            #:author "Ralf Hinze and Ross Paterson"
            #:location "Journal Functional Programming"
            #:date "2006"))
