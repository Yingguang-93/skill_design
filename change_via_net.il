;
;FileName:        fChangeViaNet.il
;Load:                load("fChangeViaNet.il")
;Command:        cvn
;使用方法:
;        1.執行cvn
;        2.選擇vias (兩種方式:直接滑鼠點選或是框選)
;        3.選擇新的net名稱 (兩種方式:直接滑鼠點選新的net物件,另外是在Option上勾選Enable,在瀏覽Net名稱)
;        以上步驟就可以改變Via的網路名稱
;
;        4.滑鼠右鍵功能選單:
;                Done => 結束程式,
;                Oops => 恢復上一次的動作,
;                Cancel => 取消程式.
;        5.Option功能選項:
;                "Enable" => 啟用網路名稱,
;                "Popup選單" => 要改變的網路名稱(如果是空白,會改為由滑鼠點選物件網路),
;                "..." => 瀏覽選擇網路名稱.
;
;程式的特色:
;        1.兩種選擇:直接點選其他物件的網路和選擇Option上的網路名稱,
;        2.滑鼠右鍵Oops恢復上一次功能,沒有任何事件可以恢復時,其選項就變成灰色不能再選.
;        3.源代碼分享,讓所有人都可以依照自己的方式加入其他功能,
;                例如加入快捷鍵.
;                或是在右鍵選單加其他功能.
;                或是自己再優化程式代碼,以加快程式執行速度.
;                或是將英文訊息改文中文訊息.
;                或是其他功能,自己想像.
axlCmdRegister("cvn" 'fnChangeViaNet ?cmdType "interactive" ?doneCmd 'fnCVNPopupDone ?cancelCmd 'fnCVNPopupCancel)
procedure(fnChangeViaNet() ;主程式
        let((frmCVN)
                frmCVN = fnCVNBuildForm()
                fnCVNSetVariables(frmCVN)
                fnCVNSetFormField(frmCVN)
                fnCVNStart(frmCVN)
        )
)
procedure(fnCVNBuildForm()
        let((tFile pPort frmCVN)
                drain()
                tFile = axlTempFile()
                pPort = outfile(tFile)
                fprintf(pPort "FILE_TYPE=FORM_DEFN VERSION=2\nFORM\nFIXED\nPORT 1 1\n\n")
                fprintf(pPort "HEADER \"\"\n")
                
                fprintf(pPort "POPUP <netname> \"\"\"\"\n")
                                
                fprintf(pPort "TILE\n\n")
                
                fprintf(pPort "TEXT\n")
                fprintf(pPort "FLOC 1 0\n")
                fprintf(pPort "INFO ProgName 1\n")
                fprintf(pPort "FSIZE 25 2\n")
                fprintf(pPort "OPTIONS BOLD\n")
                fprintf(pPort "ENDTEXT\n")
                                
                fprintf(pPort "TEXT \"Assign net name:\"\n")
                fprintf(pPort "TLOC 1 3\n")
                fprintf(pPort "OPTIONS BOLD\n")
                fprintf(pPort "ENDTEXT\n")
                
                fprintf(pPort "FIELD enable\n")
                fprintf(pPort "FLOC 2 5\n")
                fprintf(pPort "CHECKLIST \"Enable\"\n")
                fprintf(pPort "ENDFIELD\n")
                
                fprintf(pPort "FIELD netname\n")
                fprintf(pPort "FLOC 2 7\n")
                fprintf(pPort "ENUMSET 18\n")
                fprintf(pPort "OPTIONS prettyprint\n")
                fprintf(pPort "POP \"netname\"\n")
                fprintf(pPort "ENDFIELD\n")
        
                fprintf(pPort "FIELD browse\n")
                fprintf(pPort "FLOC 23 7\n")
                fprintf(pPort "MENUBUTTON \"...\" 3 3\n")
                fprintf(pPort "ENDFIELD\n")
                
                fprintf(pPort "ENDTILE\n")
                fprintf(pPort "ENDFORM\n")
                close(pPort)
                axlControlRaise('options)
                frmCVN = axlMiniStatusLoad(gensym() tFile 'fnCVNCallback t)
                frmCVN
        )
)
procedure(fnCVNCallback(frmCVN)
        let((lNewName)
                case(frmCVN->curField
                        ("browse"
                                lNewName = axlUIDataBrowse('NET '(RETRIEVE_OBJECT) "Please select net" t)
                                when(lNewName
                                        frmCVN->lNetName = cons(car(lNewName) frmCVN->lNetName)
                                        frmCVN->lNetName = sort(frmCVN->lNetName nil)
                                        axlFormBuildPopup(frmCVN "netname" fnCVNSetPopupValue(frmCVN->lNetName))
                                        axlFormSetField(frmCVN "netname" car(lNewName))
                                )
                        )
                )
        )
)
procedure(fnCVNChange(lSelObjs tNetName)
        prog((tOldPadName lOldXY tOldNetName lNewVia tMessage) 
                axlClearSelSet()
                foreach(dObj lSelObjs
                        tOldPadName = dObj->name
                        lOldXY = dObj->xy
                        tOldNetName = dObj->net->name
                        if(axlDBIsFixed(dObj) then
                                printf("E-Ignore Change FIXED VIA @ %L\n" dObj->xy)
                                return(nil)
                        else
                                ;axlDBAssignNet
                                lNewVia = axlDBCreateVia(tOldPadName lOldXY tNetName)
                        )
                        if(tOldNetName then
                                tMessage = sprintf(nil "M-Change via net from %s to %s" tOldNetName tNetName)
                        else
                                tMessage = sprintf(nil "M-Change via net from nil to %s" tNetName)
                        )
                        axlMsgPut(tMessage)
                )
                axlDeleteObject(lSelObjs) ;刪除舊的Via
                axlDBRefreshId(nil)
                axlClearSelSet()
                return(t)
        )
)
procedure(fnCVNSetPopupValue(lList)
        let((lNewList)
                foreach(dItem lList
                        lNewList = append1(lNewList list(dItem dItem))
                )
                lNewList
        )
)
procedure(fnCVNPopupCancel()
        when(frmCVN->xTransMark
                axlDBTransactionRollback(frmCVN->xTransMark)
        )
        axlClearSelSet()
        axlCancelEnterFun()
        axlUICmdPopupSet(nil)
        axlUIPopupSet(nil)
)
procedure(fnCVNPopupCallback(rEvent)
        fnCVNPopupCheck(frmCVN)
)
;=======================================
procedure(fnCVNPopupCheck(frmCVN)
        ;解決執行Oops後Popup變成灰色的
        axlUICmdPopupSet(frmCVN->rPopupOrign)
        if(frmCVN->xMarkCount >= 1 then
                axlUIPopupSet(frmCVN->rPopupOrign)
        else
                axlUIPopupSet(frmCVN->rPopupGray)
        )
)
procedure(fnCVNPopupDone()
        when(frmCVN->xTransMark
                axlDBTransactionCommit(frmCVN->xTransMark)
        )
        axlClearSelSet()
        axlFinishEnterFun()
        axlUICmdPopupSet(nil)
        axlUIPopupSet(nil)
)
procedure(fnCVNPopupInit()
        ;定義Popup
        frmCVN->rPopupOrign = axlUIPopupDefine(nil
                list(list("Done" 'fnCVNPopupDone)
                        list("Oops" 'fnCVNPopupOops)
                        list("Cancel" 'fnCVNPopupCancel)
                )
        )
        frmCVN->rPopupGray = axlUIPopupDefine(nil
                list(list("Done" 'fnCVNPopupDone)
                        ;list("Oops" 'fnCVNPopupOops)        ;沒有任何選擇時會變成灰色
                        list("Cancel" 'fnCVNPopupCancel)
                )
        )
)
procedure(fnCVNPopupOops()
        if(!axlDBTransactionOops(frmCVN->xTransMark) then
                frmCVN->xMarkCount = 0
        else
                axlUIWPrint(nil "Oops")
                frmCVN->xMarkCount = sub1(frmCVN->xMarkCount)
                axlClearSelSet()
        )
        when(frmCVN->lSelVias
                frmCVN->lSelVias = nil
                lEventMask = list('PICK 'STARTDRAG 'STOPDRAG)
                axlSetFindFilter(?enabled list("noall" "vias") ?onButtons list("noall" "vias"))
                printf("M-Please select vias...\n")
        )
        fnCVNPopupCheck(frmCVN)
)
procedure(fnCVNPopupUndoTimes(rFormID @optional (xCount 1))
        for(xIndex 0 xCount-1
                if(!axlDBTransactionOops(rFormID->xTransMark) then
                        rFormID->xMarkCount = 0
                else
                        rFormID->xMarkCount = sub1(rFormID->xMarkCount)
                )
        )
)
procedure(fnCVNSetFormField(frmCVN)
        axlFormColorize(frmCVN "ProgName" 'text 'red)
        axlFormSetField(frmCVN "ProgName" frmCVN->tProgName)
)
procedure(fnCVNSetVariables(frmCVN)
        frmCVN->tProgName = "   Change Via Net V1.00"
        
        frmCVN->lSelVias = nil        ;存放所選擇的Vias物件
        frmCVN->lNetName = nil        ;Option上的Popup的net名稱選項
        
        ;設定滑鼠右鍵選單相關變數
        frmCVN->xTransMark = nil
        frmCVN->xMarkCount = 0
        frmCVN->rPopupOrign = nil
        frmCVN->rPopupGray = nil
)
procedure(fnCVNStart(frmCVN)
        let(((bDoFlag t) lEventMask rEventID tNetName lTempXY)
                fnCVNPopupInit()
                axlEventSetStartPopup('fnCVNPopupCallback)
                frmCVN->xTransMark = axlDBTransactionStart()
            axlClearSelSet()
                while(bDoFlag
                        if(frmCVN->lSelVias then
                                lEventMask = list('PICK)
                                axlSetFindFilter(?enabled '("noall" "Vias" "Shapes" "Pins" "Clines") ?onButtons '("Vias" "Shapes" "Pins" "Clines"))
                                printf("M-Please pick via, shape, pin or cline to get a net!") 
                        else
                                lEventMask = list('PICK 'STARTDRAG 'STOPDRAG)
                                axlSetFindFilter(?enabled list("noall" "vias") ?onButtons list("noall" "vias"))
                                printf("M-Please select vias...\n")
                        )
                        rEventID = axlEnterEvent(lEventMask nil nil)
                        caseq(rEventID->type
                                (PICK ;滑鼠按下左鍵一次
                                        axlDBTransactionMark(frmCVN->xTransMark)
                                        frmCVN->xMarkCount = add1(frmCVN->xMarkCount)
                                        if(frmCVN->lSelVias then
                                                axlClearSelSet()
                                                if(axlAddSelectPoint(rEventID->xy) then
                                                        tNetName = car(axlGetSelSet())->net->name
                                                        fnCVNPopupUndoTimes(frmCVN) ;恢復一次
                                                        when(fnCVNChange(frmCVN->lSelVias tNetName)
                                                                frmCVN->lSelVias = nil
                                                        )
                                                else
                                                        ;恢復一次,因為沒有選到認一物件
                                                        fnCVNPopupUndoTimes(frmCVN)
                                                        axlHighlightObject(frmCVN->lSelVias)
                                                )
                                        else
                                                axlAddSelectPoint(rEventID->xy)
                                                frmCVN->lSelVias = axlGetSelSet()
                                                unless(frmCVN->lSelVias
                                                        ;恢復一次,因為沒有選到認一物件
                                                        fnCVNPopupUndoTimes(frmCVN)
                                                )
                                                when(axlFormGetField(frmCVN "enable") == "1" ;直接取option上的netname
                                                        tNetName = axlFormGetField(frmCVN "netname")
                                                        unless(tNetName == ""
                                                                when(fnCVNChange(frmCVN->lSelVias tNetName)
                                                                        frmCVN->lSelVias = nil
                                                                )
                                                        )
                                                )
                                                
                                        )
                                )
                                (STARTDRAG ;使用滑鼠拉一個矩形框開始位置
                                        lTempXY = rEventID->xy
                                        axlAddSimpleRbandDynamics(lTempXY "box" ?origin lTempXY ?var_point (0:0))
                                )
                                (STOPDRAG ;使用滑鼠拉一個矩形框結束位置
                                        axlClearDynamics()
                                        axlDBTransactionMark(frmCVN->xTransMark)
                                        frmCVN->xMarkCount = add1(frmCVN->xMarkCount)
                                        axlAddSelectBox(list(lTempXY rEventID->xy))
                                        frmCVN->lSelVias = axlGetSelSet()
                                        unless(frmCVN->lSelVias
                                                ;恢復一次,因為沒有選到認一物件
                                                fnCVNPopupUndoTimes(frmCVN)
                                        )
                                        when(axlFormGetField(frmCVN "enable") == "1" ;直接取option上的netname
                                                tNetName = axlFormGetField(frmCVN "netname")
                                                unless(tNetName == ""
                                                        when(fnCVNChange(frmCVN->lSelVias tNetName)
                                                                frmCVN->lSelVias = nil
                                                        )
                                                )
                                        )
                                )
                                (DONE ;滑鼠按下右鍵,選擇done
                                        bDoFlag = nil
                                )
                                (CANCEL ;滑鼠按下右鍵,選擇cancel
                                        bDoFlag = nil
                                )
                        )
                        fnCVNPopupCheck(frmCVN)
                )
                axlEventSetStartPopup()
        )
)
