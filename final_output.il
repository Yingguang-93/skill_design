/****************************************************/
/*             Title : 输出及打包最终                */
/*            Author : tb669                        */
/*     Creation Date : 2016-08-22                   */
/*            Update :                              */
/*           Version : 2.0                          */
/****************************************************/

/**********************************************************************************************/
/*使用方法加载il文件后依次输入30,31,32,33,执行即可，各功能说明如下                               */
/*              notice : 弹出提示框(已关闭)                                                   */
/*        check_status(30) : database check并打开statue查看                                   */
/*      artwork_export(31) : 设置artwork device type为RS274X Format为5:5 并选择所有films输出   */
/* drill_placement_ipc(32) ：输出nc drill Format为5:5 命名为nc 输出placement 输出ipc 命名为ipc */
/*             package(33) : 按公司规范压缩最终数据分别为-pcb -smt -asm -cam                   */
/*********************************************************************************************/

/*******************************************/
/*注意使用此工具出数据请先确保如下           */
/* 1.artwork层叠设置正确                   */
/* 2.未定义线宽设置正确                    */
/* 3.shape、global下artwork fomat为RS274X */
/* 4.drill legend 会直接重新放置 如有特殊要求请在58行前加；或不用此工具  */
/* 5.工具不出.rou文件，执行完32请注意comand窗口会有类似WARNING:         */
/* …… NOT be drilled.……NC Route instead请注意手动出，但压缩最终可识别此文件*/
/*****************************************/




;axlCmdRegister( "34" 'notice)
axlCmdRegister( "30" 'check_status ?cmdType "general")
axlCmdRegister( "31" 'artwork_export ?cmdType "general")
axlCmdRegister( "32" 'drill_placement_ipc ?cmdType "general")
axlCmdRegister( "33" 'package)


;defun( notice ()
;axlUIConfirm("\n\n\312\271\323\303\261\276\271\244\276\337\307\260\307\353\310\267\261\243\n1.\artwork\262\343\265\376\311\350\326\303\325\375\310\267\n2.\316\264\266\250\322\345\317\337\277\355\311\350\326\303\325\375\310\267\n3.\shape/global\317\302artworkfomat\316\252RS274X         \n4.drill legend\316\252\327\356\320\302\267\305\326\303")
;)
defun( check_status ()
script = outfile("./temp.scr")
fprintf(script "scriptmode +i +n\n")
fprintf(script "generaledit\ndbdoctor \nsetwindow form.dbdoctor_allegro\nFORM dbdoctor_allegro drc YES \nFORM dbdoctor_allegro shapes YES \nFORM dbdoctor_allegro xnets YES\n")
fprintf(script "FORM dbdoctor_allegro execute  \nFORM dbdoctor_allegro close  \nsetwindow pcb\ngeneraledit \nstatus \ngeneraledit\n")
	close(script)
	axlShell(strcat("replay " "./temp.scr"))
deleteFile("./temp.scr")
axlUIWPrint(nil "plase check the status")
)

defun( artwork_export ()
param = outfile("./art_param.txt")
fprintf(param "DEVICE-TYPE           GERBER_RS274X\n")
fprintf(param "FILM-SIZE             2400000 1600000\n")
fprintf(param "FORMAT                5.5")
close(param)
script = outfile("./temp.scr")
fprintf(script "scriptmode +i +n\n")
fprintf(script "generaledit\nsetwindow pcb \nncdrill legend\nsetwindow form.nc_drilllegend  \nFORM nc_drilllegend done \nsetwindow pcb \npick 0 -20\n")
fprintf(script "generaledit\nartwork \nsetwindow form.film_control\nFORM film_control general_parameters  \nFORM film_control film_control\n")
fprintf(script "FORM film_control select_all  \nFORM film_control create  \nFORM film_control ok  \n")
	close(script)
	axlShell(strcat("replay " "./temp.scr"))
deleteFile("./temp.scr")
axlUIWPrint(nil "^_^ artwork completed successfully")
)

defun( drill_placement_ipc ()
script = outfile("./temp.scr")
fprintf(script "scriptmode +i +n\n")
fprintf(script "placementedit\nnctape_full \nsetwindow form.nc_drill\nFORM nc_drill tape_name NC \nFORM nc_drill parameters  \nsetwindow form.nc_parameters\n")
fprintf(script "FORM nc_parameters integer_places 5 \nFORM nc_parameters decimal_places 5 \nFORM nc_parameters done  \nsetwindow form.nc_drill\n")
fprintf(script "FORM nc_drill execute  \nFORM nc_drill close  \nsetwindow pcb\nplacementedit \nplctxt out \nsetwindow form.plctxt\nFORM plctxt body_center YES \nFORM plctxt execute  \n")
fprintf(script "FORM plctxt cancel  \nsetwindow pcb\nplacementedit \nipc356 out \nplacementedit \nsetwindow form.ipc356\nFORM ipc356 outfilename IPC \nFORM ipc356 run  \nFORM ipc356 close")
	close(script)
	axlShell(strcat("replay " "./temp.scr"))
deleteFile("./temp.scr")
axlUIWPrint(nil "drill/placement/ipc export successfully")
)

;shell("winrar路径?执行命令?压缩文件名?需要压缩的文件或文件夹")
;a 添加文件到压缩文件


defun( package ()
;SMT
;shell("winrar.exe a -apSMT SMT.rar RA.art")
name = strcat(axlCurrentDesign())
shell(strcat("winrar.exe a -ap" name "-SMT" " " name "-SMT.rar" " " "RA.art"))
shell(strcat("winrar.exe a -ap" name "-SMT" " " name "-SMT.rar" " " "RB.art"))
shell(strcat("winrar.exe a -ap" name "-SMT" " " name "-SMT.rar" " " "SA.art"))
shell(strcat("winrar.exe a -ap" name "-SMT" " " name "-SMT.rar" " " "SB.art"))
shell(strcat("winrar.exe a -ap" name "-SMT" " " name "-SMT.rar" " " "PA.art"))
shell(strcat("winrar.exe a -ap" name "-SMT" " " name "-SMT.rar" " " "PB.art"))
shell(strcat("winrar.exe a -ap" name "-SMT" " " name "-SMT.rar" " " "place_txt.txt"))
shell(strcat("winrar.exe a -ap" name "-SMT" " " name "-SMT.rar" " " "*.drl"))
shell(strcat("winrar.exe a -ap" name "-SMT" " " name "-SMT.rar" " " "*.rou"))
;ASM
shell(strcat("winrar.exe a -ap" name "-ASM" " " name "-ASM.rar" " " "SA.art"))
shell(strcat("winrar.exe a -ap" name "-ASM" " " name "-ASM.rar" " " "SB.art"))
shell(strcat("winrar.exe a -ap" name "-ASM" " " name "-ASM.rar" " " "RA.art"))
shell(strcat("winrar.exe a -ap" name "-ASM" " " name "-ASM.rar" " " "RB.art"))

;CAM
;移除当前文件夹内cam
shell(strcat("winrar.exe m -ap" name "-CAM" " " name "-CAM.rar" " " "*.art"))
shell(strcat("winrar.exe m -ap" name "-CAM" " " name "-CAM.rar" " " "*.ipc"))
shell(strcat("winrar.exe m -ap" name "-CAM" " " name "-CAM.rar" " " "place_txt.txt"))
shell(strcat("winrar.exe m -ap" name "-CAM" " " name "-CAM.rar" " " "*.drl"))
shell(strcat("winrar.exe m -ap" name "-CAM" " " name "-CAM.rar" " " "*.rou"))
shell(strcat("winrar.exe a -ap" name "-CAM" " " name "-CAM.rar" " " "nc_param.txt"))
shell(strcat("winrar.exe a -ap" name "-CAM" " " name "-CAM.rar" " " "art_param.txt"))

;PCB
shell(strcat("winrar.exe a -ap" name "-PCB" " " name "-PCB.rar" " " "*.brd"))
shell(strcat("winrar.exe X " name "-PCB.rar"))
shell("del *-PCB.rar")
axlUIWPrint(nil "finaldate package successfully")
)
