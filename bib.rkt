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
(define hood-mel
  (make-bib  #:title "Real-time queue operations in pure Lisp"
             #:is-book? #f
             #:author (authors "Robert Hood" "Robert Melville")
             #:location "Information Processing Letters, 13(2):50-53"
             #:date "1981"))
(define pairing
  (make-bib  #:title "The pairing heap: A new form of self-adjusting heap"
             #:is-book? #f
             #:author (authors "Michael L. Fredman" "Robert Sedgewick" "Daniel D. K. Sleator" "Robert E. Tarjan")
             #:location "Algorithmica 1 (1): 111-129"
             #:date "1986"))
(define vuillemin
  (make-bib  #:title "A data structure for manipulating priority queues"
             #:is-book? #f
             #:author (author-name "Jean" "Vuillemin")
             #:location "Communications of the ACM, 21(4):309-315"
             #:date "1978"))
(define brown
  (make-bib  #:title "Implementation and analysis of binomial queue algorithms"
             #:is-book? #f
             #:author (author-name "Mark R" "Brown")
             #:location "SIAM Journal on Computing, 7(3):298-319"
             #:date "1978"))
(define crane
  (make-bib  #:title "Linear lists and priority queues as balanced binary trees"
             #:is-book? #f
             #:author (author-name "Clark Allan" "Crane")
             #:location "PhD thesis, Computer Science Department, Stanford University. STAN-CS-72-259."
             #:date "1972"))
(define sla
  (make-bib  #:title "Self-adjusting binary search trees"
             #:is-book? #f
             #:author (authors "Daniel D. K. Sleator" "Robert E. Tarjan")
             #:location "Journal of the ACM, 32(3):652-686"
             #:date "1985"))
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
            #:author (authors "Ralf Hinze" "Ross Paterson")
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
(define thf-dls
  (make-bib #:title "Interlanguage Refactoring: From Scripts to Programs"
            #:author (authors "Sam Tobin-Hochstadt" "Matthias Felleisen")
            #:location (proceedings-location "Dynamic Languages Symposium")
            #:date "2006"))
(define ctf-scheme
  (make-bib #:title "Advanced Macrology and the Implementation of Typed Scheme"
            #:author (authors "Ryan Culpepper" "Sam Tobin-Hochstadt" "Matthias Felleisen")
            #:location (proceedings-location "Scheme and Functional Programming")
            #:date "2007"))
(define stf-esop
  (make-bib #:title "Practical Variable-Arity Polymorphism"
            #:author (authors "T. Stephen Strickland" "Sam Tobin-Hochstadt" "Matthias Felleisen")
            #:location (proceedings-location "European Symposium on Programming")
            #:date "2009"))
(define th-diss
  (make-bib #:title "Typed Scheme: From Scripts to Programs"
            #:author "Sam Tobin-Hochstadt"
            #:location (dissertation-location #:institution "Northeastern University")
            #:date "2010"))

#|
@article{pierce:lti,
 author = {Benjamin C. Pierce and David N. Turner},
 title = {Local type inference},
 journal = toplas,
 volume = {22},
 number = {1},
 year = {2000},
 pages = {1--44},
 publisher = acmpress,
 address = nyny,
}
|#

(define (toplas p n v) 
  (journal-location "ACM Transactions on Programming Languages and Systems"
		    #:pages p
		    #:number (if (number? n) (number->string n) n)
		    #:volume (if (number? v) (number->string v) v)))

(define lti-journal
  (make-bib #:title "Local type inference"
	    #:location (toplas '(1 44) 1 22)
	    #:date "2000"
	    #:author (authors "Benjamin C. Pierce" "David N. Turner")))

(define plt-manual
  (make-bib #:title "Reference: PLT Scheme"
	    #:author (authors "Matthew Flatt" "PLT")
	    #:date "2010"
	    #:location (techrpt-location #:number "PLT-TR2010-reference-v4.2.5"
					 #:institution "PLT Scheme Inc.")))

(define skew
  (make-bib #:title "An applicative random-access stack"
            #:author "Eugene W. Myers"
            #:date "1983"
            #:location (journal-location "Information Processing Letters"
                                         #:pages '(241 248)
                                         #:number 5
                                         #:volume 17)))
(define (planet-cite pkg ver author [date #f])
  (make-bib #:title (format "~a, version ~a" pkg ver)
            #:author author
            #:date date
            #:location "PLaneT Package Repository"))

(define planet
  (make-bib #:title "Component Deployment with PLaneT: You Want it Where?"
            #:author "Jacob Matthews"
            #:date "2006"
            #:location (proceedings-location "Scheme and Functional Programming")))

(define galore (planet-cite "Galore" "4.2" "Jens Axel Soegaard"  "2009"))
(define dvh-ra (planet-cite "RaList: Purely Functional Random-Access Lists" 
                       "2.3"
                       (authors (author-name "David" "Van Horn"))
                       "2010"))