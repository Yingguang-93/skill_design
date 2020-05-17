;***********************************************
;
;      Report pins with NO_DRC Property
;
;
;THIS PROGRAM IS PROVIDED "AS IS", AND IS NOT SUPPORTED BY
;CADENCE DESIGN SYSTEMS.
;
;
;This program will examine component pins and highlight
;those pins that have the NO_DRC property. 
;When completed it will display the contents of the log file
;that lists all of the pins found.
;
;
; To use this program load this file no_drc.il and from
;the Allegro/APD command line use the command  no_drc
;
;
;Author: Ron Guthrie
;	Principal Support AE
;	Cadence Design Systems
;Date: August 2002.
;
;Version 1.0 - Initial release.


defun(no_drc ()
axlSetFindFilter(?enabled '(noall pins) ?onButtons '(noall pins))
l_no_drc=list()
board_name = axlGetDrawingName()
rep_time = getCurrentTime()
log_file = "no_drc_prop.log"
axlClearSelSet()
axlAddSelectAll()
l_pins=axlGetSelSet()
axlDehighlightObject(l_pins)
axlClearSelSet()
foreach( pin l_pins		
	if(pin->prop!=nil	;check to see if there are properties
	then
		l_props=pin->prop->??
			foreach( prop l_props	;check properties for NO_DRC
				sprintf(s_prop "%s", prop)	;convert symbols to strings
				when( s_prop == "NO_DRC"	;<--rbg. Something is messed up here
					l_no_drc=cons(pin l_no_drc)	;add pin to the list
				);endwhen s_prop
			);endforeach prop
	);endif pin
);endforeach pin
axlHighlightObject(l_no_drc)

outport = outfile(log_file)	;open a log file.
fprintf(outport "|------------------------------------------------------------------------------\n")
fprintf(outport "|                        NO_DRC PIN PROPERTY REPORT\n")
fprintf(outport "|------------------------------------------------------------------------------\n")
fprintf(outport "|  Design: %s\n", board_name)
fprintf(outport "|  Time:   %s\n", rep_time)
fprintf(outport "|------------------------------------------------------------------------------\n\n")

if( l_no_drc != nil then
	foreach( pin l_no_drc
		pin_num=pin->number
		ref_des=pin->parent->refdes
		fprintf(outport "%s.%s\n", ref_des pin_num)
	);endforeach pin
else
	fprintf(outport "No pins found with the NO_DRC property.")
);endif l_no_drc
close(outport)
outport=nil
axlUIViewFileCreate( log_file "Pins with NO_DRC property" nil)
);enddef
axlCmdRegister( "no_drc" 'no_drc)