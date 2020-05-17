axlCmdRegister("c2s" 'LCB_cline_to_shape ?cmdType "interactive"
 ?doneCmd 'LCB_Done ?cancelCmd 'LCB_Cancel)
;axlSetFunckey("c2s" "c2sXXX")
procedure(LCB_cline_to_shape()
let( ()
 axlSetFindFilter(?enabled list("noall" "clines" "lines" ) 
                  ?onButtons list("noall" "clines" "lines"))
 LCBpopup = axlUIPopupDefine( nil (list
    (list "Undo" 'LCB_unDo)
    (list "Done" 'LCB_Done)
    (list "Cancel" 'LCB_Cancel)
     ))
 axlUIPopupSet(LCBpopup)

 LCB_mark = axlDBTransactionStart()
 notdone = t
 while(notdone
  lclines = axlGetSelSet(axlSelect(?prompt "Select Clines to convert to a shape."))
  if(lclines then
    foreach(clinedbid lclines
      ;layer = "etch/bottom"
      layer = car(axlGetSelSet())->layer
       polydbid = axlPolyFromDB(clinedbid ?endCapType "ROUND")
       if(polydbid then
        ;axlDeleteObject(clinedbid)
        if(! axlDBCreateShape(car(polydbid) t layer)  then
          axlUIWPrint(nil "** Error. Failed to create Shape from Cline. **")
        ); endif
	if(cadr(polydbid) then
            axlDBCreateShape(cadr(polydbid) t layer)  )
       else
        axlUIWPrint(nil "** Error. Failed to create Polydbid from Cline. **")
       ); endif
    ); end foreach cline
  ); endif
 ); end while
 axlDBTransactionCommit(LCB_mark)

)); let and procedure

procedure(LCB_unDo()
let( ()
  if(! axlDBTransactionOops(LCB_mark) then
    axlUIWPrint(nil "-- Nothing Left To Undo. --")
  else
    axlUIWPrint(nil "-- Replacing Clines. --")
  ); endif
  axlClearSelSet()
)); end let procedure

procedure(LCB_Cancel()
let( ()
  axlUIWPrint(nil "** Cancelled Program. **")
  ;axlDBTransactionRollback(LCB_mark)
  notdone = nil
  axlClearSelSet()
  axlCancelEnterFun()

)); end let procedure

procedure(LCB_Done()
 let( ()
  axlUIWPrint(nil "- Done -")
  axlDBTransactionCommit(LCB_mark)
  notdone = nil
  axlCancelEnterFun()
   
)); end let and procedure
