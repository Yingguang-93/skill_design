;************************************************************************************
;Change Width beta1.0
;
;���ܸ������������迹�������ƣ���ĳһ���ڻ����ͬ���߿����и��ġ�
;
;ʹ��˵����	���ȼ��ش�il�ļ�����pcbenv�ļ�Ŀ¼�µ�allegro.ilinit���һ������
;	   	load("change_width.il")��axlCmdRegister("cw" 'change_width))�е�"cw"	
;		Ϊ��������ؼ���,�����Զ���˹ؼ��֡�
;         
;������ϸ	1. ͨ����CIW��������cw���������Ѿ��Զ��������������ܴ��塣
;			2. ��active����ѡ����Ҫ�����Ĳ㣬���Զ�ѡ��ȫѡ����ʱ���view���Ե�����ʾ��Щ�㡣
;			3. ��old width������Դ���߿�����new width������Ŀ���߿���
;			6. ����ͨ�����viewȥ������Щ�ߡ�
;			4. ������������Ϻ���changeִ�и��ġ�
;			5.����ִ�����Ҫ��ִ��done�����ȷ����ok��������cancel��
;   
;
;���ߣ�chen_ck of WXTB
;
;������ʷ
;
;2013.6.4 �����д���
;2014.5.13 ���������߿�����
;2013.6.16 ���������߿����Ĳ���Ӧ������
;2013.
;

axlCmdRegister("cw" , 'change_width)
defun( change_width ()
let( (items formPath p_wh)
	formPath = "./changeW_.form"
	p_wh = outfile( formPath "w")
	fprintf(p_wh "FILE_TYPE=FORM_DEFN VERSION=2\n")
	fprintf(p_wh "FORM\n")
	fprintf(p_wh "FIXED\n")
	fprintf(p_wh "PORT 45 10\n")
	fprintf(p_wh "HEADER \"Change Width\"\n")
	fprintf(p_wh "TILE\n")
/******************����б�**********************/	
	fprintf(p_wh "GROUP \n")
	fprintf(p_wh "FLOC 1 0\n")
	fprintf(p_wh "FSIZE 14 20\n")
	fprintf(p_wh "ENDGROUP\n")

	fprintf(p_wh "TEXT \"Active Layer:\"\n")
	fprintf(p_wh "FLOC 3 1\n")
	fprintf(p_wh "ENDTEXT\n")

	fprintf(p_wh "FIELD activelayer\n")
	fprintf(p_wh "FLOC 2 3\n")
	fprintf(p_wh "LIST \"\" 12 7\n")
	fprintf(p_wh "OPTIONS multiselect prettyprint\n")
	fprintf(p_wh "ENDFIELD\n")

	fprintf(p_wh "FIELD selall\n")
	fprintf(p_wh "FLOC 2 17\n")
	fprintf(p_wh "MENUBUTTON \"Select All\" 12 3\n")
	fprintf(p_wh "ENDFIELD\n")
	
/******************ִ������**********************/	
	fprintf(p_wh "GROUP \n")
	fprintf(p_wh "FLOC 16 0\n")
	fprintf(p_wh "FSIZE 14 20\n")
	fprintf(p_wh "ENDGROUP\n")
	
	fprintf(p_wh "TEXT \"Old Width:\"\n")
	fprintf(p_wh "FLOC 19 2\n")
	fprintf(p_wh "ENDTEXT\n")

	fprintf(p_wh "FIELD oldW\n")
	fprintf(p_wh "FLOC 18 4\n")
	fprintf(p_wh "REALFILLIN 9 10\n")
	fprintf(p_wh "MIN 0.0000\n")
	fprintf(p_wh "MAX 100.0000\n")
	fprintf(p_wh "DECIMAL 4\n")
	fprintf(p_wh "ENDFIELD\n")

	fprintf(p_wh "FIELD view\n")
	fprintf(p_wh "FLOC 17 7\n")
	fprintf(p_wh "MENUBUTTON \"View Select\" 12 3\n")
	fprintf(p_wh "ENDFIELD\n")
	
	fprintf(p_wh "TEXT \"New Width:\"\n")
	fprintf(p_wh "FLOC 19 12\n")
	fprintf(p_wh "ENDTEXT\n")

	fprintf(p_wh "FIELD newW\n")
	fprintf(p_wh "FLOC 18 14\n")
	fprintf(p_wh "REALFILLIN 9 10\n")
	fprintf(p_wh "MIN 0.0000\n")
	fprintf(p_wh "MAX 100.0000\n")
	fprintf(p_wh "DECIMAL 4\n")
	fprintf(p_wh "ENDFIELD\n")

	fprintf(p_wh "FIELD ignfix\n")
	fprintf(p_wh "FLOC 18 17\n")
	fprintf(p_wh "CHECKLIST \"Ignore Fixed\"\n")
	fprintf(p_wh "ENDFIELD\n")	
	
	
/******************��Χ������������**********************/

	fprintf(p_wh "GROUP \n")
	fprintf(p_wh "FLOC 31 0\n")
	fprintf(p_wh "FSIZE 14 20\n")
	fprintf(p_wh "ENDGROUP\n")
	

	fprintf(p_wh "TEXT \"Area Width:\"\n")
	fprintf(p_wh "FLOC 32 1\n")
	fprintf(p_wh "ENDTEXT\n")

	fprintf(p_wh "FIELD activewidth\n")
	fprintf(p_wh "FLOC 32 3\n")
	fprintf(p_wh "LIST \"\" 12 7\n")
	fprintf(p_wh "OPTIONS multiselect prettyprint\n")
	fprintf(p_wh "ENDFIELD\n")
	
	fprintf(p_wh "FIELD select\n")
	fprintf(p_wh "FLOC 32 17\n")
	fprintf(p_wh "MENUBUTTON \"Select Area\" 12 3\n")
	fprintf(p_wh "ENDFIELD\n")
	
;	fprintf(p_wh "FIELD desel\n")
;	fprintf(p_wh "FLOC 18 9\n")
;	fprintf(p_wh "MENUBUTTON \"Clear\" 10 3\n")
;	fprintf(p_wh "ENDFIELD\n")
/******************ȷ�ϰ�ť**********************/	

	fprintf(p_wh "FIELD changeW\n")
	fprintf(p_wh "FLOC 7 21\n")
	fprintf(p_wh "MENUBUTTON \"Change\" 10 3\n")
	fprintf(p_wh "ENDFIELD\n")
	
	fprintf(p_wh "FIELD ok\n")
	fprintf(p_wh "FLOC 20 21\n")
	fprintf(p_wh "MENUBUTTON \"Ok\" 10 3\n")
	fprintf(p_wh "ENDFIELD\n")
	
	fprintf(p_wh "FIELD cancel\n")
	fprintf(p_wh "FLOC 33 21\n")
	fprintf(p_wh "MENUBUTTON \"Cancel\" 10 3\n")
	fprintf(p_wh "ENDFIELD\n")
	
	fprintf(p_wh "ENDTILE\n")
	fprintf(p_wh "ENDFORM\n")
	close(p_wh)
	
	ch_form = axlFormCreate( (gensym) "changeW_.form" `(ne inner "msglines" 2) `changeW_Action t nil)
	axlUIWPerm( ch_form t )
	axlFormDisplay( ch_form )
	
	etchs = axlGetParam("paramLayerGroup:ETCH")
	etchs = etchs->groupMembers
	
	axlFormSetField( ch_form "activelayer"  etchs)
	axlFormSetField( ch_form "oldW" 		  0)
	axlFormSetField( ch_form "newW" 		  nil)
	axlFormDefaultButton(ch_form 			  nil)
	view_sel = nil
	width_lst = nil
	
	deleteFile(formPath)
);let
);defun

defun( changeW_Action (ch_form)

	old_w  = nil
	new_w  = nil
	layers = nil
	
	etch = axlFormListGetSelItems(ch_form "activelayer")
	foreach(tmp etch
		layers = tconc(layers buildString( list("ETCH" tmp) "/"))
	);foreach
	layers = car(layers)
	
	case(ch_form->curField
		("selall" 		if(ch_form->multi 
							then
								ch_form->multi = nil  
							else 
								ch_form->multi = t)
						axlFormListSelAll(ch_form "activelayer" ch_form->multi)
		);#selall
		
		("view"			get_cline()
						
		);#view"
		
		("changeW" 		change_cline() 	
						axlFormRestoreField(ch_form "oldW")
						axlFormRestoreField(ch_form "newW")
		);#changeW
		("select" 		area_sel()
		);#select
;		("desel" 		;de_sel()
;		);#clear
		("activewidth" 		axlFormSetField( ch_form "oldW" ch_form->curValue)
		);#select	
		
		("ok"			axlFinishEnterFun() 
						;axlDBTransactionCommit(widthMark)
		);#ok

		("cancel"		;unless(!boundp('widthMark)
							;axlDBTransactionRollback(widthMark)
						;);unless
						axlCancelEnterFun()
		);#cancel
	);case
);defun

defun( get_cline ()
	
	view_sel = nil
	axlVisibleDesign(nil)
	foreach(db layers
		axlVisibleLayer(db t)
	);foreach
	axlVisibleUpdate(t)
	axlClearSelSet()
	axlSetFindFilter(?enabled list("noall" "clinesegs") ?onButtons list("noall" "clinesegs"))
	viewclines = axlGetSelSet(axlAddSelectAll())
	axlClearSelSet()
	if(viewclines
		then
			foreach(db3 viewclines
				if(db3->width == axlFormGetField(ch_form "oldW")
					then
						axlHighlightObject(db3)
						view_sel =  cons(db3 view_sel)
				)
			);foreach
		else
			axlUIWPrint(ch_form "NO CLINES")
	);if	

);defun

defun(	area_sel ()

	while(axlFormListDeleteItem(ch_form "activewidth" 0) nil)
	axlFormSetField( ch_form "oldW" 0)
	width_lst = nil
	axlClearSelSet()
	axlSetFindFilter(?enabled list("noall" "clinesegs") ?onButtons list("noall" "clinesegs"))
	;area_clines = axlGetSelSet(axlSelect(?groupMode nil ?prompt nil))
	axlSingleSelectBox()
	area_clines = axlGetSelSet()
	width_lst = cons(car(area_clines)->width width_lst);�ռ���һ������
	foreach(db area_clines
		unless(member(db->width width_lst)
			width_lst = cons(db->width width_lst)
			
		);unless ɸѡ
	);�ռ����еĿ���
	foreach(db3 width_lst
		axlFormSetField( ch_form "activewidth" db3)
	);foreach
);defun
defun( de_sel ()
	width_lst = nil
	while(axlFormListDeleteItem(ch_form "activewidth" 0) nil)
	;axlFormSetField( ch_form "oldW" 		  nil)
)
	
defun( change_cline ()

	;widthMark = axlDBTransactionStart()

	fixed = nil;�ж���������
	
	while(axlFormListDeleteItem(ch_form "activewidth" 0) nil)
	if(axlFormGetField(ch_form "ignfix")
		then
			axlDBIgnoreFixed( t)
		else
			axlDBIgnoreFixed( nil)
	);
	if(width_lst
		then 
			allclines = area_clines
		else if(view_sel 
				then 
					allclines = view_sel
				else
					axlClearSelSet()
					axlSetFindFilter(?enabled list("noall" "clinesegs") ?onButtons list("noall" "clinesegs"))
					allclines = axlGetSelSet(axlAddSelectAll())
			);if
	)
	buffer = nil
	foreach(db1 allclines
		if(db1->width == axlFormGetField(ch_form "oldW")
			then
				buffer = tconc(buffer db1)
				when(axlDBIsFixed(db1) fixed = t)
		);if
	);foreach
	buffer = car(buffer)

	foreach(db2 buffer
		axlChangeWidth(db2 , axlFormGetField(ch_form "newW"))
	);foreach
	;axlDBTransactionMark(widthMark)
	if(fixed 
		then
			axlUIWPrint(ch_form "Some clines were fixed!")
	);
	gc()
	width_lst = nil
);defun 
defun(cancel_ ()
	unless(!boundp('widthMark)
		axlDBTransactionRollback(widthMark)
	);unless
);defun