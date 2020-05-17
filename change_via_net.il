;
;FileName:        fChangeViaNet.il
;Load:                load("fChangeViaNet.il")
;Command:        cvn
;ʹ�÷���:
;        1.����cvn
;        2.�x��vias (�ɷN��ʽ:ֱ�ӻ����c�x���ǿ��x)
;        3.�x���µ�net���Q (�ɷN��ʽ:ֱ�ӻ����c�x�µ�net���,��������Option�Ϲ��xEnable,�ڞg�[Net���Q)
;        ���ϲ��E�Ϳ��Ը�׃Via�ľW·���Q
;
;        4.�������I�����x��:
;                Done => �Y����ʽ,
;                Oops => �֏���һ�εĄ���,
;                Cancel => ȡ����ʽ.
;        5.Option�����x�:
;                "Enable" => ���þW·���Q,
;                "Popup�x��" => Ҫ��׃�ľW·���Q(����ǿհ�,���Ğ��ɻ����c�x����W·),
;                "..." => �g�[�x��W·���Q.
;
;��ʽ����ɫ:
;        1.�ɷN�x��:ֱ���c�x��������ľW·���x��Option�ϵľW·���Q,
;        2.�������IOops�֏���һ�ι���,�]���κ��¼����Ի֏͕r,���x헾�׃�ɻ�ɫ�������x.
;        3.Դ���a����,׌�����˶����������Լ��ķ�ʽ������������,
;                ����������I.
;                ���������I�x�μ���������.
;                �����Լ��ك�����ʽ���a,�Լӿ��ʽ�����ٶ�.
;                ���ǌ�Ӣ��ӍϢ��������ӍϢ.
;                ������������,�Լ�����.
axlCmdRegister("cvn" 'fnChangeViaNet ?cmdType "interactive" ?doneCmd 'fnCVNPopupDone ?cancelCmd 'fnCVNPopupCancel)
procedure(fnChangeViaNet() ;����ʽ
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
                axlDeleteObject(lSelObjs) ;�h���f��Via
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
        ;��Q����Oops��Popup׃�ɻ�ɫ��
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
        ;���xPopup
        frmCVN->rPopupOrign = axlUIPopupDefine(nil
                list(list("Done" 'fnCVNPopupDone)
                        list("Oops" 'fnCVNPopupOops)
                        list("Cancel" 'fnCVNPopupCancel)
                )
        )
        frmCVN->rPopupGray = axlUIPopupDefine(nil
                list(list("Done" 'fnCVNPopupDone)
                        ;list("Oops" 'fnCVNPopupOops)        ;�]���κ��x��r��׃�ɻ�ɫ
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
        
        frmCVN->lSelVias = nil        ;������x���Vias���
        frmCVN->lNetName = nil        ;Option�ϵ�Popup��net���Q�x�
        
        ;�O���������I�x�����P׃��
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
                                (PICK ;���������Iһ��
                                        axlDBTransactionMark(frmCVN->xTransMark)
                                        frmCVN->xMarkCount = add1(frmCVN->xMarkCount)
                                        if(frmCVN->lSelVias then
                                                axlClearSelSet()
                                                if(axlAddSelectPoint(rEventID->xy) then
                                                        tNetName = car(axlGetSelSet())->net->name
                                                        fnCVNPopupUndoTimes(frmCVN) ;�֏�һ��
                                                        when(fnCVNChange(frmCVN->lSelVias tNetName)
                                                                frmCVN->lSelVias = nil
                                                        )
                                                else
                                                        ;�֏�һ��,���]���x���Jһ���
                                                        fnCVNPopupUndoTimes(frmCVN)
                                                        axlHighlightObject(frmCVN->lSelVias)
                                                )
                                        else
                                                axlAddSelectPoint(rEventID->xy)
                                                frmCVN->lSelVias = axlGetSelSet()
                                                unless(frmCVN->lSelVias
                                                        ;�֏�һ��,���]���x���Jһ���
                                                        fnCVNPopupUndoTimes(frmCVN)
                                                )
                                                when(axlFormGetField(frmCVN "enable") == "1" ;ֱ��ȡoption�ϵ�netname
                                                        tNetName = axlFormGetField(frmCVN "netname")
                                                        unless(tNetName == ""
                                                                when(fnCVNChange(frmCVN->lSelVias tNetName)
                                                                        frmCVN->lSelVias = nil
                                                                )
                                                        )
                                                )
                                                
                                        )
                                )
                                (STARTDRAG ;ʹ�û�����һ�����ο��_ʼλ��
                                        lTempXY = rEventID->xy
                                        axlAddSimpleRbandDynamics(lTempXY "box" ?origin lTempXY ?var_point (0:0))
                                )
                                (STOPDRAG ;ʹ�û�����һ�����ο�Y��λ��
                                        axlClearDynamics()
                                        axlDBTransactionMark(frmCVN->xTransMark)
                                        frmCVN->xMarkCount = add1(frmCVN->xMarkCount)
                                        axlAddSelectBox(list(lTempXY rEventID->xy))
                                        frmCVN->lSelVias = axlGetSelSet()
                                        unless(frmCVN->lSelVias
                                                ;�֏�һ��,���]���x���Jһ���
                                                fnCVNPopupUndoTimes(frmCVN)
                                        )
                                        when(axlFormGetField(frmCVN "enable") == "1" ;ֱ��ȡoption�ϵ�netname
                                                tNetName = axlFormGetField(frmCVN "netname")
                                                unless(tNetName == ""
                                                        when(fnCVNChange(frmCVN->lSelVias tNetName)
                                                                frmCVN->lSelVias = nil
                                                        )
                                                )
                                        )
                                )
                                (DONE ;���������I,�x��done
                                        bDoFlag = nil
                                )
                                (CANCEL ;���������I,�x��cancel
                                        bDoFlag = nil
                                )
                        )
                        fnCVNPopupCheck(frmCVN)
                )
                axlEventSetStartPopup()
        )
)