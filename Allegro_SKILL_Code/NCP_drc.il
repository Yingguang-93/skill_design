;##################################################
;                                                 #
;  Incentive for this Program:                    #
;         A Cadence customer has found that a     #
;         particular TI part has an error in the  #
;         data book which omits the fact that a   #
;         particular pin on this part if left     #
;         unconnected will cause the part to      #
;         "blow up" when power is applied.        #
;                                                 #
;         The customer asked if there is a way    #
;         to flag this particular part in Allegro #
;         if there is NOT a NET NAME on this      #
;         PIN, thus showing that the design entry #
;         engineer forgot to terminate this pin.  #
;                                                 #
;         Although this could be done with        #
;         the Allegro Extracts,this is being done #
;         in Allegro Skill as an excercise to     #
;         learn Skill as well as being able to    #
;         make this program an interactive        #
;         command which would allow the user to   #
;         find this problem without having to     #
;         leave the Allegro Layout editor.        #
;                                                 #
;  This program is a post layout process.         #
;                                                 #
;  Assumptions:                                   #
;        All components (reference designators)   #
;        have been placed.  That is, there are    #
;        NO UNPLACED components.                  #
;                                                 #
;        There is NO error checking done to       #
;        make sure that all parts have been       #
;        placed.  It is the responsibility of the #
;        user to make sure that this is a fully   #
;        PLACED layout.                           #
;                                                 #
;        There is NO error checking done for      #
;        a correct device type or pin number      #
;        that the user enters.  The program       #
;        will search the Allegro database for     #
;        whatever the user enters from the        #
;        prompts.                                 #
;                                                 #
;  This program will search the Allegro Layout    #
;  for all the components placed.   It will       #
;  examine each component for the DEVICE TYPE     #
;  in question.                                   #
;                                                 #
;  After acquiring all the components with the    #
;  DEVICE TYPE in question, the program will      #
;  examine the particular PIN NUMBER of interest  #
;  to see if it has a NET NAME.                   #
;                                                 #
;  A log file named blowup.log will record all    #
;  instances found and print out the REFERENCE    #
;  DESIGNATOR, the PIN NUMBER, and the NET NAME   #
;  on the PIN.                                    #
;                                                 #
;  If there is NOT a NET NAME associated with     #
;  the PIN NUMBER, then a DRC ERROR message is    #
;  is printed in the log file.                    #
;                                                 #
;  A DRC marker will then be placed in the        #
;  Allegro Layout on the PIN that does NOT have   #
;  a NET NAME.                                    #
;                                                 #
;  The log file (blowup.log) will then be         #
;  displayed in the lower left corner.            #
;  When the user "DONEs" the form, the file       #
;  blowup.log will be deleted.  If the user       #
;  wishes to keep a copy of the logfile, he       #
;  may do so via the SAVE button in the form.     #
;                                                 #
;  It is then the responsiblity of the user to    #
;  re-associate a new net list to the Allegro     #
;  Layout with a NET NAME associated to the PIN.  #
;                                                 #
;  How to invoke:                                 #
;  In Allegro 8.0, at the command line:           #
;  Allegro >  (load("NCP_drc.il"))                 #
;  Allegro >  (NCP_drc)                            #
;                                                 #
;                                                 #
;##################################################


;**************************************************
;
;         MAIN ROUTINE
;
;**************************************************

(defun NCP_drc ()
  prog( (tipart tipin logfile)

; Global variable
log = "blowup.log"
;**************************************************
;
; Prompt user for the DEVICE TYPE and PIN NUMBER
;
;**************************************************
devmsg = ">> Enter DEVICE TYPE [i.e.,74AS74-1]: "
devprompt
  tipart = axlUIPrompt(devmsg)
;
; Check if answer is nil. If nil then exit
; else if empty repeat prompt else change
; to upper case
;
  case( tipart
      ( nil printf("** Cancel Received **")
            return())
      ("" devmsg = "** Hit CANCEL or enter Device Type: "
          go(devprompt)); end empty
      (t  tipart = upperCase(tipart)
            ); end default
  ); end case
pinmsg = strcat(">> Enter " tipart " Pin Number [i.e.,D01,8]: ")
pin_prompt
  tipin = axlUIPrompt(pinmsg)
;
; Check if answer is nil. If nil then exit
; else if empty repeat prompt else change
; to upper case
;
  case( tipin
      ( nil printf("** Cancel Received **")
            return())
      ("" pinmsg = strcat("** Hit CANCEL or Pin Number for " tipart ": ")
          go(pin_prompt)); end empty
      (t  tipin = upperCase(tipin)
            ); end default
  ); end case

;**************************************************
;
; Find all DEVICE TYPE instances and report to the
; log file all Reference Designator, Pin Number,
; and Net Name for the part in question.  If the
; Pin does NOT have a NET NAME associated with it,
; then flag that as an ERROR in the log file.
;
;**************************************************
   l_ref_xyloc =  _NCPfindAll(tipart tipin log)

   if(l_ref_xyloc == nil then
      printf("** NO DRC errors found for Unterminated Pins **")
   else
      printf("** -- FOUND Unterminated PINS. -- **\n")
      printf("** Check DRC markers for Errors.  **\n")
;**************************************************
;
; Put DRCs in the Allegro Layout for all violations
;
;**************************************************
   foreach(item l_ref_xyloc
      refdes = nthelem( 1 item)
      xloc = nthelem( 1 nthelem(2 item))
      yloc = nthelem( 2 nthelem(2 item))
      _NCPputDRC(refdes xloc yloc)
   ); end foreach

   );endif
;**************************************************
;
;   Display the logfile and delete
;
;**************************************************
axlUIViewFileCreate(log "Unterminated PIN" t '(80 24) '(sw outer))



 ); end prog
); end defun
;**************************************************
;
;         End MAIN ROUTINE
;
;**************************************************

;**************************************************
;**************************************************
;         Function Subroutines
;**************************************************
;**************************************************

;**************************************************
;
;         _NCPfindAll() function
;
;**************************************************

(defun _NCPfindAll (devtype needToTermPin log)
 prog( (curdesign compid l_symbols
        pin_id no_termination symbol_id l_err)


   d_name = axlCurrentDesign()
   d_type = axlDesignType(t)
   curdate = getCurrentTime()
   l_symbols = list() ; make a variable of type list
   l_err = list()     ; make a variable of type list
   logfile = axlDMOpenLog(log)

   fprintf(logfile "\n")
   fprintf(logfile "#######################################################\n")
   fprintf(logfile "          Design Name is: %s\n" d_name)
   fprintf(logfile "          Design Type is: %s\n" d_type)
   fprintf(logfile "           Time Stamp is: %s\n" curdate)
   fprintf(logfile "#######################################################\n")


   ; find the dbids for all the components

   curdesign = axlDBGetDesign()


   foreach(compid curdesign->components
       if(compid->deviceType == devtype then
         l_symbols = cons(compid->symbol l_symbols)
         )     ; create a list of dbids that match the device type
   ) ; end foreach

   ; Next find the pin dbids
   foreach(symbol_id l_symbols
       ; WORK on each pin dbid
       foreach(pin_id symbol_id->pins
               no_termination = pin_id->net->name
               if(pin_id->number == needToTermPin then
                  if(no_termination == "" then
                   fprintf(logfile "\n")
                   fprintf(logfile "\n")
                   fprintf(logfile "              DRC ERROR \n")
                   fprintf(logfile "*******************************************************\n"
)
                   fprintf(logfile "  Reference Designator: %s\n" symbol_id->refdes)
                   fprintf(logfile "  PIN NUMBER %s does NOT have a NET NAME\n" pin_id->number
)
                   fprintf(logfile "\n")
                   fprintf(logfile "  PART %s will BLOW UP when POWER is applied!\n" devtype)
                   fprintf(logfile "*******************************************************\n"
)
                   l_err = cons( list(strcat(symbol_id->refdes "." pin_id->number) pin_id->xy)
 l_err)
                  else
                   fprintf(logfile "\n")
                   fprintf(logfile "-------------------------------------------------------\n"
)
                   fprintf(logfile "  Reference Designator: %s\n" symbol_id->refdes)
                   fprintf(logfile "  Pin Number %s has a Net Name: %s\n" needToTermPin pin_id
->net->name)
                   fprintf(logfile "-------------------------------------------------------\n"
)
                   fprintf(logfile "\n")
                  ); endif
                );endif
       ); end foreach pin_id
   ); end foreach symbol_id


   ; return the device list to the calling function
   fprintf(logfile "\n")
   fprintf(logfile "\n")
   fprintf(logfile "\n")
   fprintf(logfile "#######################################################\n")
   fprintf(logfile "                  End of Log File \n")
   fprintf(logfile "#######################################################\n")
   axlDMClose(logfile)
   return( l_err )

  ) ; end of prog
) ; end defun
;**************************************************
;
;       End of  _NCPfindAll() function
;
;**************************************************

;**************************************************
;
;         _NCPputDRC() function
;
;**************************************************
(defun _NCPputDRC (pin_name drcx drcy)
 (let (errormsg drclayer )
   errormsg = "No NET NAME on this PIN"
   drclayer = "drc error/all"

; Place DRC marker
  if(pin_name then
     axlDBCreateExternalDRC( errormsg list(drcx drcy) drclayer nil nil pin_name)
  else
     printf("\n")
     printf("** No Unterminated Pins **\n")
     printf("\n")
  ); endif

 ); end let
); end defun
;**************************************************
;
;       End of  _NCPputDRC() function
;
;**************************************************

;**************************************************
;**************************************************
;         END of Function Subroutines
;**************************************************
;**************************************************


