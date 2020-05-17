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
; File: mirrorvia.il
;
; Usage: Load this file mirrorvia.il
;  Issue the command mirror via on the Allegro command line.
;
;Author: Michael Becker
;	Cadence Design Systems
;  Version 1.0
;  Date: March 22,2006
procedure(_mirror_via()
  _makeForm1()
  axlFormDisplay(_Form1)
); end procedure

(defun _makeForm1 ()
   _Form1=outfile("./form1.form" "w")
   fprintf(_Form1 "FILE_TYPE=FORM_DEFN VERSION=2\n")
   fprintf(_Form1 "FORM\n")
   fprintf(_Form1 "FIXED\n")
   fprintf(_Form1 "PORT 35 10\n")
   fprintf(_Form1 "HEADER \"Pick a via to un-mirror\"\n")
   fprintf(_Form1 "TILE\n")

   fprintf(_Form1 "FIELD cancel\n")
   fprintf(_Form1 "FLOC 10 6\n")
   fprintf(_Form1 "MENUBUTTON \"DONE\" 14 3\n")
   fprintf(_Form1 "ENDFIELD\n")

   fprintf(_Form1 "FIELD execute\n")
   fprintf(_Form1 "FLOC 10 2\n")
   fprintf(_Form1 "MENUBUTTON \"Click to pick\" 14 3\n")
   fprintf(_Form1 "ENDFIELD\n")

   fprintf(_Form1 "ENDTILE\n")
   fprintf(_Form1 "ENDFORM\n")
   close(_Form1)
   _Form1=axlFormCreate( (gensym) "form1.form" '(e inner)
                                   '_Form1_Action t)
); end defun _makeForm1

(defun _Form1_Action (_Form1)
  (case _Form1 -> curField

     ("cancel"
       axlFormClose(_Form1)
       axlCancelEnterFun()
       deleteFile("form1.form")
     t)

     ("execute"
         axlSetFindFilter(?enabled "VIAS" ?onButtons "VIAS")
         l_vias = axlGetSelSet(axlSelect(?prompt "Select via(s) to unmirror"))
         foreach(via l_vias
         	gotViaName   = via -> name
         	gotViaLoc    = via -> xy
         	gotViaNet    = via -> net -> name
         	gotViaRot    = via -> rotation

         	if(axlDBCreateVia(gotViaName, gotViaLoc, gotViaNet, nil, gotViaRot) then
         		axlDeleteObject(via)
         	else
         		printf("There was a problem creating via %s at %L\n", gotViaName gotViaLoc)
         	);endif
         );end foreach
         axlCancelEnterFun()
     nil); end case execute

  ); end case
); end defun _Form1_Action

axlCmdRegister("mirror via" '_mirror_via ?cmdType "interactive")
