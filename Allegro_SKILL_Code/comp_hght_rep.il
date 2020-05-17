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
; File: comp_hght_rep.il
;
;
;
; Usage: Load this file comp_hght_rep.il
;  Issue the command height_rep on the Allegro command line.
;
; Notes: This code creates an extract command file that is used to extract
;			information from the database in memory.
;			The information is then processed and written to a report file.
;
;
;	Author: Ron Guthrie
;	Cadence Design Systems
;	Version 1.0
;	Date: May 19,2006
;
axlCmdRegister("height_rep" '_extract_report ?cmdType "general")
defun( _extract_report ()
let(list(last_line extract_commands extract_data report_file cmd_file ext_results f_report l_fields)
last_line = ""
extract_commands = "_tmp_extract.txt"	;name of temp extract command file
extract_data = "_tmp_extract.dat"
report_file = "comp_height_report"

;Create the extract command file
cmd_file = outfile(extract_commands)
fprintf(cmd_file "GEOMETRY\n")
fprintf(cmd_file "REFDES!=\"\"\n")
fprintf(cmd_file "CLASS = \"PACKAGE GEOMETRY\"\n")
fprintf(cmd_file "SUBCLASS=\"PLACE_BOUND_TOP\"\n")
fprintf(cmd_file "OR\n")
fprintf(cmd_file "SUBCLASS=\"PLACE_BOUND_BOTTOM\"\n")

fprintf(cmd_file "REFDES\n")
fprintf(cmd_file "GRAPHIC_DATA_NAME\n")
fprintf(cmd_file "SUBCLASS\n")
fprintf(cmd_file "GEO_PACKAGE_HEIGHT_MIN\n")
fprintf(cmd_file "GEO_PACKAGE_HEIGHT_MAX\n")
fprintf(cmd_file "END\n")
close(cmd_file)

axlExtractToFile(extract_commands extract_data '("quiet"))
ext_results = infile(extract_data)
f_report = axlDMOpenFile("ALLEGRO_REPORT" report_file "w")
while( gets(line_rd ext_results)
	l_fields=parseString(line_rd "!")
	if(car(l_fields)=="S" then
		unless(last_line==line_rd
		;unless the line read matches the last line write it to the report.

			fprintf(f_report "%s", line_rd)
			last_line=line_rd		;reset the last line value
		);end unless
	);end if
);end while
close(ext_results)
close(f_report)
;Clean up
deleteFile(extract_commands)	;delete the view file
deleteFile(extract_data)		;delete the raw data file
printf("Report complete.\n")
);end let
);end defun