axlCmdRegister( "300" 'check_status22 ?cmdType "general")
defun( check_status22 ()
tyName= axlCurrentDesign()
script = outfile("./temp.scr")
fprintf(script "scriptmode +i +n\n")
fprintf(script "placementedit\ndownrev\nsetwindow form.downrev\nFORM downrev save2 YES \nFORM downrev save \n")
fprintf(script "fillin %s\n" tyName)
fprintf(script "FORM downrev close\n")
	close(script)
	axlShell(strcat("replay " "./temp.scr"))
deleteFile("./temp.scr")
axlUIWPrint(nil "plase check the status")
)
;nfillin "163.brd"\nFORM downrev close\n