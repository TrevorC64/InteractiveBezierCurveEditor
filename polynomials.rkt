;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname polynomials) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(define-struct non-constant [polynomial number])

; A Polynomial is one of:
;   - Number
;   - (make-non-constant (Polynomial Number))

(define poly1 5) ; 5
(define poly2 (make-non-constant poly1 2)) ;        5n + 2
(define poly3 (make-non-constant poly2 3)) ; 5n^2 + 2n + 3


(define (express-polynomial p)
  (lambda (n)
    (cond
      [(number? p) p]
      [(non-constant? p)
       (+ (* n ((express-polynomial (non-constant-polynomial p)) n))
          (non-constant-number p))])))

(define (p+ p1 p2)
  (cond
    [(and (number? p1)
          (number? p2)) (+ p1 p2)]
    [(and (non-constant? p1)
          (non-constant? p2))
     (make-non-constant (p+ (non-constant-polynomial p1)
                            (non-constant-polynomial p2))
                        (+ (non-constant-number p1)
                           (non-constant-number p2)))]
    [(and (non-constant? p1)
          (number? p2))
     (make-non-constant (non-constant-polynomial p1)
                        (+ (non-constant-number p1)
                           p2))]
    [(and (number? p1)
          (non-constant? p2))
     (make-non-constant (non-constant-polynomial p2)
                        (+ (non-constant-number p2)
                           p1))]))


(define (p- p1 p2)
  (cond
    [(and (number? p1)
          (number? p2)) (- p1 p2)]
    [(and (non-constant? p1)
          (non-constant? p2))
     (make-non-constant (p- (non-constant-polynomial p1)
                            (non-constant-polynomial p2))
                        (- (non-constant-number p1)
                           (non-constant-number p2)))]
    [(and (non-constant? p1)
          (number? p2))
     (make-non-constant (non-constant-polynomial p1)
                        (- (non-constant-number p1)
                           p2))]
    [(and (number? p1)
          (non-constant? p2))
     (make-non-constant (non-constant-polynomial p2)
                        (- (non-constant-number p2)
                           p1))]))



(define (p*n p n)
  (cond
    [(number? p) (* p n)]
    [(non-constant? p)
     (make-non-constant
      (p*n (non-constant-polynomial p) n)
      (* n (non-constant-number p)))]))



(define (p/n p n)
  (cond
    [(number? p) (/ p n)]
    [(non-constant? p)
     (make-non-constant
      (p/n (non-constant-polynomial p) n)
      (/ n (non-constant-number p)))]))



(define (p* p1 p2)
  (cond
    [(and (non-constant? p1)
          (number? p2)) (p*n p1 p2)]
    [(and (non-constant? p1)
          (non-constant? p2))
     (make-non-constant
      (p+ (p* p1 (non-constant-polynomial p2))
          (p*n (non-constant-polynomial p1)
               (non-constant-number p2)))
      (* (non-constant-number p1)
         (non-constant-number p2)))]))


















