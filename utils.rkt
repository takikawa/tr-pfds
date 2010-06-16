#lang at-exp racket

(require scribble/eval scribble/core scribble/sigplan)

(provide (all-defined-out))

(define evaluate (make-base-eval))

(define (lpara . items)
  (make-element (make-style "paragraph" '(exact-chars))
                items))

(define (exact . items)
  (make-element (make-style "identity" '(exact-chars))
                items))

(define Ologn @exact{$O(\mathop{\mathrm{log}} n)$})
(define Olgn @exact{$O(\mathop{\mathrm{lg}} n)$})
(define Olog*n @exact{$O(\mathop{\mathrm{log}}^* n)$})
(define O1 @exact{$O(1)$})
(define On @exact{$O(n)$})
(define log*n @exact{$\mathop{\mathrm{log}}^* n$})