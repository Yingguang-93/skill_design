; $Header:  $
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; SKILL file
; del_unconn.il --      file containing function to delete unconnected etch shapes
;
; This module contains: expand_window
;                       _ducMain 
;                       _ducGetDeletable 
;                       _ducCallBack 
;                       _ducDeleteCurrent 
;                       _ducDeleteAll 
;                       _ducPopCurrent 
;                       _ducAbort 
;                       _ducMadeVisible 
;                       _ducResetVisible 
;                       _ducResetWindow 
;                      
;
;
;;
;; _ducMain
;;
;; Allegro command for deleting unconnected shapes.  Function initiates global
;; variables, opens the form, and builds the initial list of shapes eligible
;; for deletion.  Form opened is a blocking function, and returns control to
;; this function only upon its termination
;; 
;; In addition to this file, you will need to download the .form file
;; which has also been downloaded into shareware.
;;
;; After installation into your local skill environment directory, type
;; "del unconn" to execute. 
;;
 
axlCmdRegister( "del unconn" '_ducMain)
 
 
(defun _ducMain ()
    (let (layer_name 
          (default_layer 
              (parseString (axlGetParam "paramDisplay")->activeLayer "/"))
         )
 
        ; make a list of eligible shapes
        (setq _ducEligibleShapes nil)
 
        ; indicate whether or not current shape's
        ; layer is visible
        (setq _ducWasInvisible nil)
 
        ; remember the current window so we can return to it upon completion
        ; of the command
        (setq _ducWindow (axlWindowBoxGet))
 
        ; open the form
        (axlFormCreate '_ducForm "del_unconn.form" '("south" "outer")
                       '_ducCallBack nil)
 
        ; build the available subclass popup
        (axlFormBuildPopup _ducForm "duc_select_layer" 
                  (cons "All" (axlGetParam "paramLayerGroup:ETCH")->groupMembers))
 
        ; if the default class is etch, use the default subclass,
        ; otherwise, use the first ETCH subclass
        (cond ((eq (strcmp (car default_layer) "ETCH") 0)
                  (setq layer_name (cadr default_layer))
              ) ; class eq ETCH
              (t (setq layer_name 
                       (car (axlGetParam "paramLayerGroup:ETCH")->groupMembers))
              ) ; else
        ) ; cond default layer
 
        ; set the default layer name into the form
        (axlFormSetField _ducForm "duc_select_layer" layer_name)
 
        ; find all shapes, and display the first one
        (_ducGetDeletable)
 
        ; and display the form
        (axlFormDisplay _ducForm)
 
    ) ; let
) ; _ducMain
 
/*
#ifdef DOC_C
 NAME
    expand_window - Function to expand a window by an integral scaling factor
 
 SYNOPSIS
    expand_window(
        l_window
        x_factor
    )
    ==> l_window
 
 FUNCTION
    The expand_window function expands the minimum and maximum points away
    from the center of the window.  The factor provided indicates how much
    larger than the original window the final window should be.  This function
    does not provide for fractional or negative expansion.
 
 NEEDS
    l_window - list containing the min point and max point of the window.  Function
               does no checking for order, assumes that min is the first point 
               pair in the list and that the max is the second point. i.e.:
               ((minx miny)(maxx maxy)) 
    x_factor - positive integral expansion factor.
 
 RETURNS
    expand_window - list containing expanded window points
 
 NOTE
    final window is not guaranteed to be within any limits
 
 EXAMPLE
#endif
 */
;;
;; expand_window
;;
;; factor the size of a window
;;
;; basic function for all points is (F + 1)/2 * (point) - (F-1)/2 *opposite point
;; where F is the integer scaling factor
;;
(defun expand_window (window F)
    (let ((x1 (caar window)) ; first item in first list
          (y1 (cadar window)); second item in first list
          (x2 (caadr window)) ; first item in second list
          (y2 (cadadr window)); second item in second list
          f1 f2 f3 f4)
        (setq f1 (quotient (difference (times (plus F 1) x1)
                                       (times (difference F 1) x2)) 2))
        (setq f2 (quotient (difference (times (plus F 1) y1)
                                       (times (difference F 1) y2)) 2))
        (setq f3 (quotient (difference (times (plus F 1) x2)
                                       (times (difference F 1) x1)) 2))
        (setq f4 (quotient (difference (times (plus F 1) y2)
                                       (times (difference F 1) y1)) 2))
        (setq window (list (list f1 f2) (list f3 f4)))
        window
    ) ; let
) ; expand_window
 
;;
;; _ducPresentShape
;;
;; support function for _ducMain - takes a provided shape, 
;; windows in on it, and highlights it.  Function also sets net and layer
;; fields in the form
;;
(defun _ducPresentShape (shape) 
    (let (window layer_words net_name)
 
        ; make layer visible if it is not
        (setq _ducWasInvisible 
            (cons (_ducMadeVisible shape->layer) _ducWasInvisible))
 
        ; given shape extents, window in
        (setq window shape->bBox)
        (setq window (expand_window window 3))
 
        ; window in on it
        (axlWindowBoxSet window)
 
        ; highlight the shape
        (axlHighlightObject shape)
 
        ; set the fields in the form for net and layer
        (setq layer_words (parseString shape->layer "/"))
        (cond ((eq shape->net->name "")
                  (setq net_name "<none>"))
              (t (setq net_name shape->net->name))
        ) ; cond
 
        ; fill in the required fields in the form
        (axlFormSetField _ducForm "duc_layer" (cadr layer_words))
        (axlFormSetField _ducForm "duc_net" net_name)
        (axlFormSetInfo _ducForm "duc_count" 
            (sprintf nil "%d" (length _ducEligibleShapes)))
 
    ) ; let
) ; _ducPresentShape
 
;;
;; _ducGetDeletable
;;
;; function to process all unconnected shapes on current ETCH layer, present
;; them to the user, and determine if the user wants to delete said shape
;;
(defun _ducGetDeletable ()
    (let ((shapes (_ducFindAllShapes))
          (layer_wo_etch (axlFormGetField _ducForm "duc_select_layer"))
          layer_words
          )
 
        ; reset visibility in case previously viewed layer was invisible
        (_ducResetVisible)
 
        ; reset the available list
        (setq _ducEligibleShapes nil)
 
        ; walk all the shapes on the layout
        (foreach shape shapes
 
            ; retrieve the subclass portion of the layer string for the shape
            (setq layer_words (parseString shape->layer "/"))
 
            ; insure that the shape is an ETCH shape
            (cond ((eq (strcmp "ETCH" (car layer_words)) 0)
 
                      ; verify that the shape is not connected
                      (cond ((eq shape->connect nil)
 
                                ; accept all etch shapes if wildcarded
                                (cond ((eq (strcmp layer_wo_etch "All") 0)
                                          (setq _ducEligibleShapes 
                                                   (cons shape _ducEligibleShapes))
                                      ) ; eq "*"
 
                                      ; accept specific layer match if no wildcard
                                      ((eq (strcmp 
                                            layer_wo_etch (cadr layer_words)) 0)
                                          (setq _ducEligibleShapes 
                                                   (cons shape _ducEligibleShapes))
                                      ) ; eq strmp
                                ) ; cond layer name
                            ) ; cond connect nil
                       ) ; cond connect
                  ) ; eq ETCH
            ) ; cond etch
        ) ; foreach shape
 
        ; if any eligible shapes exist
        (cond (_ducEligibleShapes
 
                  ; show the first shape to the user
                  (_ducPresentShape (car _ducEligibleShapes))
                  (axlFlushDisplay)
 
              ) ; cond _ducEligibleShapes
 
              ; if not eligible shapes, then say so
              (t (axlMsgPut (list "No eligible shapes on layer %s." 2) 
                            layer_wo_etch)
                 (axlFormSetInfo _ducForm "duc_count" "0")
                 (axlFormSetField _ducForm "duc_layer" "")
                 (axlFormSetField _ducForm "duc_net" "")
                 (_ducResetWindow)
              ) ; else
        ) ; cond
    ) ; let
    t
) ; _ducGetDeletable
 
;;
;; _ducCallBack
;;
;; callback for delete unconnected shapes confirmation form
;;
(defun _ducCallBack (form)
 
    ; determine which button has been pushed and act accordingly
    (cond
        ((equal (get form 'curField) "duc_select_layer") 
            (_ducGetDeletable)) 
        ((equal (get form 'curField) "duc_yes") 
            (when _ducEligibleShapes (_ducDeleteCurrent)))
        ((equal (get form 'curField) "duc_no")  
            (when _ducEligibleShapes (_ducPopCurrent)))
        ((equal (get form 'curField) "duc_all") 
            (when _ducEligibleShapes (_ducDeleteAll)))
        ((equal (get form 'curField) "done")(_ducAbort))
    ) ; cond
 
    ; now, refresh the display so all this stuff REALLY happens
    (axlFlushDisplay)
 
) ; _ducCallBack
 
;;
;; _ducDeleteCurrent
;;
;; function to delete the current head of the eligible shape list, and to 
;; present the next one in the list for deletion
;;
(defun _ducDeleteCurrent ()
    (let ((current (car _ducEligibleShapes)))
        (setq _ducEligibleShapes (cdr _ducEligibleShapes))
 
        ; tell the user which shape was deleted
        (axlMsgPut (list 
                    "Unconnected Shape at (%g, %g), layer %s, net \"%s\" deleted."
                    0)
                   (caar (car current->segments)->startEnd)
                   (cadar (car current->segments)->startEnd)
                   current->layer current->net->name)
 
        ; delete it 
        (axlDeleteObject current)
 
        ; if the shape's layer was invisible before we presented it, blank it now
        (_ducResetVisible)
 
        ; if there are any remaining shapes, present the next one.  Otherwise,
        ; reset the deletable list
        (cond ((car _ducEligibleShapes)
                  (_ducPresentShape (car _ducEligibleShapes)))
                 (t (_ducGetDeletable))
        ) ; cond
    ) ; let
) ; _ducDeleteCurrent
 
;;
;; _ducDeleteAll
;;
;; function to delete all shapes in current list.  This does not mean ALL shapes,
;; rather all that remain in the list.  All shapes that have been Popped off of ;; the list will not be deleted.  Function highlights all shapes remaining, 
;; makes all layers visible that are invisible (for each shape), then windows
;; out far enough to display them all
;;
(defun _ducDeleteAll ()
 
    ; retrieve the extents of ALL
    (axlWindowBoxSet (expand_window (emiGetExtents _ducEligibleShapes) 2))
 
    ; set all invisible layers visible
    (foreach current _ducEligibleShapes
        (setq _ducWasInvisible 
            (cons (_ducMadeVisible current->layer) _ducWasInvisible))
    ) ; foreach
 
    ; highlight all
    (foreach current _ducEligibleShapes
        (axlHighlightObject current)
    ) ; foreach
 
    ; verify
    (cond ((axlUIYesNo 
              (sprintf nil 
                  "Delete these %d remaining unconnected shapes on current layer?" 
                  (length _ducEligibleShapes)))
 
        (foreach current _ducEligibleShapes
            ; tell the user which shape was deleted
            (axlMsgPut (list 
                        "Unconnected Shape at (%g, %g), layer %s, net \"%s\" deleted."
                        0)
                       (caar (car current->segments)->startEnd)
                       (cadar (car current->segments)->startEnd)
                       current->layer current->net->name)
 
            ; delete it 
            (axlDeleteObject current)
        ) ; foreach
 
        ; re-fetch remaining
        (_ducGetDeletable)
 
        ) ; cond Yes
 
        ; otherwise, if Delete All rejected, return to the first one in the list
        (t 
            ; de-highlight all
            (foreach current _ducEligibleShapes
                (axlDehighlightObject current)
            )
 
            ; reset visibility
            (_ducResetVisible)
 
            ; and present the first one in the list again
            (_ducPresentShape (car _ducEligibleShapes))
        ) ; cond No
 
    ) ; cond YesNo
) ; _ducDeleteAll
 
;;
;; _ducPopCurrent
;;
;; function to pop the current element off of the top of the list without 
;; deleting it
;;
(defun _ducPopCurrent ()
    ; dehighlight it
    (axlDehighlightObject (car _ducEligibleShapes))
 
    ; if the shape's layer was invisible before we presented it, blank it now 
    (_ducResetVisible)
 
    ; skip to the next object in the list
    (setq _ducEligibleShapes (cdr _ducEligibleShapes))
 
    ; if there are any remaining, present the next one in the list for deletion.    ; Otherwise, abort
    (cond ((car _ducEligibleShapes)
              (_ducPresentShape (car _ducEligibleShapes)))
            (t (_ducGetDeletable))
    ) ; cond
) ; _ducPopCurrent
 
;;
;; _ducAbort
;;
;; function to abort the deletion function.  Function brings down the open form, 
;; and restores invisible layers if they were exposed
;;
(defun _ducAbort ()
    ; if there is an active, highlighted shape, unhighlight it
    (when (car _ducEligibleShapes)
        (axlDehighlightObject (car _ducEligibleShapes))
    ) ; when
 
    ; close the form
    (axlFormClose _ducForm)
 
    ; if the shape's layer was invisible, restore it to invisible
    (_ducResetVisible)
    (axlFlushDisplay)
 
    ; finally, restore original window
    (_ducResetWindow)
) ; _ducAbort
 
;;
;; _ducMadeVisible
;;
;; function to determine if a given shapes's layer is invisible.  If so, function
;; makes that layer visible, and remembers that it was invisible so that another;; function can restore it to invisible later
;;
(defun _ducMadeVisible (layer)
    (let ((layer_words (parseString layer "/"))
          (madevisible nil)
          layerp
         )
 
        ; insure that the layer is visible
        (setq layerp (axlGetParam 
                     (strcat "paramLayerGroup:ETCH/paramLayer:" 
                     (cadr layer_words))))
 
        ; if the layer is invisible, make it visible
        (unless layerp->visible
            (layerp->visible = t)
            (axlSetParam layerp)
            (setq madevisible layerp)
        ) ; unless
 
        ; return layer if invisible
        madevisible
 
    ) ; let
) ; _ducMadeVisible
 
;; 
;; _ducResetVisible
;; 
;; function to restore the invisibility of the active shape's layer.  If that
;; layer was invisible when we started, function will restore it to invisible.
;;
(defun _ducResetVisible ()
 
    (foreach layer _ducWasInvisible
        (when layer
            ; make it invisible
            (layer->visible = nil)
            (axlFlushDisplay)
 
            ; set it in the database
            (axlSetParam layer)
        ) ; when
    ) ; foreach
 
    (setq _ducWasInvisible nil)
 
) ; _ducResetVisible
 
;;
;; _ducResetWindow
;;
;; resets the window to the original window when the command began
;;
(defun _ducResetWindow ()
    (axlWindowBoxSet _ducWindow)
) ; _ducResetWindow 
 
;;
;; _ducFindAllShapes
;;
;; finds all shapes 
;;
(defun _ducFindAllShapes ()
    (let (selSet)
 
        ; clear the selection set
        (axlClearSelSet)
 
        ; establish the find filter to find all shapes
        (axlSetFindFilter ?enabled (list "noall" "SHAPES" "invisible")
                          ?onButtons "all")
 
        ; add all shapes in the database to the selection set
        (axlAddSelectAll)
 
        ; retrieve the desired shapes
        (setq selSet (axlGetSelSet))
 
        ; clear those highlighted objects
        (axlClearSelSet)
 
        ; return the selected shapes
        selSet
 
    ) ; let
) ; _ducFindAllShapes


