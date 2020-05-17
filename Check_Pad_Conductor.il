;************************************************************************************
;Check_Pad_Conductor beta0.0
;
;功能概述：用于检查盘出线总线宽包括shape，可检查出线总宽度大于80mil、全连接、线宽于盘。
;
;使用说明：	首先加载此il文件，在pcbenv文件目录下的allegro.ilinit最后一行添加
;	   	load("Check_Pad_Conductor.il")，axlCmdRegister("cpc" 'Find_illegal_pad)中的"cpc"	
;		为启动命令关键字,可以自定义此关键字。
;         
;功能亮点	1. 检查焊盘出线总宽度大于80mil；
;			2. 兼容Cline出线和正负片平面连接检查；
;			3. 全连接检查。
;			4. 出线单线宽度大于焊盘最小宽度。
;			5. 定位违规焊盘位置并高亮。
;			
;
;作者：chen_ck of WXTB
;
;升级历史
;
;2014.9.29 代码编写完成。
;2014.
;2014.
;2014.
;******************************************************
; 

axlCmdRegister("cpc" 'Find_illegal_pad)

defun( Find_illegal_pad ()
	formPath = "./illegal_info.form" 
	OPort = outfile( formPath "w")
	fprintf(OPort "fprintf(OPort \"FILE_TYPE=FORM_DEFN VERSION=2\"\n")
	fprintf(OPort "FORM\n")
	fprintf(OPort "FIXED\n")
	fprintf(OPort "PORT 36 28\n")
	fprintf(OPort "HEADER \"Pad Conductor V0.0\"\n")
	fprintf(OPort "TILE\n")

	fprintf(OPort "TEXT \"By Chen CK\"\n")
	fprintf(OPort "FLOC 25 0\n")
	fprintf(OPort "OPTIONS BOLD\n")
	fprintf(OPort "ENDTEXT\n")
	
	fprintf(OPort "GROUP\n")
	fprintf(OPort "GLOC 1 1\n")
	fprintf(OPort "GSIZE 35 24\n")
	fprintf(OPort "ENDGROUP\n")
	
	fprintf(OPort "TEXT \"Illegal Pads\"\n")
	fprintf(OPort "FLOC 2 3\n")
	fprintf(OPort "ENDTEXT\n")
	
	fprintf(OPort "FIELD ilgpadList\n")
	fprintf(OPort "FLOC 2 5\n")
	fprintf(OPort "LIST \"\" 16 10\n")
	fprintf(OPort "OPTIONS multiselect\n") 
	fprintf(OPort "ENDFIELD\n")

	fprintf(OPort "TEXT \"Pad Attributes\"\n")
	fprintf(OPort "FLOC 20 3\n")
	fprintf(OPort "ENDTEXT\n")
	
	fprintf(OPort "FIELD ilgatr\n")
	fprintf(OPort "FLOC 19 5\n")
	fprintf(OPort "LIST \"\" 16 10\n") 
	fprintf(OPort "OPTIONS multiselect\n") 
	fprintf(OPort "ENDFIELD\n")
	
	fprintf(OPort "FIELD analyze\n")
	fprintf(OPort "FLOC 12 26\n")
	fprintf(OPort "MENUBUTTON \"Check up\" 14 4\n")
	fprintf(OPort "ENDFIELD\n")

	fprintf(OPort "ENDTILE\n")
	fprintf(OPort "ENDFORM\n")
	close(OPort)
	
	GForm = axlFormCreate( (gensym) "illegal_info.form" `(e inner) `FIP_CB t nil)
	axlUIWPerm( GForm t )
	axlFormDisplay( GForm )
	deleteFile(formPath)
);defun form	
defun( 	FIP_CB (GForm)
	case(GForm->curField
		("analyze" 	Select_Pads())
		("ilgpadList" show_atr(axlFormListGetSelItems(GForm "ilgpadList") idx)    )
	);case
);defun
/***************显示盘的属性********************/
defun(show_atr (eletem idx)
	nidx = 0
	axlFormListDeleteAll(GForm "ilgatr")
	for(i 0 idx
		when(car(eletem) == nth(i err_list)
			nidx  = i;
			axlFormSetField(GForm "ilgatr" error_info[nidx]->xy)
			axlFormSetField(GForm "ilgatr" error_info[nidx]->CWidth)
			axlFormSetField(GForm "ilgatr" error_info[nidx]->Shapes)
			axlFormSetField(GForm "ilgatr" error_info[nidx]->FC)
			axlFormSetField(GForm "ilgatr" error_info[nidx]->LILG)
			axlZoomToDbid(error_info[nidx]->dbid t)
		);when
	);for
);defun show Attributes
/***************选择所有焊盘********************/
defun(Select_Pads ()

	axlFormListDeleteAll(GForm "ilgpadList");清除列表内容
	axlFormListDeleteAll(GForm "ilgatr");清除列表内容
	
	axlVisibleLayer("PIN/TOP",t)
	axlVisibleLayer("PIN/BOTTOM",t)
	axlVisibleUpdate(t)
	axlClearSelSet()
	axlSetFindFilter(?enabled list("pins")  ?onButtons list("pins"))
	All_Pin = axlGetSelSet(axlAddSelectAll());用户选择目标pin或via
	axlClearSelSet()
	axlDehighlightObject(All_Pin t)
	
	error_info = makeTable("Illegal_pad" nil);创建错误信息索引表/G
	idx = 0;索引号/G
	err_list = nil;错误列表/G
	foreach(db All_Pin
		get_final_width(db)
	);foreach
	for(i 0 idx
		err_list = append1(err_list error_info[i]->owner)
	);for
	axlFormSetField(GForm "ilgpadList" err_list)
);defun	
/***************计算焊盘出线的总线宽********************/
defun(get_final_width (targetPin)
	
	con_elements = nil;/L
	line_width = 0;/L
	shape_list = nil;/L
	FCMK = nil;/全连接标志/L
	Line_ilg = nil;走线宽于盘/L
	BL = nil;盘bBox low/L
	BH = nil;盘bBox High/L
	disX = nil;盘x长度/L
	disY = nil;盘y长度/L
	W = 0;/L
	if(targetPin
		then
			con_elements = axlDBGetConnect(targetPin t)
		else
			axlUIWPrint(cdc_form "Nothing were selected!")
	);
	/*获取焊盘连接线宽和覆铜层信息*/
	when(con_elements
		foreach(db con_elements
			when(db->objType == "path"
				if(db->isSameWidth
					then
						line_width = line_width + car(db->segments)->width;
					else
						min_LW = car(db->segments)->width
						foreach(db2 db->segments
							if(db2->width < min_LW
								then
									min_LW = db2->width;
							);if
						);foreach
						line_width = line_width + min_LW;获取线的总宽度
				);end if
				/*每层etch pad的大小，包括椭圆形的*/
				foreach(PSTK targetPin->pads
					when(rexMatchp("^ETCH/" PSTK->layer)
						BL = car(PSTK ->bBox)
						BH = cadr(PSTK ->bBox)
						disX = car(BH) - car(BL)
						disY = cadr(BH) - cadr(BL)
						W = car(db->segments)->width
						when(min(disX disY) != 0 && W > min(disX disY)
							Line_ilg = t;
						);when
					);when
				);foreach
			);when
			when(db->objType == "shape" 
				shape_list = append1(shape_list db->layer)
			);when
		);end foreach
	);end when 获取线的总宽度
	
	/*平面层相连接的覆铜*/
	shape_string = ""
	when(shape_list
		shape_list = unique(shape_list)
		foreach(db shape_list
			shape_string = strcat(shape_string cadr(parseString(db "/")),"     ")
		);foreach
	);when 
	/*计算走线宽度和覆铜层信息*/
	when(shape_list
		foreach(shapes shape_list
			if(axlDBGetLayerType(shapes) == "CONDUCTOR"
				then
					FCMK = t;全连接
				else
					Spoke_Width = get_thermal_spoke(targetPin);调用计算花盘函数
					line_width = line_width + Spoke_Width;
			);if
		);foreach
	);when
	/*违规信息判别：全连接、线宽于盘、走线大于80mil*/
	when(FCMK || Line_ilg || line_width >= 80
		error_info[idx] = gensym()
		if(FCMK
			then
				error_info[idx]->FC = "Full Conductor";全连接
			else
				error_info[idx]->FC = nil;非全连接
		);end if
		if(Line_ilg 
			then
				error_info[idx]->LILG = "ClineW > PadW";线宽于盘
			else
				error_info[idx]->LILG = nil;非线宽于盘
		);end if
		error_info[idx]->dbid = targetPin;dbid
		error_info[idx]->xy = targetPin->xy;输出坐标
		error_info[idx]->owner = strcat(targetPin->component->name "." targetPin->number);输出名字
		error_info[idx]->CWidth = line_width;连接宽度
		error_info[idx]->Shapes = shape_list
		idx++;
		axlHighlightObject(targetPin t)
	);when
);defun

/***************分析花盘和计算花盘尺寸********************/
defun(get_thermal_spoke (PAD)
	
	loop_mark1 = t;控制循环次数1/L
	ArcCenter = PAD->xy;焊盘圆心/L
	spoke_path = nil;spoke的路径/L
	first_spk = nil;第一个spoke信息/L
	EndPoint = nil;第一个spoke路径的端点/L
	FCMK = nil;/全连接标志/L
	
	foreach(db_Pad PAD->pads
		when(db_Pad->figureName == "FLASH" && loop_mark1
			first_spk = car(db_Pad->figure);4种spoke的第一个
			spoke_path = first_spk->_pathList;5-6个部分
			foreach(db_SP spoke_path
				EndPoint = append1(EndPoint db_SP->_endPoint)
			);foreach
			loop_mark1 = nil;控制循环次数1
		);when
	);foreach
	when(loop_mark1
		foreach(db_Pad PAD->pads
			when(db_Pad->figureName == "CIRCLE" && loop_mark1
				FCMK = t;全连接
				loop_mark1 = nil;控制循环次数1
			);when
		);foreach
	);when
	RMAX = 0;/L
	Cal_Point_max = nil;在花盘最大半径上的点/L
	Spoke_DisLst = nil;spoke 的内弧或外弧的端点列表/L
	Spoke_Dis = 0;spoke 的内弧或外弧的总弧长/L
	Spoke_Width = 0;spoke宽度/G
	if(EndPoint
		then
			foreach(db EndPoint
				when(RMAX < axlDistance(ArcCenter db)
					RMAX = axlDistance(ArcCenter db)
				);when 获取Flash最大半径和最小半径
			);foreach
			foreach(db EndPoint
				when(round(RMAX) == round(axlDistance(ArcCenter db))
					Cal_Point_max = append1(Cal_Point_max db)
				);when 获取Flash最大半径
			);foreach 
			Cal_Point_max = unique(Cal_Point_max);去重

			foreach(db1 Cal_Point_max
				foreach(db2 Cal_Point_max
					when(axlDistance(db1 db2) != 0
						Spoke_DisLst = append1(Spoke_DisLst axlDistance(db1 db2))
					);when
				);foreach
			);foreach
			Spoke_DisLst = unique(Spoke_DisLst);去重
			Spoke_DisLst = sort(Spoke_DisLst 'greaterp);排序
			Spoke_Dis = car(Spoke_DisLst);获取最大值
			unless(Spoke_Dis print(PAD->xy))
			arc_len = 2 * RMAX * asin(Spoke_Dis*0.5/RMAX);弧长
			Spoke_Width = pi * RMAX / 2 - arc_len

			Spoke_Width = round(Spoke_Width)
		else
			"No Flash!"
	);if
	Spoke_Width = 4 * Spoke_Width;
);defun



