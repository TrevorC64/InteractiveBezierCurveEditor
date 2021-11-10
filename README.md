# InteractiveBezierCurveEditor
Interactive editor for bezier curves </br >
Personal solution for challenge exersices for IU CSCI C211, created while testing a lab before students attempted.
; Commands </br >
; ------------------ </br >
; General: </br >
;  - 'r' ~ recolor all lines </br >
;  3 modes: </br >
;      - 'l' ~ activate line mode </br >
;      - 'c' ~ activate curve mode </br >
;      - 'p' ~ activate point mode </br >
; </br >  
; </br >
;  In 'line' mode: </br >
;      - 'a' ~ add a line connecting the 2 most recent points </br >
;      - 'd' ~ deletes most recent curve  </br >
; </br >
;  In 'curve' mode:  </br >
;      - 'b' ~ makes a new curve by blending the 2 most recent curves, then deletes the two curves used </br >
;      - 'd' ~ deletes  most recent curve </br >
;    </br >
;  In 'point' mode: </br >
;      - 'd' ~ deletes most recent point </br >
; </br >
 </br >
; Features </br >
; ------------------- </br >
;  Making new points: </br >
;      - click anywhere to make a new point </br >
;      - while in 'point' mode press 'd' to delete most recent point </br >
; </br >
;  Making new lines: </br >
;      1. first make 2 new points </br >
;      2. press 'l' to go into 'line' mode  </br >
;      3. press 'a' to add a new line connecting the two points, your line will be green </br >
; </br >
;  Making new curves: </br >
;      1. make 2 new lines (see above) </br >
;      2. press 'c' to go into 'curve' mode </br >
;      3. press 'b' to blend the 2 new lines into a curve </br >
;     (**) if you do not make new lines and try to blend, it will use the two most recent curves </br >
; </br >
;  Recolor curves: </br >
;    - press 'r' at any time to recolor all curves </br >
; </br >
;  Deleting curves/lines: </br >
;   - press 'd' while in 'curve' or 'line' mode to delete the most recent curve </br >
; </br >
;  Deleting points: </br >
;   - press 'd' while in 'point' mode to delete the most recent point </br >
; </br >
;  Selecting Curves: </br >
;   - if you click on a curve it will select it and colors it red, has no functionality </br >
; </br >
