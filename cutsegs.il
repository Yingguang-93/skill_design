/****************************************************/
/*               Title :  Cline Segs Cut			*/
/*     Execute Command :  cline_segs_cut			*/
/*              Author :  Vivien Luo                */
/*       Creation Date :  2013-06-18                */
/*       		Update :  		                */
/*            Web site :  www.allegro-skill.com     */
/*             E-maial :  admin@allegro-skill.com	*/
/****************************************************/

axlCmdRegister("cutsegs" 'cline_segs_cut ?cmdType "interactive" 
				?doneCmd 'ClineSegsCutDone ?cancelCmd 'ClineSegsCutCancel)

procedure(cline_segs_cut()
	cline_segs_popup = axlUIPopupDefine(nil (list
			(list "Done" 'ClineSegsCutDone )
			(list "Cancel" 'ClineSegsCutCancel ))
	)
	axlUIPopupSet(cline_segs_popup)
	notdone = t
	axlClearSelSet()
;	ClineCutVersion("1.0")
	while(notdone
		;
		axlSetFindFilter(?enabled '("noall" "CLINESEGS" "linesegs") ?onButtons '("noall" "CLINESEGS" "linesegs"))
		ClineSegsSelBox = axlEnterBox()
		when(ClineSegsSelBox
			ClineSegsSelBox = ClinesSegsComputeBox(ClineSegsSelBox)
			lxBox = xCoord(car(ClineSegsSelBox))
			lyBox = yCoord(car(ClineSegsSelBox))
			hxBox = xCoord(cadr(ClineSegsSelBox))
			hyBox = yCoord(cadr(ClineSegsSelBox))
			axlSingleSelectBox(ClineSegsSelBox)
			ClineSegsSel = axlGetSelSet()
			axlClearSelSet()
			when(ClineSegsSel
				l_horSegs = nil
				l_verSegs = nil
				l_slopeSegs = nil
				ClineSegsCut(ClineSegsSel)
			);end when
		);end when
	);end while
);end procedure
procedure(ClineSegsCut(l_clines)
	foreach(s_clines l_clines
    case(axlLineSlope(s_clines->startEnd)
      ( (0.0 0)
        ;; Horizontal segment
        l_horSegs = cons(s_clines l_horSegs)
      ); end 0
      (nil
        ;; Vertical segment
        l_verSegs = cons(s_clines l_verSegs)
      ); end nil
      (t
       ;; sloped lines
       l_slopeSegs = cons(s_clines l_slopeSegs)
      ); end t
	); end case
	);end foreach
	remove('nil l_horSegs)
	remove('nil l_verSegs)
	remove('nil l_slopeSegs)
	;Cut segs of Horizontal
	when(l_horSegs
		foreach(horSeg l_horSegs
			;Delete in SelBox segs...
			when(horSeg
			y_coord = nil
			beginX_coord = nil
			endX_coord = nil
			horLayer = nil
			horWidth = nil
			horNet = nil
			l_point = nil
			if(FindClineSegInBox(car(horSeg->startEnd) ClineSegsSelBox) && FindClineSegInBox(cadr(horSeg->startEnd) ClineSegsSelBox)
				then
					axlDeleteObject(horSeg)
				else
					y_coord = yCoord(car(horSeg->startEnd))
					beginX_coord = xCoord(car(horSeg->startEnd))
					endX_coord = xCoord(cadr(horSeg->startEnd))
					horLayer = horSeg->layer
					horWidth = horSeg->width
					horNet = horSeg->net->name
					when(beginX_coord > endX_coord
						xchange = beginX_coord
						beginX_coord = endX_coord
						endX_coord = xchange
					);end when
					;segment start with left to right
					axlDeleteObject(horSeg)
					when(beginX_coord < lxBox
						l_point = list(beginX_coord:y_coord lxBox:y_coord)
						axlDBCreateLine(l_point horWidth horLayer horNet)								
					)
					when(endX_coord > hxBox
						l_point = list(hxBox:y_coord endX_coord:y_coord)
						axlDBCreateLine(l_point horWidth horLayer horNet)
					)					
			);end if
			)
		)
	);end when
	;Cut segs of Vertical
	when(l_verSegs
		foreach(verSeg l_verSegs
			;Delete in SelBox segs...
			when(verSeg
			x_coord = nil
			beginY_coord = nil
			endY_coord = nil
			verLayer = nil
			verWidth = nil
			verNet = nil
			l_point = nil
			if(FindClineSegInBox(car(verSeg->startEnd) ClineSegsSelBox) && FindClineSegInBox(cadr(verSeg->startEnd) ClineSegsSelBox)
				then
					axlDeleteObject(verSeg)
				else
					x_coord = xCoord(car(verSeg->startEnd))
					beginY_coord = yCoord(car(verSeg->startEnd))
					endY_coord = yCoord(cadr(verSeg->startEnd))
					verLayer = verSeg->layer
					verWidth = verSeg->width
					verNet = verSeg->net->name
					when(beginY_coord > endY_coord
						xchange = beginY_coord
						beginY_coord = endY_coord
						endY_coord = xchange
					);end when
					;segment start with bottom to top
					axlDeleteObject(verSeg)
					when(beginY_coord < lyBox
						l_point = list(x_coord:beginY_coord x_coord:lyBox)
						axlDBCreateLine(l_point verWidth verLayer verNet)
					);end when
					when(endY_coord > hyBox
						l_point = list(x_coord:hyBox x_coord:endY_coord)
						axlDBCreateLine(l_point verWidth verLayer verNet)
					);end when
			);end if
			)
		)
	);end when
	;Cut segs of slope...
	when(l_slopeSegs
		foreach(slopeSeg l_slopeSegs
			when(slopeSeg
			;Delete in SelBox segs...
			tan_slope = nil
			beginCoord = nil
			endCoord = nil
			beginX_coord = nil
			beginY_coord = nil
			endX_coord = nil
			endY_coord = nil
			slopeLayer = nil
			slopeWidth = nil
			slopeNet = nil
			l_point = nil
			if(FindClineSegInBox(car(slopeSeg->startEnd) ClineSegsSelBox) && FindClineSegInBox(cadr(slopeSeg->startEnd) ClineSegsSelBox)
				then
					axlDeleteObject(slopeSeg)
				else
					tan_slope = axlLineSlope(slopeSeg->startEnd)
					beginCoord = car(slopeSeg->startEnd)
					endCoord = cadr(slopeSeg->startEnd)
					when(yCoord(beginCoord) > yCoord(endCoord) && tan_slope > 0
						xchange = beginCoord
						beginCoord = endCoord
						endCoord = xchange
					);end when
					when(yCoord(beginCoord) < yCoord(endCoord) && tan_slope < 0
						xchange = beginCoord
						beginCoord = endCoord
						endCoord = xchange
					);end when
					beginX_coord = xCoord(beginCoord)
					beginY_coord = yCoord(beginCoord)
					endX_coord = xCoord(endCoord)
					endY_coord = yCoord(endCoord)
					slopeLayer = slopeSeg->layer
					slopeWidth = slopeSeg->width
					slopeNet = slopeSeg->net->name
					axlDeleteObject(slopeSeg)
					if(tan_slope < 0
						then
							lyCoord = beginY_coord - (lxBox-beginX_coord) * abs(tan_slope)
							lxCoord = endX_coord - (lyBox-endY_coord) / abs(tan_slope)
							ryCoord = endY_coord + (endX_coord-hxBox) * abs(tan_slope)
							rxCoord = beginX_coord + (beginY_coord-hyBox)/abs(tan_slope)
							when(beginX_coord < lxBox || beginY_coord > hyBox
								when(lyCoord > lyBox && lyCoord < hyBox
									l_point = list(beginCoord lxBox:lyCoord)
									axlDBCreateLine(l_point slopeWidth slopeLayer slopeNet)	
								);end when
								when(rxCoord > lxBox && rxCoord < hxBox
									l_point = list(beginCoord rxCoord:hyBox)
									axlDBCreateLine(l_point slopeWidth slopeLayer slopeNet)	
								);end when
							)
							when(endY_coord < lyBox || endX_coord > hxBox
								when(lxCoord > lxBox && lxCoord < hxBox
									l_point = list(lxCoord:lyBox endCoord)
									axlDBCreateLine(l_point slopeWidth slopeLayer slopeNet)	
								);end when
								when(ryCoord > lyBox && ryCoord < hyBox
									l_point = list(hxBox:ryCoord endCoord)
									axlDBCreateLine(l_point slopeWidth slopeLayer slopeNet)	
								);end when
							)       						
						else
							ryCoord = (hxBox-beginX_coord)*tan_slope+beginY_coord
							lyCoord = (lxBox-beginX_coord)*tan_slope+beginY_coord
							rxCoord = beginX_coord+(lyBox-beginY_coord)/tan_slope
	        				lxCoord = endX_coord-(endY_coord-hyBox)/tan_slope        				
							when(beginX_coord < lxBox || beginY_coord < lyBox
								when(lyCoord > lyBox && lyCoord < hyBox
									l_point = list(beginCoord lxBox:lyCoord)
									axlDBCreateLine(l_point slopeWidth slopeLayer slopeNet)	
								);end when
								when(rxCoord > lxBox && rxCoord < hxBox
									l_point = list(beginCoord rxCoord:lyBox)
									axlDBCreateLine(l_point slopeWidth slopeLayer slopeNet)	
								);end when
							)
							when(endY_coord > hyBox || endX_coord > hxBox
								when(lxCoord > lxBox && lxCoord < hxBox
									l_point = list(lxCoord:hyBox endCoord)
									axlDBCreateLine(l_point slopeWidth slopeLayer slopeNet)	
								);end when
								when(ryCoord > lyBox && ryCoord < hyBox
									l_point = list(hxBox:ryCoord endCoord)
									axlDBCreateLine(l_point slopeWidth slopeLayer slopeNet)	
								);end when
							)  
					);end if
			);end if		
			);		
		);end foreach
	);end when
);end procedure

;Find the Shape's segments wether in the Bounding Box
procedure(FindClineSegInBox(TempInCoord inBox)
	inBoxCoord = nil
	when(car(TempInCoord) > caar(inBox) && car(TempInCoord) < caadr(inBox) && cadr(TempInCoord) > cadar(inBox) && cadr(TempInCoord) < cadadr(inBox)
		inBoxCoord = TempInCoord	
	)		
	inBoxCoord 					;The Return Value
);end procedure


;Compute the Box Coordinate as LowerLeft and UpperRight 
procedure(ClinesSegsComputeBox(InBox)
	fx=caar(InBox)				;The x Coordinate of the First Point 
	fy=cadar(InBox)				;The y Coordinate of the First Point
	sx=caadr(InBox)				;The x coordinate of the Second Point
	sy=cadadr(InBox)			;The y coordinate of the Second Point
	if( fx < sx 
		then
			llx = fx 
			urx = sx
		else
			llx = sx 
			urx = fx
	);end if
	if( fy < sy
		then
			lly = fy
			ury = sy
		else
			lly = sy
			ury = fy
	);end if
	list(llx:lly urx:ury) 		;The Return Value
)
procedure(ClineSegsCutDone()
	notdone = nil
	axlFinishEnterFun()
	axlUIWPrint(nil "- Done -")
)
procedure(ClineSegsCutCancel()
	notdone = nil 
	axlCancelEnterFun()
	axlUIWPrint(nil "- Cancel -")
)
;procedure(ClineCutVersion(ver)
;	axlUIWPrint(nil "------ Cline Cut Ver %s ---- Written By Vivien Luo  ------" ver)
;	axlUIWPrint(nil "------ E-mail : vivienluo@allegro-skill.com ------ Jun 18, 2013 ------")
;);End Procedure