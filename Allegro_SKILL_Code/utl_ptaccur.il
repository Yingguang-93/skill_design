;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Title:  utl_ptaccur.il
;;
;;  Purpose:  To generate the proper format text to print a number or
;;	      an xy location in the current design database's accuracy.
;;
;;
;;  Example #1:
;;
;;		format = utl_printWithAccuracy()
;;		sprintf(command "Pin is located at %s %s." format format)
;;		sprintf(sentence command xCoord(pin->xy) yCoord(pin->xy))
;;
;;		if the db accuracy equals 2 and
;;		   pin->xy equals (25.00000 45.00000) then
;;
;;			format   = "%.2f"
;;			command  = "Pin is located at %.2f %.2f."
;;			sentence = "Pin is located at 25.00 45.00."
;;
;;
;;  Example #2:
;;
;;		format = utl_printXYwithAccuracy()
;;		sprintf(command "Pin is located at %s." format)
;;		sprintf(sentence command xCoord(pin->xy) yCoord(pin->xy))
;;
;;		if the db accuracy equals 2 and
;;		   pin->xy equals (25.00000 45.00000) then
;;
;;			format   = "X %.2f Y %.2f"
;;			command  = "Pin is located at X %.2f Y %.2f."
;;			sentence = "Pin is located at X 25.00 Y 45.00."
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



(defun utl_printWithAccuracy ( )

  (prog (cmd accur)

    accur = car(cdr(axlDBGetDesignUnits()))
    sprintf(cmd "%%.%df" accur)

    return( cmd )

   ) ;end-prog
) ;end-defun



(defun utl_printXYwithAccuracy ( )

  (prog (cmd accur)

    accur = car(cdr(axlDBGetDesignUnits()))
    sprintf(cmd "X %%.%df Y %%.%df" accur accur)

    return( cmd )

   ) ;end-prog
) ;end-defun

