;------------ Cut Here and save to file as: add_device_label.il ---------------
;###########################################################################
;#                                                                         #
;#                      Comment Section                                    #
;#                                                                         #
;###########################################################################
;  Author:  Larry Bowman - Cadence Design Systems, Technical Services
;   Email:  bowman@cadence.com
; Product:  Allegro
; Version:  10.0, 11.0
;    Date:  February 21, 1996

; This program was created to help assign the DEVICE_LABEL property to
; components in Allegro in preparation for running the HP3070 tester
; interface.  Normally these properties should be part of the Physical
; Parts Table file and get assigned when PackagerXL is run.
;
; However, since these properties may not be known to be needed at the
; time of packaging, this program will assign the DEVICE_LABEL properties
; based on the reference designator prefix. The reference designator
; prefixes and its corresponding DEVICE_LABEL property value will be
; assigned according to the following listing:

    ; Reference Desginator Prefix        device_label
    ; ---------------------------        ------------
    ;  C                                 CAPACITOR
    ;  J                                 CONNECTOR
    ;  CR                                DIODE
    ;  QT                                FET
    ;  TH                                FUSE
    ;  FB                                INDUCTOR
    ;  L                                 INDUCTOR
    ;  JP                                JUMPER
    ;  PT                                POTENTIOMETER
    ;  R                                 RESISTOR
    ;  F                                 SWITCH
    ;  Q                                 TRANSISTOR
    ;  Z                                 ZENER
;
; This program will not overwrite any DEVICE_LABEL properties already 
; assigned, if they were included in the packaging (PackagerXL) run.
;
; To change which reference designator prefix to look for, you will have
; to modify this program from line 169 to line 180 and line 210 to line 258.
;
; If you need to look for a referenced designator prefix with more than
; two characters, then you will also need to add a section to look for
; that number of characters instead of just two characters after line 198 .
;
; To run this program in the Allegro editor at the command line, you would
; type in the command, "add device_label".
;
; This Allegro Skill program may be loaded automatically
; when Allegro is invoked by creating an allegro.ilinit or allegro_layout.ilinit
; or allegro_interactive.ilinit file in the user's pcbenv directory 
; (i.e., ~/pcbenv/allegro.ilinit,~/pcbenv/allegro_layout.ilinit, etc.).
;
; The allegro.ilinit file could look like the following:

;----------- Start of allegro.ilinit file -----------------------------
;setSkillPath(". ~/scripts/SKILL.sav /cds/9502/ibm/tools/pcb/etc/skill")
;load("add_device_label.il")
;----------- End of allegro.ilinit file --------------------------------
;
; Where this file, add_device_label.il, is located in one of the directory paths
; as defined by the setSkillPath function.
;
; Note:  If you ever change the Allegro Skill path with the setSkillPath
;        function as noted above, ALWAYS be sure to include the period(.),
;        which is the current working directory, as part of the search path
;        definition.  There are some Allegro commands that expect to see the
;        current working directory as part of the search path and will fail
;        if it is not part of the search path.
;
;        Also, most of the Skill functions that do file access will use the
;        setSkillPath value as the directory paths to perform their file
;        reads and writes.

; For example:
; Allegro>  add device_label
;
; You may also modify an Allegro menu to include this command as a menu
; selection.

; A side benefit after executing this program (whether you allow it to
; assign the DEVICE_LABEL property or not), is that you will have access
; to this property in the EDIT->PROPERTY and SHOW ELEMENT->Find By Property
; menu selections.  You could then assign the DEVICE_LABEL property on a
; per instances basis or use wildcards in the Find Filter form.
;
;###########################################################################
;#                                                                         #
;#                      End Of Comment Section                             #
;#                                                                         #
;###########################################################################
;
;###########################################################################
;#                                                                         #
;#                      Main Program - add device_label                    #
;#                                                                         #
;###########################################################################

axlCmdRegister("add device_label" 'lcbAddDevLabel)

(defun lcbAddDevLabel ()
  prog( ()
    
    ; Create variables
    d_name = axlCurrentDesign()
    d_type = axlDesignType(t)
    curdate = getCurrentTime()


    cap_device = list("device_label" "CAPACITOR")
    conn_device = list("device_label" "CONNECTOR")
    diode_device = list("device_label" "DIODE")
    fet_device = list("device_label" "FET")
    fuse_device = list("device_label" "FUSE")
    inductor_device = list("device_label" "INDUCTOR")
    jumper_device = list("device_label" "JUMPER")
    pot_device = list("device_label" "POTENTIOMETER")
    resistor_device = list("device_label" "RESISTOR")
    switch_device = list("device_label" "SWITCH")
    transistor_device = list("device_label" "TRANSISTOR")
    zener_device = list("device_label" "ZENER")



    ; Get a list of components
    l_comp = axlDBGetDesign()->components

    
    if(l_comp == nil 
     then
        printf("** No netlist has been associated into %s **\n" d_name)
        printf("** Run fet2a or 3rd party netin and try again. **\n")
        return() 
    ); endif

    ; add the DEVICE_LABEL property to the dictionary. NO matter what!
        if(axlDBCreatePropDictEntry("device_label" "string" list("components")) == nil then
          printf("** Warning - Could not add DEVICE_LABEL to the Dictionary. **\n")
        ); endif

    ; DEVICE_LABEL property is in the dictionary, so proceed.
    logfile = outfile("device_label.log")

    ; Print Header Message to log file
    fprintf(logfile "\n")
    fprintf(logfile "#######################################################\n")
    fprintf(logfile "          Design Name is: %s\n" d_name)
    fprintf(logfile "          Design Type is: %s\n" d_type)
    fprintf(logfile "           Time Stamp is: %s\n" curdate)
    fprintf(logfile "#######################################################\n")
    fprintf(logfile "\n")

    ; Print what the DEVICE_LABELS reference designators represent.
    fprintf(logfile "This program was written to add the correct DEVICE_LABEL property \n")
    fprintf(logfile "to components in preparation for using the HP3070 tester interface. \n")
    fprintf(logfile "\nNormally, the DEVICE_LABEL property cannot be seen with the SHOW->ELEMENT\n")
    fprintf(logfile "or EDIT->PROPERTY menu selections.  You will now be able to\n")
    fprintf(logfile "access the DEVICE_LABEL property with the above menu selections.\n\n")
    fprintf(logfile "If you are proceeding to use the HP3070 program, be sure to write out\n")
    fprintf(logfile "this Allegro database so these property values may be seen.\n\n")
    fprintf(logfile "The Following Reference Designator's prefixes will be used to add\n")
    fprintf(logfile "the DEVICE_LABEL property.\n")
    fprintf(logfile "\nReference Designator Prefix   DEVICE_LABEL Property Value\n")
    fprintf(logfile "---------------------------   ---------------------------\n")
    fprintf(logfile "C                             CAPACITOR \n")
    fprintf(logfile "J                             CONNECTOR \n")
    fprintf(logfile "CR                            DIODE \n")
    fprintf(logfile "QT                            FET \n")
    fprintf(logfile "TH                            FUSE \n")
    fprintf(logfile "FB or L                       INDUCTOR \n")
    fprintf(logfile "JP                            JUMPER \n")
    fprintf(logfile "PT                            POTENTIOMETER \n")
    fprintf(logfile "R                             RESISTOR \n")
    fprintf(logfile "F                             SWITCH \n")
    fprintf(logfile "Q                             TRANSISTOR \n")
    fprintf(logfile "Z                             ZENER \n")

    close(logfile)
    
    devlog = axlUIViewFileCreate("device_label.log" "DEVICE_LABELS Added" nil '(80 40) )
    if(axlUIYesNo("Continue with Property Assignment?") == nil then
      printf("** No DEVICE_LABEL property was assigned, User said NO.**")
      return()
    );endif

    ; append to the log file
    logfile = outfile("device_label.log" "a")

    fprintf(logfile "\n########## DEVICE_LABEL Properties Added. ##########\n\n")
    prop_count = 0
    foreach(refdes l_comp
     if(refdes->prop->DEVICE_LABEL == nil then
      ;
      ; Get the first two characters of the reference designators.
      refdes_prefix = substring(refdes->name 1 2)
      
      ; Check to see if the second character is a number.
      if(rexMatchp("[0-9]" substring(refdes_prefix 2 1)) == t then
        refdes_prefix = substring(refdes->name 1 1) 
      );endif

      ; ################################################################
      ;   Get all the Reference Designators with one character prefix.
      ; ################################################################
      case(refdes_prefix
          ( "C" if(axlDBAddProp(refdes cap_device) != nil then
                prop_count++
                fprintf(logfile "Reference Designator: %-10s %s\n" refdes->name "DEVICE_LABEL = CAPACITOR")
                ));endif
          ( "J" if(axlDBAddProp(refdes conn_device) != nil then
                prop_count++
                fprintf(logfile "Reference Designator: %-10s %s\n" refdes->name "DEVICE_LABEL = CONNECTOR")
                ));endif
          ( "CR" if(axlDBAddProp(refdes diode_device) != nil then
                prop_count++
                fprintf(logfile "Reference Designator: %-10s %s\n" refdes->name "DEVICE_LABEL = DIODE")
                ));endif
          ( "QT" if(axlDBAddProp(refdes fet_device) != nil then
                prop_count++
                fprintf(logfile "Reference Designator: %-10s %s\n" refdes->name "DEVICE_LABEL = FET")
                ));endif
          ( "TH" if(axlDBAddProp(refdes fuse_device) != nil then
                prop_count++
                fprintf(logfile "Reference Designator: %-10s %s\n" refdes->name "DEVICE_LABEL = FUSE")
                ));endif
          ( "FB" if(axlDBAddProp(refdes inductor_device) != nil then
                prop_count++
                fprintf(logfile "Reference Designator: %-10s %s\n" refdes->name "DEVICE_LABEL = INDUCTOR")
                ));endif
          ( "L" if(axlDBAddProp(refdes inductor_device) != nil then
                prop_count++
                fprintf(logfile "Reference Designator: %-10s %s\n" refdes->name "DEVICE_LABEL = INDUCTOR")
                ));endif
          ( "JP" if(axlDBAddProp(refdes jumper_device) != nil then
                prop_count++
                fprintf(logfile "Reference Designator: %-10s %s\n" refdes->name "DEVICE_LABEL = JUMPER")
                ));endif
          ( "PT" if(axlDBAddProp(refdes pot_device) != nil then
                prop_count++
                fprintf(logfile "Reference Designator: %-10s %s\n" refdes->name "DEVICE_LABEL = POTENTIOMETER")
                ));endif
          ( "R" if(axlDBAddProp(refdes resistor_device) != nil then
                prop_count++
                fprintf(logfile "Reference Designator: %-10s %s\n" refdes->name "DEVICE_LABEL = RESISTOR")
                ));endif
          ( "F" if(axlDBAddProp(refdes switch_device) != nil then
                prop_count++
                fprintf(logfile "Reference Designator: %-10s %s\n" refdes->name "DEVICE_LABEL = SWITCH")
                ));endif
          ( "Q" if(axlDBAddProp(refdes transistor_device) != nil then
                prop_count++
                fprintf(logfile "Reference Designator: %-10s %s\n" refdes->name "DEVICE_LABEL = TRANSISTOR")
                ));endif
          ( "Z" if(axlDBAddProp(refdes zener_device) != nil then
                prop_count++
                fprintf(logfile "Reference Designator: %-10s %s\n" refdes->name "DEVICE_LABEL = ZENER")
                ));endif
      ); endcase
     );endif
    ); endforeach
    ; Add the number of properties added
    fprintf(logfile "\n There were %n DEVICE_LABEL properties added.\n\n" prop_count)
    close(logfile)


  axlUIViewFileReuse(devlog "device_label.log" "DEVICE_LABELS Added" t )
  ); end prog
); end lcbAddDevLabel
;###########################################################################
;#                                                                         #
;#                      End of Main Program - add device_label             #
;#                                                                         #
;###########################################################################
