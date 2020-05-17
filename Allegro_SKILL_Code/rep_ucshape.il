; SKILL file rep_ucshape.il
;
;	This file will look at the current database to find any shapes
;	that unconnected and have no net name associated with them.
;
;	Related documents:
;			SourceLink Solution 11090048
;			Enhancement PCR 587712
;
; 05/16/2003 Ron Guthrie
;		Initial release.
;
; After loading the file type rep_shape to execute.
;

axlCmdRegister( "rep_shape" 'rep_dummy_shape)
defun( rep_dummy_shape ()
	logfile="./uncon_shapes.log"
	axlClearSelSet()
	axlSetFindFilter(?enabled '(noall shapes invisible) ?onButtons '(noall shapes))
	axlAddSelectAll()
	rep_file=outfile(logfile)
	fprintf(rep_file "\tUnconnected Shape Report\n\nLocation\t\t\tLayer\n\n")
	l_shapes=axlGetSelSet()
	axlClearSelSet()
	foreach( shape l_shapes
		if( shape->net!=nil	;only get etch shapes
		  then
			if( shape->net->name==""	;get unconnected shapes
			  then
				location=car(shape->bBox)
				layer=shape->layer
				fprintf(rep_file "%L\t\t%s\n" location,layer)
			);endif
		);endif
	);endfor
	close(rep_file)
	axlUIViewFileCreate(logfile "Unconnected Shapes Log" nil)
);end defun