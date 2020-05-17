;		add_symbol.il

;

; Used to add a symbol to the database

; 01/17/2001 Ron Guthrie

;		Initial release.

; 10/02/2001 Ron Guthrie 

;		Release 2

;		-Ability to set the part using the mouse

;

; The Place -> Symbol -> Package, Mechanical,Format command has been 

; removed in the 14.X and up releases. Use this SKILL file if you need 

; the functionality that that command provided.

;

; Usage: add_sym symb type

; 

; symb	symbol name

; type	symbol type p=package m=mechanical f=format

; x_loc	x location to place the symbol

; y_loc	y location to place the symbol

; mir		mirror status t=true (mirrored) nil = not mirrored

; rot		symbol rotation in degrees

;

;

;Variable initialization.

x_loc=nil

y_loc=nil

mir=nil

rot=0



axlCmdRegister( "add_sym" 'add_symbol ?cmdType "interactive")



defun(add_symbol (symb type)



;get design extents



case( type

   ( "p"

    type = "package"

   )

   ( "m"

     type = "mechanical"

   )

   ( "f"

     type = "format"

   )

   ( t

      printf("%s is not a legal symbol type. Use p m or f.\n" type)

   )

);endcase



position=axlEnterPoint()

x_loc=car(position)

y_loc=cadr(position)



place=axlDBCreateSymbol(list(symb type) x_loc:y_loc mir rot)



	if(place==nil then

		printf("Placement of symbol %s failed.\n" symb)

	else

		if(cadr(place)!=nil then

			printf("DRC errors created when placing %s.\n" symb)

		); end if cadr(place)

	);end if place1



);end defun add_symbol



