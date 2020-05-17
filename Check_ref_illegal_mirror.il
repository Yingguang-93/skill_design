;============================================================
;This Function check SILKSCREEN_BOTTOM if exist Text noMirror
;   SILKSCREEN_TOP if exist Text Mirror
;============================================================

axlCmdRegister("ss_mir_check" 'ss_mir_check)
defun(ss_mir_check ()
	l_nomirtext =l_mirtext= nil
	l_vis= axlVisibleGet()
	axlVisibleDesign(nil)
	axlVisibleLayer("REF DES/SILKSCREEN_BOTTOM" t )
	axlVisibleLayer("BOARD GEOMETRY/SILKSCREEN_BOTTOM" t )
	axlVisibleLayer("PACKAGE GEOMETRY/SILKSCREEN_BOTTOM" t )
	axlVisibleLayer("PACKAGE GEOMETRY/ASSEMBLY_BOTTOM" t )	
	axlVisibleLayer("REF DES/ASSEMBLY_BOTTOM" t )
	axlVisibleLayer("REF DES/DISPLAY_BOTTOM" t )
	axlSetFindFilter(?enabled '(noall text) ?onButtons '(text))
	axlVisibleUpdate(nil)
	axlAddSelectAll()
	l_text= axlGetSelSet()
	foreach(text l_text
		unless(text->isMirrored
			
				l_nomirtext = append1(l_nomirtext text)
		);unless
	);foreach
	axlHighlightObject(l_text)
	report_file = "ssb_not_mir_text.txt"
	fileport = outfile(report_file)
	fprintf(fileport "SILKSCREEN_BOTTOM: \n %d texts not mirrored.\n" length(l_nomirtext))
	foreach(text 	l_nomirtext
		fprintf(fileport "  %s			\t%L\n" text->text text->xy)
	);foreach
	axlVisibleDesign(nil)
	axlClearSelSet()
	axlVisibleLayer("REF DES/SILKSCREEN_TOP" t )
	axlVisibleLayer("BOARD GEOMETRY/SILKSCREEN_TOP" t )
	axlVisibleLayer("PACKAGE GEOMETRY/SILKSCREEN_TOP" t )
	axlVisibleLayer("PACKAGE GEOMETRY/ASSEMBLY_TOP" t )	
	axlVisibleLayer("REF DES/ASSEMBLY_TOP" t )
	axlVisibleLayer("REF DES/DISPLAY_TOP" t )
	axlSetFindFilter(?enabled '(noall text) ?onButtons '(text))
	axlVisibleUpdate(nil)
	axlAddSelectAll()
	l_top_text= axlGetSelSet()
	foreach(tp_text l_top_text
		if(tp_text->isMirrored
				l_mirtext = append1(l_mirtext tp_text)
		);if
	);foreach
	axlHighlightObject(l_top_text)
	fprintf(fileport "SILKSCREEN_TOP:\n %d texts mirrored.\n" length(l_mirtext))
	foreach(tp_text l_mirtext
		fprintf(fileport "  %s			\t%L\n" tp_text->text tp_text->xy)
	);foreach
	close(fileport)
	
	axlVisibleSet(l_vis)
	axlVisibleLayer("REF DES/SILKSCREEN_BOTTOM" t )
	axlVisibleLayer("BOARD GEOMETRY/SILKSCREEN_BOTTOM" t )
	axlVisibleLayer("PACKAGE GEOMETRY/SILKSCREEN_BOTTOM" t )
	axlVisibleLayer("PACKAGE GEOMETRY/ASSEMBLY_BOTTOM" t )	
	axlVisibleLayer("REF DES/ASSEMBLY_BOTTOM" t )
	axlVisibleLayer("REF DES/DISPLAY_BOTTOM" t )
	axlVisibleLayer("REF DES/SILKSCREEN_TOP" t )
	axlVisibleLayer("BOARD GEOMETRY/SILKSCREEN_TOP" t )
	axlVisibleLayer("PACKAGE GEOMETRY/SILKSCREEN_TOP" t )
	axlVisibleLayer("PACKAGE GEOMETRY/ASSEMBLY_TOP" t )	
	axlVisibleLayer("REF DES/ASSEMBLY_TOP" t )
	axlVisibleLayer("REF DES/DISPLAY_TOP" t )
	axlVisibleUpdate(nil)
	axlUIViewFileCreate(report_file "SilkScreen_Text_Mirrored_Check" t)	
);