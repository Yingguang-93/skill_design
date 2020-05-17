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
; File: smd_pad_count.il
;
; Usage: Load this file smd_pad_count.il
;  Issue the command smd_count on the Allegro command line.
;  This code is a simple example of counting objects in a design.
;
; Note:This file is NOT SUPPORTED by Cadence.
;
;
;Author: Ron Guthrie
;	Cadence Design Systems
; Version 1.0
; Date: June 20,20065
;
axlCmdRegister("smd_count" '_smd_pad_count )
defun( _smd_pad_count ()
	axlSetFindFilter(?enabled '(invisible noall pins) ?onButtons '(pins))
	axlClearSelSet()
	axlAddSelectAll()
	l_pins=axlGetSelSet()
	axlClearSelSet()
	smd_top_count=0
	smd_bot_count=0
	foreach(pin l_pins
		if(!(pin->isThrough) then
			case(car(pin->startEnd)
				("ETCH/TOP"
					smd_top_count++
				)
				("ETCH/BOTTOM"
					smd_bot_count++
				)
				(t
					printf("Unexpected value of the startEnd attribute for %s\n" pin->name)
				)
			);case
		);if
	);foreach
	printf("There are %n SMD pins on the top of the board and %n on the bottom.\n"
				smd_top_count smd_bot_count)
)