;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; file.del_fp_prop.il
;
; Author -- Rik Lee
; Cadence Design Systems
;
; Function --
; 
; Copyright, 2005, Cadence Design Systems, Inc.
; No part of this file may be reproduced, stored in a retrieval system,
; or transmitted in any form or by any means --- electronic, mechanical,
; photocopying, recording, or otherwise --- without prior written permission
; of Cadence Design Systems, Inc.
;
; WARRANTY:
; NONE. NONE. NONE.
; Use all material in this code at your own risk.  Cadence Design Systems 
; makes no claims about any material in this archive.  These examples may
; not function or may only function in specific instances.
;
; RESTRICTIONS:
; All software contained within this archive is in the public domain or
; the author has given us permission for redistribution.  Some packages
; have explicit copyrights and notices concerning their redistribution.
; Please carefully read all documentation with any package on this tape.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	Tested on WinXP using the 15.2.51CX and v15-5-78A release
;
;
; The following Skill routine will remove invisible properties FP_*.
;
; The intent of this Skill program is to provide users with the ability of 
; deleting the invisible properties that the MBS translator applies. 
;  
; To install: Copy del_fp_prop.il to any directory defined
;             within your setSkillPath in your 
;             allegro.ilinit. Add a "load("del_fp_prop.il")"
;             statement to your allegro.ilinit.
;
; To execute: Within the Allegro symbol editor type "dfp_prop" or 
;             "del fp props". This routine should
;             only take seconds to complete.
;               
; Deficiencies: This routine does not allow for Window or
;               Group selection. 
;
;
; Delete invisible FP_* properties.
;
axlCmdRegister( "dfp_prop" 'delete_fp_notes)
axlCmdRegister( "del fp props" 'delete_fp_notes)				

(defun delete_fp_notes ()

  (axlClearSelSet)	;clear any selected objects

(setq clineSet (axlDBGetDesign))
  (axlDBDeleteProp clineSet "FP_NOTES_TEXT_BLOCK")	;Remove the property
  (axlDBDeleteProp clineSet "FP_REFDES_TEXT_BLOCK")	;Remove the property
  (axlDBDeleteProp clineSet "FP_ROOM_NAME_TEXT_BLOCK")	;Remove the property
)