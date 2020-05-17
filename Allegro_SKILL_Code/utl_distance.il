;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Title:  utl_distance.il
;;
;;  Purpose:  To find the distance between two point or
;;	      to find the distance from a given point to 0,0
;;
;;
;;  Example #1:
;;
;;		distance = utl_distance(pt1 pt2)
;;		pt1 = 35.0,50.0   pt2 = 65.0,90.0   distance = 50.0
;;
;;
;;  Example #2:
;;
;;		distance = utl_distanceAbsolute(pt)
;;		pt = 30.0,40.0   distance = 50.0
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



(defun utl_distance ( pt1 pt2 )

  (prog ( delta_x delta_y dist )

    delta_x = abs(xCoord(pt1) - xCoord(pt2))
    delta_y = abs(yCoord(pt1) - yCoord(pt2))
    dist = sqrt( (delta_x * delta_x) +
		 (delta_y * delta_y) )
    return( dist )

   ) ;end-prog
) ;end-defun



(defun utl_distanceAbsolute ( pt )

  (prog ( delta_x delta_y dist )

    delta_x = abs(xCoord(pt))
    delta_y = abs(yCoord(pt))
    dist = sqrt( (delta_x * delta_x) +
		 (delta_y * delta_y) )
    return( dist )

   ) ;end-prog
) ;end-defun

