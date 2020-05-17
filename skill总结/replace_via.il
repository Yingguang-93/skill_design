;*****************************************************
;Date: 2003-5-26
;Author:Xinghai Tang
;       Dept.of Science & Technology Management
;       Fiberhome Telecommunications Co., Ltd.
;
;Today,base on the original program which were downloaded,I had changed the program,
;delete the update_via command and funtion,and add some additional
;facilities such as variable padstack name and properties into the replace_via funtion,
;so it is easier to be used and operated than before.
;warning:in some conditions,after replaceing,the properties on the old vias will still
;exist on the replaced vias.During the cource of testing,I find if via is a testprep,the "test" 
;properties on these vias will disappear.so you must be careful to use this program

;This program can replace one or multiple vias by a new padstack whose name selected by users.During the
;course of operating,users can change the input padstack name at any moment.
;After replacing,it will print the count of successfully been replaced and unsuccessfully been replaced.
;usage:just copy the file to a directory,and change the file allegro.ilinit in your $home directory as follow
;  setSkillPath(buildString(append1(getSkillPath()  "D:/data/skill/skillcode")))
;  load(replace_via.il)
;then restart your allegro program,you can use replace _via command now .
;enjoy
;*****************************************************

axlCmdRegister("replace_via" `replace_via)

replace_pstk_name = "initial via name"
;=========================================================
;==================== MAIN ROUTINE =======================
;=========================================================

(defun replace_via ()
	(prog (vias)
		mypopup=axlUIPopupDefine( nil
					(list (list "Done" `axlFinishEnterFun)))
		axlUIPopupSet( mypopup)
		_create_replace_via_form()
		axlMsgPut("use padstack %s\n",replace_pstk_name)
		axlClearSelSet()
		axlSetFindFilter(?enabled `("NOALL" "VIAS")
		 			?onButtons `("VIAS"))
		(while (axlSelect)
			axlMsgPut("use padstack %s to replace select vias\n",replace_pstk_name)
			vias = axlGetSelSet()
			if( vias!=nil then
           		_doReplacement( vias )
       		else
				axlMsgPut( "No via was found.")
       		)
			axlClearSelSet()
		);end of while
		axlFinishEnterFun()
	);prog
) ;end-defun

(defun _doReplacement ( vias )
	(prog (successCount failCount fixedCount sameNameCount sumSelCount prevPstk 
			save_xy save_name deleteFlag status vias_props vias_netname)
		successCount = 0
		failCount = 0
		fixedCount = 0
		sameNameCount = 0
		sumSelCount=axlGetSelSetCount()
		save_name = car(vias)->name
		foreach( prevPstk vias
			save_name = prevPstk->name
			save_xy   = prevPstk->xy
			if( save_name != replace_pstk_name then
    			vias_props = axlDBGetProperties(prevPstk)
    			vias_netname = prevPstk->net->name  ;remember the net name
    			deleteFlag=axlDeleteObject(prevPstk)
    			if(deleteFlag then
    				status = axlDBCreateVia(replace_pstk_name save_xy vias_netname)
    				if( status == nil then
						axlMsgPut("Can't replace vias. Please check the new padstack name that replace.")
						status = axlDBCreateVia(save_name save_xy vias_netname nil 0. nil)
					else
						successCount = successCount + 1
					)  ;end-if
					if( vias_props != nil
						axlDBAddProp(status vias_props)
					);if
				else
					fixedCount = fixedCount + 1
					failCount = failCount + 1
				);if
			else
				sameNameCount = sameNameCount +1
				failCount = failCount + 1
			);if
		) ;end-foreach
		axlClearSelSet()
		axlFlushDisplay()
		axlMsgPut("Total Selected: %d		,Success: %d		,Fail:%d (of which Same Name: %d	Fixed: %d)"
					sumSelCount successCount failCount sameNameCount fixedCount)
	) ;prog
) ;end-defun

(defun _create_replace_via_form ()
	padpathCount=0
	replace_via_form_file="./replace_via.form"
	_create_form_file(replace_via_form_file)
	replace_via_form=axlMiniStatusLoad( (gensym) replace_via_form_file '_action_replace_via_form t)
	if(isFile(replace_via_form_file) then
 		deleteFile(replace_via_form_file)
	else
 		printf("*** Warning, cannot find %s to delete\n" replace_via_form_file)
	);endif
	padpath_list=parseString(axlGetVariable("padpath"))
		;get the path list of environment variable "padpath"
	foreach(padpathItem padpath_list
		padpathCount=padpathCount+1  ;padpath count
	)
	pstk_list=_select_padpath(nthelem(1 padpath_list)) ;change "1" into "padpathCount",can get last padpath
	axlFormSetField(replace_via_form "padpath" nthelem(1 padpath_list))
	axlFormDisplay(replace_via_form)
);defun

(defun _action_replace_via_form (replace_via_form)
	case( replace_via_form->curField
		("padstack_list"
			axlFormSetField(replace_via_form "padstack_name"	replace_via_form->curValue)
			replace_pstk_name=replace_via_form->curValue
			t
		)
		("padstack_name"
			if( replace_via_form->curValue
				(progn
					input_pstk_name=upperCase(replace_via_form->curValue)
					if(member( input_pstk_name pstk_list) then
						axlFormSetField( replace_via_form "padstack_name" input_pstk_name)
					else
						axlFormRestoreField(replace_via_form "padstack_name")
					);if
				)
			);if
			replace_pstk_name=axlFormGetField(replace_via_form "padstack_name")
			axlFormListSelect(replace_via_form "padstack_list" replace_pstk_name)
			t
		);padstack_name
		("padpath"
			t
		);padpath
	)
)

(defun _select_padpath (padpath)
	(prog ()
		i=0
		padstackName_list=nil
		padpath=buildString(parseString(padpath "\\") "/")
		filelist = (cdr (cdr (getDirFiles  padpath)))
 		foreach( fileName filelist
 			UpfileName=upperCase(fileName)
 			if(rexMatchp("[.]PAD$" UpfileName) then
 			 	i=i+1
 			 	UpfileName=car(parseString(UpfileName "."))
 			 	padstackName_list=cons(UpfileName padstackName_list)
 			 	axlFormSetField( replace_via_form "padstack_list" UpfileName)
 				if((i ==1) && (replace_pstk_name == "initial via name") then
 					replace_pstk_name=UpfileName
 				)
			);if
		);foreach
		axlFormSetField( replace_via_form "padstack_name" replace_pstk_name)
		axlFormSetField( replace_via_form "padstack_list" nil)
		axlFormListSelect( replace_via_form "padstack_list" replace_pstk_name)
		return(padstackName_list)
	)
)

(defun _create_form_file (form_file)
	(prog (my_form_file)
		my_form_file=outfile(form_file "w")
		if(my_form_file !=nil then
			fprintf(my_form_file "FILE_TYPE=FORM_DEFN VERSION=2\n")
			fprintf(my_form_file "FORM\n")
			fprintf(my_form_file "FIXED\n")
			fprintf(my_form_file "PORT 50 11\n")
			fprintf(my_form_file "HEADER \"Replace Via\"\n")
			fprintf(my_form_file "\n")
			fprintf(my_form_file "TILE\n")
			fprintf(my_form_file "TEXT \"Select Padstack\"\n")
			fprintf(my_form_file "TLOC 8 1\n")
			fprintf(my_form_file "ENDTEXT\n")
			fprintf(my_form_file "\n")
			fprintf(my_form_file "FIELD padstack_list\n")
			fprintf(my_form_file "FLOC 1 3\n")
			fprintf(my_form_file "LIST \"\" 28 5\n")
			fprintf(my_form_file "ENDFIELD\n")
			fprintf(my_form_file "\n")
			fprintf(my_form_file "TEXT \"Padstack Name:\"\n")
			fprintf(my_form_file "TLOC 1 12\n")
			fprintf(my_form_file "ENDTEXT\n")
			fprintf(my_form_file "\n")
			fprintf(my_form_file "FIELD padstack_name\n")
			fprintf(my_form_file "FLOC 5 14\n")
			fprintf(my_form_file "STRFILLIN 20 24\n")
			fprintf(my_form_file "ENDFIELD\n")
			fprintf(my_form_file "\n")
			fprintf(my_form_file "TEXT \"First Padpath(ReadOnly):\"\n")
			fprintf(my_form_file "TLOC 1 16\n")
			fprintf(my_form_file "ENDTEXT\n")
			fprintf(my_form_file "\n")
			fprintf(my_form_file "FIELD padpath\n")
			fprintf(my_form_file "FLOC 1 18\n")
			fprintf(my_form_file "LIST \"\" 25 3\n")
			fprintf(my_form_file "ENDFIELD\n")
			fprintf(my_form_file "\n")
			fprintf(my_form_file "ENDTILE\n")
			fprintf(my_form_file "ENDFORM\n")
			close(my_form_file)
		else
			printf("ERROR,can't create form file!")
			return(nil)
		)
	)
)

        