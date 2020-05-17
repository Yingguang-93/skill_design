/****************************************************/
/*               Title :  快速设置格点               */
/*              Author :  tb669                     */
/*       Creation Date :  2015-09-10                */
/*              Update :                            */
/****************************************************/

axlCmdRegister("g" 'set_grids ?cmdType "interactive")
axlCmdRegister("~e" 'set_grids5 ?cmdType "interactive")
axlCmdRegister("~b" 'set_grids25 ?cmdType "interactive")
axlCmdRegister("~a" 'set_grids1 ?cmdType "interactive")
axlCmdRegister("~" 'set_grids0_1 ?cmdType "interactive")

procedure(set_grids(@optional (grids ""))
	if(grids != ""
		then
			gird_value = atof(grids)
			if(gird_value
				then
					SetGridsScriptCreate(gird_value)
				else
					axlUIWPrint(nil "Sorry,You enter the wrong grid.... Grid set failed...")
			)
		else
			axlUIWPrint(nil "Please Input argument...")
	);end if 
);end procedure
procedure(SetGridsScriptCreate(InGrid)
	SGScriptFile = outfile("./grids.scr")
	fprintf(SGScriptFile "scriptmode +i +n\n")
	fprintf(SGScriptFile "version 15.5\n")
	fprintf(SGScriptFile "setwindow pcb\n")
	fprintf(SGScriptFile "trapsize 15382\n")
	fprintf(SGScriptFile "define grid\n")
	fprintf(SGScriptFile "setwindow form.grid\n")
fprintf(SGScriptFile "FORM grid non_etch non_etch_x_grids %n\n" InGrid)
fprintf(SGScriptFile "FORM grid non_etch non_etch_y_grids %n\n" InGrid)
fprintf(SGScriptFile "FORM grid all_etch all_etch_x_grids %n\n" InGrid)
fprintf(SGScriptFile "FORM grid all_etch all_etch_y_grids %n\n" InGrid)
	fprintf(SGScriptFile "FORM grid done\n")
	fprintf(SGScriptFile "setwindow pcb\n")
	close(SGScriptFile)
	axlShell(strcat("replay " "./grids.scr"))
	deleteFile("./grids.scr")
	axlUIWPrint(nil "^_^ Set Grid Successful...")
);end procedure

procedure(set_grids5(@optional (grids "5"))
	gird_value = atof(grids)					SetGridsScriptCreate(gird_value))
procedure(SetGridsScriptCreate(InGrid)
	SGScriptFile = outfile("./grids.scr")
	fprintf(SGScriptFile "scriptmode +i +n\n")
	fprintf(SGScriptFile "setwindow pcb\n")
	fprintf(SGScriptFile "define grid\n")
	fprintf(SGScriptFile "setwindow form.grid\n")
fprintf(SGScriptFile "FORM grid non_etch non_etch_x_grids %n\n" InGrid)
fprintf(SGScriptFile "FORM grid non_etch non_etch_y_grids %n\n" InGrid)
fprintf(SGScriptFile "FORM grid all_etch all_etch_x_grids %n\n" InGrid)
fprintf(SGScriptFile "FORM grid all_etch all_etch_y_grids %n\n" InGrid)
	fprintf(SGScriptFile "FORM grid done\n")
	fprintf(SGScriptFile "setwindow pcb\n")
	close(SGScriptFile)
	axlShell(strcat("replay " "./grids.scr"))
	deleteFile("./grids.scr")
	axlUIWPrint(nil "^_^ Set Grid Successful...")
);end procedure

procedure(set_grids1(@optional (grids "1"))
	gird_value = atof(grids)					SetGridsScriptCreate(gird_value))
procedure(SetGridsScriptCreate(InGrid)
	SGScriptFile = outfile("./grids.scr")
	fprintf(SGScriptFile "scriptmode +i +n\n")
	fprintf(SGScriptFile "setwindow pcb\n")
	fprintf(SGScriptFile "define grid\n")
	fprintf(SGScriptFile "setwindow form.grid\n")
fprintf(SGScriptFile "FORM grid non_etch non_etch_x_grids %n\n" InGrid)
fprintf(SGScriptFile "FORM grid non_etch non_etch_y_grids %n\n" InGrid)
fprintf(SGScriptFile "FORM grid all_etch all_etch_x_grids %n\n" InGrid)
fprintf(SGScriptFile "FORM grid all_etch all_etch_y_grids %n\n" InGrid)
	fprintf(SGScriptFile "FORM grid done\n")
	fprintf(SGScriptFile "setwindow pcb\n")
	close(SGScriptFile)
	axlShell(strcat("replay " "./grids.scr"))
	deleteFile("./grids.scr")
	axlUIWPrint(nil "^_^ Set Grid Successful...")
);end procedure

procedure(set_grids25(@optional (grids "25"))
	gird_value = atof(grids)					SetGridsScriptCreate(gird_value))
procedure(SetGridsScriptCreate(InGrid)
	SGScriptFile = outfile("./grids.scr")
	fprintf(SGScriptFile "scriptmode +i +n\n")
	fprintf(SGScriptFile "setwindow pcb\n")
	fprintf(SGScriptFile "define grid\n")
	fprintf(SGScriptFile "setwindow form.grid\n")
fprintf(SGScriptFile "FORM grid non_etch non_etch_x_grids %n\n" InGrid)
fprintf(SGScriptFile "FORM grid non_etch non_etch_y_grids %n\n" InGrid)
fprintf(SGScriptFile "FORM grid all_etch all_etch_x_grids %n\n" InGrid)
fprintf(SGScriptFile "FORM grid all_etch all_etch_y_grids %n\n" InGrid)
	fprintf(SGScriptFile "FORM grid done\n")
	fprintf(SGScriptFile "setwindow pcb\n")
	close(SGScriptFile)
	axlShell(strcat("replay " "./grids.scr"))
	deleteFile("./grids.scr")
	axlUIWPrint(nil "^_^ Set Grid Successful...")
);end procedure

procedure(set_grids0_1(@optional (grids "0.1"))
	gird_value = atof(grids)					SetGridsScriptCreate(gird_value))
procedure(SetGridsScriptCreate(InGrid)
	SGScriptFile = outfile("./grids.scr")
	fprintf(SGScriptFile "scriptmode +i +n\n")
	fprintf(SGScriptFile "setwindow pcb\n")
	fprintf(SGScriptFile "define grid\n")
	fprintf(SGScriptFile "setwindow form.grid\n")
fprintf(SGScriptFile "FORM grid non_etch non_etch_x_grids %n\n" InGrid)
fprintf(SGScriptFile "FORM grid non_etch non_etch_y_grids %n\n" InGrid)
fprintf(SGScriptFile "FORM grid all_etch all_etch_x_grids %n\n" InGrid)
fprintf(SGScriptFile "FORM grid all_etch all_etch_y_grids %n\n" InGrid)
	fprintf(SGScriptFile "FORM grid done\n")
	fprintf(SGScriptFile "setwindow pcb\n")
	close(SGScriptFile)
	axlShell(strcat("replay " "./grids.scr"))
	deleteFile("./grids.scr")
	axlUIWPrint(nil "^_^ Set Grid Successful...")
);end procedure
