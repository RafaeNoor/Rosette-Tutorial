#lang rosette

;; This file describes how to use
;; Rosette to perform symbolic 
;; evaluation and synthesis

(require rosette/lib/synthax)
(require rosette/lib/angelic)
(require racket/pretty)


;; Specifying 2500 MB memory limit to Rosette
(custodian-limit-memory (current-custodian) (* 2500 1024 1024))

;; Interpret infinite precision integers
;; as 32 bit integer values for solver
;; efficiency
(current-bitwidth 32)


;; Suppose we want to learn a simple polynomial
;; distribution with 

(define-grammar (poly-grammar a b c)

                [expr 
                  ( choose
                    a
                    b
                    c
                    (+ (expr) (expr))
                    (- (expr) (expr))
                    (/ (expr) (expr))
                    (* (expr) (expr))
                    )]

                )

(define (synth_grammar arg1 arg2 arg3)
                    (poly-grammar arg1 arg2 arg3 #:depth 3))






(define a_1 1)
(define b_1 2)
(define c_1 1)
(define res1 5)



(define a_2 2)
(define b_2 5)
(define c_2 6)
(define res2 33)


(define a_3 0)
(define b_3 0)
(define c_3 0)
(define res3 0)

(define sol
    (synthesize
    #:forall (list a_1 b_1 c_1 res1 a_2 b_2 c_2 res2 a_3 b_3 c_3 res3 )
    #:guarantee  (begin
            (assert  
                (equal? res1 (synth_grammar a_1 b_1 c_1) ))
            (assert  
                (equal? res2 (synth_grammar a_2 b_2 c_2) ))

            (assert  
                (equal? res3 (synth_grammar a_3 b_3 c_3) ))
        )
    )
)

(assert (sat? sol) "Unsatisfiable")
(print-forms sol)


;; Output: 
;; '(define (synth_grammar arg1 arg2 arg3)
;;   (+ (+ (+ arg2 arg2) (* arg3 arg3)) (- (- arg2 arg3) (* arg1 arg3))))
