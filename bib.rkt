#lang racket

(require scriblib/autobib)

(provide (all-defined-out))

(define-cite cite citet gen-bib)

(define bagwell (author-name "Phil" "Bagwell"))
(define okasaki (author-name "Chris" "Okasaki"))

(define oka
  (make-bib #:title "Purely Functional Data Structures"
            #:is-book? #t
            #:author okasaki
            #:location (book-location #:publisher "Cambridge University Press")
            #:date "1998"))
(define bagwell-lists
  (make-bib #:title "Fast Functional Lists, Hash-Lists, Deques and Variable Length Arrays"
            #:is-book? #f
            #:author bagwell
            #:location "In Implementation of Functional Languages, 14th International Workshop"
            #:date "2002"))
(define bagwell-trie
  (make-bib  #:title "Fast And Space Efficient Trie Searches"
             #:is-book? #f
             #:author bagwell
             #:location "Technical report, 2000/334, Ecole Polytechnique  F´ed´erale de Lausanne"
             #:date "2000"))
(define kaplan-tarjan
  (make-bib #:title "Persistent lists with catenation via recursive slow-down"
            #:is-book? #f
            #:author (authors "Haim Kaplan" "Robert E. Tarjan")
            #:location "Proceedings of the twenty-seventh annual ACM symposium on Theory of computing"
            #:date "1995"))
(define oka-red-black
  (make-bib #:title "Red-Black Trees in Functional Setting"
            #:is-book? #f
            #:author okasaki
            #:location "Journal Functional Programming"
            #:date "1999"))
(define finger
  (make-bib #:title "Finger trees: a simple general-purpose data structure"
            #:is-book? #f
            #:author "Ralf Hinze and Ross Paterson"
            #:location "Journal Functional Programming"
            #:date "2006"))

(define srfi/1
  (make-bib #:title "SRFI-1: List Library"
            #:author "Olin Shivers"
            #:date "1999"))
(define thf-popl
  (make-bib #:title "The Design and Implementation of Typed Scheme"
            #:author (authors "Sam Tobin-Hochstadt" "Matthias Felleisen")
            #:location (proceedings-location "Symposium on Principles of Programming Languages")
            #:date "2008"))