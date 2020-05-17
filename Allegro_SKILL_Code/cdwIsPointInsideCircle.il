; SKILL function to determine whether a target point is within a circle
;    inputs
;        pt_target		- an (x y) list
;        pt_center_circle	- an (x y) list
;        d_radius		- a number
;    outputs
;        t if point is within the circle
;      nil if point is not within the circle
defun( cdwIsPointInsideCircle ( pt_target pt_center_circle d_radius)
let((compr result return_val)

pt_target_x = xCoord( pt_target)
pt_target_y = yCoord( pt_target)

pt_center_circle_x = xCoord( pt_center_circle)
pt_center_circle_y = yCoord( pt_center_circle)

compr = ((( pt_target_x - pt_center_circle_x)*( pt_target_x - pt_center_circle_x)
        + ( pt_target_y - pt_center_circle_y)*( pt_target_y - pt_center_circle_y)) / (d_radius*d_radius))

if( compr < 1.0 then
    result = t
else
    result = nil
);end-if

return_val = result

);end-let

);end-defun
