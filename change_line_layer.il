/****************************************************/
/*             Title : Change Line Layer            */
/*   Execute Command : change_line_layer            */
/*            Author : VivienLuo                    */
/*     Creation Date : 2014-03-23                   */
/*            Update :                              */
/*           Version : 1.0                          */
/*           Website : www.allegro-skill.com        */
/*           E-maial : admin@allegro-skill.com      */
/****************************************************/

axlCmdRegister("change_line_layer" 'Change_Line_Layer_Main ?cmdType "interactive" ?doneCmd 'CLLDone ?cancelCmd 'CLLCancel)
;axlSetFunckey("cll" "change_line_layer")
defun( Change_Line_Layer_Main ()
let((notdone form CLL_popup selLines)
	CLL_popup = axlUIPopupDefine(nil (list
				(list "Done" 'CLLDone )
				(list "Cancel" 'CLLCancel ))
				)
	axlUIPopupSet(CLL_popup)
	notdone = t
	CLLFormCreate()
	axlControlRaise('options)
	form = axlMiniStatusLoad((gensym) "./CLLForm.form" nil t)
	axlFormDisplay(form)	
	deleteFile("./CLLForm.form")
	axlFormColorize(form "cll_up" 'text 'red)
	axlFormColorize(form "cll_sel" 'text 'red)
	axlFormColorize(form "cll_name" 'text 'blue)
	axlFormColorize(form "cll_author" 'text 'blue)
	axlFormColorize(form "cll_date" 'text 'blue)
	axlFormColorize(form "cll_web" 'text 'blue)
	axlSetActiveLayer("BOARD GEOMETRY/SILKSCREEN_TOP")
	while(notdone
		selLines = nil
		axlSetFindFilter( ?enabled list("noall" "lines") ?onButtons list("noall" "lines"))
		axlClearSelSet()
		axlSelect()
		selLines = axlGetSelSet()
		when(selLines
		layer = axlGetActiveLayer()
		foreach(line selLines
			Line_Change_Layer(line layer)
		);end foreach
		);end when
	);end while
);end let
);end defun
defun( Line_Change_Layer (lineDbid lineLayer)
	;endPoint = cadr(nthelem(lineDbid->nSegs lineDbid->segments)->startEnd)
	;startPoint = car(car(lineDbid->segments)->startEnd)
	linePath = axlPathStart(list(car(car(lineDbid->segments)->startEnd)))
	foreach(temp lineDbid->segments
		case(temp->objType
			("line"
				axlPathLine(linePath temp->width cadr(temp->startEnd))
				)
			("arc"
				axlPathArcCenter(linePath temp->width cadr(temp->startEnd) temp->isClockwise temp->xy)
				)
			(t
				printf("Path Type is Unknown!\n")
				)
		);end case			
	)
	axlDeleteObject(lineDbid)
	axlDBCreatePath(linePath lineLayer 'line)
	;axlDehighlightObject(axlChangeWidth(car(axlDBCreatePath(linePath a_Layer 'line)) abs(a_Expands)))
);end procedure
defun(CLLFormCreate ()
	Design_DECIMAL = cadr(axlDBGetDesignUnits())
	CLLFormPort = outfile("./CLLForm.form")	
	fprintf(CLLFormPort "FILE_TYPE=FORM_DEFN VERSION=2\n")
	fprintf(CLLFormPort "FORM\n")
	fprintf(CLLFormPort "FIXED\n")
	fprintf(CLLFormPort "PORT 20 50\n")
	fprintf(CLLFormPort "HEADER \"AntiEtch Create...\"\n\n")
	fprintf(CLLFormPort "POPUP <class>\"class\"\n" )
	fprintf(CLLFormPort "POPUP <subclass>\"subclass\"\n" )
	fprintf(CLLFormPort "TILE\n\n")
	
	fprintf(CLLFormPort "TEXT \"Create to Class/Subclass:\"\n")
	fprintf(CLLFormPort "TLOC 1 1\n")
	fprintf(CLLFormPort "ENDTEXT\n\n")
		
	fprintf(CLLFormPort "FIELD class\n")
	fprintf(CLLFormPort "FLOC 5 4\n")
	fprintf(CLLFormPort "ENUMSET 15\n")
	fprintf(CLLFormPort "OPTIONS prettyprint\n")
	fprintf(CLLFormPort "POP \"class\"\n")
	fprintf(CLLFormPort "ENDFIELD\n")
	fprintf(CLLFormPort "FIELD subcolor\n")
	fprintf(CLLFormPort "FLOC 2 7\n")
	fprintf(CLLFormPort "COLOR 2 1\n")
	fprintf(CLLFormPort "OPTIONS colorchooser\n")
	fprintf(CLLFormPort "ENDFIELD\n")
	fprintf(CLLFormPort "FIELD subclass\n")
	fprintf(CLLFormPort "FLOC 5 7\n")
	fprintf(CLLFormPort "ENUMSET 15\n")
	fprintf(CLLFormPort "POP \"subclass\"\n")
	fprintf(CLLFormPort "ENDFIELD\n\n")	
	
	fprintf(CLLFormPort "TEXT \"\241\374 \241\374 \241\374 \241\374 \241\374 \241\374 \241\374 \241\374\" cll_up\n")
	fprintf(CLLFormPort "TLOC 5 9\n")
	fprintf(CLLFormPort "ENDTEXT\n\n")
	
	fprintf(CLLFormPort "TEXT \" \307\353    \321\241    \324\361    \262\343    \303\346\" cll_sel\n")
	fprintf(CLLFormPort "TLOC 5 11\n")
	fprintf(CLLFormPort "ENDTEXT\n\n")
	
	fprintf(CLLFormPort "GROUP \"About Me\"\n")
	fprintf(CLLFormPort "GLOC 1 13\n")
	fprintf(CLLFormPort "GSIZE 25 11\n")
	fprintf(CLLFormPort "ENDGROUP\n")
	
	fprintf(CLLFormPort "TEXT \"Change Line Layer V1.0\" cll_name\n")
	fprintf(CLLFormPort "TLOC 5 15\n")
	fprintf(CLLFormPort "ENDTEXT\n\n")
	
	fprintf(CLLFormPort "TEXT \"Written By VivienLuo\"cll_author\n")
	fprintf(CLLFormPort "TLOC 5 17\n")
	fprintf(CLLFormPort "ENDTEXT\n\n")
	
	fprintf(CLLFormPort "TEXT \"Mar 23,2014\" cll_date\n")
	fprintf(CLLFormPort "TLOC 5 19\n")
	fprintf(CLLFormPort "ENDTEXT\n\n")
	
	fprintf(CLLFormPort "TEXT \"www.allegro-skill.com\" cll_web\n")
	fprintf(CLLFormPort "TLOC 5 21\n")
	fprintf(CLLFormPort "ENDTEXT\n\n")
	
	fprintf(CLLFormPort "\n")
	fprintf(CLLFormPort "\n")
	fprintf(CLLFormPort "\n")
	fprintf(CLLFormPort "ENDTILE\n")
	fprintf(CLLFormPort "ENDFORM\n")
	close(CLLFormPort)
);end procedure

procedure(CLLDone()
	notdone = nil
	axlFinishEnterFun()
	axlUIWPrint(nil "- Done -")
)
procedure(CLLCancel()
	notdone = nil 
	axlCancelEnterFun()
	axlUIWPrint(nil "- Cancel -")
)