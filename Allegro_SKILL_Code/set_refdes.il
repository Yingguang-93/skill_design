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
; File: set_refdes.il
;
; Usage: Load this file set_refdes.il
;  Issue the command srd <arg> on the Allegro command line. Where <arg>
;	is a command line argument that can be either save or get
;
;	srd save			Saves refdes data to the file refdes.txt
;	srd get			Retrieves refdes data from the refdes.txt file.
;
/* This utility can be used in an environment where one designer is
working on the etch once the design placement is stable.
A second designer can work with the silkscreen text moving the reference
designators to the desired location. When completed the silkscreen data
can be saved to a file with the "srd save" command.
The designer working on the etch can read the reference designator changes
with the command "srd get"
*/
;
; Note: Minimal testing on v15.x only
;		No testing is done to check if either of the files have had
;		auto-rename run on them.
;
;
;	Author:	Ron Guthrie
;	Company:	Cadence Design Systems
;	Version:	1.0
;	Date:		March 23,2006
;	Status:	Working
;
; Revision: 1.1 Ron Guthrie
;	Date: April 18, 2008
;	Notes: Consider situation when the text block has been changed.
;		Minimal testing with v15.7
;
axlCmdRegister("srd" '_set_refdes_from_file ?cmdType "general")
procedure( _set_refdes_from_file( mode )
prog( list(l_text refdes t_loc t_rot t_mirror t_justify t_layer l_vis l_old_loc mir rot)
l_old_loc=list()

case(mode
	("save"	;save the current refdes text information to a file
		printf("Mode:save\n")
		printf("Saving refdes data to file refdes.txt\n")
		p_refdes=outfile("./refdes.txt")	;open a file to store the data
		axlClearSelSet()		;clear any selected objects
		axlSetFindFilter(?enabled '(noall text) ?onButtons '(text))
		l_vis=axlVisibleGet()	;Store the current layer visibility
		axlVisibleDesign(nil)	;Set the visibility as desired.
		axlVisibleLayer("REF DES/SILKSCREEN_TOP" t )
		axlVisibleLayer("REF DES/SILKSCREEN_BOTTOM" t )
		axlUIWUpdate(nil)
		axlAddSelectAll()			;Select all of the visible text
		l_text=axlGetSelSet()	;Save the selected text in a list
		axlClearSelSet()
		foreach(text l_text		;Check each text string
			parent_type = text->parent->objType
			text_class = car(parseString(text->layer "/"))
			if(parent_type == "symbol" && text_class=="REF DES" then
				;probably found a refdes. Store the text details
				refdes=text->text
				t_loc=text->xy
				t_rot=text->rotation
				t_mirror=text->isMirrored
				t_layer=text->layer
				t_textblock=text->textBlock
				t_justify = text->justify
				;write the data to a file
				println(list(refdes t_loc t_layer t_rot t_mirror t_textblock) p_refdes)
			);endif
		);end foreach refdes
		close(p_refdes)	;close the file
		axlVisibleSet(l_vis)
		axlUIWUpdate(nil)
		printf("Refdes save completed.\n")
	);save
	("get"	;Read the file and process the text
		printf("Mode:get\n")
		l_visible=axlVisibleGet()		;store current visibility settings.
		axlVisibleDesign(nil)			;turn everything invisible
		axlVisibleLayer("REF DES/SILKSCREEN_TOP" t )
		axlVisibleLayer("REF DES/SILKSCREEN_BOTTOM" t )
		p_refdes=infile("./refdes.txt")
		while(l_refdes=car(lineread(p_refdes))
			refdes=nth(0 l_refdes)
			loc=nth(1 l_refdes)
			layer=nth(2 l_refdes)
			new_rot=nth(3 l_refdes)
			new_mir=nth(4 l_refdes)
			new_tblock=nth(5 l_refdes)
			new_justify=nth(6 l_refdes)
			l_old_loc = _find_refdes(refdes layer)	;call procedure to find the original text
			old_xy = nth(1 l_old_loc)					;current coordinates of refdes
			old_rot = nth(0 l_old_loc)->rotation	;current refdes rotation
			old_mir = nth(0 l_old_loc)->isMirrored	;current mirror status
			old_tblock=nth(0 l_old_loc)->textBlock	;current text block used
			o_component=nth(0 l_old_loc)->parent		;need the parent if creating new text
			when(old_xy			;if there is an xy then we found the text and can do a transform
				if(old_tblock==new_tblock then			;if the same text block then do a transform
					delta_x=xCoord(loc) - xCoord(old_xy)	;calculate the x offset
					delta_y=yCoord(loc) - yCoord(old_xy)	;calculate the y offset
					l_delta=list(delta_x delta_y)				;distance to move the text
					rot=new_rot-old_rot							;calculate the rotation
					mir=(new_mir && !old_mir)||(!new_mir && old_mir)	;mirror is XOR
					axlTransformObject(car(l_old_loc) ?move l_delta ?mirror mir ?angle rot)	;move the text
				else
					;if textblocks don't match then create a new refdes.
					new_orient=make_axlTextOrientation(?textBlock new_tblock, ?rotation new_rot, ?mirrored new_mir, ?justify new_justify )
					new_refdes=axlDBCreateText(refdes, loc, new_orient, layer, o_component)
					if(new_refdes then		;if new refdes successful then delete old one.
						axlClearSelSet()
						axlSetFindFilter(?enabled '(noall text) ?onButtons '(text))
						axlSingleSelectPoint(old_xy)
						axlDeleteObject(axlGetSelSet())
						axlClearSelSet()
					);end_if
				);end_if
			);end_when
		);end while
		close(p_refdes)
		axlVisibleSet(l_visible)	;restore layer visibility.
		printf("Process complete.\n")
	);get
	(t
		printf("Invalid command line argument.\n")
		printf("Command syntax: srd save   or  srd get \n")
		return(nil)
	)
);endcase
);endprog
);endproc

procedure( _find_refdes(sym tlayer)
	;procedure to return the dbid and location of the refdes for the symbol
prog(	list(child l_children o_type o_layer match_loc)
	l_children = car(axlSelectByName("REFDES" sym))->children
	foreach(child l_children
		o_type = child->objType
		o_layer = child->layer
		if(o_type=="text" && o_layer==tlayer then
			;probably found a refdes match.
			match_loc=child->xy
			axlClearSelSet()
			return(list(child match_loc))	;return the dbid and location of the text
			;if match_loc returns as nil then the text was not found
		);endif

	);foreach child
);end prog
);end proc _find_refdes
