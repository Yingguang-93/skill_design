; ###############################################################################
 
;                          Single pin net checker

;  This routine will go through the database searching for single pin nets. Any net
;  found with only one pin associated to it will be highlighted. A log file is written
;  containing the net name and pin location of each single pin net. At the end of the
;  search, the log file is displayed in a viewlog within Allegro.

;  Note: Single pin nets can not be found if the board is 100% routed

;  To run the checker in Allegro type "spnchk"
 
;  Written by David J. Scheuring
;  Sr. Applications Eng. Cadence Design Systems
;  June 5, 1995
;
;  Feb. 11,2005 changed line 12 to show the command as spnchk


axlCmdRegister("spnchk" 'Single_Pin_Net_Check_Routine ?cmdType "interactive")

; Define the routine that does the checking
; #########################################
defun(Single_Pin_Net_Check_Routine ()

   ; Clear the variables
   ; ###################
   Net_List=nil; This variable represents a list of all nets in the design including dummys
   Real_Nets_List=nil; This variable represents a list of all nets in the design minus dummys
   Single_Pin_Nets_List=nil; This variable list all single pin nets
   Pin=nil; This variable is used to track the pin location for single pin nets
   Counter=0; This variableis used to track the number of pins in a net
   Date=(getCurrentTime); This variable records the date for the log file

   ; Open the log file and print the header info
   ; ###########################################
   Single_Pin_Net_Log_File=outfile("./Single_Pin_Net.log" "w")
   fprintf(Single_Pin_Net_Log_File "\n\n\n\t%s\n\n" Date)
   fprintf(Single_Pin_Net_Log_File "\tSingle Pin Net Logfile\n\n\n")

   ; Set up the find filter and select all the nets
   ; ##############################################
   axlClearSelSet()
   axlSetFindFilter(?enabled '(noall nets) ?onButtons '(noall nets))
   Net_List=axlGetSelSet(axlAddSelectAll())

   ; Throw away the dummy nets
   ; #########################
   foreach(Net Net_List
      if(Net->name != "" then
         Real_Nets_List=cons(Net Real_Nets_List)
      ); end if Net->name != ""
   ); end foreach Net Net_List

   ; Parse the nets for those with only one pin
   ; ##########################################
   foreach(Net Real_Nets_List; Grab each net in the list
   Counter=0
      while(Counter <= 1; Stop checking as soon as you find a 2nd pin
         foreach(Branch Net->branches; Grab each branch of the net
            foreach(Child Branch->children; Grab each child in the branch

               ; Check if the child is a pin and incriment the counter if it is
               ; ##############################################################
                  if(Child->objType == "pin" then
                  Pin=Child
                  Counter=Counter+1
               ); end if(Child->objType == "pin"
            ); end foreach Child Branch->children
         ); end foreach Child Branch->children

         ; Check if there is only one pin and update the log file
         ; ######################################################
         if(Counter == 1 then
            Single_Pin_Nets_List=cons(Net Single_Pin_Nets_List); append the net to the list
            fprintf(Single_Pin_Net_Log_File
               "Net name - %s, is a single pin net\n\tLocated at - %f %f\n\n"
                Net->name car(Pin->xy) car(cdr(Pin->xy)))
         ); end if Counter == 1
      ); end while Counter <= 1
   ); end foreach Net Real_Nets_List

   ; Check if there are any single pin nets and update the log file
   ; ##############################################################
   if(Single_Pin_Nets_List == nil then
      fprintf(Single_Pin_Net_Log_File "\tNo Single Pin Nets Found\n")
   ); end if Single_Pin_Nets_List == nil

   ; Highlight the single pin nets
   ; #############################
   axlClearSelSet()
   axlHighlightObject(Single_Pin_Nets_List)

   ; Close the log file, refresh the graphics, and open a viewlog
   ; ############################################################
   close(Single_Pin_Net_Log_File)
   axlShell("redisplay")
   axlShell("viewlog ./Single_Pin_Net.log")
); end defun Single_Pin_Net_Check_Routine
