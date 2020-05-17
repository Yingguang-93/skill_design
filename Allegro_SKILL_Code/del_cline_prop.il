;
;	Tested on NT 13.6
;
;
;
; The following Skill routine will remove invisible
; properties from CLINES and VIAS.
; The intent of this Skill program is to provide
; users with the ability of deleting the invisible
; properties that SPECCTRA/SPIF puts on. This will allow the moving
; of symbols without the attached clines/vias once the
; design is returned from SPECCTRA if the fanouts were originally
; put in during an Allegro session.
;  
; To install: Copy del_cline_prop.il to any directory defined
;               within your setSkillPath in your 
;               allegro.ilinit. Add a "load("del_cline_prop.il")"
;               statement to your allegro.ilinit.
;
; To execute: Within the Allegro editor type "dprop" or 
;               "del cline props". This routine should
;               only take seconds to complete.
;               
; Deficiencies: This routine does not allow for Window or
;               Group selection. 
;
; WARRANTYS: NONE. THIS PROGRAM WAS WRITTEN AS "SHAREWARE" AND IS AVAILABLE AS IS 
;              AND MAY NOT WORK AS ADVERTISED IN ALL ENVIRONMENTS. THERE IS NO
;              SUPPORT FOR THIS PROGRAM.
;
; Delete invisible cline/via properties.
;
axlCmdRegister( "dprop" 'delete_cline_prop)
axlCmdRegister( "del cline props" 'delete_cline_prop)				

(defun delete_cline_prop ()
  ;; Set the Find Filter to Select only clines
  (axlSetFindFilter ?enabled (list "CLINES" "VIAS")
                    ?onButtons  (list "CLINES" "VIAS"))

  (axlClearSelSet)	;clear any selected objects
  (axlAddSelectAll)	;select all clines and vias

  (setq clineSet (axlGetSelSet))
  (axlDBDeleteProp clineSet "SYMBOL_ETCH")	;Remove the property
  (axlClearSelSet)				;unselect everything
)