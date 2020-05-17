; The following Skill routine automates the process
; of adding the PINUSE property to a particular 
; component. Typically, these properties reside
; in the database through attributes assigned during
; logic entry but are unaccessible to the user
; to review and modify if needed. After executing 
; AddPinUse, each pin of the selected component
; will have an Allegro PINUSE property attached
; to it. From that point on, the system will display
; this value for other commands that access that data,
; for example Show->Element, Show->Property, and Edit->
; Property.
;  
; To install: Copy addpinuse.il to any directory defined
;               within your setSkillPath in your 
;               allegro.ilinit. Add a "load("addpinuse.il")"
;               statement to your allegro.ilinit.
;
; To execute: Within allegro type "add pinuse" or 
;               "pinuse" and select the desired component. 
;               This routine should take only
;               seconds to complete. 
;
; Deficiencies: This routine does not allow for Window or
;               Group selection. Also, if the selection does
;               not find a component, the command completes
;               with no changes made to the active design.
;
axlCmdRegister( "add pinuse" 'AddPinUse)
axlCmdRegister( "pinuse" 'AddPinUse)
defun( AddPinUse ()
_SCSelectComp()
if( (compdbid!=nil) then
_GPUgetPinUse(compdbid)
_APaddProp()
axlShell("run rm extract.log* temporary*.txt")
);end-if
);end-defun
defun( _SCSelectComp ()
prog( ()
        ;
; Select component and call routine to extract pin use.
;
compdbid=nil
axlClearSelSet()
axlSetFindFilter(?enabled `("noall" "Components")
                          ?onButtons '("COMPONENTS"))
                axlSingleSelectPoint()
                compdbid=car(axlGetSelSet())
    );end-prog
);end-defun
defun( _GPUgetPinUse (compdbid)
let( (extfile)
;
; Extract pin use for selected component.
;
extfile=outfile("temporaryviewfile.txt")
fprintf(extfile "COMPONENT_PIN\nREFDES=\"%s\"\n" compdbid->name)
fprintf(extfile "REFDES\nPIN_NUMBER\nPIN_TYPE\n")
close(extfile)
axlExtractToFile("temporaryviewfile.txt" 
 "temporaryoutfile.txt")
);end-let
);end-defun _GPUgetPinUse
defun( _APaddProp ()
let( (extin data1 data2 test refdes pinnum pinuse 
reverse_pindbid_list pindbid_list pindbid
pindbid_current_list)
data1   = nil
data2   = nil
test    = nil
refdes  = nil
pinnum  = nil
pinuse  = nil
pindbid = nil
reverse_pindbid_list = list()
pindbid_list         = list()
pindbid_current_list = list()
extin = infile("temporaryoutfile.txt")
reverse_pindbid_list = axlExtractMap("temporaryviewfile.txt")
foreach(pindbid reverse_pindbid_list
pindbid_list=cons(pindbid pindbid_list)
);end-foreach
 
                line = gets(data1 extin)
                pindbid=car(pindbid_list)
                pindbid_current_list = cdr(pindbid_list)
 
                while((line != nil)
                        data2 = parseString(line "!")
                        test=car(data2)
 
                        if((test == "S") then
                                pinnum = nthelem( 3 data2)
                                pinuse = nthelem( 4 data2)
 
                                if(((pindbid->number) == pinnum) then
                                        axlDBAddProp(pindbid list("PINUSE" pinuse))
                                        pindbid=car(pindbid_current_list)
                                        pindbid_current_list = cdr(pindbid_current_list)
                                        );end-if
 
                                );end-if
 
                        line = gets(data1 extin)
                );end-while
 
                close(extin)
        );end-let
);end-defun _APaddProp


