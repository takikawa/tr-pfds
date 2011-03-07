#lang at-exp racket/base
(require scribble/manual
         (for-label racket/base))

(define racket-map @racket[map])
(define racket-foldl @racket[foldl])
(define racket-foldr @racket[foldr])
(define racket-filter @racket[filter])
(define racket-remove @racket[remove])
(define racket-andmap @racket[andmap])
(define racket-ormap @racket[ormap])
(define racket-build-list @racket[build-list])
(define racket-make-list @racket[make-list])
(provide racket-map racket-foldl racket-foldr racket-filter racket-remove
         racket-andmap racket-ormap racket-build-list racket-make-list)
