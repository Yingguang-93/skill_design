; fcircle.il
; Ver. 1.0 - 08-21-00 - VC
; Ver. 2.0 - 09-20-00 - redfined global variables and changed OK button to Add
; 			changed the Cancel button to Close
;			cleaned up lint warnings to give a score of 100
; Written by:
;      Vincent Canulli Sr.
; boardman0@lycos.com
;
; To have this command available to you from the Allegro Command line
; Place this line in your allegro.ilinit file - load("fcircle.il")
;
; This assumes you already have your skill path set and the file fcircle.il is in that folder
; You start this program by entering "add fcircle" on the Allegro Command Line
;
; You can also select the menu command "Add fcIrcle" if you are set up for my custom menu
; The menu short-cut is <ALT-A><i>

axlCmdRegister( "add fcircle" 'fc_Start )		;register the command with allegro

;Globals
vcXpos = 0
vcYpos = 0
vcDiam = 0
vcRad = 0

vcTmphlpfile=nil
vcTmphlpfile = makeTempFileName("qhelp")	;setup temp help file
vcTmphlpfile = strcat(vcTmphlpfile ".txt")

defun( fc_Help ()
let( (hlpPort )
	hlpPort = outfile( vcTmphlpfile )
  fprintf( hlpPort "===============================================================================\n")
  fprintf( hlpPort "\n              	 Create Filled Circle - Ver 2.0 - VC             \n\n")
  fprintf( hlpPort "===============================================================================\n")
  fprintf( hlpPort " This Command is used to create filled circles as a shape.\n")
  fprintf( hlpPort " All you have to do is enter the x,y coordinates and the diameter.\n")
  fprintf( hlpPort " Select the correct Class and SubClass in the Options Tab\n")
  fprintf( hlpPort " Then click Add.\n")
  fprintf( hlpPort " A filled circle will be created on the Class and SubClass you selected.\n")
  fprintf( hlpPort " \n")
  fprintf( hlpPort "  Add:			This button add's the filled circle.\n")
  fprintf( hlpPort "  Close:		This button closes the form and exits this Command.\n")
  fprintf( hlpPort "  Help:			This button displays this message.\n")
  fprintf( hlpPort "===============================================================================\n")
  fprintf( hlpPort "\n")
     close(hlpPort) 
     if(! isFile( vcTmphlpfile) then
      	axlUIConfirm("Unable to Open Help File, Check Permissions!")
     else
	axlUIViewFileCreate( vcTmphlpfile "Create Filled Circle - Help" nil)
     );if
));defun

;===============================================================================
;
;	This function is called upon the exection of this skill command. It will
;	create the form file and call the functions to open the form.
;	The Global Variable for the form pointer (vcFormPtr) is also intialized.
;	
;===============================================================================

defun( fc_Start ()
;let( (formname )
    vcFormPtr = nil
    formname = fc_MkForm()
        if(! isFile( formname ) then
        	axlUIConfirm("Unable to Open Form File, Check Permissions!")
            fc_Cancel()
        else
           fc_FormDisplay( formname )
        );if 
);defun

;===============================================================================
;
;	This function is called by the 'OK' button on the form.
;
;===============================================================================

defun( fc_RunCmd ()

	fc_MkCircle()
	
);defun

;===============================================================================
;
;	This function will Close the form assigned to Global variable vcFormPtr.
;
;===============================================================================

defun( fc_Cancel ()
      when( vcFormPtr  axlFormClose( vcFormPtr ))
      when( isFile( vcTmphlpfile )
	 deleteFile( vcTmphlpfile )
      )
);defun

;===============================================================================
;
;	This function will create a circle.
;
;===============================================================================

defun( fc_MkCircle ()
    let( ( xpos1 ypos1 ypos_rad layer cirpath tmppath fillme)

	vcRad = vcFormdata->vcDiam / 2.0
	xpos1 = vcFormdata->vcXpos
	ypos1 = vcFormdata->vcYpos
	ypos_rad = (ypos1+vcRad)
	layer = (axlGetParam("paramLayerGroup:ETCH")->curValue)
	
cirpath = axlPathStart( (list xpos1:ypos_rad ))

cirpath = axlPathArcCenter( cirpath, 0, xpos1:ypos_rad, t, xpos1:ypos1 )

tmppath = axlDBCreatePath( cirpath, "Board Geometry/Outline" )

fillme = axlDBCreateOpenShape( cirpath, t, layer , , nil)
axlDBCreateCloseShape( fillme )


axlDeleteObject( car(tmppath ))

));defun

;===============================================================================
; 
;        This function is used to define the callback.
;	     
;===============================================================================

defun(  fc_FormCallBack ( vcFormPtr )
    case( get( vcFormPtr 'curField)
	( "vcXpos" putprop( vcFormdata get( vcFormPtr 'curValue) 'vcXpos))
	( "vcYpos" putprop( vcFormdata get( vcFormPtr 'curValue) 'vcYpos))
	( "vcDiam" putprop( vcFormdata get( vcFormPtr 'curValue) 'vcDiam))
        ( "add" fc_RunCmd())
        ( "close" fc_Cancel())
	( "vhelp" fc_Help())
	
    );case
);defun

;===============================================================================
;
;        This function is used in the axlCreateForm command. This Call is to
;	identify values and actions from the form currently displayed.
;     
;===============================================================================

defun(  fc_FormDisplay ( formname )
   progn( ()
   vcFormdata = nil
   let( (form)
   form = axlFormCreate( (gensym) formname '(CENTER) 'fc_FormCallBack t)
   setq(vcFormPtr  form)
   unless( vcFormdata 
        setq( vcFormdata t)
        axlFormSetField( vcFormPtr "vcXpos" 0)
        putprop( vcFormdata 0 'vcXpos)
        axlFormSetField( vcFormPtr "vcYpos" 0)
        putprop( vcFormdata 0 'vcYpos)
       
        axlFormSetField( vcFormPtr "vcDiam" 300)
        putprop( vcFormdata 300 'vcDiam)
        axlFormDisplay( form )
   );unless
  when( isFile( formname )  deleteFile( formname ))
)));defun

;===============================================================================
;
;        This function creates a form file in the /tmp directory with a temporary
;        name. The temporary name is returned. This form file is used to collect
;        information 
;     
;===============================================================================

defun( fc_MkForm ()
prog(nil let((tmpformfile formPort) 
	(tmpformfile = makeTempFileName("fcircleform")) 
	(tmpformfile = strcat(tmpformfile ".form"))

	formPort = outfile( tmpformfile )
    fprintf( formPort "FILE_TYPE = FORM_DEFN VERSION=2\n FORM\nFIXED\nPORT 45 12\n")
    fprintf( formPort "HEADER \"Filled Circle Param's\"\n\n")
    fprintf( formPort "TILE\n\nGROUP \"Circle Center Coordinates\"\nGLOC 1 1\nGSIZE 45 10\nENDGROUP\n\n")
    fprintf( formPort "TEXT \"X Coord:\"\n TLOC 2 4\n FGROUP \"Circle Center Coordinates\"\n ENDTEXT\n \n")
    fprintf( formPort "FIELD vcXpos\n FLOC 10 4\n REALFILLIN 11 11\n DECIMAL 4\n FGROUP \"Circle Center Coordinates\"\n ENDFIELD\n \n")
    fprintf( formPort "TEXT \"Y Coord:\"\n TLOC 24 4\n FGROUP \"Circle Center Coordinates\"\n ENDTEXT\n \n")
    fprintf( formPort "FIELD vcYpos\n FLOC 32 4\n REALFILLIN 11 11\n DECIMAL 4\n FGROUP \"Circle Center Coordinates\"\n ENDFIELD\n \n")
    fprintf( formPort "TEXT \"Circle Diameter:\"\n TLOC 2 6\n FGROUP \"Circle Center Coordinates\"\n ENDTEXT\n \n")
    fprintf( formPort "FIELD vcDiam\n FLOC 17 6\n REALFILLIN 9 9\n DECIMAL 4\n FGROUP \"Circle Center Coordinates\"\n ENDFIELD\n \n")

    fprintf( formPort "FIELD add\n FLOC 1 13\n MENUBUTTON \" Add \" 10 3\n ENDFIELD\n\n")
    fprintf( formPort "FIELD close\n FLOC 18 13\n MENUBUTTON \"Close\" 10 3\n ENDFIELD\n\n")
    fprintf( formPort "FIELD vhelp\n FLOC 35 13\n MENUBUTTON \" Help \" 10 3\n ENDFIELD\n\n")

    fprintf( formPort "ENDTILE\n ENDFORM\n")
	close( formPort )

	return( tmpformfile )

))); defun
