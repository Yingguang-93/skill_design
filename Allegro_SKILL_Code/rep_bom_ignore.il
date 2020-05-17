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
; File: rep_bom_ignore.il
;
; SourceLink Solution Reference: 11322170
;
; Usage: Load this file rep_bom_ignore.il
;  The report will be registered and will be available as a report BOM Ignore
;	on the Tools > Quick Report menu as well it will appear on the list of
;	reports in the Tools > Report form.
;
; Note:
;	This file was created as an example of how to use the axlReportRegister
;	function to allow users to create a custom report from the Allegro PCB
;	Editor report menu. It uses the allegro axlExtractToFile function to
;	retrieve the data to be put in the report.
;
;	This code is unsupported.
;
;Author: Ron Guthrie
;	Cadence Design Systems
; Version 1.0
; Date: Mar 28,2007
;
;Set variables
;Report Description that appears on the menu
rep_desc = "BOM Ignore"
rep_title = "BOM Ignore"
axlReportRegister('Bom_ignore_Report, rep_desc rep_title)

; The callback Bom_ignore_Report matches the function defined below. It is
; the function below that creates the report. To customize this for other
; reports change the callback function and extract command file to obtain
; the report data that you require. Also the fprintf line that selects the
; fields to print will need to be modified to suit your needs.
;
; optional keyword allows you to call Bom_ignore_Report with a nil where
; the report file generated will be bom_ignore.rpt. Otherwise if
; called from report dialog, it will be passed a temporary filename
procedure( Bom_ignore_Report(@optional (rptName "bom_ignore"))

	let( (ext_cmd_file rep_file temp_bir ex_in extract_data l_fields )

	;create the extract command file.
	ext_cmd_file = "bom_ignore"
	ext_cmd = axlDMOpenFile("ALLEGRO_TEXT" ext_cmd_file "w")
	fprintf(ext_cmd "COMPONENT\n")
	fprintf(ext_cmd "BOM_IGNORE != ''\n")
	fprintf(ext_cmd "REFDES\n")
	fprintf(ext_cmd "BOM_IGNORE\n")
	fprintf(ext_cmd "END\n")
	axlDMClose(ext_cmd)
	;To create other reports or modify the contents of this report edit the
	;fprintf lines below to create the extract file that you need.
	;Refer to the Extract Data Dictionary in the online documentation for help
	;with creating an extract command file.
	;If it is not created by the SKILL code found above the extract command file
	;bom_ignore.txt must exist in the path specified by the TEXTPATH variable
	;for the following line to work

	rep_file = axlDMOpenFile("ALLEGRO_REPORT" rptName "w")	;open a report file
	axlLogHeader(rep_file "BOM_Ignore Report")	;write a header to the report file
	temp_bir = axlTempFile( t )	;create a temp file to write the extract output

	;extract the required information from the database. The short option will
	;dump the data without the ! delimiters and the header lines
	axlExtractToFile("bom_ignore" temp_bir list("short" "quiet"))
	;open the extract output file for reading
	ex_in = axlDMOpenFile("ALLEGRO_TEXT" temp_bir "r")
	when(ex_in
		while(gets(extract_data ex_in)	;read each line until we reach the EOF
			l_fields = parseString(extract_data)	;break up the line into fields
			;write the desired field information to the report file
			fprintf(rep_file "%s %s\n" nth(0 l_fields) nth(1 l_fields))
		);endwhile
	);endwhen
	;cleanup
	axlDMClose(ex_in)
	axlTempFileRemove( temp_bir )
	axlTempFileRemove( strcat(ext_cmd_file ".txt"))
	axlDMClose(rep_file)
	t
);endlet
);enddefun
