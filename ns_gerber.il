(defun ns_gerber_help ()
let((txt_file)
txt_file = axlDMOpenFile("ALLEGRO_TEXT", "help_info", "w")
fprintf(txt_file "This skill program creates artwork films\n")
fprintf(txt_file "To run the program type \"ns_gerber\" on the Allegro command line.\n")
fprintf(txt_file "\n")
fprintf(txt_file "NB:You need to create Drill Legend before running the program\n")
fprintf(txt_file "-----------------------------------------------------------------\n")
fprintf(txt_file "Tested on Allegro 16.3\n")
fprintf(txt_file "The program is delivered as is and no responsibility is taken.\n")
fprintf(txt_file "Use at own risk\n")
fprintf(txt_file "\n")
fprintf(txt_file "Revision 15.7 : First revision\n")
fprintf(txt_file "Revision 16.3 : Corrected a spelling error for pastemask films. Added this help text\n")
fprintf(txt_file "Written by:\n")
fprintf(txt_file "Ole Ejlersen\n")
fprintf(txt_file "Technical Service Manager\n")
fprintf(txt_file "Nordcad Systems A/S - Representing Cadence in Denmark\n")
fprintf(txt_file "I can be reached at the following Email address: oe@nordcad.dk\n")
fprintf(txt_file "-----------------------------------------------------------------\n")
axlDMClose(txt_file)
axlUIViewFileCreate("help_info.txt" "Help for creating gerber films" t)
))


(defun ns_gerber ()
	ns_gerber_help()
; initialize variables
	units = car(axlDBGetDesignUnits())

; Specify undefined line width below (in mm)
	undefwidth = 0.25
	sprintf(ulw "%f" 1000*axlMKSConvert(undefwidth "mm" units)) ;undefined_line_width
	ulw =atoi(ulw)
	sprintf(sbb "%f" 1000*axlMKSConvert(2.54 "mm" units)) ; shape bounding box, only used for negative artwork
	sbb = atoi(sbb)

;delete existing film records
	my_films_members = axlGetParam("artwork")->groupMembers

; create temp artwork film - will be deleted later on
	(axlfcreate "temp" '(0 0 0 200 2540 1 0 0 0 0 0 1 1) nil)
	foreach(film my_films_members;->groupMembers
		filmparams = axlGetParam(strcat("artwork:" film))
		axlDeleteObject(filmparams)
	)

; get conductor layers
	my_layers = axlGetParam("paramLayerGroup:etch")
	etchcount = 0
	i = 0
	foreach(layer my_layers->groupMembers
		layerparams = axlLayerGet(strcat("ETCH/" layer))
		if(layerparams->type=="PLANE" && layerparams->drcPhotoType=="negative" then
			pm = 0 ; plot mode negative
		else
			pm = 1 ; plot mode positive
		)
		sprintf(film_name "%d_%s" ++i layer)
		ld1 = strcat("VIA CLASS/" layer)
		ld2 = strcat("PIN/" layer)
		ld3 = strcat("ETCH/" layer)
		data_list = (list ld1 ld2 ld3)
		param_list = (list 0 0 0 ulw sbb pm 0 0 0 0 0 1 1)
		(axlfcreate film_name param_list data_list)
		++etchcount
	)

; Create drill layers gerber files
	param_list = (list 0 0 0 ulw sbb 1 0 0 0 0 0 1 1)
	drill_created = "YES"
	drill_count = 0
	my_layers = axlGetParam("paramLayerGroup:Manufacturing")
	foreach(layer my_layers->groupMembers
		if(nindex(layer "NCLEGEND")!=nil then
			ld1 = strcat("MANUFACTURING/" layer)
			data_list = (list ld1)
			film_name = layer
			(axlfcreate film_name param_list data_list)
			++drill_count
		else
			drill_created = "NO"

		)
	)
	if( drill_created == "NO" && drill_count == 0 then
		axlUIConfirm( "No drill drawing generated - Please create!" )
	)

	param_list = (list 0 0 0 ulw sbb 1 0 0 0 0 0 1 1)
; Board outline
	data_list = (list "BOARD GEOMETRY/OUTLINE")
	film_name = "Board_outline"
	(axlfcreate film_name param_list data_list)
; Soldermask top
	data_list = (list "PIN/SOLDERMASK_TOP" "VIA CLASS/SOLDERMASK_TOP" "PACKAGE GEOMETRY/SOLDERMASK_TOP" "BOARD GEOMETRY/SOLDERMASK_TOP")
	film_name = "Soldermask_top"
	(axlfcreate film_name param_list data_list)
; Soldermask bottom
	data_list = (list "PIN/SOLDERMASK_BOTTOM" "VIA CLASS/SOLDERMASK_BOTTOM" "PACKAGE GEOMETRY/SOLDERMASK_BOTTOM" "BOARD GEOMETRY/SOLDERMASK_BOTTOM")
	film_name = "Soldermask_bot"
	(axlfcreate film_name param_list data_list)

; Pastemask top
	data_list = (list "BOARD GEOMETRY/PASTEMASK_TOP" "VIA CLASS/PASTEMASK_TOP" "PIN/PASTEMASK_TOP")
	film_name = "Solderpaste_top"
	(axlfcreate film_name param_list data_list)


; Pastemask bottom
	data_list = (list "BOARD GEOMETRY/PASTEMASK_BOTTOM" "VIA CLASS/PASTEMASK_BOTTOM" "PIN/PASTEMASK_BOTTOM")
	film_name = "Solderpaste_bot"
	(axlfcreate film_name param_list data_list)

; Assembly top
	data_list = (list "MANUFACTURING/TITLE_BLOCK_TOP" "REF DES/ASSEMBLY_TOP" "PACKAGE GEOMETRY/ASSEMBLY_TOP")
	film_name = "Assembly_top"
	(axlfcreate film_name param_list data_list)

; Assembly bottom
	data_list = (list "MANUFACTURING/TITLE_BLOCK_BOTTOM" "REF DES/ASSEMBLY_BOTTOM" "PACKAGE GEOMETRY/ASSEMBLY_BOTTOM")
	film_name = "Assembly_bot"
	(axlfcreate film_name param_list data_list)

; Silkscreen top
	jobcounter = 71
	data_list = (list "PACKAGE GEOMETRY/SILKSCREEN_TOP" "BOARD GEOMETRY/SILKSCREEN_TOP" "REF DES/SILKSCREEN_TOP")
	film_name = "Silkscreen_top"
	(axlfcreate film_name param_list data_list)

; Silkscreen bottom
	data_list = (list "PACKAGE GEOMETRY/SILKSCREEN_BOTTOM" "BOARD GEOMETRY/SILKSCREEN_BOTTOM" "REF DES/SILKSCREEN_BOTTOM")
	film_name = "Silkscreen_bot"
	(axlfcreate film_name param_list data_list)

; Masterdrawing
	data_list = (list "Manufacturing/Stackup_figure")
	film_name = "Masterdrawing"
	(axlfcreate film_name param_list data_list)


; Delete temp layer
	filmparams = axlGetParam(strcat("artwork:" "temp"))
	axlDeleteObject(filmparams)

); end ns_gerber
axlCmdRegister( "ns_gerber" `ns_gerber)
