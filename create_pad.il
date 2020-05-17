/********************************************************/
/*               Title :  Create Pad                    */
/*     Execute Command :  create pad                    */
/*              Author :  Vivien Luo                    */
/*       Creation Date :  2013-10-24                    */
/*               Update :                               */
/*              E-mail :  admin@allegro-skill.com       */
/********************************************************/
axlCmdRegister("cpad" 'create_pad)
;axlSetFunckey("cpad" "cpad")
defun(create_pad ()
let((create_pad_form)
    CreatePadForm()
    ;axlFormTest("./create_pad.form")
    create_pad_form = axlFormCreate((gensym) "./create_pad.form" nil 'CreatePadFormAction t nil)
    axlFormDisplay(create_pad_form)
    deleteFile("./create_pad.form")
    curPadType = "Smd_Pad"
    axlFormSetField(create_pad_form "cirPad" t)
    axlFormSetFieldEditable(create_pad_form "cirPadWidth" nil)
    axlFormSetFieldEditable(create_pad_form "cirPadHeight" nil)
    axlUIWPrint(create_pad_form "Written By Vivien Luo --> ^_^~~~")
);end let
);end defun

defun( CreatePadFormAction (create_pad_form)
let((drillSize)
    case(create_pad_form->curField
    ("tab"
        curPadType = create_pad_form->curValue
    )
    ("cirNPH"
        if(create_pad_form->curValue
        then
            axlFormSetField(create_pad_form "cirPadSize" nil)
            axlFormSetField(create_pad_form "cirPadWidth" nil)
            axlFormSetField(create_pad_form "cirPadHeight" nil)
            cirPadFieldEditable(create_pad_form->curValue)
        else
            cirPadFieldEditable(create_pad_form->curValue)
            drillSize = axlFormGetField(create_pad_form "cirDrillSize")
            when(axlFormGetField(create_pad_form "cirNPH") == nil && drillSize && axlFormGetField(create_pad_form "cirPad")
            axlFormSetField(create_pad_form "cirPadSize" drillSize + 20)
            );end when
        );end if
    )
    ("cirDrillSize"
        when(axlFormGetField(create_pad_form "cirNPH") == nil && axlFormGetField(create_pad_form "cirPad")
            axlFormSetField(create_pad_form "cirPadSize" create_pad_form->curValue+20)
        )
    )
    ("cirPad"
        axlFormSetField(create_pad_form "cirPadWidth" nil)
        axlFormSetField(create_pad_form "cirPadHeight" nil)
        axlFormSetFieldEditable(create_pad_form "cirPadSize" t) 
        axlFormSetFieldEditable(create_pad_form "cirPadWidth" nil)
        axlFormSetFieldEditable(create_pad_form "cirPadHeight" nil)
        drillSize = axlFormGetField(create_pad_form "cirDrillSize")
        when(drillSize
            axlFormSetField(create_pad_form "cirPadSize" drillSize + 20)
        );end when
    )
    ("cirRect" || "cirOblong"
        axlFormSetField(create_pad_form "cirPadSize" nil)
        axlFormSetFieldEditable(create_pad_form "cirPadSize" nil) 
        axlFormSetFieldEditable(create_pad_form "cirPadWidth" t)
        axlFormSetFieldEditable(create_pad_form "cirPadHeight" t)
    )
    ("oblNPH"
        if(create_pad_form->curValue == t
        then
            axlFormSetField(create_pad_form "oblPadWidth" nil)
            axlFormSetField(create_pad_form "oblPadHeight" nil)
            axlFormSetFieldEditable(create_pad_form "oblPadWidth" nil)
            axlFormSetFieldEditable(create_pad_form "oblPadHeight" nil)
        else
            axlFormSetFieldEditable(create_pad_form "oblPadWidth" t)
            axlFormSetFieldEditable(create_pad_form "oblPadHeight" t)
            when(axlFormGetField(create_pad_form "oblDrillWidth") > 0
                axlFormSetField(create_pad_form "oblPadWidth" axlFormGetField(create_pad_form "oblDrillWidth")+20)
            );end when
            when(axlFormGetField(create_pad_form "oblDrillHeight") > 0
                axlFormSetField(create_pad_form "oblPadHeight" axlFormGetField(create_pad_form "oblDrillHeight")+20)
            );end when
        );end if
    )
    ("oblDrillWidth"
        when(axlFormGetField(create_pad_form "oblNPH") == nil 
            axlFormSetField(create_pad_form "oblPadWidth" create_pad_form->curValue+20)
        )
    )
    ("oblDrillHeight"
        when(axlFormGetField(create_pad_form "oblNPH") == nil
            axlFormSetField(create_pad_form "oblPadHeight" create_pad_form->curValue+20)
        )
    )
    ("CreatePad"
        case(curPadType
        ("Smd_Pad"
            createSmdPad()
        )
        ("Circle_Hole"
            createCirclePad()
        )
        ("Oblong_Hole"
            createOblongPad()
        )
        );end case
    )
    ("EXITPAD"
        axlFormClose(create_pad_form)
    )
    );end case
);end let
);end defun

defun( createOblongPad ()
let((dirllWidth drillHeight padWidth padHeight padName pad_list oblDrillChar padID flashChar drillType)
    dirllWidth = axlFormGetField(create_pad_form "oblDrillWidth")
    drillHeight = axlFormGetField(create_pad_form "oblDrillHeight")
    if(dirllWidth == 0 || drillHeight == 0 
    then
        axlUIConfirm("ERROR:\nDrill Size must greater than 0 .\nOr Width is equal to Height .")
    else
        ;get the dril char
        if(dirllWidth>drillHeight
        then
            sprintf(oblDrillChar "%d" drillHeight)            
            sprintf(flashChar "%d" dirllWidth+30)
        else
            sprintf(oblDrillChar "%d" dirllWidth)
            sprintf(flashChar "%d" drillHeight+30)
        )
        if(axlFormGetField(create_pad_form "oblNPH")
        then
            padWidth = dirllWidth
            padHeight = drillHeight
            sprintf(padName "OB%d_%dX%d_%dU" dirllWidth drillHeight padWidth padHeight)
            drillType = 'NON_PLATED
        else
            padWidth = axlFormGetField(create_pad_form "oblPadWidth")
            padHeight = axlFormGetField(create_pad_form "oblPadHeight")
            if(padWidth >= dirllWidth && padHeight >= drillHeight
            then
                sprintf(padName "OB%d_%dX%d_%dD" padWidth padHeight dirllWidth drillHeight)
            else
                axlUIConfirm("ERROR:\nPad size must be greater than Drill size.")    
            )
            drillType = 'PLATED
        );end if
        when(padName
            ;axlUIConfirm(padName)
            ;create drill size
            drill_data = make_axlPadStackDrill(?slotSize dirllWidth:drillHeight, ?holeType 'OVAL_SLOT , ?drillChar oblDrillChar ?plating drillType)
            ;create top layer and bottom layer
            pad_list = cons(make_axlPadStackPad(?layer "TOP",?type 'REGULAR, ?figure 'OBLONG, ?figureSize padWidth:padHeight) nil)
            pad_list = cons(make_axlPadStackPad(?layer "BOTTOM", ?type 'REGULAR, ?figure 'OBLONG, ?figureSize padWidth:padHeight) pad_list)
            ;create internal layer
            pad_list = cons(make_axlPadStackPad(?layer "DEFAULT INTERNAL", ?type 'REGULAR, ?figure 'OBLONG, 
                    ?figureSize padWidth:padHeight) pad_list)
            pad_list = cons(make_axlPadStackPad(?layer "DEFAULT INTERNAL", ?type 'THERMAL, ?figure 'OBLONG, 
                        ?figureSize dirllWidth+30:drillHeight+30 ?flash flashChar) pad_list)
            pad_list = cons(make_axlPadStackPad(?layer "DEFAULT INTERNAL", ?type 'ANTIPAD, ?figure 'OBLONG, 
                        ?figureSize dirllWidth+30:drillHeight+30) pad_list)
            ;create soldermask of top and bottom
            pad_list = cons(make_axlPadStackPad(?layer "SOLDERMASK_TOP",?type 'REGULAR, ?figure 'OBLONG, 
                        ?figureSize padWidth+6:padHeight+6) pad_list)
            pad_list = cons(make_axlPadStackPad(?layer "SOLDERMASK_BOTTOM", ?type 'REGULAR, ?figure 'OBLONG, 
                        ?figureSize padWidth+6:padHeight+6) pad_list)
                        
            padID = axlDBCreatePadStack(padName, drill_data, pad_list , t)
            if(padID
            then
                axlUIConfirm(strcat("PAD \"" padName "\" create sucessful..."))
            else
                axlUIConfirm("Pad stack already exists")
            );end if
        )
    );end if    
);end let
);end defun

defun(createCirclePad ()
let((drillSize width height padName pad_list drill_data padID figureType drillFigureSize padSize drillType) 
    drillSize = axlFormGetField(create_pad_form "cirDrillSize")
    drillFigureSize = 100
    when(drillSize <= 50
    drillFigureSize = 50
    );end when
    if(drillSize == 0 
    then
        ;Create NPH PAD
        axlUIConfirm("ERROR:\nDrill Size must greater than 0 .")
    else
        ;get attribute of pad 
        if(axlFormGetField(create_pad_form "cirNPH") 
        then
            sprintf(padName "PAD%dCIR%dU" drillSize drillSize)
            padWidth = padHeight = drillSize
            figureType = 'CIRCLE
            drillType = 'NON_PLATED
        else
            ;pad is circle
            when(axlFormGetField(create_pad_form "cirPad")
                padSize = axlFormGetField(create_pad_form "cirPadSize")
                padWidth = padHeight = padSize
                sprintf( padName "PAD%dCIR%dD" padSize drillSize)
                figureType = 'CIRCLE
            );end when
            ;pad is RECT
            when(axlFormGetField(create_pad_form "cirRect")
                padWidth = axlFormGetField(create_pad_form "cirPadWidth")
                padHeight = axlFormGetField(create_pad_form "cirPadHeight")
                if(padWidth == padHeight
                then
                    sprintf( padName "PAD%dSQ%dD" padWidth drillSize)
                    figureType = 'SQUARE
                else
                    sprintf( padName "RE%d_%dCIR%dD" padWidth padHeight drillSize)
                    figureType = 'RECTANGLE
                );end if
                                
            );end when
            ;pad is Oblong
            when(axlFormGetField(create_pad_form "cirOblong")
                padWidth = axlFormGetField(create_pad_form "cirPadWidth")
                padHeight = axlFormGetField(create_pad_form "cirPadHeight")
                ;can't create oblong pad if the Width is equal to the Height
                if(padWidth != padHeight && padWidth >= drillSize && padHeight >= drillSize
                then
                    sprintf( padName "OB%d_%dCIR%dD" padWidth padHeight drillSize)
                else
                    axlUIConfirm("ERROR:\nWidth is equal to Height,or less than Drill Size.")    
                );end if
                figureType = 'OBLONG
            );end when    
            drillType = 'PLATED        
        );end if
        ;axlUIConfirm(strcat("Pad Name:" padName))
    );end if 
    ;checked ok,then create the pad.
    when(drillSize != 0 && padName
        drill_data = make_axlPadStackDrill(?drillDiameter drillSize, ?holeType 'CIRCLE_DRILL , ?drillChar sprintf(nil "%d" drillSize)
                    ?figure 'CIRCLE, ?figureSize drillFigureSize:drillFigureSize, ?plating drillType)
        ;create top layer and bottom layer
        pad_list = cons(make_axlPadStackPad(?layer "TOP",?type 'REGULAR, ?figure figureType, ?figureSize padWidth:padHeight) nil)
        pad_list = cons(make_axlPadStackPad(?layer "BOTTOM", ?type 'REGULAR, ?figure figureType, ?figureSize padWidth:padHeight) pad_list)
        ;create internal layer
        ;if top and bottom layer is oblong or RECTANGLE then INTERNAL REGULAR regular pad default greater 20 than drill size
        if(axlFormGetField(create_pad_form "cirOblong") || axlFormGetField(create_pad_form "cirRect")
        then
        pad_list = cons(make_axlPadStackPad(?layer "DEFAULT INTERNAL", ?type 'REGULAR, ?figure 'CIRCLE, 
                    ?figureSize drillSize+20:drillSize+20) pad_list)
        else
        pad_list = cons(make_axlPadStackPad(?layer "DEFAULT INTERNAL", ?type 'REGULAR, ?figure 'CIRCLE, 
                    ?figureSize padWidth:padHeight) pad_list)
        );endif
        pad_list = cons(make_axlPadStackPad(?layer "DEFAULT INTERNAL", ?type 'THERMAL, ?figure 'CIRCLE, 
                    ?figureSize drillSize+30:drillSize+30 ?flash sprintf(nil "%d" drillSize+30)) pad_list)
        pad_list = cons(make_axlPadStackPad(?layer "DEFAULT INTERNAL", ?type 'ANTIPAD, ?figure 'CIRCLE, 
                    ?figureSize drillSize+30:drillSize+30) pad_list)
        ;create soldermask of top and bottom
        pad_list = cons(make_axlPadStackPad(?layer "SOLDERMASK_TOP",?type 'REGULAR, ?figure figureType, 
                    ?figureSize padWidth+6:padHeight+6) pad_list)
        pad_list = cons(make_axlPadStackPad(?layer "SOLDERMASK_BOTTOM", ?type 'REGULAR, ?figure figureType, 
                    ?figureSize padWidth+6:padHeight+6) pad_list)
        padID = axlDBCreatePadStack(padName, drill_data, pad_list t)
        if(padID
        then
            axlUIConfirm(strcat("PAD \"" padName "\" create sucessful..."))
        else
            axlUIConfirm("Pad stack already exists")
        )
    );end when
);end let
);end defun

defun( createSmdPad ()
let((width height padName pad_list padFigure padID)
    width = axlFormGetField(create_pad_form "smdWidth")
    height = axlFormGetField(create_pad_form "smdHeight")
    ;get pad name
    if(axlFormGetField(create_pad_form "smdOblong") == t
    then
        if(width == height
        then
            sprintf(padName "BALL%d" width)
            padFigure = 'CIRCLE
        else
            sprintf(padName "SMD%d_%dOB" width height)
            padFigure = 'OBLONG
        )
    else
        sprintf(padName "SMD%d_%d" width height)
        if(width == height
        then
            padFigure = 'SQUARE
        else
            padFigure = 'RECTANGLE
        )        
    )
    ;create TOP layer of pad
    pad_list = cons(make_axlPadStackPad(
                ?layer "TOP", ?type 'REGULAR,
                ?figure padFigure, ?figureSize width:height) nil)
    ;create PASTMASK layer of pad
    pad_list = cons(make_axlPadStackPad(
                ?layer "PASTEMASK_TOP", ?type 'REGULAR,
                ?figure padFigure, ?figureSize width:height) pad_list)
    ;create SOLDERMASK layer of pad
    pad_list = cons(make_axlPadStackPad(
                ?layer "SOLDERMASK_TOP", ?type 'REGULAR,
                ?figure padFigure, ?figureSize width+5:height+5) pad_list)
    if(width != 0 && height!= 0 
    then
        padID = axlDBCreatePadStack(padName, nil, pad_list t)
        if(padID
        then
            axlUIConfirm(strcat("PAD \"" padName "\" create sucessful..."))
        else
            axlUIConfirm("Pad stack already exists")
        )
    else
        axlUIConfirm("ERROR:\nWidth or Height must greater than 0.")
    )
);end let
);end defun

defun(cirPadFieldEditable (Editable)
if(Editable == t
    then
        axlFormSetFieldEditable(create_pad_form "cirPad" nil)
        axlFormSetFieldEditable(create_pad_form "cirOblong" nil)
        axlFormSetFieldEditable(create_pad_form "cirPadSize" nil) 
        axlFormSetFieldEditable(create_pad_form "cirPadWidth" nil)
        axlFormSetFieldEditable(create_pad_form "cirPadHeight" nil)
        axlFormSetFieldEditable(create_pad_form "cirRect" nil)
    else        
        axlFormSetFieldEditable(create_pad_form "cirPad" t)
        axlFormSetFieldEditable(create_pad_form "cirOblong" t)
        axlFormSetFieldEditable(create_pad_form "cirRect" t)
        if(axlFormGetField(create_pad_form "cirPad") == t
        then
        axlFormSetFieldEditable(create_pad_form "cirPadSize" t) 
        else
        axlFormSetFieldEditable(create_pad_form "cirPadWidth" t)
        axlFormSetFieldEditable(create_pad_form "cirPadHeight" t)
        );end if
);end if

);end defun

defun( CreatePadForm ()
    create_pad_port = outfile("./create_pad.form")
    fprintf(create_pad_port "FILE_TYPE = FORM_DEFN VERSION=2\n")
    fprintf(create_pad_port "FORM\n")
    fprintf(create_pad_port "FIXED\n")
    fprintf(create_pad_port "PORT 40 35\n")
    fprintf(create_pad_port "HEADER \"Create Pad Ver 1.0\"\n")
    fprintf(create_pad_port "TILE\n\n")
    
    fprintf(create_pad_port "TABSET \"tab\"\n")
    fprintf(create_pad_port "OPTIONS tabsetDispatch\n")
    fprintf(create_pad_port "FLOC 2 1\n")
    fprintf(create_pad_port "FSIZE 35 17\n")
/*-------------------    SMD PAD TAB   ------------------*/
    fprintf(create_pad_port "TAB \"Smd Pad\"\n\n")
        
    fprintf(create_pad_port "TEXT \"Width :\"\n")
    fprintf(create_pad_port "TLOC 2 1\n")
    fprintf(create_pad_port "ENDTEXT\n\n")
    
    fprintf(create_pad_port "FIELD smdWidth\n")
    fprintf(create_pad_port "FLOC 8 1\n")
    fprintf(create_pad_port "INTFILLIN 5 10\n")
    fprintf(create_pad_port "MIN 0\n")
    fprintf(create_pad_port "ENDFIELD\n\n")
    
    fprintf(create_pad_port "TEXT \"Height :\"\n")
    fprintf(create_pad_port "TLOC 17 1\n")
    fprintf(create_pad_port "ENDTEXT\n\n")
    
    fprintf(create_pad_port "FIELD smdHeight\n")
    fprintf(create_pad_port "FLOC 23 1\n")
    fprintf(create_pad_port "INTFILLIN 5 10\n")
    fprintf(create_pad_port "MIN 0\n")
    fprintf(create_pad_port "ENDFIELD\n\n")
    
    fprintf(create_pad_port "FIELD smdOblong\n")
    fprintf(create_pad_port "FLOC 8 4\n")
    fprintf(create_pad_port "CHECKLIST \"Oblong\"\n")
    fprintf(create_pad_port "ENDFIELD\n\n")    
    
    fprintf(create_pad_port "TEXT \"Written By Vivien Luo\"\n")
    fprintf(create_pad_port "TLOC 8 8\n")
    fprintf(create_pad_port "ENDTEXT\n\n")
    
    fprintf(create_pad_port "TEXT \"Email:admin@allegro-skill.com\"\n")
    fprintf(create_pad_port "TLOC 8 10\n")
    fprintf(create_pad_port "ENDTEXT\n\n")
    
    fprintf(create_pad_port "TEXT \"Cadence Skill\302\333\314\263 2013-10-28\"\n")
    fprintf(create_pad_port "TLOC 8 12\n")
    fprintf(create_pad_port "ENDTEXT\n\n")
    
    fprintf(create_pad_port "GROUP \"About Author\"\n")
    fprintf(create_pad_port "GLOC 6 6\n")
    fprintf(create_pad_port "GSIZE 24 8\n")
    fprintf(create_pad_port "ENDGROUP\n\n")    
    
    fprintf(create_pad_port "ENDTAB\n\n")
    
/*-------------------    Circle Hole TAB   ------------------*/    
    fprintf(create_pad_port "TAB \"Circle Hole\"\n\n")
    
    fprintf(create_pad_port "TEXT \"Drill Size:\"\n")
    fprintf(create_pad_port "TLOC 3 1\n")
    fprintf(create_pad_port "ENDTEXT\n\n")
    
    fprintf(create_pad_port "FIELD cirDrillSize\n")
    fprintf(create_pad_port "FLOC 11 1\n")
    fprintf(create_pad_port "INTFILLIN 5 10\n")
    fprintf(create_pad_port "ENDFIELD\n\n")
        
    fprintf(create_pad_port "FIELD cirNPH\n")
    fprintf(create_pad_port "FLOC 19 1\n")
    fprintf(create_pad_port "CHECKLIST \"Non-Plated\"\n")
    fprintf(create_pad_port "ENDFIELD\n\n")
    
    fprintf(create_pad_port "FIELD cirPad\n")
    fprintf(create_pad_port "FLOC 19 5\n")
    fprintf(create_pad_port "CHECKLIST \"Circle Pad\" padType\n")
    fprintf(create_pad_port "ENDFIELD\n\n")
    
    fprintf(create_pad_port "FIELD cirRect\n")
    fprintf(create_pad_port "FLOC 19 8\n")
    fprintf(create_pad_port "CHECKLIST \"Rectangle\" padType\n")
    fprintf(create_pad_port "ENDFIELD\n\n")
    
    fprintf(create_pad_port "FIELD cirOblong\n")
    fprintf(create_pad_port "FLOC 19 11\n")
    fprintf(create_pad_port "CHECKLIST \"Oblong\" padType\n")
    fprintf(create_pad_port "ENDFIELD\n\n")
    
    fprintf(create_pad_port "TEXT \"Pad Size:\"\n")
    fprintf(create_pad_port "TLOC 3 5\n")
    fprintf(create_pad_port "ENDTEXT\n\n")
    
    fprintf(create_pad_port "FIELD cirPadSize\n")
    fprintf(create_pad_port "FLOC 11 5\n")
    fprintf(create_pad_port "INTFILLIN 5 10\n")
    fprintf(create_pad_port "ENDFIELD\n\n")
    
    fprintf(create_pad_port "TEXT \"Width:\"\n")
    fprintf(create_pad_port "TLOC 3 8\n")
    fprintf(create_pad_port "ENDTEXT\n\n")
    
    fprintf(create_pad_port "FIELD cirPadWidth\n")
    fprintf(create_pad_port "FLOC 11 8\n")
    fprintf(create_pad_port "INTFILLIN 5 10\n")
    fprintf(create_pad_port "ENDFIELD\n\n")
    
    fprintf(create_pad_port "TEXT \"Height:\"\n")
    fprintf(create_pad_port "TLOC 3 11\n")
    fprintf(create_pad_port "ENDTEXT\n\n")
    
    fprintf(create_pad_port "FIELD cirPadHeight\n")
    fprintf(create_pad_port "FLOC 11 11\n")
    fprintf(create_pad_port "INTFILLIN 5 10\n")
    fprintf(create_pad_port "ENDFIELD\n\n")
    
    fprintf(create_pad_port "GROUP \"Pad Attribute\"\n")
    fprintf(create_pad_port "GLOC 2 3\n")
    fprintf(create_pad_port "GSIZE 30 11\n")
    fprintf(create_pad_port "ENDFIELD\n\n")

    fprintf(create_pad_port "ENDTAB\n\n")
/*-------------------    Oblong Hole TAB   ------------------*/        
    fprintf(create_pad_port "TAB \"Oblong Hole\"\n")
    
    fprintf(create_pad_port "GROUP \"Drill Size\"\n")
    fprintf(create_pad_port "GLOC 2 1\n")
    fprintf(create_pad_port "GSIZE 30 7\n")
    fprintf(create_pad_port "ENDGROUP\n\n")
    
    fprintf(create_pad_port "TEXT \"Width:\"\n")
    fprintf(create_pad_port "TLOC 4 3\n")
    fprintf(create_pad_port "ENDTEXT\n\n")
    
    fprintf(create_pad_port "FIELD oblDrillWidth\n")
    fprintf(create_pad_port "FLOC 9 3\n")
    fprintf(create_pad_port "INTFILLIN 5 10\n")
    fprintf(create_pad_port "ENDFIELD\n\n")
    
    fprintf(create_pad_port "TEXT \"Height:\"\n")
    fprintf(create_pad_port "TLOC 17 3\n")
    fprintf(create_pad_port "ENDTEXT\n\n")
    
    fprintf(create_pad_port "FIELD oblDrillHeight\n")
    fprintf(create_pad_port "FLOC 23 3\n")
    fprintf(create_pad_port "INTFILLIN 5 10\n")
    fprintf(create_pad_port "ENDFIELD\n\n")
    
    fprintf(create_pad_port "FIELD oblNPH\n")
    fprintf(create_pad_port "FLOC 9 6\n")
    fprintf(create_pad_port "CHECKLIST \"Non-Plated\"\n")
    fprintf(create_pad_port "ENDFIELD\n\n")
    
    fprintf(create_pad_port "GROUP \"Pad Size\"\n")
    fprintf(create_pad_port "GLOC 2 8\n")
    fprintf(create_pad_port "GSIZE 30 6\n")
    fprintf(create_pad_port "ENDGROUP\n\n")
    
    fprintf(create_pad_port "TEXT \"Width:\"\n")
    fprintf(create_pad_port "TLOC 4 11\n")
    fprintf(create_pad_port "ENDTEXT\n\n")
    
    fprintf(create_pad_port "FIELD oblPadWidth\n")
    fprintf(create_pad_port "FLOC 9 11\n")
    fprintf(create_pad_port "INTFILLIN 5 10\n")
    fprintf(create_pad_port "ENDFIELD\n\n")
    
    fprintf(create_pad_port "TEXT \"Height:\"\n")
    fprintf(create_pad_port "TLOC 17 11\n")
    fprintf(create_pad_port "ENDTEXT\n\n")
    
    fprintf(create_pad_port "FIELD oblPadHeight\n")
    fprintf(create_pad_port "FLOC 23 11\n")
    fprintf(create_pad_port "INTFILLIN 5 10\n")
    fprintf(create_pad_port "ENDFIELD\n\n")    

    fprintf(create_pad_port "ENDTAB\n\n")
    
    fprintf(create_pad_port "ENDTABSET\n")
    
    fprintf(create_pad_port "FIELD CreatePad\n")
    fprintf(create_pad_port "FLOC 5 19\n")
    fprintf(create_pad_port "MENUBUTTON \"Create\" 7 4\n")
    fprintf(create_pad_port "ENDFIELD\n\n")
    
    fprintf(create_pad_port "FIELD EXITPAD\n")
    fprintf(create_pad_port "FLOC 28 19\n")
    fprintf(create_pad_port "MENUBUTTON \"EXIT\" 7 4\n")
    fprintf(create_pad_port "ENDFIELD\n")
    fprintf(create_pad_port "\n")
    
    fprintf(create_pad_port "ENDTILE\n")
    fprintf(create_pad_port "ENDFORM\n")
    fprintf(create_pad_port "\n")
    close(create_pad_port)
    
);end defun