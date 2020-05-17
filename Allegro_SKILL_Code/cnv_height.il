;		cnv_height.il
;
;	The purpose of this file is to convert the value of the height text
;	in mils to match the database units.
;
;	Several customers have created symbols in mm or other units and the
;	height is set in mils. When the symbol is upreved to Allegro 14.x the
;	text is assumed to be in the units of the drawing and this causes the
;	height properties to be incorrect in version 14.
;
; Usage: On the Allegro command line enter 
;			cnv_ht
;
; Current known limitations.
;	1. Limited error checking.
;	2. No check to see if the process has already been run.
;	3. Assumes that the units for the height text is mils.
;
;##########################################################
;
;	This program is provided as is and it is not supported 
;	by Cadence Design Systems.
;
;	Author:
;	Ron Guthrie 
;	Principal Support AE
;	PCB Systems Division
;
;	Version 1.0 January 2002
;	Version 1.1 October 2002 
;			R. Guthrie - Updated error checking to try 3 times before
;			failing to update text. 
;
;##########################################################
axlCmdRegister( "cnv_ht" `convert_height)

defun(convert_height ( )	; main function
;	Initialization
;
h_units = "mils"
t_justify_c = "center"	;Set alternative justifications.
t_justify_r = "right"

d_units = axlDBGetDesignUnits()
units = car(d_units)
accuracy = cadr(d_units)
l_visible = axlVisibleGet()	; store current visibility
axlVisibleDesign(nil)		; turn off all layers

; Open a log file 
symbol_name = axlCurrentDesign()
log_file = strcat(symbol_name "_log.txt")
out_log = outfile(log_file)

; Turn visibility on for only PLACE_BOUND
axlVisibleLayer("PACKAGE GEOMETRY/PLACE_BOUND_TOP" t)  
axlVisibleLayer("PACKAGE GEOMETRY/PLACE_BOUND_BOTTOM" t)

axlSetFindFilter(?enabled list("noall" "text") ?onButtons list("noall" "text" ))

axlClearSelSet()
axlAddSelectAll()				; select all of the text within the drawing
l_text=axlGetSelSet()			; get the selected text
axlClearSelSet()
	foreach( text l_text
	fprintf(out_log "Processing symbol %s.\n" symbol_name)
	;retrieve all text information
		t_block = text->textBlock
		t_rotate = text->rotation
		t_mirror = text->isMirrored
		t_justify = text->justify
		t_location = text->xy
		t_value = text->text
		t_layer = text->layer
		t_parent = text->parent
		height_text = make_axlTextOrientation(
						?textBlock t_block 
						?rotation t_rotate 
						?mirrored t_mirror 
						?justify t_justify
						)
		height_text_c = make_axlTextOrientation(
						?textBlock t_block 
						?rotation t_rotate 
						?mirrored t_mirror 
						?justify t_justify_c
						)
		height_text_r = make_axlTextOrientation(
						?textBlock t_block 
						?rotation t_rotate 
						?mirrored t_mirror 
						?justify t_justify_r
						)

		;convert the value of the text
		value=evalstring(t_value)	;Convert the string to a number

		;Conversion is based on assumption that the text is in mils
		case( units
			("inches"
			value=value*0.001
			printf("Units = %s\n" units)
			printf("Value = %f\n" value)
			)
			("mils"
			value=value*1.0
			printf("Units = %s\n" units)
			printf("Value = %f\n" value)
			)
			("millimeters"
			value=value*0.0254
			printf("Units = %s\n" units)
			printf("Value = %f\n" value)
			)
			("centimeters"
			value=value*0.00254
			printf("Units = %s\n" units)
			printf("Value = %f\n" value)
			)
			("microns"
			value=value*25.4
			printf("Units = %s\n" units)
			printf("Value = %f\n" value)
			)
			(t
			printf("Error in units conversion.\n")
			)
		);end case
		old_value = t_value		;Save the original text
		sprintf(t_value "%L" value)	;Convert back to string
		;delete the text and add the new text in its place
		if( axlDeleteObject( text ) then
			fprintf(out_log "Text deleted, %s.\n" old_value)
		else
			fprintf(out_log "Failed to delete text, %s.\n" old_value)
		); endif
		
		;Add text. If it fails, try other text justifications to see if it fits.
		
		if( axlDBCreateText( t_value t_location height_text t_layer t_parent ) then
		  fprintf(out_log "Added text %s.\n" t_value)
		else
		  if( axlDBCreateText( t_value t_location height_text_c t_layer t_parent ) then
		    fprintf(out_log "Added text %s.\n" t_value)
		  else
		    if( axlDBCreateText( t_value t_location height_text_r t_layer t_parent ) then
		      fprintf(out_log "Added text %s.\n" t_value)
		    else
		      fprintf(out_log "Failed to add text, %s.\n" t_value)
		    ); endif text right
		  ); endif text center
		); endif text default
	);end foreach text
axlVisibleSet( l_visible )
close(out_log)			;close the log file
axlCompileSymbol()		;create the symbol .psm file
axlSaveDesign()			;save the drawing .dra file

);end-defun
