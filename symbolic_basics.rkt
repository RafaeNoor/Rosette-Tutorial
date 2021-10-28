#lang rosette

;; This file describes how to use
;; Rosette to perform symbolic 
;; evaluation and synthesis

(require rosette/lib/synthax)
(require rosette/lib/angelic)
(require racket/pretty)


;; Specifying 50 MB memory limit to Rosette
(custodian-limit-memory (current-custodian) (* 50 1024 1024))


;; Rosette provides a new define-symbolic keyword
;; for defining symbolic values. These values can
;; be integers or bitvectors (with differennt underlying
;; theories). 
(define-symbolic _x (bitvector 32))

(println _x)
;; Output:  _x


;; Rosette hides away the complexity of
;; using symbolic/concrete variant of bitvector
;; operations by exposing the same name for 
;; bitvector operations for both.

(define y 
  (bv 1 (bitvector 32)))

(println (bvadd _x y))
;; Output: (bvadd (bv #x00000001 32) _x)


;; We can perform some interesting things with
;; using symbolic bitvectors / integers.

;; Let's say we want to define a query to return
;; to lowest common multiple of two bitvectors, but using
;; falling back on symbolic evaluation to solve it.

(define-symbolic _lcm (bitvector 32))

(define (symbolic-lcm-first a b)
  (define zero (bv 0 (bitvector 32)))
  (assume (bvsgt _lcm zero))

  (solve (begin 
            (assert (equal? zero (bvsrem _lcm a))
            (assert (equal? zero (bvsrem _lcm b))
                    )) 
           )
    )
)

(define res 
  (symbolic-lcm-first (bv 5 (bitvector 32)) (bv 7 (bitvector 32)))
  )

(println res)
;; Output: (model
;;  [_lcm (bv #x302f6941 32)])

(assert (sat? res) "Unsatisfiable query")

;; assign lcm_val the concrete value 
;; for _lcm according to the 'model' 
;; generated.
(define lcm_val (evaluate _lcm res))

(println lcm_val)
;; Output: (bv #x302f6941 32)

;; Converting to integer
(println (bitvector->integer lcm_val))

;; Output: 808413505


;; 808413505 is not the LCM for 7 and 5!
;; What went wrong?

;; The constraints were under specified. There
;; are multiple values which the remainder returns
;; zero. We want the smallest possible value in
;; that set.

;; Clearing any verification conditions
;; , assumptions, assertions from
;; previous portion of the code.
(clear-vc!)

(define-symbolic _lcm2 (bitvector 32))


;; We use another symbolic construct
;; to include the constraint that we
;; want to minimize the specific
;; multiple value.
(define (symbolic-lcm a b)
  (define zero (bv 0 (bitvector 32)))
  (assume (bvsgt _lcm2 zero)) ;; Assume Positive
  (define result 
    (optimize
      #:minimize (list  (bvsub _lcm2 a) (bvsub  _lcm2 b)) ;; list of constraints to minimize
      #:guarantee  (begin 
            (assert (equal? zero (bvsrem _lcm2 a)))
            (assert (equal? zero (bvsrem _lcm2  b)))
            )
    )
  )
  result
)


(define lcm_7_5 
  (symbolic-lcm (bv 5 (bitvector 32)) (bv 7 (bitvector 32)) 
                ))

(println lcm_7_5)

;; Output: (model
;; [_lcm2 (bv #x00000023 32)]) 


(assert (sat? res) "Unsatisfiable query")

(define final-res (evaluate _lcm2 lcm_7_5))

(println (bitvector->integer final-res))
;; Output: 35!

