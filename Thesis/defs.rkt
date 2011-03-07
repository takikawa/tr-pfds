#lang racket


(struct: (alpha) Node 
  ([rank  : Integer]
   [elem  : alpha]
   [trees : (Listof (Node alpha))]))

(struct: (alpha) Heap 
  ([compare : (alpha alpha -> Boolean)]
   [trees   : (Listof (Node alpha))]))

(struct heap 
  (comparer trees))

(struct: (alpha) Node 
  ([rank : Natural]
   [elem : alpha]
   [left : (Tree alpha)]
   [right : (Tree alpha)]))

(define-type (Tree alpha) (U Null (Node alpha)))

(struct: (alpha) Heap 
  ([compare : (alpha alpha -> Boolean)]
   [tree    : (Tree alpha)]))


(struct: (alpha) Node 
  ([elem : alpha]
   [trees : (Listof (Tree alpha))]))

(define-type (Tree alpha) (U Null (Node alpha)))

(struct: (alpha) Heap 
  ([compare : (alpha alpha -> Boolean)]
   [heap       : (Tree alpha)]))


(struct: (alpha) Leaf ([first : alpha]))

(struct: (alpha) Node 
  ([first : alpha]
   [left : (Tree alpha)] 
   [right : (Tree alpha)]))

(define-type (Tree alpha) (U (Leaf alpha) (Node alpha)))

(struct: (alpha) Root 
  ([size : Integer]
   [first : (Tree alpha)]
   [rest : (List alpha)]))

(define-type (List alpha) (U Null (Root alpha)))


(struct: (alpha) Node
         ([element   : alpha]
          [left        : (Tree alpha)]
          [right       : (Tree alpha)]
          [priority  : Real]))

(define-type (Tree alpha) (U Null (Node alpha)))

(struct: (alpha) Treap
         ([comparer : (alpha alpha -> Boolean)]
          [tree      : (Tree alpha)]
          [size      : Integer]))

(define-type Color (U 'red 'black))

(struct: (alpha) RBNode 
  ([color    : Color]
   [element : alpha]
   [left      : (Tree alpha)]
   [right     : (Tree alpha)]))

(define-type (Tree alpha) (U Null (RBNode alpha)))

(struct: (alpha) RedBlackTree 
  ([compare : (alpha alpha -> Boolean)]
   [tree       : (Tree alpha)]))

