;************************************************************************************
;
;
;功能概述：
;
;使用说明：	首先加载此il文件，在pcbenv文件目录下的allegro.ilinit最后一行添加
;	   	load("snap__sp.il"),axlCmdRegister("sp" 'snap)是命令声明语句，sp即调用功能.
;         
;功能明细	1. axlSetFunckey("s" "skill snap" t)中的s既是快捷健，在CMD按s时立即执行，
;			   用户可以自行更改。
;			2. 此功能是吸附pin的中心，在move模式、user Pick模式皆可以使用此功能。
;			3.点击select选择需要摆放的器件
;注意：谨慎使用，注意保存。
;
;作者：chen_ck of WXTB
;
;升级历史
;
;2013.11,19 代码编写完成
;2013.
;2013.
;2013.

axlCmdRegister("sp" 'snap_main)

defun( snap_main ()

		formPath = "./snap.form" 
		pform = outfile( formPath "w")

		fprintf(pform "FILE_TYPE=FORM_DEFN VERSION=2\n")
		fprintf(pform "FORM\n")
		fprintf(pform "FIXED\n")		
		fprintf(pform "PORT 35 10\n") 
		fprintf(pform "HEADER \"Snap\"\n")
		fprintf(pform "TILE\n")
		
		fprintf(pform "FIELD sel\n")
		fprintf(pform "FLOC 2 1\n")
		fprintf(pform "MENUBUTTON \"Select Area\" 14 4\n")
		fprintf(pform "ENDFIELD\n")
		
		fprintf(pform "FIELD pic\n")
		fprintf(pform "FLOC 18 1\n")
		fprintf(pform "MENUBUTTON \"Place each\" 14 4\n")
		fprintf(pform "ENDFIELD\n")
		
		fprintf(pform "TEXT \"Snap  Key:\"\n")
		fprintf(pform "TLOC 2 5\n")
		fprintf(pform "ENDTEXT\n")
		
		fprintf(pform "TEXT \"Place Key:\"\n")
		fprintf(pform "TLOC 2 7\n")
		fprintf(pform "ENDTEXT\n")
		
		fprintf(pform "TEXT \"F11\"\n")
		fprintf(pform "TLOC 22 5\n")
		fprintf(pform "OPTIONS BOLD\n")
		fprintf(pform "ENDTEXT\n")
		
		fprintf(pform "TEXT \"F12\"\n")
		fprintf(pform "TLOC 22 7\n")
		fprintf(pform "OPTIONS BOLD\n")
		fprintf(pform "ENDTEXT\n")
		
		fprintf(pform "ENDTILE\n")
		fprintf(pform "ENDFORM\n")	
		close(pform)
		
		snp = axlFormCreate( (gensym) "snap.form" '(e inner) 'snpCB t nil)
		axlFormDisplay( snp )
		deleteFile(formPath)
		
		axlSetFunckey("F12" "skill snap" t);吸附命令
			
		axlSetFunckey("F11" "skill place_each" t);放置命令
			
		if(car(axlDBGetDesignUnits()) == "mils"
			then
				scale = 1
			else
				scale = 40
		);if
		
		formove = nil
);defun
defun(snpCB (snp)
	func_list = axlGetFunckey(nil)
	func_list = append( axlGetAlias(nil) func_list)
	case(snp->curField
		("sel" axlUIWPrint(snp "select box")  newMove());case 1
		("pic" if(!formove
					then
						axlUIWPrint(snp "Select symbols by box") 
					else
						if(I != 0   /* box = axlLastPick(nil) */ lastbox = axlWindowBoxGet()) 
						place_each()
				);if
		);case 2
	);case 
	when(snp->doneState == 3 
		axlSetFunckey("F11"  "zoom in" t);吸附命令
		axlSetFunckey("F12"  "zoom out" t);放置命令
	);when
		
);defun
defun(newMove ()
	I = 0;
	axlClearSelSet()
	axlSetFindFilter(?enabled list( "noall" "symbols" ) ?onButtons list( "noall" "symbols"))

	;axlSelect(?groupMode nil ?prompt nil)
	axlAddSelectBox()
	syms = axlGetSelSet()
	formove = nil
	foreach(db syms 
		formove = append1(formove db->refdes)
	);foreach
	axlUIWPrint(snp "Place symbols one by one!")
);defun


defun(place_each ()
prog(()
	unless(formove return("select box first"))
	if(I != 0 then /* box = axlLastPick(nil) */ lastbox = axlWindowBoxGet())
	active = car(formove)
	formove = cdr(formove)
	if(active
		then
			axlShell("move")
			axlShell("setwindow form.mini")
			axlShell("FORM mini rotate_point Sym Pin # ")
			axlShell("setwindow form.find")
			axlShell("FORM find name_type Symbol (or Pin)")
			axlShell(sprintf(nil "FORM find find_name %s" active))
			
			when(I != 0	
				axlWindowBoxSet(lastbox)	
			);when	
				
			I++;
	);if
);prog
);	defun

defun(snap ()
	cursor = axlCursorGet(nil)
	axlShell(sprintf(nil "prepopup %L" cursor))
	axlShell("pop dyn_option_select 'Snap pick to@:@Pin'")
	;axlShell("pop dyn_option_select 'Snap pick to@:@Segment Vertex'")
);defun 
;		load("snap.il")
	
