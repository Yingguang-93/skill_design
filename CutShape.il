
axlCmdRegister("cutshape" 'fnCutShapesMain ?cmdType "interactive" ?doneCmd 'fnCutShapesDone ?cancelCmd 'fnCutShapesCancel)
               
procedure(fnCutShapesMain()
	prog((rCutShapesPopup )
		unless(axlOKToProceed()
	    	axlUIConfirm("Please Finish current command!")  
			return(nil)
	    )
		axlSetFindFilter(?enabled '("noall" "shapes") ?onButtons '("noall" "shapes"))
				
		rCutShapesPopup = axlUIPopupDefine(nil list(
		    	list("Done" 'fnCutShapesDone) 
				list("Oops" 'fnCutShapesUndo) 
				list("Cancel" 'fnCutShapesCancel)
		    )
		)
	    axlUIPopupSet(rCutShapesPopup)
	    bCSDoFlag = t
	    nCSMark = axlDBTransactionStart()
	    while(bCSDoFlag
			fnCutShapesAction()
	    )
	    bCSDoFlag = 'unbound
	    nCSMark = 'unbound
	)
)

procedure(fnCutShapesAction()
	prog((lShapeIDs, lCutBox, tRectLayer, dRectCut, dRectCutPoly, lSelectShapes, lShapes, dShape, dShapeID, lShapePoly, lSplitPoly, dNewPoly, lShapeCut, tErrorMsg)
		lShapeIDs = nil
		axlClearSelSet()
		lCutBox = axlEnterBox(?prompts list("Please select an area."))
		tRectLayer = "BOARD GEOMETRY/DIMENSION"
		axlDBTransactionMark(nCSMark)
		when(lCutBox
			dRectCut = car(axlDBCreateRectangle(lCutBox nil tRectLayer nil nil))
			dRectCutPoly = axlPolyFromDB(dRectCut)
			axlSingleSelectBox(lCutBox)
			lSelectShapes = axlGetSelSet()
			lShapes = setof(dShape lSelectShapes dShape->objType == "shape")
			lShapes = setof(dShape lShapes nth(0 parseString(dShape->layer "/")) != "BOUNDARY")
			
			if(lShapes then
				foreach(dShape lShapes
					if(dShape->shapeBoundary then
						dShapeID = dShape->shapeBoundary
					else
						dShapeID = dShape
					)
					lShapeIDs = cons(dShapeID lShapeIDs)
					lShapePoly = axlPolyFromDB(dShapeID)
					lSplitPoly = axlPolyOperation(lShapePoly dRectCutPoly 'ANDNOT)
					if(! member(nil lSplitPoly) then 
						foreach(dNewPoly lSplitPoly
							lShapeCut = axlDBCreateShape(dNewPoly t dShapeID->layer dShape->net->name nil)
							if(lShapeCut then
								if(nth(1 lShapeCut) then
									axlUIWPrint(nil "E- Created DRC errors. Please Correct.")
								else
									axlUIWPrint(nil "No DRC errors.")
								)
							else
								axlUIWPrint(nil "E- Could not cut shape.")
								axlDBTransactionOops(nCSMark)
							)
						)
					else
						if(tErrorMsg = axlPolyErrorGet() then
							axlUIWPrint(nil "E- %L" tErrorMsg)
						else
							axlUIWPrint(nil "E- Cut area larger than shape. Try again.")
						)
					)
				)
				when(lShapeIDs
					axlDeleteObject(lShapeIDs)
				)
			else
				axlUIWPrint(nil "W- No Shape Selected. Try again.")
			)
		)
    	when(dRectCut
			axlDeleteObject(dRectCut)                                   
		)
	)
)

procedure(fnCutShapesUndo()
	let(()
		if(! axlDBTransactionOops(nCSMark) then
    		axlUIWPrint(nil "W- Nothing Left To Undo.")
		else
    		axlUIWPrint(nil "")
    		axlUIWPrint(nil "Restoring Shapes.")
		)
		axlClearSelSet()
	)
)

procedure(fnCutShapesCancel()
	let(()
		axlDBTransactionRollback(nCSMark)
		bCSDoFlag = nil
		axlClearSelSet()
		axlCancelEnterFun()
		gc()
	)
)

procedure(fnCutShapesDone()
	let(()
		axlDBTransactionCommit(nCSMark)
		bCSDoFlag = nil
		axlCancelEnterFun()
		gc()
	)
)
