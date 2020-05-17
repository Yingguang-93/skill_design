; File Name: save_shape_drc.il
; Revision: 0				12/26/1996
; Distributed by Barbara Seeger blm@cadence.com for 11.x Allegro 
; 
;       If autovoid causes DRC's, this program will help to view the 
;	drc locations during shape cleanup. A method which provides the 
;	best success for drc cleanup after autovoid is: 
;
;	1. "set av_notrim" on the allegro command 
;	2. Execute this skill program (see instructions below).
;	3. Edit the shape and void ELEMENT by pick or by group, selecting
;	   all pins, vias, and clines which appear in the center area of 
;	   the circles created with this program.
;	4. Fill the shape, and re-execute step 2 and 3 if all drc's have
;          not been cleaned up.
;	5. "unset av_notrim" on the allegro command line.
; 
;	Note: Setting av_notrim suppresses smoothing during autovoid, therefore 
;	      it should not be used as a default setting. Smoothing is needed 
;             to clean up problem spots in shapes.
;       
; Instructions for executing this skill program
;	1. Add and entry for this file into your allegro.ilinit file
;		or
;		type: Skill load "save_shape_drc.il"
;		(Don't forget what directory the skill file is in.)
;	2. Set you Ministatus so that the ETCH CLASS/SUBCLASS displays
;		the layer that the shape you are editing is defined.
;	3. In the Allegro command window type
;		sv_drc
;	4. A new layer MANUFACTURING/SHAPE DRC is created and displayed.
;		A circle, the same size as the DRC figure will be placed
;		over the Shape DRCs for that layer only.
;	5. When done with shape editing, re run this command to get a message 
;               that no shape drcs exist for that layer.
;
;
	
axlCmdRegister( "sv_drc" 'PSDR_start)

;
;============================================================
; This is the function that gets everything rolling.
;============================================================
defun( PSDR_start ()
	unless( axlIsLayer( "MANUFACTURING/SHAPE DRC")
		axlMsgPut("Creating Layer MANUFACTURING/SHAPE DRC")
		axlLayerCreateNonConductor("MANUFACTURING/SHAPE DRC")
	)
	unless( axlIsVisibleLayer( "MANUFACTURING/SHAPE DRC")
		axlMsgPut("Displaying Layer MANUFACTURING/SHAPE DRC")
		axlVisibleLayer( "MANUFACTURING/SHAPE DRC" t )
        )
	axlMsgPut("Removing Old Shape DRC Holders") 
        drc_arc_list = PSDR_SelDrcArc()	
	if( drc_arc_list then
        	axlDeleteObject( drc_arc_list )	
        )
	drc_list = PSDR_SelectDRCAll()
        PSDR_GetDRCs(drc_list)
	axlMsgPut("Done")
);end-defun

;============================================================
;This function sets the association between the ETCH subclass
; in the ministatus with the DRC ERROR CLASS subclass.
;============================================================
defun( PSDR_GetLayerName ()
prog( ()
let( (alayer)
	alayer = nil
	alayer = strcat( "DRC ERROR CLASS/"  nthelem( 2 parseString( axlGetActiveLayer() "/")) )
	return(alayer)
)));end-defun

;============================================================
; This function checks all of the "found" drcs and verifies
; that each drc is on the active layer in the mini-status,
; and that the drc is a shape drc.
;============================================================
defun( PSDR_GetDRCs (drc_list)
let( (alyr drc_count)	
	drc_count = 0
	alyr = PSDR_GetLayerName()
	foreach( drc drc_list
		when( drc->layer == alyr
		    when( nindex( drc->name "Shape")
			PSDR_DrawError( drc->xy drc->bBox)
			drc_count++
		    )
		)
        )
	if( drc_count < 1 then
		axlMsgPut("No Shape DRC's for %s were Found." axlGetActiveLayer())
        )
));end-defun

;============================================================
;this function draws an arc on the MANUFACTURING/SHAPE DRC
;  layer.
;============================================================

defun( PSDR_DrawError ( xyloc figsize)
let( ( xyr )	
		size = (caadr(figsize)-caar(figsize))/2
	        xyr = nil
		xyr= cons(size xyr)
		xyr= cons(xyloc xyr)	
		axlDBCreateCircle( xyr 0.0 "MANUFACTURING/SHAPE DRC" nil)
));end-defun

;===================================================================
;       This function creates a list ofdbids for all DRC
;       contained within the design and highlights them.
;===================================================================
defun( PSDR_SelectDRCAll ()
prog( ()
let( ( sel_drc_lst )
        axlClearSelSet()
        axlSetFindFilter(
                ?enabled '("NOALL" "DRCS")
                ?onButtons '("DRCS")
        )
        sel_drc_lst = axlGetSelSet(axlAddSelectAll())
        return( sel_drc_lst )
)));end - defun
;============================================================
;This Function returns a list of dbids for all of the arcs 
;   on the "Manufactuing/shape drc" layer.
;============================================================
defun( PSDR_SelDrcArc ()
prog( ()
let( ( sel_arc_lst arc_lst)
	sel_arc_lst = nil
	arc_lst = nil
        axlClearSelSet()
        axlSetFindFilter(
                ?enabled '("NOALL" "LINESEGS")
                ?onButtons '("LINESEGS")
        )
        sel_lst = axlGetSelSet(axlAddSelectAll())
	foreach( id sel_lst
		if( id->objType == "arc" arc_lst = cons( id arc_lst))
	)

	foreach( id arc_lst
		if(id->layer == "MANUFACTURING/SHAPE DRC" sel_arc_lst = cons( id sel_arc_lst))
	)
        return( sel_arc_lst )
)));end - defun
