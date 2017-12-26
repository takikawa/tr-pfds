#lang racket/base

(require racket/contract (submod "trie.rkt" secret))

(provide Trie)
(provide/contract [bind (list? any/c Trie? . -> . any)]
                  [lookup (list? Trie? . -> . any)]
                  [insert (list? (listof list?) Trie? . -> . any)]
                  [tries (list? (listof list?) . -> . any)]
                  [trie ((listof list?) . -> . any)])
