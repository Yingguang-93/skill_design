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
; File: dh_dummy_net.il
;
; SourceLink Solution Reference: None
;
; Usage: Load this file dh_dummy_net.il
;  Call the function _dehilite_dummy_net from your SKILL code. It will
;		remove the highlight from any dummy net in the design.
;
; Note: This code is not supported !
;	This SKILL code has had limited testing and performs
;	no error checking.
;
;
;Author: Ron Guthrie
;	Cadence Design Systems
;	Version 1.0
;	Date: Oct. 10,2007
;
defun( _dehilite_dummy_net ()
let(list(l_dnets dnet)
	axlSetFindFilter(?enabled '(noall nets) ?onButtons '(nets))
	axlClearSelSet()
	axlSelectByName("NET" "Dummy")
	l_dnets = axlGetSelSet()
	axlClearSelSet()
	foreach(dnet l_dnets
			axlDehighlightObject(dnet t)
	);end foreach
);end let
);end defun