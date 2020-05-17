axlCmdRegister("sca" 'savecopyas_time)
axlCmdRegister( "ds" 'downdesignsave ?cmdType "general")
/*
├─
│ ├─        程序名称：null
│ ├─        程序功能：保存文件到../bak文件夹，并注上当前时间为后缀，不改变当前打开的设计（不同于save as）与Altium Designer的save copy as功能类似，
│ ├─        创建时间：2016年09月29日
│ ├─        修改时间：
│ ├─        作    者：tb0669
│ └─        备    注：使用前请先保正../bak文件夹存在（此文件夹专用于设计文件备份）
├─

对于sD1 sD2 sT1 sT2:
        sD1;日期前缀 eg: _X0824_1200.brd
        sD2;日期后缀 eg: _0824X_1200.brd
        sT1;时间前缀 eg: _0824_X1200.brd
        sT2;时间后缀 eg: _0824_1200X.brd
*/
procedure( savecopyas_time(@optional (mode "date") )
prog( (tm sDate sTime sDName sDNameNew sPre sPost pt sD1 sD2 sT1 sT2)
        sD1= ""
        sD2= ""
        sT1= ""
        sT2= ""
        sDName= axlCurrentDesign()        ;axlGetDrawingName
        tm= timeToTm(stringToTime(getCurrentTime()))
        sTime= sprintf(nil,"_%s%2d%2d%s",sT1,tm->tm_hour,tm->tm_min,sT2)
        sDate= sprintf(nil,"_%s%2d%2d%s%s",sD1,tm->tm_mon + 1,tm->tm_mday,sD2,sTime)    ;tm->tm_year
        rexCompile(" ")
        sTime= rexReplace(sTime,"0",0)
        sDate= rexReplace(sDate,"0",0)
        case(mode
                ("time" pt= strcat("^\\(.+\\)[-_]+",sT1,"[0-2][0-9]\\.*[0-5][0-9]",sT2,"$"),sPost=sTime)
                ("date" pt= strcat("^\\(.+\\)[-_]+",sD1,"[0-1][0-9][0-3][0-9]",sD2,"[-_]+",sT1,"[0-2][0-9]\\.*[0-5][0-9]",sT2,"$"),sPost=sDate)
                (t printf("ERROR:wxSaveFileBT: 'wxsf' argument error,\n"),return(nil))
        );case
        rexCompile(pt)
        if(rexExecute(sDName) then
                sPre= rexSubstitute( "\\1" )
                sDNameNew= strcat(sPre,sPost)
        else
                sDNameNew= strcat(sDName,sPost)
        );if
axlShell(strcat("write " "../bak/" sDNameNew))
       ; axlSaveDesign(?design strcat(sDNameNew ".brd"))
		; axlSaveDesign(?design sDNameNew)
       printf("[ %s ]\322\321\261\243\264\346\265\275bak\316\304\274\376\274\320\n",sDNameNew)
);prog
);procedure

defun( downdesignsave ()
tyName = axlCurrentDesign()
tyName163 = strcat(tyName "_16_3")
script = outfile("./temp.scr")
fprintf(script "scriptmode +i +n\n")
fprintf(script "placementedit\ndownrev\nsetwindow form.downrev\nFORM downrev save2 YES \nFORM downrev save \n")
fprintf(script "fillin %s\n" tyName163)
fprintf(script "FORM downrev close\n")
	close(script)
	axlShell(strcat("replay " "./temp.scr"))
deleteFile("./temp.scr")
axlUIWPrint(nil "save to 16.3 complete")
)



