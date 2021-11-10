;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname lab07) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require 2htdp/image)
(require 2htdp/universe)
(require "polynomials.rkt")

(define (number-between a b n)
  (+ a (* (/ n 100) (- b a))))

(define (posn-between p1 p2 n)
  (make-posn (number-between (posn-x p1)
                             (posn-x p2)
                             n)
             (number-between (posn-y p1)
                             (posn-y p2)
                             n)))


(define background (empty-scene 200 200))

(define (wave n)
  (make-posn (* n 2)
             (+ 70 (* 30 (sin (/ n 5))))))



(define (draw n bg f color)
  (cond
    [(= n 0) bg]
    [else (place-image
           (circle 1 "solid" color)
           (posn-x (f n))
           (posn-y (f n))
           (draw (- n 1) bg f color))]))

; redefining the functions above...

(define (draw-wave n bg)
  (draw n bg wave "dark green"))

(define (draw-line1 n bg)
  (draw n bg line1 "blue"))

(define (blend n f1 f2)
  (posn-between (f1 n) (f2 n) n))


(define (curve1 n)
  (blend n line1 wave))

(define (curve2 n)
  (blend n line2 line1))


(define (curve3 n)
  (blend n line2 wave))

(define (curve4 n)
  (blend n line1 line2))

(define (curve5 n)
  (blend n curve2 curve4))

(define (line1-start n)
  (make-posn 20 90))
(define (line1-end n)
  (make-posn 180 10))

(define (line1 n)
  (blend n line1-start line1-end))

(define (line2-start n)
  (make-posn 30 200))

(define (line2-end n)
  (make-posn 10 0))

(define (line2 n)
  (blend n line2-start line2-end))


;----------------------------------------------
;----------------- Challenges -----------------
;----------------------------------------------


;----------------- Exercise 15 ----------------

; A Style is (make-style [NaturalNumber -> Posn] String)
(define-struct style [curve color])

; A ListOfStyles is one of:
; - empty
; - (cons Style ListOfStyles)

; draw-styles : ListOfStyles Image -> Image
; draw the given styles on the given image
#;
(check-expect (draw-styles empty background) background)
#;
(check-expect (draw-styles
               (list (make-style curve5 (make-color 255 0 255))
                     (make-style curve2 (make-color 150 0 255))
                     (make-style curve4 (make-color 255 0 150))
                     (make-style line1  (make-color   0 0 255))
                     (make-style line2  (make-color 255 0   0)))
               background)
              'image)

; -------------------------- Challenge 16 --------------------------
(require 2htdp/universe)

; A Mode is one of:
;   - "point"
;   - "line"
;   - "curve"

; A ListOfPosn is one of:
;  - empty
;  - (cons Posn ListOfPosn)


; A World is (make-world ListOfStyles Mode ListOfPosn)
(define-struct world [los mode points])

(define styles (list (make-style curve5 (make-color 255 0 255))
                     (make-style curve2 (make-color 150 0 255))
                     (make-style curve4 (make-color 255 0 150))
                     (make-style line1  (make-color   0 0 255))
                     (make-style line2  (make-color 255 0   0))))

; re-stylize : ListOfStyles -> ListOfStyles
; changes the colors of each style to a new random color
(define (re-stylize los)
  (cond
    [(empty? los) empty]
    [else
     (cons (make-style (style-curve (first los)) (make-color (random 255)
                                                             (random 255)
                                                             (random 255)))
           (re-stylize (rest los)))]))

; eq-posn? : Posn Posn -> Boolean
; determines if the two posns are the same
(define (eq-posn? p1 p2)
  (and (eq? (floor (posn-x p1)) (floor (posn-x p2)))
       (eq? (floor (posn-y p1)) (floor (posn-y p2)))))

; intersect? : [NaturalNumber -> Posn] Posn -> Boolean
; determines if the given Posn is on the given curve
(define (intersect? curve n p)
  (cond
    [(= n -1) #f]
    [(eq-posn? p (curve n)) #t]
    [else (intersect? curve (- n 1) p)]))

; intersect-any? : ListOfStyles Posn -> Boolean
; determines if the given Posn intersects any of the curves in ListOfStyles
(define (intersect-any? los p)
  (cond
    [(empty? los) #f]
    [(intersect? (style-curve (first los))
                 100
                 p) #t]
    [else (intersect-any? (rest los) p)]))

; get-intersect : ListOfStyles Posn -> [NaturalNumber -> Posn]
; returns the curve in the given list that intersects the given Posn
(define (get-intersect los p)
  (cond
    [(empty? los) (error "curve not in list, check with intersect-any? first!")]
    [(intersect? (style-curve (first los))
                 100
                 p) (style-curve (first los))]
    [else (get-intersect (rest los) p)]))

; draw-styles : ListOfStyles -> Image
; draws each Style in ListOfStyles on a predefined background
(define (draw-styles los)
  (cond
    [(empty? los) background]
    [else
     (draw 100
           (draw-styles (rest los))
           (style-curve (first los))
           (style-color (first los)))]))

; make-line : Posn Posn -> [NaturalNumber -> Posn]
; creates a line starting at the first Posn and ending at the second Posn
(define (make-line p1 p2)
  (lambda (n)
    (blend n (lambda (x)
               p1)
           (lambda (x)
             p2))))


; editor : World KeyEvent -> World
; determines the current Mode and calls respective editor
(define (editor w ke)
  (cond
    [(string=? (world-mode w) "point") (editor-point w ke)]
    [(string=? (world-mode w) "curve") (editor-curve w ke)]
    [(string=? (world-mode w) "line")  (editor-line w ke)]
    [else (error "unknown mode :" (world-mode w))]))

; editor-line : World KeyEvent -> World
; handles KeyEvents when in 'line' Mode
(define (editor-line w ke)
  (cond
    [(key=? ke "a") ; creates a new line from the two most recent points
     (cond
       [(<= 2 (length (world-points w)))
        (make-world
         (cons (make-style (make-line (first (world-points w))
                                      (second (world-points w)))
                           "green")
               (world-los w))
         (world-mode w)
         (rest (rest (world-points w))))]
       [else w])]
    [(key=? ke "d") ; deletes most recent curve
     (cond
       [(empty? (world-los w)) w]
       [else (make-world (rest (world-los w))
                         (world-mode w)
                         (world-points w))])]
    [else (editor-gen w ke)]))

; editor-point : World KeyEvent -> World
; handles KeyEvents when in 'point' Mode
(define (editor-point w ke)
  (cond
    [(key=? ke "d") ; deletes most recent point
     (cond
       [(empty? (world-points w)) w]
       [else (make-world (world-los w)
                         (world-mode w)
                         (rest (world-points w)))])]
    [else (editor-gen w ke)]))

; editor-curve : World KeyEvent -> World
; handles KeyEvents when in 'curve' Mode
(define (editor-curve w ke)
  (cond
    [(key=? ke "d") ; deletes most recent curve
     (cond
       [(empty? (world-los w)) w]
       [else (make-world (rest (world-los w))
                         (world-mode w)
                         (world-points w))])]
    [(key=? ke "b")  ; blends the 2 most recent curves
     (cond
       [(> 2 (length (world-los w))) w]
       [else
        (make-world
         (cons (make-style (lambda (n) (blend n
                                              (style-curve (first (world-los w)))
                                              (style-curve (second (world-los w)))))"orange")
               (rest (rest (world-los w))))
         (world-mode w)
         (world-points w))
        ])
     ]
    [else (editor-gen w ke)]))

; editor-gen : World KeyEvent -> World
; acts as a base case for other editors, handles commands that are available in all Modes
(define (editor-gen w ke)
  (cond
    [(key=? ke "r") ; recolor all curves
     (make-world (re-stylize (world-los w))
                 (world-mode w)
                 (world-points w))]
    [(key=? ke "p") ; set mode to 'point'
     (make-world (world-los w)
                 "point"
                 (world-points w))]
    [(key=? ke "c") ; set mode to 'curve'
     (make-world (world-los w)
                 "curve"
                 (world-points w))]
    [(key=? ke "l") ; set mode to 'line'
     (make-world (world-los w)
                 "line"
                 (world-points w))]
    [else w]))

; mouse-handler : World Number Number MouseEvent -> World
; handles MouseEvents and acts accordingly
(define (mouse-handler w x y me)
  (cond
    [(mouse=? me "button-down")
     (cond
       [(intersect-any? (world-los w) ; highlight the curve that was clicked
                        (make-posn x y))
        (make-world (cons (make-style (get-intersect (world-los w) (make-posn x y))
                                      "red")
                          (world-los w))
                    (world-mode w)
                    (world-points w))]
       [else (make-world (world-los w) ; adds a new point
                         (world-mode w)
                         (cons (make-posn x y)
                               (world-points w)))])]
    [else w]))

; draw-points : ListOfPoints Image -> Image
; draws all points in given list on the given image
(define (draw-points lop bg)
  (cond
    [(empty? lop) bg]
    [else (place-image
           (circle 1 "solid" "black")
           (posn-x (first lop))
           (posn-y (first lop))
           (draw-points (rest lop) bg))]))

; draw-world : World -> Image
; draws the world using draw-points & draw-styles
(define (draw-world w)
  (place-image
   (text (world-mode w) 10 "black")
   175
   175
   (draw-points
    (world-points w)
    (draw-styles (world-los w)))))


(big-bang (make-world styles "point" empty)
  [on-draw draw-world]
  [on-key editor]
  [on-mouse mouse-handler])

; Commands
; ------------------
; General:
;  - 'r' ~ recolor all lines
;  3 modes:
;      - 'l' ~ activate line mode
;      - 'c' ~ activate curve mode
;      - 'p' ~ activate point mode
;  
;
;  In 'line' mode:
;      - 'a' ~ add a line connecting the 2 most recent points
;      - 'd' ~ deletes most recent curve 
;
;  In 'curve' mode: 
;      - 'b' ~ makes a new curve by blending the 2 most recent curves, then deletes the two curves used
;      - 'd' ~ deletes  most recent curve
;   
;  In 'point' mode:
;      - 'd' ~ deletes most recent point
;

; Features
; -------------------
;  Making new points:
;      - click anywhere to make a new point
;      - while in 'point' mode press 'd' to delete most recent point
;
;  Making new lines:
;      1. first make 2 new points
;      2. press 'l' to go into 'line' mode 
;      3. press 'a' to add a new line connecting the two points, your line will be green
;
;  Making new curves:
;      1. make 2 new lines (see above)
;      2. press 'c' to go into 'curve' mode
;      3. press 'b' to blend the 2 new lines into a curve
;     (**) if you do not make new lines and try to blend, it will use the two most recent curves
;
;  Recolor curves:
;    - press 'r' at any time to recolor all curves
;
;  Deleting curves/lines:
;   - press 'd' while in 'curve' or 'line' mode to delete the most recent curve
;
;  Deleting points:
;   - press 'd' while in 'point' mode to delete the most recent point
;
;  Selecting Curves:
;   - if you click on a curve it will select it and colors it red, has no functionality
;



