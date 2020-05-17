; recursive object-displaying SKILL function
; Written by: Chris Walters		Nvidia		2002/06/07
;
; Description:
; This SKILL function will print all the attributes of a given object
; and recursively call itself to display those which are themselves objects.
; Attributes are indented four spaces from the object listing.
; The function writes these details to a file called objects.txt .
;
; Preparation:
;     Position this file (prtobj.il) in the directory path where all other
;     skill routines are located. In the allegro.ilinit file include the line
;     load("prtobj.il")
;
; Usage:
;     1) place the following lines at the beginning/end of your routine:
;           objfile=outfile("objects.txt" "w")
;           close(objfile)
;     2) place a call to prtobj wherever you choose to in your routine:
;           prtobj( xxx yyy)
;        where xxx is the dbid of the object you wish to write out
;        and   yyy is the initial indentation desired. 0 is a good default to use.
;
; Associated files:
;     None
;
; Revision History
;    --		2002/06/07  Chris Walters	Initial release
;==========================================================================
defun( prtobj ( obj_dbid depth)
let( (( _indent "") ( _next_depth 0))
obj_list = obj_dbid->?		; remember this is a list of SYMBOLS not text
remdq( 'parent obj_list)	; skip doing parent
remdq( 'readOnly obj_list)	; skip doing readOnly
obj_list = sort( obj_list 'alphalessp)
for( ii 1 depth
	_indent = strcat( _indent "    ")
);end-for
fprintf(objfile,"%s%L%s\n" _indent obj_dbid "------------------")
_next_depth = depth + 2
_indent = strcat( _indent "    ")
full_obj_name = ""
foreach( obj obj_list
	obj_name  = get_pname( obj)	; returns stringname of symbol
	obj_value = get( obj_dbid obj) ; returns value of symbol
	fprintf(objfile,"%s%s%s%L\n" _indent obj_name " = " obj_value)
	if( otherp( obj_value) then		; obj_value is a single dbid
        prtobj( obj_value _next_depth)
	);end-if
	if( listp( obj_value) then		; obj_value is a list
		if( otherp( car( obj_value)) then		; obj_value is a list of dbids
			foreach( tesst obj_value
				prtobj( tesst _next_depth)
			);end-foreach
		);end-if
	);end-if
);end-foreach

);end-let
);end-defun
