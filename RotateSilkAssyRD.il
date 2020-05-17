;###########################################################################
;#                                                                         #
;#   Rotate Reference Designator Text on Silkscreen and Assembly Layers    #
;#                                                                         #
;#  This routine rotates Silkscreen and Assembly Reference Designators     #
;#  such that they are all "rightward reading".  This means that all RDs   #
;#  will read left to right if they are horizontal, or bottom to top if    #
;#  they are vertical.                                                     #
;#                                                                         #
;#  Additionally, any Assy RD will automatically be moved to the component #
;#  origin.                                                                #
;#                                                                         #
;#                                                                         #
;#  Usage:  rotate_silkassy (from within Allegro)                          #
;###########################################################################

/*
	History:
 	2.0	26-Jan-11	DE	Commented out SetupDir() and inserted FormDir = "./"
 	2.1	07-Jun-12	DE	Added feature to skip text with fixed or locked parents.
 	2.2	21-May-15	DE	Re-wrote for 16.6 and stricter Skill coding style. Added prefix fields.
 	2.3	06-Mar-17	DE	Added Values. Fixed bug(?) with 180 degree rotations.
*/

;load(strcat(eval('mySkillPath), "\\RotateSilkAssyRD.il")) RotateSilkAssyRD()
;AFn_lint(strcat(eval('mySkillPath), "\\RotateSilkAssyRD.il"), ?ignores nil)

;##########################
;#  Register Program Name #
;##########################

axlCmdRegister("rotate_silkassy" 'RotateSilkAssyRD)

;#############################
;# MAIN Program Starts Here. #
;#############################

defun( RotateSilkAssyRD ()
 let((fStr, embFID, form, formFile)
	if( axlOKToProceed() then
		; ==== Create and Display the User Interface ====
		unless(boundp('RotateSilkAssyRD_mediumPrefixes), defvar(RotateSilkAssyRD_mediumPrefixes, "RN, RP, FB, KP"))
		unless(boundp('RotateSilkAssyRD_smallPrefixes), defvar(RotateSilkAssyRD_smallPrefixes, "C, R, D, TP"))
		fStr = createRotateRDFormStr()
		if(axlVersion('version) >= 16.6 then
			embFID = gensym()
			form = axlFormCreate(embFID, list(sprintf(nil, "embeddedForm_%s", embFID), list(fStr)), nil, 'rotateRDForm_Action, t)
		 else
			formFile = "rotateRDForm.form"
			form = axlDMOpenFile("FORM", formFile, "w")
			fprintf(form, createRotateRDFormStr())
			axlDMClose(form)
			form = axlFormCreate((gensym), formFile, nil, 'rotateRDForm_Action, t)
		)
		axlFormSetField(form, "refdes", t)
		;axlFormSetField(form, "values", t)
		axlFormSetField(form, "LRBT", t); Default is Left to Right, Bottom to Top
		axlFormSetField(form "CenterAssy", t)
		axlFormSetField(form "TextBlockLarge", 6)
		axlFormSetField(form "TextBlockMedium", 3)
		axlFormSetField(form "TextBlockSmall", 1)
		axlFormSetField(form, "mediumPrefixes", RotateSilkAssyRD_mediumPrefixes)
		axlFormSetField(form, "smallPrefixes", RotateSilkAssyRD_smallPrefixes)
		axlFormDisplay(form)
		when(formFile, deleteFile(formFile))
	 else
		printf("E- Please terminate your interactive command .\n")
	);endif OKToProceed
)); end defun - MAIN Program

;############################################################################
;# DoRotateSilkAssy - When OK is hit, perform Reference Designator Rotation #
;#                   Do each layer separately to improve performance.       #
;############################################################################

defun( DoRotateSilkAssy (form)
 let((okFixed, allTxtObjs, layers, layerTxtObjs)
	okFixed = axlFormGetField(form, "okfixed")
	axlClearSelSet()
	axlSetFindFilter(?enabled '("noall", "text", "invisible"), ?onButtons '("text"))
	allTxtObjs = axlGetSelSet(axlAddSelectAll())
	axlClearSelSet()
	axlMsgPut("Silk/Assy RD rotation started.")
	axlVisibleLayer("BOARD GEOMETRY/OUTLINE", t)
	when(axlFormGetField(form, "AssyBot"), layers = RotateSilkAssyLayers(form, "ASSEMBLY_BOTTOM", layers))
	when(axlFormGetField(form, "AssyTop"), layers = RotateSilkAssyLayers(form, "ASSEMBLY_TOP", layers))
	when(axlFormGetField(form, "SilkBot"), layers = RotateSilkAssyLayers(form, "SILKSCREEN_BOTTOM", layers))
	when(axlFormGetField(form, "SilkTop"), layers = RotateSilkAssyLayers(form, "SILKSCREEN_TOP", layers))
	foreach(layer, layers
		layerTxtObjs = setof(txtObj, allTxtObjs, txtObj ->layer == layer)
		unless(okFixed, layerTxtObjs = setof(txtObj, layerTxtObjs, !axlDBIsFixed(txtObj ->parent) && !txtObj ->parent ->prop ->LOCKED))
		unless(zerop(length(layerTxtObjs)), RotateSilkAssy(form, layerTxtObjs))
		axlMsgPut(strcat(layer, ": Rotation completed."))
	); foreach layer
)); end defun - DoRotateSilkAssy

;######################################################################
;# RotateSilkAssy - Check layer type, Get RD Coordinates and rotation.#
;#                  Rotate RD in place if wrong orientation, change   #
;#                  text justification to "center".                   #
;######################################################################

defun( RotateSilkAssy (form, txtObjs)
 let((mediumPrefixes, smallPrefixes, changeit, text, xy, txt_tblk, txt_rot, rdPrefix, sym_x, sym_y, textHeight, txtOffset, halfTextHeight, textOrientation)
	mediumPrefixes = parseString(axlFormGetField(form, "mediumPrefixes"), ", ")
	smallPrefixes = parseString(axlFormGetField(form, "smallPrefixes"), ", ")
	foreach(txtObj, txtObjs
		; ==== retrieve current information on text id              ====
		changeit = nil
		text = txtObj ->text
		xy = txtObj ->xy
		txt_tblk = readstring(txtObj ->textBlock)
		; ==== Change Text to "Center" Justification for ease of use ====
		unless(txtObj ->justify == "CENTER", changeit = t)
		; ==== Check current rotation against preferred orientation and change if necessary ====
		txt_rot = round(txtObj ->rotation)
		cond(
			(axlFormGetField(form, "LRBT") && txt_rot == 180, txt_rot =   0, changeit = t)
			(axlFormGetField(form, "LRBT") && txt_rot == 270, txt_rot =  90, changeit = t)
			(axlFormGetField(form, "LRTB") && txt_rot == 180, txt_rot =   0, changeit = t)
			(axlFormGetField(form, "LRTB") && txt_rot ==  90, txt_rot = 270, changeit = t)
			(axlFormGetField(form, "RLBT") && zerop(txt_rot), txt_rot = 180, changeit = t)
			(axlFormGetField(form, "RLBT") && txt_rot == 270, txt_rot =  90, changeit = t)
			(axlFormGetField(form, "RLTB") && zerop(txt_rot), txt_rot = 180, changeit = t)
			(axlFormGetField(form, "RLTB") && txt_rot ==  90, txt_rot = 270, changeit = t)
		)
		; ==== ON Assembly Layers, if requested by user in form move Assy Text to Calculated Symbol origin    ====
		; ====    Change Text Block Sizes for easier reading.   ====
		when(axlFormGetField(form, "ChangeTextSize") && car(parseString(txtObj ->layer, "/")) == "REF DES"
			changeit = t
			rdPrefix = car(parseString(text, "0123456789"))
			txt_tblk = cond(
				(listnindex(mediumPrefixes, rdPrefix), axlFormGetField(form, "TextBlockMedium"))
				(listnindex(smallPrefixes, rdPrefix), axlFormGetField(form, "TextBlockSmall"))
				(t, axlFormGetField(form, "TextBlockLarge"))
			)
		)
		when(axlFormGetField(form "CenterAssy")
			foreach(childid, txtObj ->parent ->children
				when(childid ->layer == "PACKAGE GEOMETRY/PLACE_BOUND_TOP" || childid ->layer == "PACKAGE GEOMETRY/PLACE_BOUND_BOTTOM"
					sym_x = (xCoord(car(childid ->bBox)) + xCoord(cadr(childid ->bBox))) / 2.0
					sym_y = (yCoord(car(childid ->bBox)) + yCoord(cadr(childid ->bBox))) / 2.0
				);when childid
			);end foreach childid
			
			textHeight = axlGetParam(sprintf(nil, "paramTextBlock:%d", txt_tblk)) ->height
			txtOffset = if(car(parseString(txtObj ->layer, "/")) == "COMPONENT VALUE" then textHeight * 1.3 else 0)
			halfTextHeight = textHeight / 2.0
			case(txt_rot
				(  0, sym_y = sym_y - halfTextHeight - txtOffset)
				( 90, sym_x = sym_x + halfTextHeight + txtOffset)
				(180, sym_y = sym_y + halfTextHeight + txtOffset)
				(270, sym_x = sym_x - halfTextHeight - txtOffset)
			)
			xy = list(sym_x, sym_y)
			changeit = t
		); when CenterAssy
		; ==== Do text movement, if anything has changed ====
		when(changeit
			textOrientation = make_axlTextOrientation( ?textBlock txt_tblk, ?rotation txt_rot, ?mirrored txtObj ->isMirrored, ?justify "CENTER")
			if(axlDBCreateText(text, xy, textOrientation, txtObj ->layer, txtObj ->parent)
			 then axlDeleteObject(txtObj)
			 else axlMsgPut(strcat("Update Failed on ", text))
			)
		)
	); endforeach
)); end defun - rotateSilkAssy

 ;###########################################################
 ;# Form CallBacks - Determine Allegro command to execute   #
 ;#                  based on the user's selection          #
 ;###########################################################

defun( rotateRDForm_Action (form)
	case(form ->curField
		("mediumPrefixes"
			RotateSilkAssyRD_mediumPrefixes = buildString(unique(parseString(upperCase(form ->curValue), " ,")), ",")
			axlFormSetField(form, "mediumPrefixes", RotateSilkAssyRD_mediumPrefixes)
		)
		("smallPrefixes"
			RotateSilkAssyRD_smallPrefixes = buildString(unique(parseString(upperCase(form ->curValue), " ,")), ",")
			axlFormSetField(form, "smallPrefixes", RotateSilkAssyRD_smallPrefixes)
		)
		("apply", DoRotateSilkAssy(form))
		("cancel", axlFormClose(form), axlCancelEnterFun())
	); end case
); end defun - rotateRDForm_Action

defun( RotateSilkAssyLayers (form, subclass, layers)
 let((doRefdes, doValues)
	doRefdes = axlFormGetField(form, "refdes")
	doValues = axlFormGetField(form, "values")
	axlVisibleLayer(strcat("PACKAGE GEOMETRY/", subclass), t)
	when(doRefdes
		axlVisibleLayer(strcat("REF DES/", subclass), t)
		layers = cons(strcat("REF DES/", subclass), layers)
	)
	when(doValues
		axlVisibleLayer(strcat("COMPONENT VALUE/", subclass), t)
		layers = cons(strcat("COMPONENT VALUE/", subclass), layers)
	)
	layers
))

;###########################################################
 ;# createTitleBlockForm - Main User Interface Form         #
 ;#                        Brought up by executing command. #
 ;###########################################################

;load(strcat(eval('mySkillPath), "\\RotateSilkAssyRD.il")) RotateSilkAssyRD()
defun( createRotateRDFormStr ()
 let((fStr, (lineNo 1))
	fStr = strcat(
		"FILE_TYPE=FORM_DEFN VERSION=2\n"
		"FORM\n"
		"FIXED\n"
		"PORT 77 20\n"
		"HEADER \"Rotate Silkscreen/Assembly Reference Designators V2.3\"\n"
		"TILE\n"
	)

	fStr = sprintf(fStr, "%sGROUP \"Select Text Objects to Rotate\"\n", fStr)
	fStr = sprintf(fStr, "%sGLOC 2 %d\n", fStr, lineNo)
	fStr = sprintf(fStr, "%sGSIZE 73 4\n", fStr)
	fStr = sprintf(fStr, "%sENDGROUP\n", fStr)

	lineNo = lineNo + 2
	fStr = sprintf(fStr, "%sFIELD \"refdes\"\n", fStr)
	fStr = sprintf(fStr, "%sFLOC 3 %d\n", fStr, lineNo)
	fStr = sprintf(fStr, "%sCHECKLIST \"Reference Designators\"\n", fStr)
	fStr = sprintf(fStr, "%sENDFIELD\n", fStr)

	fStr = sprintf(fStr, "%sFIELD \"values\"\n", fStr)
	fStr = sprintf(fStr, "%sFLOC 37 %d\n", fStr, lineNo)
	fStr = sprintf(fStr, "%sCHECKLIST \"Values\"\n", fStr)
	fStr = sprintf(fStr, "%sENDFIELD\n", fStr)

	lineNo = lineNo + 2
	fStr = sprintf(fStr, "%sGROUP \"Select Layers to Rotate\"\n", fStr)
	fStr = sprintf(fStr, "%sGLOC 2 %d\n", fStr, lineNo)
	fStr = sprintf(fStr, "%sGSIZE 73 4\n", fStr)
	fStr = sprintf(fStr, "%sENDGROUP\n", fStr)

	lineNo = lineNo + 2
	fStr = sprintf(fStr, "%sFIELD \"SilkTop\"\n", fStr)
	fStr = sprintf(fStr, "%sFLOC 3 %d\n", fStr, lineNo)
	fStr = sprintf(fStr, "%sCHECKLIST \"Silkscreen-Top\"\n", fStr)
	fStr = sprintf(fStr, "%sENDFIELD\n", fStr)

	fStr = sprintf(fStr, "%sFIELD \"SilkBot\"\n", fStr)
	fStr = sprintf(fStr, "%sFLOC 20 %d\n", fStr, lineNo)
	fStr = sprintf(fStr, "%sCHECKLIST \"Silkscreen-Bottom\"\n", fStr)
	fStr = sprintf(fStr, "%sENDFIELD\n", fStr)

	fStr = sprintf(fStr, "%sFIELD \"AssyTop\"\n", fStr)
	fStr = sprintf(fStr, "%sFLOC 37 %d\n", fStr, lineNo)
	fStr = sprintf(fStr, "%sCHECKLIST \"Assembly-Top\"\n", fStr)
	fStr = sprintf(fStr, "%sENDFIELD\n", fStr)

	fStr = sprintf(fStr, "%sFIELD \"AssyBot\"\n", fStr)
	fStr = sprintf(fStr, "%sFLOC 54 %d\n", fStr, lineNo)
	fStr = sprintf(fStr, "%sCHECKLIST \"Assembly-Bottom\"\n", fStr)
	fStr = sprintf(fStr, "%sENDFIELD\n", fStr)

	lineNo = lineNo + 2
	fStr = sprintf(fStr, "%sGROUP \"Select Orientations\"\n", fStr)
	fStr = sprintf(fStr, "%sGLOC 2 %d\n", fStr, lineNo)
	fStr = sprintf(fStr, "%sGSIZE 32 13\n", fStr)
	fStr = sprintf(fStr, "%sENDGROUP\n", fStr)

	fStr = sprintf(fStr, "%sGROUP \"Text Alterations\"\n", fStr)
	fStr = sprintf(fStr, "%sGLOC 36 %d\n", fStr, lineNo)
	fStr = sprintf(fStr, "%sGSIZE 39 13\n", fStr)
	fStr = sprintf(fStr, "%sENDGROUP\n", fStr)

	lineNo = lineNo + 2
	fStr = sprintf(fStr, "%sTEXT \"Horizontal           Vertical \"\n", fStr)
	fStr = sprintf(fStr, "%sTLOC 6 %d\n", fStr, lineNo)
	fStr = sprintf(fStr, "%sENDTEXT\n", fStr)

	lineNo = lineNo + 2
	fStr = sprintf(fStr, "%sFIELD \"LRBT\"\n", fStr)
	fStr = sprintf(fStr, "%sFLOC 3 %d\n", fStr, lineNo)
	fStr = sprintf(fStr, "%sCHECKLIST \"Left to Right     Bottom to Top\" \"rotate_group\"\n", fStr)
	fStr = sprintf(fStr, "%sENDFIELD\n", fStr)

	lineNo = lineNo + 2
	fStr = sprintf(fStr, "%sFIELD \"LRTB\"\n", fStr)
	fStr = sprintf(fStr, "%sFLOC 3 %d\n", fStr, lineNo)
	fStr = sprintf(fStr, "%sCHECKLIST \"Left to Right     Top to Bottom\" \"rotate_group\"\n", fStr)
	fStr = sprintf(fStr, "%sENDFIELD\n", fStr)

	lineNo = lineNo + 2
	fStr = sprintf(fStr, "%sFIELD \"RLBT\"\n", fStr)
	fStr = sprintf(fStr, "%sFLOC 3 %d\n", fStr, lineNo)
	fStr = sprintf(fStr, "%sCHECKLIST \"Right to Left     Bottom to Top\" \"rotate_group\"\n", fStr)
	fStr = sprintf(fStr, "%sENDFIELD\n", fStr)

	lineNo = lineNo + 2
	fStr = sprintf(fStr, "%sFIELD \"RLTB\"\n", fStr)
	fStr = sprintf(fStr, "%sFLOC 3 %d\n", fStr, lineNo)
	fStr = sprintf(fStr, "%sCHECKLIST \"Right to Left     Top to Bottom\" \"rotate_group\"\n", fStr)
	fStr = sprintf(fStr, "%sENDFIELD\n", fStr)

	lineNo = 11
	fStr = sprintf(fStr, "%sFIELD \"CenterAssy\"\n", fStr)
	fStr = sprintf(fStr, "%sFLOC 37 %d\n", fStr, lineNo)
	fStr = sprintf(fStr, "%sCHECKLIST \"Center Text at Part Origin\"\n", fStr)
	fStr = sprintf(fStr, "%sENDFIELD\n", fStr)

	lineNo = lineNo + 2
	fStr = sprintf(fStr, "%sFIELD \"ChangeTextSize\"\n", fStr)
	fStr = sprintf(fStr, "%sFLOC 37 %d\n", fStr, lineNo)
	fStr = sprintf(fStr, "%sCHECKLIST \"Change Ref Des Text Block Sizes\"\n", fStr)
	fStr = sprintf(fStr, "%sENDFIELD\n", fStr)

	lineNo = lineNo + 2
	fStr = sprintf(fStr, "%sTEXT \"Large Text Block: \"\n", fStr)
	fStr = sprintf(fStr, "%sTLOC 38 %d\n", fStr, lineNo)
	fStr = sprintf(fStr, "%sENDTEXT\n", fStr)

	fStr = sprintf(fStr, "%sFIELD \"TextBlockLarge\"\n", fStr)
	fStr = sprintf(fStr, "%sFLOC 53 %d\n", fStr, lineNo)
	fStr = sprintf(fStr, "%sINTSLIDEBAR 3 3\n MIN 1\n MAX 60\n FGROUP\"TxtBlock\"\n", fStr)
	fStr = sprintf(fStr, "%sENDFIELD\n", fStr)

	lineNo = lineNo + 2
	fStr = sprintf(fStr, "%sTEXT \"Medium Text Block: \"\n", fStr)
	fStr = sprintf(fStr, "%sTLOC 38 %d\n", fStr, lineNo)
	fStr = sprintf(fStr, "%sENDTEXT\n", fStr)

	fStr = sprintf(fStr, "%sFIELD \"TextBlockMedium\"\n", fStr)
	fStr = sprintf(fStr, "%sFLOC 53 %d\n", fStr, lineNo)
	fStr = sprintf(fStr, "%sINTSLIDEBAR 3 3\n MIN 1\n MAX 60\n FGROUP\"TxtBlock\"\n", fStr)
	fStr = sprintf(fStr, "%sENDFIELD\n", fStr)

	fStr = sprintf(fStr, "%sFIELD \"mediumPrefixes\"\n", fStr)
	fStr = sprintf(fStr, "%sFLOC 60 %d\n", fStr, lineNo)
	fStr = sprintf(fStr, "%sSTRFILLIN 12 99\n", fStr)
	fStr = sprintf(fStr, "%sENDFIELD\n", fStr)

	lineNo = lineNo + 2
	fStr = sprintf(fStr, "%sTEXT \"Small Text Block: \"\n", fStr)
	fStr = sprintf(fStr, "%sTLOC 38 %d\n", fStr, lineNo)
	fStr = sprintf(fStr, "%sENDTEXT\n", fStr)

	fStr = sprintf(fStr, "%sFIELD \"TextBlockSmall\"\n", fStr)
	fStr = sprintf(fStr, "%sFLOC 53 %d\n", fStr, lineNo)
	fStr = sprintf(fStr, "%sINTSLIDEBAR 3 3\n MIN 1\n MAX 60\n FGROUP\"TxtBlock\"\n", fStr)
	fStr = sprintf(fStr, "%sENDFIELD\n", fStr)

	fStr = sprintf(fStr, "%sFIELD \"smallPrefixes\"\n", fStr)
	fStr = sprintf(fStr, "%sFLOC 60 %d\n", fStr, lineNo)
	fStr = sprintf(fStr, "%sSTRFILLIN 12 99\n", fStr)
	fStr = sprintf(fStr, "%sENDFIELD\n", fStr)
		
	lineNo = lineNo + 3

	fStr = sprintf(fStr, "%sFIELD \"okfixed\"\n", fStr)
	fStr = sprintf(fStr, "%sFLOC 3 %d\n", fStr, lineNo)
	fStr = sprintf(fStr, "%sCHECKLIST \"Ignore fixed/locked status\"\n", fStr)
	fStr = sprintf(fStr, "%sENDFIELD\n", fStr)

	fStr = sprintf(fStr, "%sFIELD apply\n", fStr)
	fStr = sprintf(fStr, "%sFLOC 26 %d\n", fStr, lineNo)
	fStr = sprintf(fStr, "%sMENUBUTTON \"Apply\" 6 3\n", fStr)
	fStr = sprintf(fStr, "%sENDFIELD\n", fStr)

	fStr = sprintf(fStr, "%sFIELD cancel\n", fStr)
	fStr = sprintf(fStr, "%sFLOC 36 %d\n", fStr, lineNo)
	fStr = sprintf(fStr, "%sMENUBUTTON \"CANCEL\" 6 3\n", fStr)
	fStr = sprintf(fStr, "%sENDFIELD\n", fStr)

	fStr = sprintf(fStr, "%sENDTILE\n", fStr)
	fStr = sprintf(fStr, "%sENDFORM\n", fStr)
))