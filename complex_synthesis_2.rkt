#lang rosette

;; This file describes how to use
;; Rosette to perform symbolic 
;; evaluation and synthesis

(require rosette/lib/synthax)
(require rosette/lib/angelic)
(require racket/pretty)


;; Code snippets from https://docs.racket-lang.org/rosette-guide/ch_essentials.html 

;; Specifying 2500 MB memory limit to Rosette
(custodian-limit-memory (current-custodian) (* 2500 1024 1024))


; Naming a typedef for specific bitvector length type
(define int128? (bitvector 128))
(define int32? (bitvector 32))
(define int8? (bitvector 8))
(define int4? (bitvector 4))

(define (int4 i)
  (bv i int4?))

(define (int8 i)
  (bv i int8?))

(define (int32 i)
  (bv i int32?))

(define (int128 i)
  (bv i int128?))



(define (check-mid impl lo hi)     ; Assuming that
  (assume (bvsle (int32 0) lo))    ; 0 ≤ lo and
  (assume (bvsle lo hi))           ; lo ≤ hi,
  (define mi (impl lo hi))         ; and letting mi = impl(lo, hi) and
  (define diff                     ; diff = (hi - mi) - (mi - lo),
    (bvsub (bvsub hi mi)
           (bvsub mi lo)))         ; we require that
  (assert (bvsle lo mi))           ; lo ≤ mi,
  (assert (bvsle mi hi))           ; mi ≤ hi,
  (assert (bvsle (int32 0) diff))  ; 0 ≤ diff, and
  (assert (bvsle diff (int32 1)))) ; diff ≤ 1.

(define-symbolic low high int32?)

; Returns the midpoint of the interval [lo, hi].
(define (bvmid lo hi)  ; (lo + hi) / 2
  (bvsdiv (bvadd lo hi) (int32 2)))

(define cex (verify (check-mid bvmid low high)))
(println cex)
;; Output: (model
;;  [low (bv #x394f0402 32)]
;;  [high (bv #x529e7c00 32)])



























(define-grammar (fast-int32 x y)  ; Grammar of int32 expressions over two inputs:
  [expr
   (choose x y (?? int32?)        ; <expr> := x | y | <32-bit integer constant> |
           ((bop) (expr) (expr))  ;           (<bop> <expr> <expr>) |
           ((uop) (expr)))]       ;           (<uop> <expr>)
  [bop
   (choose bvadd bvsub bvand      ; <bop>  := bvadd  | bvsub | bvand |
           bvor bvxor bvshl       ;           bvor   | bvxor | bvshl |
           bvlshr bvashr)]        ;           bvlshr | bvashr
  [uop
   (choose bvneg bvnot)])         ; <uop>  := bvneg | bvnot


(define (bvmid-fast lo hi)
  (fast-int32 lo hi #:depth 2))

(define-symbolic l h (bitvector 32))

(define sol
    (synthesize
     #:forall    (list l h)
     #:guarantee (check-mid bvmid-fast l h)))

(print-forms sol)
;;(list
;;  'define
;;  '(bvmid-fast lo hi)
;;  (list 'bvlshr '(bvadd hi lo) (bv #x00000001 32))) 
