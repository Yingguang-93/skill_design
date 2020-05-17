;height_check.il
;
;Rev 1: 16 Sept 2003
;
;By Geoff Meek		 
;email: meekg@rogers.com
;
;This program finds components over, under or equal to a user specified value, on the side specified.
;It also finds the highest component. Single pick mode lets you pick any symbol in the layout.
;Made and tested in Allegro v14.2 
;
;Type "heightchk" to start
;

axlCmdRegister( "heightchk" `heightchker)

;******************************************************************************
 
(defun heightchker ()

   vis_list = axlVisibleGet()					;store design visibility
   
   symlist=makeTable("atable3" 0)				;make assocication table
   symlist2=()								;makelist
   
   height_chker_form()						;Make form
   Form1=axlFormCreate( (gensym) "height_chker_form1.form" '(e outer) 'height_chker_form_Action t)
   
   checkLimitValue=1						;preset limit variable
   axlFormSetField( Form1 "GreaterThan" 1)		;preset form value
   checkSideValue=1							;preset side variable
   axlFormSetField( Form1 "TopSide" 1)			;preset form values...
   axlVisibleDesign(nil)
   axlVisibleLayer("PIN/TOP" t)
   axlVisibleLayer("VIA CLASS/TOP" t)
   axlVisibleLayer("PACKAGE GEOMETRY/ASSEMBLY_TOP" t)
   axlVisibleLayer("BOARD GEOMETRY/OUTLINE" t)
   axlVisibleUpdate(t)
   axlFormSetField( Form1 "TestNumber" "0")
   axlFormDisplay(Form1)						;display form
   
); end defun heightchker

;*******************************************************************************

(defun height_chker_form ()

   height_chker_form1=outfile("height_chker_form1.form" "w")
   
   fprintf(height_chker_form1 "FILE_TYPE=FORM_DEFN VERSION=2\n")   
   fprintf(height_chker_form1 "FORM\n")	
   fprintf(height_chker_form1 "FIXED\n")
   fprintf(height_chker_form1 "PORT 25 72\n")
   fprintf(height_chker_form1 "HEADER \"Height Chker\"\n")
;##################################################  Display buttons
   fprintf(height_chker_form1 "TILE\n")

   fprintf(height_chker_form1 "FIELD TestNumber\n")	
   fprintf(height_chker_form1 "FLOC 1 1\n")
   fprintf(height_chker_form1 "INTFILLIN 9 6\n")
   fprintf(height_chker_form1 "ENDFIELD\n")

   fprintf(height_chker_form1 "FIELD Find\n")	
   fprintf(height_chker_form1 "FLOC 2 13\n")
   fprintf(height_chker_form1 "MENUBUTTON \"Find\" 8 3\n")
   fprintf(height_chker_form1 "ENDFIELD\n")
   
   fprintf(height_chker_form1 "FIELD Pickit\n")	
   fprintf(height_chker_form1 "FLOC 13 13\n")
   fprintf(height_chker_form1 "CHECKLIST \"Pick It\" \"tb\"\n")
   fprintf(height_chker_form1 "ENDFIELD\n")
;
   fprintf(height_chker_form1 "FIELD TopSide\n")	
   fprintf(height_chker_form1 "FLOC 1 4\n")
   fprintf(height_chker_form1 "CHECKLIST \"Top Side\" \"tbc\"\n")
   fprintf(height_chker_form1 "ENDFIELD\n")
   
   fprintf(height_chker_form1 "FIELD BotSide\n")	
   fprintf(height_chker_form1 "FLOC 1 7\n")
   fprintf(height_chker_form1 "CHECKLIST \"Bottom Side\" \"tbc\"\n")
   fprintf(height_chker_form1 "ENDFIELD\n")
   
   fprintf(height_chker_form1 "FIELD BothSide\n")	
   fprintf(height_chker_form1 "FLOC 1 10\n")
   fprintf(height_chker_form1 "CHECKLIST \"Both Sides\" \"tbc\"\n")					
   fprintf(height_chker_form1 "ENDFIELD\n")
   
   fprintf(height_chker_form1 "FIELD HighestComp\n")	
   fprintf(height_chker_form1 "FLOC 13 10\n")
   fprintf(height_chker_form1 "CHECKLIST \"Highest Comp\" \"tb\"\n")
   fprintf(height_chker_form1 "ENDFIELD\n")
      
   fprintf(height_chker_form1 "FIELD GreaterThan\n")	
   fprintf(height_chker_form1 "FLOC 13 1\n")
   fprintf(height_chker_form1 "CHECKLIST \"Greater Than\" \"tb\"\n")
   fprintf(height_chker_form1 "ENDFIELD\n")
      
   fprintf(height_chker_form1 "FIELD LessThan\n")	
   fprintf(height_chker_form1 "FLOC 13 4\n")
   fprintf(height_chker_form1 "CHECKLIST \"Less Than\" \"tb\"\n")
   fprintf(height_chker_form1 "ENDFIELD\n")
      
   fprintf(height_chker_form1 "FIELD EqualTo\n")	
   fprintf(height_chker_form1 "FLOC 13 7\n")
   fprintf(height_chker_form1 "CHECKLIST \"Equal to\" \"tb\"\n")
   fprintf(height_chker_form1 "ENDFIELD\n")
   
   fprintf(height_chker_form1 "FIELD Listing\n")	
   fprintf(height_chker_form1 "FLOC 2 16\n")
   fprintf(height_chker_form1 "MENUBUTTON \"Listing\" 8 3\n")
   fprintf(height_chker_form1 "ENDFIELD\n")
 
   fprintf(height_chker_form1 "FIELD Done\n")
   fprintf(height_chker_form1 "FLOC 15 16\n")
   fprintf(height_chker_form1 "MENUBUTTON \"Done\" 8 3\n")
   fprintf(height_chker_form1 "ENDFIELD\n")
;#################################################### End of Display buttons
   fprintf(height_chker_form1 "ENDTILE\n")
   fprintf(height_chker_form1 "ENDFORM\n");
   close(height_chker_form1 )
   
); end defun height_chker_form 

;******************************************************************************************

(defun height_chker_form_Action (height_chker_form1 )

  (case height_chker_form1 ->curField
  
	checkSideValue=0					 	;Reset value
	checkLimitValue=0					 	;Reset value
	
	
	("Find"
		Entries=0
		makelisting=0
		if( (checkLimitValue==5) then 		;If the program was in pickit mode just before...
			axlShell("Done")				;stop symbol selection
			axlFormSetField( height_chker_form1 "Pickit" 0)		;deselect pickit button - stops while loop
		);end if
		List=outfile("c:\\heightlisting.txt")	;create output file.
		p=outfile("c:\\missingprops.txt")		;create output file.
		Calc()							;call Calc
		close(p)							;close output file
		close(List)
		if( (Entries==1) then				;if there was an entry then display window
			results=axlUIViewFileCreate("c:\\missingprops.txt" "Missing Shapes and Props" nil)	;close and display results.
			axlUIWExpose(results)
		);end if
		
	)
	
	
	("Listing"
		Entries=0
		if( (checkLimitValue==5) then 		;If the program was in pickit mode just before...
			axlShell("Done")				;stop symbol selection
		);end if
		makelisting=1
		checkLimitValue=1
		axlFormSetField( height_chker_form1 "GreaterThan" 1)		;set buttons to select all comps
		checkSideValue=3
		axlFormSetField( height_chker_form1 "BothSide" 1)
		axlFormSetField( height_chker_form1 "TestNumber" "0")
		
		axlVisibleDesign(nil)
		axlVisibleLayer("PIN/TOP" t)
		axlVisibleLayer("PIN/BOTTOM" t)
		axlVisibleLayer("VIA CLASS/TOP" t)
		axlVisibleLayer("VIA CLASS/BOTTOM" t)
		axlVisibleLayer("PACKAGE GEOMETRY/ASSEMBLY_TOP" t)
		axlVisibleLayer("PACKAGE GEOMETRY/ASSEMBLY_BOTTOM" t)
		axlVisibleLayer("BOARD GEOMETRY/OUTLINE" t)
		axlVisibleUpdate(t)
		   		
		checkSideValue=3
		p=outfile("c:\\missingprops.txt")			;create output file.
		List=outfile("c:\\heightlisting.txt")		;create output file.
		fprintf(List, "Component Height Listing (in mils)\n\n")
		fprintf(List, "Layout Name:  %s \nPath:  %s \nList Created:  %s\n\n" axlCurrentDesign() axlGetVariable("cwd") getCurrentTime())
		fprintf(List, "Refdes \t Height  Side \t\t SymbolName \n\n")
		Calc()								;call Calc
		close(List)							;close output file
		close(p)								;close output file
		axlClearSelSet()
		results2=axlUIViewFileCreate("c:\\heightlisting.txt" "Component Height Listing" nil)	;close and display results.
		axlUIWExpose(results2)
		makelisting=0
		if( (Entries==1) then					;if there was an entry then display window
					results=axlUIViewFileCreate("c:\\missingprops.txt" "Missing Shapes and Props" nil)	;close and display results.
					axlUIWExpose(results)
		);end if
	)
	
	("TopSide"
		if( (checkLimitValue==5) then 	;If the program was in pickit mode just before...
			axlShell("Done")			;stop symbol selection
			checkLimitValue=1
			axlFormSetField( height_chker_form1 "GreaterThan" 1)
			message=sprintf(nil "Select Mode ended")
			axlUIWPrint(height_chker_form1 message)
		);end if
		axlVisibleDesign(nil)
		axlVisibleLayer("PIN/TOP" t)
		axlVisibleLayer("VIA CLASS/TOP" t)
		axlVisibleLayer("PACKAGE GEOMETRY/ASSEMBLY_TOP" t)
		axlVisibleLayer("BOARD GEOMETRY/OUTLINE" t)
   		axlVisibleUpdate(t)
		checkSideValue=1
	)
	
	("BotSide"
		if( (checkLimitValue==5) then 	;If the program was in pickit mode just before...
			axlShell("Done")			;stop symbol selection
			checkLimitValue=1
			axlFormSetField( height_chker_form1 "GreaterThan" 1)
			message=sprintf(nil "Select Mode ended")
			axlUIWPrint(height_chker_form1 message)
		);end if
		axlVisibleDesign(nil)
		axlVisibleLayer("PIN/BOTTOM" t)
		axlVisibleLayer("VIA CLASS/BOTTOM" t)
		axlVisibleLayer("PACKAGE GEOMETRY/ASSEMBLY_BOTTOM" t)
		axlVisibleLayer("BOARD GEOMETRY/OUTLINE" t)
   		axlVisibleUpdate(t)
		checkSideValue=2
	)
	
	("BothSide"
		if( (checkLimitValue==5) then 	;If the program was in pickit mode just before...
			axlShell("Done")			;stop symbol selection
			checkLimitValue=1
			axlFormSetField( height_chker_form1 "GreaterThan" 1)
			message=sprintf(nil "Select Mode ended")
			axlUIWPrint(height_chker_form1 message)
		);end if
		axlVisibleDesign(nil)
		axlVisibleLayer("PIN/TOP" t)
		axlVisibleLayer("PIN/BOTTOM" t)
		axlVisibleLayer("VIA CLASS/TOP" t)
		axlVisibleLayer("VIA CLASS/BOTTOM" t)
		axlVisibleLayer("PACKAGE GEOMETRY/ASSEMBLY_TOP" t)
		axlVisibleLayer("PACKAGE GEOMETRY/ASSEMBLY_BOTTOM" t)
		axlVisibleLayer("BOARD GEOMETRY/OUTLINE" t)
   		axlVisibleUpdate(t)
		checkSideValue=3
	)
	
	("GreaterThan"
		if( (checkLimitValue==5) then 	;If the program was in pickit mode just before...
			axlShell("Done")			;stop symbol selection
		);end if
		checkLimitValue=1
	)
		
	("LessThan"
		if( (checkLimitValue==5) then 	;If the program was in pickit mode just before...
			axlShell("Done")			;stop symbol selection
		);end if
		checkLimitValue=2
	)
	
	("EqualTo"
		if( (checkLimitValue==5) then 	;If the program was in pickit mode just before...
			axlShell("Done")			;stop symbol selection
		);end if
		checkLimitValue=3
	)
	
	("HighestComp"
		if( (checkLimitValue==5) then 	;If the program was in pickit mode just before...
			axlShell("Done")			;stop symbol selection
		);end if
		checkLimitValue=4
	)
	
	("Pickit"
		message=sprintf(nil "Pick Component")
		axlUIWPrint(height_chker_form1 message)
		while( axlFormGetField(height_chker_form1 "Pickit")==t			;while "Pick It" Selection Loop
			checkLimitValue=5
			Pickit()
		);end while
		message=sprintf(nil "Select Mode ended")
		axlUIWPrint(height_chker_form1 message)
	)

     ("Done"
     	if( (checkLimitValue==5) then 	;If the program was in pickit mode just before...
     		axlShell("Done")			;stop symbol selection
     	);end if
     	axlVisibleSet(vis_list)
     	axlVisibleUpdate(t)
     	axlClearSelSet()
     	deleteFile("height_chker_form1.form")
     	axlFormClose(height_chker_form1 )
     	axlCancelEnterFun()
     ); end "Done"

     
   ); end case height_chker_form1 ->curField
); end defun height_chker_form _Action

;****************************************************************************************

(defun Calc ()

	getHeights()						;call getHeights
	
	highlight=0
	count=0
	currentmaxheight=0
	Maxheightofsymbol=0
	currenthighestcomp=nil
	currenthighestcompname=nil
	
	foreach( sym symlist2
	
		;printf("sym =  %L \n" sym)
		Maxheightofsymbol=car(linereadstring(car(cdr(cdr(car(cdr(sym)))))))
		sym_refdes=car(sym)
		sym_db=car(car(cdr(sym)))
		mir=car(cdr(car(cdr(sym))))
		
		(case checkSideValue						;read the radio button settings...
	
		(1
			if( (mir==nil) then
				
				(case checkLimitValue
						
					(1
						if( (Maxheightofsymbol>axlFormGetField(height_chker_form1 "TestNumber")) then
							count=count+1
							highlight=1
						);end if
					);
							
					(2
						if( (Maxheightofsymbol<axlFormGetField(height_chker_form1 "TestNumber")) then
							count=count+1
							highlight=1
						);end if
					);
							
					(3
						if( (Maxheightofsymbol==axlFormGetField(height_chker_form1 "TestNumber")) then
							count=count+1
							highlight=1
						);end if
					);
					
					(4
						if( (Maxheightofsymbol>currentmaxheight) then
							currentmaxheight=Maxheightofsymbol
							currenthighestcomp=sym_db
							currenthighestcompname=sym_refdes
						);end if
					);
					
				);end case checkLimitValue
			);end if
			
			if( (highlight==1) && (mir==nil) then					;if 'topside' was selected
				axlAddSelectObject(sym_db)						;highlight symbol
				message=sprintf(nil "%n Symbols Highlighted" count)
				axlUIWPrint(height_chker_form1 message)
				highlight=0
			else
				message=sprintf(nil "%n Symbols Highlighted" count)
				axlUIWPrint(height_chker_form1 message)
			);end if
		);end side 1
		
		(2
			if( (mir==t) then
				
				(case checkLimitValue
								
					(1
						if( (Maxheightofsymbol>axlFormGetField(height_chker_form1 "TestNumber")) then
							count=count+1
							highlight=1
						);end if
					);
									
					(2
						if( (Maxheightofsymbol<axlFormGetField(height_chker_form1 "TestNumber")) then
							count=count+1
							highlight=1
						);end if
					);
									
					(3
						if( (Maxheightofsymbol==axlFormGetField(height_chker_form1 "TestNumber")) then
							count=count+1
							highlight=1
						);end if
					);
					
					(4
						if( (Maxheightofsymbol>currentmaxheight) then
							currentmaxheight=Maxheightofsymbol
							currenthighestcomp=sym_db
							currenthighestcompname=sym_refdes
						);
					);
									
				);end case checkLimitValue
				
			);end if
					
			if( (highlight==1) && (mir==t) then					;if Botside was selected
				axlAddSelectObject(sym_db)						;highlight symbol
				message=sprintf(nil "%n Symbols Highlighted" count)
				axlUIWPrint(height_chker_form1 message)
				highlight=0
			else
				message=sprintf(nil "%n Symbols Highlighted" count)
				axlUIWPrint(height_chker_form1 message)
			);end if
		);end side 2
		
		
		(3
			(case checkLimitValue
								
				(1
					if( (Maxheightofsymbol>axlFormGetField(height_chker_form1 "TestNumber")) then
						count=count+1
						highlight=1
					);end if
				);end 1
										
				(2
					if( (Maxheightofsymbol<axlFormGetField(height_chker_form1 "TestNumber")) then
						count=count+1
						highlight=1
					);end if
				);end 2
										
				(3
					if( (Maxheightofsymbol==axlFormGetField(height_chker_form1 "TestNumber")) then
						count=count+1
						highlight=1
					);end if
				);end 3
				
				(4
					if( (Maxheightofsymbol>currentmaxheight) then
						currentmaxheight=Maxheightofsymbol
						currenthighestcomp=sym_db
						currenthighestcompname=sym_refdes
					);end if
				);end 4
										
			);end case checkLimitValue
						
			if( (highlight==1) then								;if bothsides was selected
				axlAddSelectObject(sym_db)						;highlight symbol
				
				if( (makelisting==1) then
					if( (mir==t) then
						side="Bottom"
					else
						side="Top   "
					);end if
					fprintf(List, "%s \t %n \t %s \t %s \n" sym_refdes Maxheightofsymbol side sym_db->name)
				);end if
		
				highlight=0
			
			);end if
			
			message=sprintf(nil "%n Symbols Highlighted" count)
			axlUIWPrint(height_chker_form1 message)
			
		);end side 3
		
			
		);end case checkSideValue
	);end foreach
	
	if( (checkLimitValue==4) then
		axlAddSelectObject(currenthighestcomp)						;highlight symbol
		message=sprintf(nil "Highest Comp: %s  at %n mils" currenthighestcompname currentmaxheight)
		axlUIWPrint(height_chker_form1 message)
	);end if
	;makelisting=0
);end defun Calc

;***************************************************************************************************

(defun getHeights ()

	axlSetFindFilter( ?enabled list("symbols") ?onButtons "symbols")
	axlOpenFindFilter()
	symbol_db_list = axlGetSelSet(axlAddSelectAll())		;Make a list of all symbols
	axlClearSelSet()
	
	foreach(symbol_db symbol_db_list
		refdes = symbol_db->refdes
		if( (refdes!=nil) then
			mir = symbol_db->isMirrored
			shapefound=0
			propfound=0
			twoshapes=0
			shape_bot_found=0
		
			children_db_list = symbol_db->children
	
			if( neq(children_db_list nil) then			; checks if symbol has attached shapes
				foreach(children_db children_db_list
					isShape = children_db->objType
					shape_layer = children_db->layer
						
					if( equal(isShape "shape") then
							
					; checks if shape is on package geometry/place_bound_top
					 
							
						if( equal(shape_layer "PACKAGE GEOMETRY/PLACE_BOUND_TOP") then
							shapefound=1
							if( (shape_bot_found==1) then
								twoshapes=1
							);end if
							proplist=axlDBGetProperties(children_db)
							foreach(prop proplist
								propS=symbolToString(car(prop))
									
								if( (propS=="PACKAGE_HEIGHT_MAX") then
									prop=cons(mir cdr(prop))
									symlist[refdes]=cons(symbol_db prop)
									;printf("%L \n" symlist)
									propfound=1
								);end if		
								 
							);end foreach
								
						) ; end if package geometry
							
						if( equal(shape_layer "PACKAGE GEOMETRY/PLACE_BOUND_BOTTOM") then
							if((shapefound==1) then
								twoshapes=1
							);end if
							shapefound=1
							shape_bot_found=1
							proplist=axlDBGetProperties(children_db)
							foreach(prop proplist
								propS=symbolToString(car(prop))
									
									if( (propS=="PACKAGE_HEIGHT_MAX") then
										prop=cons(mir cdr(prop))
										symlist[refdes]=cons(symbol_db prop)
										;printf("%L \n" symlist)
										propfound=1
									);end if		
														 
								);end foreach
														
							) ; end of package geometry
							
						) ; end of is shape	
						
					) ; end of foreach
				
				) ; end of if children
			
			
				if( (shapefound==0) then
					fprintf(p, "%L has no Place bound shape! \n" refdes)
					Entries=1
				);end if
				if( (propfound==0) then
					fprintf(p, "%L has no Place bound height property! \n" refdes)
					Entries=1
				);end if
				if( (twoshapes==1) then
					fprintf(p, "%L has two Place_bound shapes! May highlight improperly!! \n" refdes)
					Entries=1
				);end if
			
		);end if refdes=nil
		
	) ; end of foreach symbol_db
	
	symlist2=sortcar(tableToList(symlist) 'alphalessp)
	
);end defun getHeights

;********************************************************************************************

(defun Pickit ()
	
	axlSetFindFilter( ?enabled list("symbols") ?onButtons "symbols")
	axlOpenFindFilter()
	comp = car(axlGetSelSet(axlSingleSelectPoint()))	
	axlClearSelSet()
	PBshapefound=0
	PBpropfound=0
	refdes=comp->refdes
	
	if( refdes!=nil then					;excludes symbols that are not components
	
		if( (comp!=nil) then
			childrenlist=comp->children
			compheight=0
	
			if( neq(childrenlist nil) then
				foreach(children_db childrenlist
					isShape = children_db->objType
					shape_layer = children_db->layer
				
					if( equal(isShape "shape") then
										
						if( equal(shape_layer "PACKAGE GEOMETRY/PLACE_BOUND_TOP") || equal(shape_layer "PACKAGE GEOMETRY/PLACE_BOUND_BOTTOM") then
					
							proplist=axlDBGetProperties(children_db)
							PBshapefound=1
							foreach(prop proplist
								propS=symbolToString(car(prop))
															
								if( (propS=="PACKAGE_HEIGHT_MAX") then
									;printf("%s \n" car(cdr(prop)))
									PBpropfound=1
									compheight=car(cdr(prop))
								);end if
							);end foreach
						
						);end if
					);end if
				);end foreach
			);end if
			
			if( (PBshapefound!=0) && (PBpropfound!=0) then
				axlAddSelectObject(comp)
				message=sprintf(nil "%s  is  %s  high" refdes compheight)
				axlUIWPrint(height_chker_form1 message)
			else
				if( PBpropfound==0 then missing="PB Property")
				if( PBshapefound==0 then missing="PB Shape")
				axlAddSelectObject(comp)
				message=sprintf(nil "%s  is  missing a  %s" refdes missing)
				axlUIWPrint(height_chker_form1 message)
			
			);end if
		else
			message=sprintf(nil "Component Not Found")
			axlUIWPrint(height_chker_form1 message)
		);end if
	);end if
);end defun