#lang rosette

;; This file describes basic bitvector operation
;; through examples


(require rosette/lib/synthax)
(require rosette/lib/angelic)
(require racket/pretty)


;; Specifying 50 MB memory limit to Rosette
(custodian-limit-memory (current-custodian) (* 50 1024 1024))

;; Rosette provides a bitvector type with arbritray
;; length. It's up to the user to interpret
;; a particular bitvector as a vector of certain
;; length and precision, or tensor with shape and precsion

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


(println (int128 10))
;; Output: (bv #x0000000000000000000000000000000a 128)



;; Rosette provides various bitvector operations on bitvectors


(println (bvadd (int32 1) (int32 3)))
;; Output: (bv #x00000004 32)


(println (bvmul (int32 2) (int32 3)))
;; Output: (bv #x00000006 32)


;; Most bitvector operations are
;; have take either two operands or 
;; one.  We can fold the binary operations
;; on lists of arbritrary lengths


(define bv_list (list (int32 0) (int32 1) (int32 2) (int32 3) (int32 4)))


;; Apply folds an operation
;; on a list of values
(define (simple-add-reduce ls)
  (apply bvadd ls)
  )

(println (simple-add-reduce bv_list))
;; Output: (bv #x0000000a 32)

(println (bitvector->integer (simple-add-reduce bv_list)))
;; Output: 10


;; Bitvector concatenation and
;; extraction


(define concat_vec 
  (concat (int32 4) (int128 3)))


(println concat_vec)
;; Output:  (bv #x0000000400000000000000000000000000000003 160)


(define value 
  (bv #x11112222 (bitvector 32)))

(println value)
;; Output: (bv #x11112222 32)


;; Extracting the bitvector starting from
;; 8 bits from the right up till 23 bits
;; from the right yielding a 
;; bitvector of length (23-8) + 1 = 16 bits
(define slice (extract 23 8 value))

(println slice)
;; Output: (bv #x1122 16)

(define neg_slice (bvneg slice))
(println neg_slice)
;; Output: (bv #xeede 16)


;; Sign extension and zero extension
(define zero-ext-slice (zero-extend neg_slice (bitvector 32)))
(println zero-ext-slice)
;; Output: (bv #x0000eede 32)


(define sign-ext-slice (sign-extend neg_slice (bitvector 32)))
(println sign-ext-slice)
;; Output: (bv #xffffeede 32)

