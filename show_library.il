;  Author:  Larry Bowman - Technical Services
;   Email:  bowman@cadence.com
; Product:  Allegro
; Version:  11.0
;    Date:  January 10, 1996

; Revision Date: Februrary 6, 1996
;        Author: Joe Morrison
;         email: joe.morrison@lmco.com
; Revision Description:
; ----------------------------------------------------------------------

axlCmdRegister("lib" 'lcbShowLibPath)

(defun lcbShowLibPath ()
  prog( ()
    
    ; Create variables
    d_name = axlCurrentDesign()
    d_type = axlDesignType(t)
    curdate = getCurrentTime()

    ; Get a list of symbol definitions
    l_symdefs = axlDBGetDesign()->symdefs
    
    if(l_symdefs == nil 
     then
        printf("** No Allegro Symbols are Placed.  **\n")
        printf("** Place symbols and try again.    **\n")
        return() 
    ); endif

    

    ; Open a log file called show_library.log
    logfile = axlDMOpenLog("show_library")

    ; Print Header Message to log file
    fprintf(logfile "\n")
    fprintf(logfile "#######################################################\n")
    fprintf(logfile "          Design Name is: %s\n" d_name)
    fprintf(logfile "          Design Type is: %s\n" d_type)
    fprintf(logfile "           Time Stamp is: %s\n" curdate)
    fprintf(logfile "#######################################################\n")
    fprintf(logfile "\n")

    ; Print out current library path settings
    fprintf(logfile "CURRENT LIBRARY PATHS\n")
    fprintf(logfile "=====================\n\n")
    fprintf(logfile "PSMPATH = %s\n" axlGetVariable("psmpath"))
    fprintf(logfile "PADPATH = %s\n" axlGetVariable("padpath"))
    fprintf(logfile "DEVPATH = %s\n\n" axlGetVariable("devpath"))


    ; See if there are any unplaced components
    l_components = axlDBGetDesign()->components
    unplaced = t
    fprintf(logfile "UNPLACED COMPONENTS\n")
    fprintf(logfile "===================\n\n")
    foreach(component l_components
      if(component->symbol == nil then
        unplaced = nil
        fprintf(logfile "Reference Designator: %-10s Device Type: %-20s\n" component->name component->deviceType)
      ); end if
    ); end foreach
    if( unplaced == t then
      fprintf(logfile "No Unplaced Components\n")
    ); end if
    fprintf(logfile "\n\nPLACED COMPONENTS and SYMBOLS\n")
    fprintf(logfile     "=============================\n\n")

    ; Find Placed Components and Symbols
    ;--------------------------------------------------------------------------
    ; Find the longest name for each Symbol entry to format each column width 
    ; to fit the longest character string.
    ;--------------------------------------------------------------------------
    name_length = 11
    type_length = 11
    path_length = 12
    foreach(symid l_symdefs

      ; Find the longest Symbol Name
      if( stringp(symid->name) == t
       then
        if( strlen(symid->name) > name_length
          then
            name_length = strlen(symid->name)
        ); end if 
      ); end if
      
      ; Find the longest Symbol Type
      if( stringp(symid->name) == t
       then
        if( strlen(symid->type) > type_length
          then
            type_length = strlen(symid->type)
        ); end if 
      ); end if

      ; Find longest Library Path
      if( stringp(symid->prop->LIBRARY_PATH) == t
       then
        if( strlen(symid->prop->LIBRARY_PATH) > path_length
          then
            path_length = strlen(symid->prop->LIBRARY_PATH)
        ); end if 
      ); end if

    ); end foreach

    ; Create format from above calculations
    sprintf(formatheader "%s-%ns %s-%ns %s-%ns \n" "%" name_length "%" type_length "%" path_length)

    ; Print Column Headers
    fprintf(logfile formatheader "Symbol Name" "Symbol Type" "Library Path")

    ; Print dash character under the title of "Symbol Name"
    i = 1
    for(i 1 name_length
        fprintf(logfile "-")
        i = i + 1
    ); end for
    fprintf(logfile " ")

    ; Print dash character under the title of "Symbol Type"
    i = 1
    for(i 1 type_length
        fprintf(logfile "-")
        i = i + 1
    ); end for
    fprintf(logfile " ")

    ; Print dash character under the title of "Library Path"
    i = 1
    for(i 1 path_length
        fprintf(logfile "-")
        i = i + 1
    ); end for
    fprintf(logfile "\n")
  
    ; Print out the Symbol Name, Symbol Type, and Library Path except for Symbol Type = DRAFTING
    foreach(symid l_symdefs
     if(symid->type != "DRAFTING" then
      fprintf(logfile formatheader symid->name symid->type symid->prop->LIBRARY_PATH)
     ); end if
    ); end foreach

   ; jtm addition for pad paths - 
   (fprintf logfile "\n\nPADSTACK LIBRARY\n================\n\n")
   (fprintf logfile "%-18s %s\n" "Pad Name" "Library Path")
   (fprintf logfile "%-18s %s\n" "------------" "----------------------------")

    padStackList=(axlDBGetDesign)->padstacks
    paddir=(axlGetVariable "padpath")
    padlist=(reverse (parseString paddir))
   (foreach padname1 padStackList
    pname=padname1->name
    pname=(lowerCase pname)
    padname=nil
    (foreach pdir padlist
      (if (isDir pdir)
        then
         (sprintf fullname "%s/%s.pad" pdir pname )
         (if (isFile fullname)
           then
            padname=fullname
         ) ;
      ) ; if
    ); foreach
    (if padname
      then
        (fprintf logfile "%-18s %s\n" pname padname)
      else
        (fprintf logfile "%-18s %s\n" pname "*** Not Found ***")
    ); if
   ); foreach pad
 
    ; Close log file
    axlDMClose(logfile)

    ; Set the width of the form output to be the longest string printed.
    ; Make sure total width of all the columns is at least 66 characters long
    xwidth = 66  ; Minimum width
    if(strlen(axlGetVariable("psmpath")) > xwidth then
      xwidth = strlen(axlGetVariable("psmpath")) + 15
    ); endif
    if(strlen(axlGetVariable("padpath")) > xwidth then
      xwidth = strlen(axlGetVariable("padpath")) + 15
    ); endif
    if(strlen(axlGetVariable("devpath")) > xwidth then
      xwidth = strlen(axlGetVariable("devpath")) + 15
    ); endif
    if(name_length + type_length + path_length + 6 > xwidth then
      xwidth = name_length + type_length + path_length + 6
    ); endif

    ; Make the width no longer than 200 characters long.
    if(xwidth > 200 then
     xwidth = 200
    ); endif
    geom = list(xwidth 20)

    ; View log file
    axlUIViewFileCreate("show_library.log" "Show Library Paths" t geom)


  ); end prog
); end lcbShowLibPath

