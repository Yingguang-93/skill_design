/*******************************************************************
* DISCLAIMER: The following code is provided for Cadence customers *
* to use at their own risk. The code may require modification to   *
* satisfy the requirements of any user. The code and any           *
* modifications to the code may not be compatible with current or  *
* future versions of Cadence products.                             *
* THE CODE IS PROVIDED "AS IS" AND WITH NO WARRANTIES, INCLUDING   *
* WITHOUT LIMITATION ANY EXPRESS WARRANTIES OR IMPLIED WARRANTIES  *
* OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR USE.              *
*******************************************************************/
; File: hps.il
;
; SourceLink Solution Reference: None
;
; Note: This code is not supported !
;	This SKILL code has had limited testing and performs little
;	or no error checking.
;
;
;Author: Ron Guthrie
;	Cadence Design Systems
;	Version 1.0
;	Date: Feb. 2008
;
; Usage: Load this file hps.il
; 			On the Allegro command line enter
;				hps PADSTACK
;
; 			Where PADSTACK is the name of the padstack you wish to
; 			highlight.
;
; 			To dehilight the padstack issue the command
;				dhps PADSTACK
;
axlCmdRegister( "hps" `RBG_hilite_padstack)
axlCmdRegister( "dhps" `RBG_dehilite_padstack)

defun(RBG_hilite_padstack ( ps )	; hilite function

axlClearSelSet()
; Padstack names in the database are all uppercase.
ps=upperCase(ps)	;convert padstack name to uppercase.

axlSetFindFilter(?enabled list("noall" "pins" "vias") ?onButtons list("noall" "pins" "vias" ))
axlAddSelectAll()
obj_list = axlGetSelSet()
axlClearSelSet()	;clear the selection set to remove the hilight

foreach(obj_db obj_list
;go through each pin and via that is selected.
;if the padstack name matches what you are looking for then highlight it.
	if(obj_db->name==ps then
		axlHighlightObject(obj_db)
	);endif
); end foreach
axlShell("redraw")

);end defun

defun(RBG_dehilite_padstack ( ps )	; dehilite function

axlClearSelSet()
; Padstack names in the database are all uppercase.
ps=upperCase(ps)	;convert padstack name to uppercase.

axlSetFindFilter(?enabled list("noall" "pins" "vias") ?onButtons list("noall" "pins" "vias" ))
axlAddSelectAll()
obj_list = axlGetSelSet()
axlClearSelSet()

foreach(obj_db obj_list
	if(obj_db->name==ps then
		axlDehighlightObject(obj_db)
	);endif
); end foreach

axlShell("redraw")

);end defun
