; drc_walk.il - Copyright 1994-96 Loral Federal Systems Owego
;
; drc walk - display DRCs in Allegro design
; layers   - show a group of class/subclass pairs for a given etch layer
;
;
; NO WARRANTY - This software is made available asis; and may not work
;  as advertised in all environment.
;
; This function works with Allegro 10+.
;
; This function will generate a list of DRCs in the current design, and
; allow the user to 'walk through' the list to inspect/verify/etc.
; User can filter the list of DRCs by layer and/or type. Select HELP
; from the drc walk menu for further details.
;
; This file also contains the layers function.
;
; Load the software (by including drc_walk.il in your allegro.ilinit file
;      or by explicity typing (load "drc_walk.il")  at your allegro command
;      line.
;
; This function builds its form & help screen in the /tmp directory
;
;  Created by:    Joe Morrison
;                 joe.morrison@lmco.com
;                 Loral Federal Systems-Owego
;
; This skill program demonstrates the following concepts:
;                 - File I/O
;                 - Asynchronous Forms & Callbacks
;                 - Manipulating design elements by database id
;                 - Create a sublist of items matching search criteria
;                 - viewfile creation
; Revision History
;    1.10    2001/05/13 Chris Walters
;                       corrected setting of _drcDir to work with any Unix or Windoze box
;    1.20    2002/07/18 Chris Walters
;                       changed the defaults for the Rollover List, Zoom To DRC and Zoom factor fields
;                       to enabled, enabled, and 2000, respectively
;                       added "NVIDIA Approved" to end of drcTypes list to be displayed - DONE
;                       added functionality such that choosing "NVIDIA Approved" brings up a list
;                           of all DRCs already marked as approved. DONE
;                       added Approve button. clicking Approve applies the approval symbol to the
;                           DRC, adds the DRC to "NVIDIA Approved" list and removes it from whichever
;                           nonapproved list it was selected from
;                       moved approve button to left edge
;                       made propagation-delay drcs visible when clicked
;                       removed drc_roll button from form
;                       enabled DRC Show Element button as default
;                       rewrote functions and list-handling such that approving a drc
;                           causes it to be immediately removed from the list and added to
;                           the approved list and decrement/increment the nonapproved/approved totals
;                           fixed glitch in removal-from-list function that didn't remove the FIRST
;                           DRC on the list
;                       updated visible layers dependant on DRC subclass and our own scripts
;                       slight correction to "ALL DRC subclass visible layer list
;                       add user-defined-property to approval symbol derived from DRC string
;                       to differentiate between DRCs at identical xy coordinates

(defun _drcZap ()
    line_list = nil
    axlClearSelSet()
    axlVisibleDesign(nil)
    axlVisibleLayer( lfsShowLayer t)
    axlSetFindFilter( ?enabled (list "noall" "lines" "clines" "invisible") ?onButtons (list "lines" "clines"))
    line_list = axlGetSelSet(axlAddSelectAll())
    foreach( line_db line_list
        axlDeleteObject( line_db)    ; delete every line off the subclass
    );end-foreach
    axlVisibleSet(vis_list)         ;restores color settings
    axlFlushDisplay()
);end-defun

(defun BuildApprovalList ()
; initialize tables and lists
approval_list = nil
all_drcs_key = nil
approval_table = makeTable("table0" nil)
all_drcs_list = nil
all_drcs_table = makeTable("table1" nil)
approved_drcs_list = nil
approved_drcs_table = makeTable("table2" nil)
nonapproved_drcs_list = nil
nonapproved_drcs_table = makeTable("table3" nil)
approval_tot = 0
all_drcs_tot = 0
approved_drcs_tot = 0
nonapproved_drcs_tot = 0

; build the list of pre-existing DRC-approval symbols
axlClearSelSet()
axlVisibleDesign(nil)
axlVisibleLayer("BOARD GEOMETRY/APPROVED_DRCS" t)
axlSetFindFilter( ?enabled (list "noall" "symbols") ?onButtons (list "symbols"))
approval_list = axlGetSelSet(axlAddSelectAll())
axlVisibleSet(vis_list)         ;restores color settings

; load approval table from list
foreach( approval_db approval_list
    app_key = cadr( car( axlDBGetProperties( approval_db)))
    approval_table[app_key] = approval_db
);end of foreach

; build unique keys for matching with property values on crosshairs later on 
foreach( drc_db drcs
    sprintf(drc_key, "%s%.2f%s%.2f%s%s%s%s%s%s%s%s%s%s",
                                             "x= " xCoord(drc_db->xy)
                                             " y= " yCoord(drc_db->xy)
                                             " name= " drc_db->name
                                             " type= " drc_db->type
                                             " layer= " drc_db->layer
                                             " expected= " drc_db->expected
                                             " actual= " drc_db->actual
    )
    all_drcs_table[drc_key] = drc_db
);end of foreach

; first weed out orphaned approvals
foreach( approval_key approval_table
    if( exists( all_drcs_key all_drcs_table ( all_drcs_key == approval_key )) then
        null( nil)                ; match
    else
        axlDeleteObject(approval_table[approval_key])
        remove( approval_key approval_table)    ; orphan approval
    );end-if
);end-foreach

; now start matching up approval symbols with DRCs
foreach( all_drcs_key all_drcs_table
    if( exists( approval_key approval_table ( all_drcs_key == approval_key )) then
         ; DRC has been approved
        approved_drcs_table[all_drcs_key] = all_drcs_table[all_drcs_key]
        approved_drcs_list  = cons( all_drcs_table[all_drcs_key] approved_drcs_list)
    else ; DRC has not been approved
        nonapproved_drcs_table[all_drcs_key] = all_drcs_table[all_drcs_key]
        nonapproved_drcs_list  = cons( all_drcs_table[all_drcs_key] nonapproved_drcs_list)
    );end-if
);end of foreach

; now gather totals
approval_tot = length( approval_list)
all_drcs_tot = length( all_drcs_table)
approved_drcs_tot = length( approved_drcs_table)
nonapproved_drcs_tot = length( nonapproved_drcs_table)
;rintf("%d%s\n", approval_tot "approval_tot")
;rintf("%d%s\n", all_drcs_tot "all_drcs_tot")
;rintf("%d%s\n", approved_drcs_tot "approved_drcs_tot")
;rintf("%d%s\n", nonapproved_drcs_tot "nonapproved_drcs_tot")

);end-defun

(defun _drcFormBuild ()
  (let (_drcPort)
    (setq _drcFormFile (strcat (makeTempFileName (strcat _drcDir "drc_walk")) ".form"))
    (setq _drcPort (outfile _drcFormFile))
   (fprintf _drcPort "FILE_TYPE=FORM_DEFN VERSION=2\n")
   (fprintf _drcPort "FORM\n")
   (fprintf _drcPort "FIXED\n")
   (fprintf _drcPort "PORT 70 16\n")
   (fprintf _drcPort "HEADER \"Allegro DRC Walker v1.20\"\n\n")
   (fprintf _drcPort "POPUP <drc_select_layer_p>\"a\"\"a\".\n")
   (fprintf _drcPort "POPUP <drc_select_type_p>\"a\"\"a\".\n\n\n")
   (fprintf _drcPort "TILE\n")
   (fprintf _drcPort "TEXT \"Layer:\"\n")
   (fprintf _drcPort "TLOC 2 2\n")
   (fprintf _drcPort "ENDTEXT\n\n")
   (fprintf _drcPort "TEXT \"Allegro DRC Walker v1.20\"\n")
   (fprintf _drcPort "TLOC 23 0\n")
   (fprintf _drcPort "ENDTEXT\n\n")
   (fprintf _drcPort "TEXT \"Matching DRCs\"\n")
   (fprintf _drcPort "TLOC 23 7\n")
   (fprintf _drcPort "ENDTEXT\n\n")
   (fprintf _drcPort "TEXT \"DRC Type:\"\n")
   (fprintf _drcPort "TLOC 2 4\n")
   (fprintf _drcPort "ENDTEXT\n\n")
   (fprintf _drcPort "TEXT \"DRC:\"\n")
   (fprintf _drcPort "TLOC 1 21\n")
   (fprintf _drcPort "ENDTEXT\n\n")
   (fprintf _drcPort "FIELD drc_select_layer\n")
   (fprintf _drcPort "FLOC 13 2\n")
   (fprintf _drcPort "ENUMSET 35\n")
   (fprintf _drcPort "POP \"drc_select_layer_p\"\n")
   (fprintf _drcPort "ENDFIELD\n\n")
   (fprintf _drcPort "FIELD drc_select_type\n")
   (fprintf _drcPort "FLOC 13 4\n")
   (fprintf _drcPort "ENUMSET 35\n")
   (fprintf _drcPort "POP \"drc_select_type_p\"\n")
   (fprintf _drcPort "ENDFIELD\n\n")
   (fprintf _drcPort "FIELD drc_list\n")
   (fprintf _drcPort "FLOC 5 9\n")
   (fprintf _drcPort "LIST \"Matching DRCs\" 50 5\n")
   (fprintf _drcPort "ENDFIELD\n\n")
   (fprintf _drcPort "FIELD drc_this\n")
   (fprintf _drcPort "FLOC 6 21\n")
   (fprintf _drcPort "INFO_ONLY\n")
   (fprintf _drcPort "STRFILLIN 57 57\n")
   (fprintf _drcPort "ENDFIELD\n\n")
   (fprintf _drcPort "FIELD drc_zoom\n")
   (fprintf _drcPort "FLOC 1 25\n")
   (fprintf _drcPort "CHECKLIST \"Zoom to DRC\"\n")
   (fprintf _drcPort "ENDFIELD\n\n")
   (fprintf _drcPort "FIELD drc_zoomsize\n")
   (fprintf _drcPort "FLOC 20 25\n")
   (fprintf _drcPort "INTSLIDEBAR 5 25\n")
   (fprintf _drcPort "MIN 1\n")
   (fprintf _drcPort "MAX 20\n")
   (fprintf _drcPort "ENDFIELD\n\n")
   (fprintf _drcPort "FIELD drc_showobj\n")
   (fprintf _drcPort "FLOC 32 25\n")
   (fprintf _drcPort "CHECKLIST \"DRC Show Element\"\n")
   (fprintf _drcPort "ENDFIELD\n\n")
   (fprintf _drcPort "FIELD lapprove\n")
   (fprintf _drcPort "FLOC  1 28\n")
   (fprintf _drcPort "MENUBUTTON \"Approve\" 8 3\n")
   (fprintf _drcPort "ENDFIELD\n\n")
   (fprintf _drcPort "FIELD drc_next\n")
   (fprintf _drcPort "FLOC 10 28\n")
   (fprintf _drcPort "MENUBUTTON \"Next\" 8 3\n")
   (fprintf _drcPort "ENDFIELD\n\n")
   (fprintf _drcPort "FIELD drc_prev\n")
   (fprintf _drcPort "FLOC 19 28\n")
   (fprintf _drcPort "MENUBUTTON \"Previous\" 12 3\n")
   (fprintf _drcPort "ENDFIELD\n\n")
   (fprintf _drcPort "FIELD drc_show\n")
   (fprintf _drcPort "FLOC 32 28\n")
   (fprintf _drcPort "MENUBUTTON \"Show\" 8 3\n")
   (fprintf _drcPort "ENDFIELD\n\n")
   (fprintf _drcPort "FIELD done\n")
   (fprintf _drcPort "FLOC 41 28\n")
   (fprintf _drcPort "MENUBUTTON \"Done\" 8 3\n")
   (fprintf _drcPort "ENDFIELD\n\n")
   (fprintf _drcPort "FIELD lhelp\n")
   (fprintf _drcPort "FLOC 50 28\n")
   (fprintf _drcPort "MENUBUTTON \"Help\" 8 3\n")
   (fprintf _drcPort "ENDFIELD\n\n")
   (fprintf _drcPort "ENDTILE\n\n")
   (fprintf _drcPort "ENDFORM\n")

     close(_drcPort)
     if(! isFile( _drcFormFile) then
        axlUIConfirm( (strcat "Unable to Open Form File, Check Permissions on " _drcDir))
        (_drcEnd)
     );if
  ) ; let
) ; defun - display form information

(defun _drcHelp ()
  (let (helpfile helpPort)
    (setq helpfile (strcat (makeTempFileName (strcat _drcDir "drcHelp")) ".txt"))
    (setq helpPort (outfile helpfile))
       (fprintf helpPort "     LAP Presents........\n\n")
       (fprintf helpPort "drc walk - A tool to inspect the Design Rule Check errors\n")
       (fprintf helpPort "in your Allegro design.\n\n")
       (fprintf helpPort "layers - A tool to turn on typical features for a given subclass of ETCH.\n")
       (fprintf helpPort "----------------------------------------------------------------------\n")
       (fprintf helpPort "The DRC Walker allows you to inspect DRC errors in your current\n")
       (fprintf helpPort "Allegro design, one at a time.  You can filter the DRC errors by\n")
       (fprintf helpPort "layer and/or DRC type.  The DRC to be inspected can either be\n")
       (fprintf helpPort "selected from the list by a mouse pick, or the user can 'walk'\n")
       (fprintf helpPort "through the list of errors using the 'next' and 'previous'\n")
       (fprintf helpPort "buttons.\n\n")
       (fprintf helpPort "Window title: the count of DRCs matching the currently selected\n")
       (fprintf helpPort "layer and type.\n\n")
       (fprintf helpPort "Layer: the list of all layers in the design containing DRC\n")
       (fprintf helpPort "errors.  You can select which layer to display using the middle\n")
       (fprintf helpPort "mouse button.\n\n")
       (fprintf helpPort "DRC Type: the list of all DRC errors currently flagged in this\n")
       (fprintf helpPort "design.  You can select which DRC to display by using the middle\n")
       (fprintf helpPort "mouse button.\n\n")
       (fprintf helpPort "Matching DRCs: the list of all DRCs that match the layer & type\n")
       (fprintf helpPort "selections.  Each line, which corresponds to one drc error, has a\n")
       (fprintf helpPort "sequence number, DRC error, the layer, and the x:y location.  You\n")
       (fprintf helpPort "can pick a particular DRC to examine with the left mouse button.\n")
       (fprintf helpPort "The currently displayed DRC is highlighted in the list.\n\n")
       (fprintf helpPort "DRC: an information only field that shows information about the\n")
       (fprintf helpPort "currently displayed DRC.\n\n")
       (fprintf helpPort "Rollover List: Normally, the 'next' button has no effect when you\n")
       (fprintf helpPort "select 'next' at the end of the list.  Similarly, 'previous' has\n")
       (fprintf helpPort "no effect when you select 'previous' at the top of the list.\n")
       (fprintf helpPort "Selecting the rollover checkbox causes 'next' at the last item to\n")
       (fprintf helpPort "show the first item in the list; and 'previous' at the first item\n")
       (fprintf helpPort "to show the last item.\n\n")
       (fprintf helpPort "DRC Show Element: If this box is selected, a 'show element'\n")
       (fprintf helpPort "window will appear to provide you with more information about the\n")
       (fprintf helpPort "current DRC.\n\n")
       (fprintf helpPort "Zoom to DRC: Normally, the full design is shown in the design\n")
       (fprintf helpPort "window. If 'Zoom to DRC' is selected, the design window will zoom\n")
       (fprintf helpPort "about the DRC. The size of the drc window is controlled by the\n")
       (fprintf helpPort "zoom factor field, which has a slider button to select the size.\n\n")
       (fprintf helpPort "Next: Pressing this button will cause the immediately following\n")
       (fprintf helpPort "DRC in the list to be displayed.\n\n")
       (fprintf helpPort "Previous: Pressing this button will cause the immediately prior\n")
       (fprintf helpPort "DRC in the list to be displayed.\n\n")
       (fprintf helpPort "Show: Redisplay the current DRC. This button is useful when you\n")
       (fprintf helpPort "change zooming or the show element controls.\n\n")
       (fprintf helpPort "Done: Exit from the DRC Walker\n\n")
       (fprintf helpPort "Help: Display this file.\n")
       (fprintf helpPort "---------------------------------------------------------------------\n\n")
       (fprintf helpPort "Layers:\n")
       (fprintf helpPort " invoke by typing:      layers [+,-] layername(s)\n")
       (fprintf helpPort " at the Allegro command line\n\n")
       (fprintf helpPort " Layername corresponds to one or more ETCH subclasses defined for\n")
       (fprintf helpPort "the current design.\n\n")
       (fprintf helpPort " A '+' causes the layer to be added to the current display\n")
       (fprintf helpPort "visibility, a '-' causes that layer to be removed. Normally, the\n")
       (fprintf helpPort "layers command causes all other currently displayed features to\n")
       (fprintf helpPort "be made invisible.\n\n")
       (fprintf helpPort " Classes involved:\n")
       (fprintf helpPort "        BOARD GEOMETRY/OUTLINE\n")
       (fprintf helpPort "        DRC ERROR CLASS/<layer>\n")
       (fprintf helpPort "        ETCH/<layer>\n")
       (fprintf helpPort "        PIN/<layer>\n")
       (fprintf helpPort "        VIA CLASS/<layer>\n")
       (fprintf helpPort "        VIA KEEPOUT/<layer>\n")
       (fprintf helpPort "        ROUTE KEEPOUT/<layer>\n")
       (fprintf helpPort "        PIN/FILMMASKTOP  - if <layer> = TOP\n")
       (fprintf helpPort "        PACKAGE GEOMETRY/ASSEMBLY_TOP  - if <layer> = TOP\n")
       (fprintf helpPort "        PIN/FILMMASKBOTTOM  - if <layer> = BOTTOM\n")
       (fprintf helpPort "        PACKAGE GEOMETRY/ASSEMBLY_BOTTOM  - if <layer> = BOTTOM\n\n")
       (fprintf helpPort "---------------------------------------------------------------------\n\n")
       (fprintf helpPort " Questions, Comments, Suggestions?\n\n")
       (fprintf helpPort " Contact\n Joe Morrison \t\t\tLoral Federal Systems-Owego\n")
       (fprintf helpPort " joe.morrison@lmco.com\t607+751-4938\n")

     close(helpPort)
     if(! isFile( helpfile) then
        axlUIConfirm( (strcat "Unable to Open Help File, Check Permissions on " _drcDir))
        (_drcEnd)
     else
        axlUIViewFileCreate( helpfile "LAP DRC Walker - Help" nil)
        (if (isFile helpfile) then
        (deleteFile helpfile)
    );end-if
     );end-if
  ) ; let
);end-defun

(procedure lfsSingleLayer( _layer @optional (vis t))    ; _layer contains subclass of drcdbid->layer
  lyr_is_etch = nil
  lyr_is_top = nil
  lyr_is_bot = nil
  lyr_is_int = nil
  lyr_is_pkgtop = nil
  lyr_is_pkgbot = nil
  lyr_is_all = nil
  if( member( _layer etch_layer_list) then        ; TOP INTn BOTTOM
      (equal lyr_is_etch t)
  );end-if
  cond(
        (_layer == "TOP"
            (equal lyr_is_top t)
            (axlVisibleLayer (strcat "BOARD GEOMETRY" "/" "OUTLINE") t)
            (axlVisibleLayer (strcat "VIA KEEPOUT" "/" "ALL") t)
            (axlVisibleLayer (strcat "ROUTE KEEPOUT" "/" "ALL") t)
            (axlVisibleLayer (strcat "BOARD GEOMETRY" "/" "CONSTRAINT_AREA") t)
            (axlVisibleLayer (strcat "DRAWING FORMAT" "/" "REVIEW_ETCH_" _layer) t)
            (axlVisibleLayer (strcat "DRC ERROR CLASS" "/" _layer) t)
            (axlVisibleLayer (strcat "ETCH" "/" _layer) t)
            (axlVisibleLayer (strcat "PIN" "/" _layer) t)
            (axlVisibleLayer (strcat "ROUTE KEEPIN" "/" "ALL") t)
            (axlVisibleLayer (strcat "VIA CLASS" "/" _layer) t)
            (axlVisibleLayer (strcat "PIN" "/" "SOLDERMASK_" _layer) t)
            (axlVisibleLayer (strcat "VIA_CLASS" "/" "SOLDERMASK_" _layer) t)
        )
          (_layer == "BOTTOM"
            (equal lyr_is_bot t)
            (axlVisibleLayer (strcat "BOARD GEOMETRY" "/" "OUTLINE") t)
            (axlVisibleLayer (strcat "VIA KEEPOUT" "/" "ALL") t)
            (axlVisibleLayer (strcat "ROUTE KEEPOUT" "/" "ALL") t)
            (axlVisibleLayer (strcat "BOARD GEOMETRY" "/" "CONSTRAINT_AREA") t)
            (axlVisibleLayer (strcat "DRAWING FORMAT" "/" "REVIEW_ETCH_" _layer) t)
            (axlVisibleLayer (strcat "DRC ERROR CLASS" "/" _layer) t)
            (axlVisibleLayer (strcat "ETCH" "/" _layer) t)
            (axlVisibleLayer (strcat "PIN" "/" _layer) t)
            (axlVisibleLayer (strcat "ROUTE KEEPIN" "/" "ALL") t)
            (axlVisibleLayer (strcat "VIA CLASS" "/" _layer) t)
            (axlVisibleLayer (strcat "PIN" "/" "SOLDERMASK_" _layer) t)
            (axlVisibleLayer (strcat "VIA_CLASS" "/" "SOLDERMASK_" _layer) t)
        )
          ( substring( _layer 1 3 ) == "INT"
            (equal lyr_is_int t)
            (axlVisibleLayer (strcat "BOARD GEOMETRY" "/" "OUTLINE") t)
            (axlVisibleLayer (strcat "VIA KEEPOUT" "/" "ALL") t)
            (axlVisibleLayer (strcat "ROUTE KEEPOUT" "/" "ALL") t)
            (axlVisibleLayer (strcat "BOARD GEOMETRY" "/" "CONSTRAINT_AREA") t)
            (axlVisibleLayer (strcat "DRAWING FORMAT" "/" "REVIEW_ETCH_" _layer) t)
            (axlVisibleLayer (strcat "DRC ERROR CLASS" "/" _layer) t)
            (axlVisibleLayer (strcat "ETCH" "/" _layer) t)
            (axlVisibleLayer (strcat "PIN" "/" _layer) t)
            (axlVisibleLayer (strcat "ROUTE KEEPIN" "/" "ALL") t)
            (axlVisibleLayer (strcat "VIA CLASS" "/" _layer) t)
        )
        (_layer == "PACKAGE_TOP"
            (equal lyr_is_pkgtop t)
            (axlVisibleLayer (strcat "BOARD GEOMETRY" "/" "OUTLINE") t)
            (axlVisibleLayer (strcat "VIA KEEPOUT" "/" "ALL") t)
            (axlVisibleLayer (strcat "ROUTE KEEPOUT" "/" "ALL") t)
            (axlVisibleLayer (strcat "BOARD GEOMETRY" "/" "TOP_ROOM") t)
            (axlVisibleLayer (strcat "BOARD GEOMETRY" "/" "PLACE_GRID_TOP") t)
            (axlVisibleLayer (strcat "BOARD GEOMETRY" "/" "SILKSCREEN_TOP") t)
            (axlVisibleLayer (strcat "BOARD GEOMETRY" "/" "SOLDERMASK_TOP") t)
            (axlVisibleLayer (strcat "BOARD GEOMETRY" "/" "TOOLING_CORNERS") t)
            (axlVisibleLayer (strcat "DRC ERROR CLASS" "/" _layer) t)
            (axlVisibleLayer (strcat "PACKAGE GEOMETRY" "/" "ASSEMBLY_TOP" ) t)
            (axlVisibleLayer (strcat "PACKAGE GEOMETRY" "/" "BODY_CENTER") t)
            (axlVisibleLayer (strcat "PACKAGE GEOMETRY" "/" "PLACE_BOUND_TOP" ) t)
            (axlVisibleLayer (strcat "PACKAGE GEOMETRY" "/" "SILKSCREEN_TOP" ) t)
            (axlVisibleLayer (strcat "PACKAGE GEOMETRY" "/" "SOLDERMASK_TOP" ) t)
            (axlVisibleLayer (strcat "PACKAGE KEEPOUT" "/" "ALL") t)
            (axlVisibleLayer (strcat "PIN" "/" "TOP") t)
            (axlVisibleLayer (strcat "PIN" "/" "SOLDERMASK_TOP" ) t)
        )
        (_layer == "PACKAGE_BOTTOM"
            (equal lyr_is_pkgbot t)
            (axlVisibleLayer (strcat "BOARD GEOMETRY" "/" "OUTLINE") t)
            (axlVisibleLayer (strcat "VIA KEEPOUT" "/" "ALL") t)
            (axlVisibleLayer (strcat "ROUTE KEEPOUT" "/" "ALL") t)
            (axlVisibleLayer (strcat "BOARD GEOMETRY" "/" "BOTTOM_ROOM") t)
            (axlVisibleLayer (strcat "BOARD GEOMETRY" "/" "PLACE_GRID_BOTTOM") t)
            (axlVisibleLayer (strcat "BOARD GEOMETRY" "/" "SILKSCREEN_BOTTOM") t)
            (axlVisibleLayer (strcat "BOARD GEOMETRY" "/" "SOLDERMASK_BOTTOM") t)
            (axlVisibleLayer (strcat "BOARD GEOMETRY" "/" "TOOLING_CORNERS") t)
            (axlVisibleLayer (strcat "DRC ERROR CLASS" "/" _layer) t)
            (axlVisibleLayer (strcat "PACKAGE GEOMETRY" "/" "ASSEMBLY_BOTTOM" ) t)
            (axlVisibleLayer (strcat "PACKAGE GEOMETRY" "/" "BODY_CENTER") t)
            (axlVisibleLayer (strcat "PACKAGE GEOMETRY" "/" "PLACE_BOUND_BOTTOM" ) t)
            (axlVisibleLayer (strcat "PACKAGE GEOMETRY" "/" "SILKSCREEN_BOTTOM" ) t)
            (axlVisibleLayer (strcat "PACKAGE GEOMETRY" "/" "SOLDERMASK_BOTTOM" ) t)
            (axlVisibleLayer (strcat "PACKAGE KEEPOUT" "/" "ALL") t)
            (axlVisibleLayer (strcat "PIN" "/" "BOTTOM") t)
            (axlVisibleLayer (strcat "PIN" "/" "SOLDERMASK_BOTTOM" ) t)
        )
        (_layer == "ALL"
            (equal lyr_is_all t)
            (axlVisibleLayer (strcat "BOARD GEOMETRY" "/" "OUTLINE") t)
            (axlVisibleLayer (strcat "VIA KEEPOUT" "/" "ALL") t)
            (axlVisibleLayer (strcat "ROUTE KEEPOUT" "/" "ALL") t)
            (axlVisibleLayer (strcat "BOARD GEOMETRY" "/" "CONSTRAINT_AREA") t)
            (axlVisibleLayer (strcat "BOARD GEOMETRY" "/" "REVIEW_ETCH_TOP") t)
            (axlVisibleLayer (strcat "BOARD GEOMETRY" "/" "REVIEW_ETCH_BOTTOM") t)
            (axlVisibleLayer (strcat "DRC ERROR CLASS" "/" _layer) t)
            (axlVisibleLayer (strcat "ETCH" "/" _layer) t)
            (axlVisibleLayer (strcat "PIN" "/" "SOLDERMASK_TOP" ) t)
            (axlVisibleLayer (strcat "PIN" "/" "SOLDERMASK_BOTTOM" ) t)
            (axlVisibleLayer (strcat "ROUTE KEEPIN" "/" _layer) t)
        )
  );end-cond
  t
) ; procedure - turn one layer on or off

(procedure lfsLayers( layer @rest args)        ; layer contains subclass of drcdbid->layer
;   (println  layer )
;   (println args)
   (setq _deferRedraw nil)
   (if (or  (or (equal layer "+") (equal layer "-")) (equal layer "*"))
      then
        (if (equal layer "*")
          then
           (setq _deferRedraw t)
          else
           (setq _deferRedraw nil)
;        (println "is  + or -")
        ) ; is a splat
      else
;        (println "not + or -")
        (axlVisibleDesign nil)
        (lfsSingleLayer layer t)
   ) ; turn off what's currently displayed

   (if (eq layer "-")
     then (setq visibility nil)
     else (setq visibility t)
   ) ; set visibility

   (foreach lyr args
;      (println lyr)
     (case lyr
        ("+"   (setq visibility t))
        ("-"   (setq visibility nil))
        (t     (lfsSingleLayer lyr visibility))
     ) ; case for argument stream
   ) ; foreach argument passed
   (if !_deferRedraw
     then
         (axlShell "redraw")
   ) ; if redraw not deferred
t
) ; procedure - turn on/off a set of layers


 ;;
 ;; lfsWindowExpand
 ;;
 ;; factor the size of a window
 ;;
 ;; basic function for all points is (F + 1)/2 * (point) - (F-1)/2 *opposite point
 ;; where F is the integer scaling factor
 ;;
 (procedure lfsWindowExpand( _window @optional (F 3))
     (let ((x1 (caar _window)) ; first item in first list
           (y1 (cadar _window)); second item in first list
           (x2 (caadr _window)) ; first item in second list
           (y2 (cadadr _window)); second item in second list
           f1 f2 f3 f4)
         (setq f1 (quotient (difference (times (plus F 1) x1)
                                        (times (difference F 1) x2)) 2))
         (setq f2 (quotient (difference (times (plus F 1) y1)
                                        (times (difference F 1) y2)) 2))
         (setq f3 (quotient (difference (times (plus F 1) x2)
                                        (times (difference F 1) x1)) 2))
         (setq f4 (quotient (difference (times (plus F 1) y2)
                                        (times (difference F 1) y1)) 2))
         (setq _window (list (list f1 f2) (list f3 f4)))
         (axlWindowBoxSet _window)
     ) ; let
     t
 ) ; lfsWindowExpand

(procedure lfsDRCFilterList(lfsLayerFilt lfsDRCFilt)
;=> lfsFilteredDRCs
lyrPart = ""
typPart = ""
(let ( lfsLayerClause lfsDRCClause tmpStr ctr drc_entry)
   (if (equal lfsLayerFilt "ALL") then
      (setq lfsLayerClause t)
      (setq lyrPart "")
    else
      (if (equal lfsLayerFilt "Approved") then
          (setq lfsLayerClause t)
          (setq lyrPart "")
       else
          (setq lfsLayerClause '(equal (cadr (parseString d1->layer "/")) lfsLayerFilt))
          (setq lyrPart (strcat " on " lfsLayerFilt))
      );end-if
   );end-if

   (if (equal lfsDRCFilt "ALL non-approved DRCs") then
          (setq lfsDRCClause t)
          (setq typPart "")
          (setq lfsDRCWorkingList (setof d1 nonapproved_drcs_list (and (eval lfsDRCClause) (eval lfsLayerClause))))
    else
        (if (equal lfsDRCFilt "Approved") then
            (setq lfsDRCClause t)
            (setq typPart "")
            (setq lfsDRCWorkingList (setof d1 approved_drcs_list (and (eval lfsDRCClause) (eval lfsLayerClause))))
        else
            (setq lfsDRCClause '(equal d1->name lfsDRCFilt))
            (setq typPart (strcat " " lfsDRCFilt))
            (setq lfsDRCWorkingList (setof d1 nonapproved_drcs_list (and (eval lfsDRCClause) (eval lfsLayerClause))))
        );end-if
   ) ; end if
   (setq lfsNumberDRCs (length lfsDRCWorkingList))
   if( lfsNumberDRCs == 0 then
       (axlFormSetFieldEditable _drcForm "lapprove" 0)    ; lock button
       (axlFormSetFieldEditable _drcForm "drc_prev" 0)    ; lock button
       (axlFormSetFieldEditable _drcForm "drc_next" 0)    ; lock button
   );end-if
   if( lfsNumberDRCs == 1 then
       (axlFormSetFieldEditable _drcForm "lapprove" 1)    ; unlock button
       (axlFormSetFieldEditable _drcForm "drc_prev" 0)    ; lock button
       (axlFormSetFieldEditable _drcForm "drc_next" 0)    ; lock button
   );end-if
   if( lfsNumberDRCs  > 1 then
       (axlFormSetFieldEditable _drcForm "lapprove" 1)    ; unlock button
       (axlFormSetFieldEditable _drcForm "drc_prev" 1)    ; unlock button
       (axlFormSetFieldEditable _drcForm "drc_next" 1)    ; unlock button
   );end-if
);end-let
   t
);end-defun

(defun lfsMarkPoint (loc)
; returns a list of dbids used to mark this location
; mark point using a diamond with extended points
(let  ((x (car loc))
       (y (cadr loc))
       (n (axlMKSConvert 1 "MILS"))
       (c (axlMKSConvert 75 "MILS"))
       (f (axlMKSConvert 500 "MILS"))
       (wid (axlMKSConvert 5 "MILS"))
       (dbid_list (list))
       pts)
 (if (nequal loc nil) then    ; valid location
     (setq pts (list x+c:y+1 x+1:y+c x:y+f x-1:y+c x-c:y+1 x-f:y
                  x-c:y-1 x-1:y-c x:y-f x+1:y-c x+c:y-1 x+f:y x+c:y+1))
     (setq db1 (axlDBCreateLine pts wid lfsShowLayer))
     (setq dbid_list (list (caar db1)))
     dbid_list
 else
     null( nil)
 );end-if
) ; end let for local variables
) ; defun mark a location for user attention

(defun _drcEnd ()
(axlFormClose _drcForm)
(axlDehighlightObject _drcHilites)
(axlDeleteObject _drcMarker)
(setq _drcHilites nil)
(setq _drcMarker nil)
(if (isFile _drcFormFile) then
    (deleteFile _drcFormFile)
);end-if

);end-defun

(procedure _drcShow( dbid)
(if (neq dbid nil) then
    (setq _drcMarker (lfsMarkPoint dbid->xy))
    (if _drcZoom then
        (lfsWindowExpand dbid->bBox _drcZoomSize)
    else
        (if _drcZoomDo then
            (axlWindowFit)
            (setq _drcZoomDo nil)
        );end-if
    );end-if
    (if (nequal _drcLastLayer dbid->layer) then
        (lfsLayers  (cadr (parseString dbid->layer "/")))
        (axlVisibleLayer lfsShowLayer t)
        (axlVisibleLayer "BOARD GEOMETRY/APPROVED_DRCS" t)
        (axlShell "redraw")
    );end-if
    (setq _drcLastLayer dbid->layer)
    (setq _drcHilites (list dbid))
    (foreach _viol dbid->violations
        (if (axlIsDBIDType _viol) then
            (setq _drcHilites (cons _viol _drcHilites))
        );end-if
    );end-foreach
    (axlHighlightObject _drcHilites)
    (if _drcShowObj then
        (axlShowObject _drcHilites)
    );end-if
);end-if
);end-procedure

(defun _drcUpdateDisp ()
(let (_tmpDB)
(foreach _tmpDB _drcHilites
    (if (nequal nil  _tmpDB->?) then
        (axlDehighlightObject _tmpDB)
    );end-if
);end-foreach
(foreach _tmpDB _drcMarker
    (if (nequal nil  _tmpDB->?) then
        (axlDeleteObject _tmpDB)
    );end-if
) ; foreach marker
(setq _drcHilites nil)
(setq _drcMarker nil)
(if (lfsNumberDRCs > 0) then
    (if (nequal nil  _drcDBID->?) then
        (_drcShow _drcDBID)
    else
        dcs=(axlDBGetDesign)->drcs
        (lfsDRCFilterList _drcCurrentLayer _drcCurrentType)
        (setq _drcLastLayer nil)
    );end-if
);end-if
(sprintf lfsDRCTitle "%d%s DRCs%s : %d Approved" lfsNumberDRCs typPart lyrPart approved_drcs_tot)
(axlFormTitle _drcForm lfsDRCTitle)
);end-let

);end-defun

(defun _drcCallBack ( foorm)    ; determine which button has been pushed and act accordingly
     (cond
        ((equal (get foorm 'curField) "drc_select_layer")
            (setq _drcCurrentLayer (get foorm 'curValue))
            (lfsDRCFilterList _drcCurrentLayer _drcCurrentType)
            (setq _drcLastLayer nil)
            _drcBuildDisplayList()
            ; force position list to 1
            (setq _drcCurrentNum 1)
            (setq _drcCurrentDRC (car lfsDisplayList))
            (axlFormListSelect foorm "drc_list" _drcCurrentDRC)
            (axlFormSetField foorm "drc_this" _drcCurrentDRC)
            (setq _drcDBID (nthelem _drcCurrentNum lfsDRCWorkingList))
            (_drcUpdateDisp )
        )
        ((equal (get foorm 'curField) "drc_select_type")
            (setq _drcCurrentType (get foorm 'curValue))
            (lfsDRCFilterList _drcCurrentLayer _drcCurrentType)
            (setq _drcLastLayer nil)
            _drcBuildDisplayList()
            ; force position list to 1
            (setq _drcCurrentNum 1)
            (setq _drcCurrentDRC (car lfsDisplayList))
            (axlFormListSelect foorm "drc_list" _drcCurrentDRC)
            (axlFormSetField foorm "drc_this" _drcCurrentDRC)
            (setq _drcDBID (nthelem _drcCurrentNum lfsDRCWorkingList))
            (_drcUpdateDisp )
        )
        ((equal (get foorm 'curField) "drc_list")
            ; positioned by clicking in list
            (setq _drcCurrentNum (add1 (get foorm 'curValueInt)))
            (setq _drcCurrentDRC (nthelem _drcCurrentNum lfsDisplayList))
            (axlFormListSelect foorm "drc_list" _drcCurrentDRC)
            (axlFormSetField foorm "drc_this" _drcCurrentDRC)
            (setq _drcDBID (nthelem _drcCurrentNum lfsDRCWorkingList))
            (_drcUpdateDisp )
        )
        ((equal (get foorm 'curField) "drc_prev")
            (axlFormSetFieldEditable foorm "drc_next" 1)    ; unlock button
            (setq _drcCurrentNum (sub1 _drcCurrentNum))
            (if _drcCurrentNum == 0 then
                (axlFormSetFieldEditable foorm "drc_prev" 0)    ; lock button
                (setq _drcCurrentNum (add1 _drcCurrentNum))        ; add back
            else
                (setq _drcCurrentDRC (nthelem _drcCurrentNum lfsDisplayList))
                (axlFormListSelect foorm "drc_list" _drcCurrentDRC)
                (axlFormSetField foorm "drc_this" _drcCurrentDRC)
                (setq _drcDBID (nthelem _drcCurrentNum lfsDRCWorkingList))
                (_drcUpdateDisp )
            );end-if
        )
        ((equal (get foorm 'curField) "drc_next")
            (axlFormSetFieldEditable foorm "drc_prev" 1)    ; unlock button
            (setq _drcCurrentNum (add1 _drcCurrentNum))
            (if _drcCurrentNum > lfsNumberDRCs then
                (axlFormSetFieldEditable foorm "drc_next" 0)    ; lock button
                (setq _drcCurrentNum (sub1 _drcCurrentNum))        ; add back
            else
                (setq _drcCurrentDRC (nthelem _drcCurrentNum lfsDisplayList))
                (axlFormListSelect foorm "drc_list" _drcCurrentDRC)
                (axlFormSetField foorm "drc_this" _drcCurrentDRC)
                (setq _drcDBID (nthelem _drcCurrentNum lfsDRCWorkingList))
                (_drcUpdateDisp )
            );end-if
        )
        ((equal (get foorm 'curField) "drc_showobj")
            (setq _drcShowObj (get foorm 'curValue))
        )
        ((equal (get foorm 'curField) "drc_zoom")
            (setq _drcZoom (get foorm 'curValue))
            (setq _drcZoomDo t)
            (setq _drcCurrentNum (add1 (get foorm 'curValueInt)))
            (setq _drcCurrentDRC (nthelem _drcCurrentNum lfsDisplayList))
            (axlFormListSelect foorm "drc_list" _drcCurrentDRC)
            (axlFormSetField foorm "drc_this" _drcCurrentDRC)
            (setq _drcDBID (nthelem _drcCurrentNum lfsDRCWorkingList))
            (_drcUpdateDisp )
        )
        ((equal (get foorm 'curField) "drc_zoomsize")
            (setq _drcZoomSize (get foorm 'curValue))
            (if _drcZoom then
                (setq _drcCurrentNum (add1 (get foorm 'curValueInt)))
                (setq _drcCurrentDRC (nthelem _drcCurrentNum lfsDisplayList))
                (axlFormListSelect foorm "drc_list" _drcCurrentDRC)
                (axlFormSetField foorm "drc_this" _drcCurrentDRC)
                (setq _drcDBID (nthelem _drcCurrentNum lfsDRCWorkingList))
                (_drcUpdateDisp )
            );end-if
        )
        ((equal (get foorm 'curField) "drc_show")
            (setq _drcCurrentNum (add1 (get foorm 'curValueInt)))
            (setq _drcCurrentDRC (nthelem _drcCurrentNum lfsDisplayList))
            (axlFormListSelect foorm "drc_list" _drcCurrentDRC)
            (axlFormSetField foorm "drc_this" _drcCurrentDRC)
            (setq _drcDBID (nthelem _drcCurrentNum lfsDRCWorkingList))
            (_drcUpdateDisp )
        )
        ((equal (get foorm 'curField) "lapprove")
            _drcApprove( _drcDBID)
            _drcBuildDisplayList()
            ; figure out new position on list force it for now
            (setq _drcCurrentNum 1)
            (setq _drcCurrentDRC (car lfsDisplayList))
            (axlFormListSelect foorm "drc_list" _drcCurrentDRC)
            (axlFormSetField foorm "drc_this" _drcCurrentDRC)
            (setq _drcDBID (nthelem _drcCurrentNum lfsDRCWorkingList))
            (_drcUpdateDisp )
        )
        ((equal (get foorm 'curField) "lhelp")
            (_drcHelp)
        )
        ((equal (get foorm 'curField) "done")
            (_drcEnd)
        )
     );end-cond

     axlFlushDisplay()        ; now, refresh the display so all this stuff REALLY happens
);end-defun

(defun _drcBuildDisplayList ()
; creates the list that gets displayed in the listbox on the form
(setq lfsDisplayList nil)
(axlFormListDeleteAll _drcForm "drc_list")
(setq ctr 1)
; build display list from working list
(foreach drc lfsDRCWorkingList
    (sprintf tmpStr "%d %s on %s %g:%g"
        ctr
        drc->name
        (cadr (parseString drc->layer "/"))
        (car drc->xy)
        (cadr drc->xy)
    );end-sprintf
    (setq lfsDisplayList (cons tmpStr lfsDisplayList))
    (setq ctr (add1 ctr))
);end-foreach
(setq lfsDisplayList (reverse lfsDisplayList))
; now refresh drc_list in form with display list
(foreach drc_entry lfsDisplayList
    (axlFormSetField _drcForm "drc_list" drc_entry)
);end-foreach
(axlFormSetField _drcForm "drc_list" nil)    ; this forces refresh to become visible
;    (setq _drcCurrentDRC (car lfsDisplayList))
;    (setq _drcCurrentNum 1)
;    (axlFormSetField _drcForm "drc_this" _drcCurrentDRC)
);end-defun

(defun _drcApprove ( dbid)            ; a nonapproved DRC has just been approved

sprintf(drc_key, "%s%.2f%s%.2f%s%s%s%s%s%s%s%s%s%s",
                                         "x= " xCoord(dbid->xy)
                                         " y= " yCoord(dbid->xy)
                                         " name= " dbid->name
                                         " type= " dbid->type
                                         " layer= " dbid->layer
                                         " expected= " dbid->expected
                                         " actual= " dbid->actual
)

; remove from nonapproved table and list
templist = remd( dbid nonapproved_drcs_list)    ; need to do this trick cuz
nonapproved_drcs_list = templist                ; remd does not work on first element
remove( drc_key nonapproved_drcs_table)
nonapproved_drcs_tot = length( nonapproved_drcs_table)

; add to approved table and list
approved_drcs_list = cons( dbid approved_drcs_list)
approved_drcs_table[drc_key] = dbid
approval_table[drc_key] = dbid
approved_drcs_tot = length( approved_drcs_table)

; place the approval symbol
l_symboldata = list( "APPROVED_DRC" "FORMAT")        ; new-style xhair
appsym_db = axlDBCreateSymbol( l_symboldata dbid->xy)
axlDBAddProp( appsym_db list("APPROVED_DRC" drc_key))
approval_list = cons( appsym_db approval_list)

; remove current drc from lfsDRCWorkingList
templist = remd( dbid lfsDRCWorkingList)        ; need to do this trick cuz
lfsDRCWorkingList = templist                    ; remd does not work on first element
(setq lfsNumberDRCs (length lfsDRCWorkingList))
if( lfsNumberDRCs == 0 then
    (axlFormSetFieldEditable _drcForm "lapprove" 0)    ; lock button
);end-if

);end-defun

(defun drc_main ()

boardname = axlCurrentDesign()
boardname_str = ""
boardname_str = strcat( boardname ".brd")

vis_list = axlVisibleGet()       ;saves color settings
templist = nil                    ; used to make sure remd works

(setq lfsShowLayer "Board Geometry/lfs_utilities")
(setq lfsApprovalLayer "BOARD GEOMETRY/APPROVED_DRCS")
(if (axlIsLayer lfsApprovalLayer) then
    null( nil)
else
    axlLayerCreateNonConductor( lfsApprovalLayer)
    printf("%s\n","created subclass to hold approval markers")
);end-if
(if (axlIsLayer lfsShowLayer) then
    null( nil)
else
    (axlLayerCreateNonConductor lfsShowLayer)
);end-if

; create the user-defined property for attachment to individual approval symbols
drcapproval_prop  = axlDBCreatePropDictEntry( "APPROVED_DRC", "STRING", list( "SYMBOLS"))

; Build the list of all DRCs
drcs=(axlDBGetDesign)->drcs
etch_layer_list= axlGetParam("paramLayerGroup:ETCH")->groupMembers

BuildApprovalList()

; open the form
; (setq _drcDir "/tmp/") -- original code doesnt work on Winbloze boxes
(setq _drcDir getWorkingDir() )
(_drcFormBuild)
(axlFormCreate '_drcForm _drcFormFile '("east" "outer") '_drcCallBack t)
_lyrList=cons("ALL" etch_layer_list)
; build the available layers popup

drcTypes=(list "ALL non-approved DRCs")
; build list of drctypes & layers
(foreach tmpDRC drcs
    (if (!(member tmpDRC->name drcTypes)) then
        drcTypes=(cons  tmpDRC->name drcTypes)
    );end-if
    (setq _chkLayer (cadr (parseString tmpDRC->layer "/")))
    (if (!(member _chkLayer _lyrList)) then
        (setq _lyrList (append1 _lyrList _chkLayer))
    );end-if
);end-foreach
drcTypes=(cons "Approved" drcTypes)    ; added v 1.12
drcTypes=(reverse drcTypes)

(axlFormBuildPopup _drcForm "drc_select_layer" _lyrList)
(axlFormBuildPopup _drcForm "drc_select_type" drcTypes)

; set the default layer name into the form
(setq _drcCurrentLayer "ALL")
(setq _drcCurrentType  "ALL non-approved DRCs")
(setq _drcZoom     t) ; in rev B changed default to t
(setq _drcZoomDo   t)
(setq _drcHilites nil)
(setq _drcMarker nil)
(setq _drcLastLayer nil)
(setq _drcShowObj t)
(setq _drcZoomSize 5)    ; in rev B changed default to 2000 from 300

(axlFormSetField _drcForm "drc_select_layer" _drcCurrentLayer)
(axlFormSetField _drcForm "drc_select_type"  _drcCurrentType)
(axlFormSetField _drcForm "drc_zoom" _drcZoom)
(axlFormSetField _drcForm "drc_showobj" _drcShowObj)
(axlFormSetField _drcForm "drc_zoomsize" _drcZoomSize)

; Build the DRC List
(lfsDRCFilterList _drcCurrentLayer _drcCurrentType)
(setq _drcLastLayer nil)
_drcBuildDisplayList()
; position list at one
(setq _drcCurrentNum 1)
(setq _drcCurrentDRC (car lfsDisplayList))
(axlFormSetField _drcForm "drc_this" _drcCurrentDRC)
(setq _drcDBID (nthelem _drcCurrentNum lfsDRCWorkingList))
(_drcUpdateDisp )

; and display the form
axlFormDisplay( _drcForm)

) ; end drc_main

(axlCmdRegister "drc walk" 'drc_main)
(axlCmdRegister "layers" 'lfsLayers)
