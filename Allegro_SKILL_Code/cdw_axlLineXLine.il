; line segment intersection determining  SKILL function
; Written by: Chris Walters		Nvidia		2002/06/19
;
; Description:
; This SKILL function will determine whether two 2D line segments intersect
; and if so where. A boolean tells whether the intersection point lies on both
; both segments (t) or not (nil)
;
; It is based upon the Liang-Barsky line-clipping algorithm and so works even if
; one or both segments are parallel to an axis, unlike the axlLineXLine function
; shipped with PSD14.1
;
; Preparation:
;     Position this file (cdw_axlLineXLine.il) in the directory path where all other
;     skill routines are located. In the allegro.ilinit file include the line
;     load("cdw_axlLineXLine.il")
;
; Usage:
;     cdw_axlLineXLine( seg_1 seg_2)
;        arguments
;             seg_1 and seg_2 are lists containing start and endpoints for the segments
;
;        returns
;             '(nil ( nil nil))  if lines segments are on are parallel
;             '(nil ( xxx yyy))  if lines segments are on intersect but the point does not lie on both segments
;             '(t   ( xxx yyy))  if lines segments are on intersect and the point does lie on both segments
;                       where (xxx yyy) is the intersection point
;
; Associated files:
;     None
;
; Revision History
;    --		2002/06/19  Chris Walters	Initial release
;==========================================================================
defun( cdw_axlLineXLine ( line_AB line_CD)	; based upon Liang-Barsky line-clipping algorithm,
let(( pt_A_x pt_A_y pt_B_x pt_B_y			; works even if one or both segmensts are parallel
      pt_C_x pt_C_y pt_D_x pt_D_y			; to either horizontal or vertical axis
      u_AB u_CD denom
      cross_x cross_y
      return_val )

pt_A_x =   caar( line_AB)
pt_A_y =  cadar( line_AB)
pt_B_x =  caadr( line_AB)
pt_B_y = cadadr( line_AB)
pt_C_x =   caar( line_CD)
pt_C_y =  cadar( line_CD)
pt_D_x =  caadr( line_CD)
pt_D_y = cadadr( line_CD)

denom =  ((pt_D_y - pt_C_y)*(pt_B_x - pt_A_x) - (pt_D_x - pt_C_x)*(pt_B_y - pt_A_y))

true_intersect_exists = nil
if( denom == 0.0 then        ; lines are parrallel, either no points intersect or ALL points intersect
    true_intersect_exists = nil    ; 
else	; an intersection exists but it may not lie on the segments
	u_AB = (((pt_D_x - pt_C_x)*(pt_A_y - pt_C_y) - (pt_D_y - pt_C_y)*(pt_A_x - pt_C_x)) / denom)
	u_CD = (((pt_B_x - pt_A_x)*(pt_A_y - pt_C_y) - (pt_B_y - pt_A_y)*(pt_A_x - pt_C_x)) / denom)

	cross_x = pt_A_x + u_AB * (pt_B_x - pt_A_x)
	cross_y = pt_A_y + u_AB * (pt_B_y - pt_A_y)
    if( (u_AB >= 0.0 && u_AB <= 1.0) && (u_CD >= 0.0 && u_CD <= 1.0) then
        true_intersect_exists = t
    else
        true_intersect_exists = nil
    );end-if
);end-if

return_val = list( true_intersect_exists list( cross_x cross_y))

);end-let

);end-defun
