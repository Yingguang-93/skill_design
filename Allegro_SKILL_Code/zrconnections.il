/*
################################################################################
#                                                                              #
#                      Command: zrconnections                                  #
#                   Skill File: zrconnections.il                               #
#                  How To Load: APD> (load("zrconnections.il"))                #
#               How To Execute: APD> zrconnections       OR                    #
#                                    zrconnections help  OR                    #
#                                    zrconnections h     OR                    #
#                                    zrconnections nomini                      #
#                       Author: Larry Bowman, Cadence Design Systems           #
#                        Email: bowman@cadence.com                             #
#                    Telephone: 512-349-1109                                   #
#                Creation Date: 10/31/2001                                     #
#                                                                              #
################################################################################

################################################################################
#  DISCLAIMER:                                                                 #
#       The user of this command assumes all responsibility and does not       #
#       hold Cadence Design Systems nor the author of this code for any        #
#       unwarranted results or problems due to the use of this code.           #
#                                                                              #
#       This is non-supported code and the user may modify it as needed.       #
#                                                                              #
################################################################################
*/


;###########################################################
;#                                                         #
;#             Main Program lcb_zrconnections              #
;#                                                         #
;###########################################################
axlCmdRegister("zrconnections" 'lcb_zrconnections ?cmdType "interactive"
 ?doneCmd '_lcb_zrCancel ?cancelCmd '_lcb_zrCancel)

(defun lcb_zrconnections (@optional (args "") )


 lnominargs = list("nomini" "-nomini" "no" "-no" "nomin" "-nomin")
 lhelpargs = list("help" "h" "-h" "-help")
;; Check for command line arguments
if(args != "" then
  case(lowerCase(args)
   ( ("help" "h" "-h" "-help")
    axlUIWPrint(nil " - Displaying Info file. -")
    ;;; ### Insert function for Info file here.
    zrconnections_info_createInfo()
    goodarg = nil 
   ); end help
   ( ("nomini" "-nomini" "no" "-no" "nomin" "-nomin")
      nomini = t
      goodarg = t
   ); end nomini
   (t
    axlUIWPrint(nil "*** Error, you entered ->%s<-" args)
    ;axlUIWPrint(nil "*** Only arguments accepted is \"help\" or \"h\" or \"nomini\".")
    axlUIWPrint(nil "     Only arguments accepted are:")
    axlUIWPrint(nil "     %L %L" lhelpargs lnominargs)
    goodarg = nil
   ); incorrect argument
  ); end case
else
 goodarg = t
 nomini = nil
); endif

; Initialize Variables
_lcb_zrinit()

if(notdone && goodarg then

;; Set the Control Panel to the Options tab
axlControlRaise('options)

_createForm_zrconnections(lpopstack lpopcomp)

if(nomini then
  zrconnections_Form=axlFormCreate( (gensym) zrconnections_form_file nil 'zrconnections_Form_Action t)
  axlFormDisplay(zrconnections_Form)
else
  zrconnections_Form=axlMiniStatusLoad( (gensym) zrconnections_form_file 'zrconnections_Form_Action t)
); endif
axlFormBuildPopup(zrconnections_Form "refdes" lcomponentpopup)
axlFormBuildPopup(zrconnections_Form "tolayer" lstackpopup) 



if(isFile(zrconnections_form_file) then
 deleteFile(zrconnections_form_file)
else
 axlUIWPrint(nil "*** Warning, cannot find %s to delete\n" zrconnections_form_file)
 axlUIWPrint(nil "*** Check SKILL path (getSkillPath()) and make sure . is first\n")
);endif


; Initialize the Form Entries
_lcb_setup_zrconnectionsForm()


; Now loop to allow user to select from layout or form.
; Will exit this loop when the user selects "Close" button
; on form, RMB-Done, or RMB-Cancel.

 while(notdone
   _lcb_zrgetpicks()
 ); end while
); endif for notdone AND goodarg

if(boundp('zroutport) then
 close(zroutport)
); endif

); end defun
;###########################################################
;#                                                         #
;#                End of Main lcb_zrconnections            #
;#                                                         #
;###########################################################

;###########################################################
;#                                                         #
;#                zrconnections_Form_Action                #
;#                                                         #
;###########################################################
(defun zrconnections_Form_Action (zrconnections_Form)
 (case zrconnections_Form->curField
  ("av_nets"
     _lcb_zrSelectNetFromFormAndLayout(zrconnections_Form->curValue)
  )
  ("allavnets"
    axlUIWPrint(nil " - Selecting all remaining nets")
    _lcb_zrSelectNetFromFormAndLayout("*")
  )
  ("refdes"
     prevlfnets = copy(final_lnetnames)
     prevrefdes = defrefdes
     lprevrefdes = list(list(prevrefdes prevlfnets))
     defrefdes = zrconnections_Form->curValue 
    
     if(assoc(prevrefdes allrefdes) then
      if(length(nthelem(2 assoc(prevrefdes allrefdes))) != length(prevlfnets) then
       rplacd(assoc(prevrefdes allrefdes) list(prevlfnets))
      ); endif
      else
        allrefdes = append(allrefdes lprevrefdes)
      ); endif

     
     if(assoc(defrefdes allrefdes) then
      ;axlUIWPrint(nil " - Found defrefdes, %s, in allrefdes" defrefdes)
       final_lnetnames = nthelem(2 assoc(defrefdes allrefdes))
       ;; load the form with prior nets
       axlFormListDeleteAll(zrconnections_Form "av_nets")
       axlFormSetField(zrconnections_Form "av_nets" final_lnetnames)
       axlFormSetField(zrconnections_Form "av_nets" nil)
     else
      ;; Go get new list of nets
      
      foreach(one lcomps
        if(one->name == defrefdes then
          axlFormListDeleteAll(zrconnections_Form "av_nets")
          _lcb_zrFindNets(one)
        ) ;endif
      ); end foreach
      
     ); endif
         
  )
  ("tolayer"
     deftargetlayer = zrconnections_Form->curValue
  )
  ("minvia"
     defminvia = zrconnections_Form->curValue
  )
  ("maxvia"
     defmaxvia = zrconnections_Form->curValue
  )
  ("xgrid"
     defxgrid = zrconnections_Form->curValue
  )
  ("ygrid"
     defygrid = zrconnections_Form->curValue
  )
  ("xoffset"
     defxoffset = zrconnections_Form->curValue
  )
  ("yoffset"
     defyoffset = zrconnections_Form->curValue
  )
  ("viatopadspace"
     defvia2pad = zrconnections_Form->curValue
  )
  ("zroutputfile"
     prevzrconnfile = zrconnectionsfile
     zrconnectionsfile = zrconnections_Form->curValue
     axlUIWClose(zrviewfile)
     _lcb_zrOpenFile(zrconnectionsfile)
  )
  ("clearfile"
    axlUIWPrint(nil " - Clearing Connections file, %s" zrconnectionsfile)
    axlUIWClose(zrviewfile)
    close(zroutport)
    if(isFile(zrconnectionsfile) then
      deleteFile(zrconnectionsfile)
      _lcb_zrOpenFile(zrconnectionsfile)
    ); endif
   
   ;; Reload the form with all nets for the current refdes selected.
      foreach(one lcomps
        if(one->name == defrefdes then
          axlFormListDeleteAll(zrconnections_Form "av_nets")
          _lcb_zrFindNets(one)
        ) ;endif
      ); end foreach
   ;; Reset the Selected Net Name field
   axlFormSetField(zrconnections_Form "selectednet" "")
  )

  ("run" 
        drain(zroutport)     
        axlUIWClose(zrviewfile)
       
        ;axlUIWPrint(nil " - Run Button")
        ;; set up batch command
        ;; zrouter <connectionsfile> <via-pad> <xgrid> <ygrid> <xoffset> <yoffset>
        sprintf(zrbatchcommand "%s %s %L %L %L %L %L %%s" "zrouter" zrconnectionsfile defvia2pad defxgrid defygrid defxoffset defyoffset)
        if(fileLength(zrconnectionsfile) > 0 then
          ;; Now run the zrouter batch command
          axlRunBatchDBProgram("zrouter" zrbatchcommand ?logfile "zrouter" ?reloadDB t)
          axlSetFindFilter(?enabled list("noall" "pins") ?onButtons list("pins"))
        else
          axlUIWPrint(nil "*** Error, %s file is empty." zrconnectionsfile)
        ); endif
  )
  ("info"
      zrconnections_info_createInfo()
      ;axlUIWPrint(nil " - Info Button")
  )
  ("lhelp" axlUIWPrint(nil " - Help Button")
           axlShell("help zrouter")
  )
  ("fbrowse"
    zroutput = axlDMFileBrowse("ALLEGRO_TEXT", nil)
    if(zroutput != nil then
      axlUIWClose(zrviewfile)
      prevzrconnfile = zrconnectionsfile
      _lcb_zrOpenFile(zroutput)
    ); endif
  )
  ("vzrlog" 
    if(isFile(zlog) then
     axlUIEditFile(zlog "zrouter.log" nil)
    else
     axlUIWPrint(nil "*** Warning, No %s file to view." zlog)
    ); endif
  )
  ("close"
     _lcb_zrCancel()
  ); end cancel
 ); end case
);end defun
;###########################################################
;#                                                         #
;#            End of zrconnections_Form_Action             #
;#                                                         #
;###########################################################

;###########################################################
;#                                                         #
;#            _lcb_zrSelectNetFromFormAndLayout            #
;#                                                         #
;###########################################################
defun( _lcb_zrSelectNetFromFormAndLayout (netpick)

;; netpick is a single net name.

if(netpick != "*" then
 if(member(netpick final_lnetnames) then
  selnet = netpick
  

  ;; if selnet has a space in the name then the sprintf command will
  ;; have extra fields.
  lselnet = parseString(selnet)
  if(length(lselnet) > 1 then
   axlUIWPrint(nil "*** Error, Illegal net name. Net %s" selnet)
   axlUIWPrint(nil "     has %n Space(s) in the name." length(lselnet) - 1)
   axlUIWPrint(nil "     Ignoring net name, %s ." selnet)
  else
  
  axlFormSetField(zrconnections_Form "selectednet" selnet)
  ;; ## Assume all fields will be set for:
  ;; Refdes ToLayer MinVia MaxVia
  sprintf(zrconnline "%s %s %s %s %s" defrefdes selnet deftargetlayer defminvia defmaxvia)
  
  ;; Set info into Form for Connections File Name
  axlFormSetField(zrconnections_Form "assigned_nets" zrconnline)

  ;; Write data to Connections File
  _lcb_zrWriteToFile(zrconnline)

  ;; Remove selection from Nets in the Form.
  axlFormListDeleteItem(zrconnections_Form "av_nets" zrconnections_Form->curValueInt)

  ;; Remove selection from original list of net names
  final_lnetnames = remd(selnet final_lnetnames)


  ;; highlight all pins with the selected net name.
  foreach(one lcomps
   if(one->name == defrefdes then
    lcompindbids = one->pins
   ); endif
  ); endforeach
  foreach(cpin lcompindbids
    if(cpin->net->name == selnet then
      axlUIWPrint(nil " - Highlighting %s.%s with net %s." defrefdes cpin->number selnet)
      axlHighlightObject(cpin)
      lhighpinsdbids = cons(cpin lhighpinsdbids)     
    ); endif
  ); endforeach
 ); endif for lselnet
 else

  if(netpick != "" then
   axlUIWPrint(nil " - Net %s has already been selected. Only %n net name(s) left." netpick length(final_lnetnames))
  else
   axlUIWPrint(nil " - This is a DUMMY net. Ignoring Selection.")
  ); endif
 ); endif of member

else
 ; Wildcard
  selnet = netpick
  axlFormSetField(zrconnections_Form "selectednet" selnet)

  ;; ## Assume all fields will be set for:
  ;; Refdes ToLayer MinVia MaxVia
  sprintf(zrconnline "%s %s %s %s %s" defrefdes selnet deftargetlayer defminvia defmaxvia)
 
  ;; Set info into Form for Connections File Name
  axlFormSetField(zrconnections_Form "assigned_nets" zrconnline)

  ;; Write data to Connections File
  _lcb_zrWriteToFile(zrconnline)

  ;; Remove selection from Nets in the Form.
  axlFormListDeleteAll(zrconnections_Form "av_nets")

  
  ;; highlight all pins with the selected net name.
  compdbid = nthelem(2 assoc(defrefdes lcompdbids))
  lcompindbids = compdbid->pins
  foreach(cpin lcompindbids
   if(cpin->net->name != "" then
    axlHighlightObject(cpin)
   ); endif
  ); end foreach


  ;; Remove all net names from the list of net names
  if(final_lnetnames then
    final_lnetnames = list()
  ) ;endif
 );endif
 

); end defun 
;###########################################################
;#                                                         #
;#            End of _lcb_zrSelectNetFromFormAndLayout     #
;#                                                         #
;###########################################################

;###########################################################
;#                                                         #
;#            _lcb_zrWriteToFile                           #
;#                                                         #
;###########################################################
defun( _lcb_zrWriteToFile (dataline)
  h1 = "# RefDes"
  h2 = "NetName"
  h3 = "ToLayer"
  h4 = "MinVia"
  h5 = "MaxVia"
  hyphen = "-"
  hyphen1 = "# -"

  lheader = list(h1 h2 h3 h4 h5)

  ldata = parseString(dataline)
  d1 = nthelem(1 ldata)
  d2 = nthelem(2 ldata)
  d3 = nthelem(3 ldata)
  d4 = nthelem(4 ldata)
  d5 = nthelem(5 ldata)

 
for(y 1 length(ldata)
  if(strlen(nthelem(y ldata)) >= strlen(nthelem(y lheader)) then
    long = strlen(nthelem(y ldata))    
  else
    long = strlen(nthelem(y lheader))
  ); endif
  
  if(y == 1 then
    for(i 3 long
     hyphen1 = strcat(hyphen1 "-")
    ); endfor
    ;hyphen1 = _lcb_zrgetformat(hyphen1 long)
  else
    for(i 1 long
      hyphen = strcat(hyphen "-")
    ); endfor
  ); endif
  long = long + 4
   case(y
   (1
       h1 = _lcb_zrgetformat(h1 long)
       d1 = _lcb_zrgetformat(d1 long)
       hyphen1 = _lcb_zrgetformat(hyphen1 long)      
   )
   (2
       h2 = _lcb_zrgetformat(h2 long)
       d2 = _lcb_zrgetformat(d2 long)
       hyphen2 = _lcb_zrgetformat(hyphen long)
    )
   (3
        h3 = _lcb_zrgetformat(h3 long)
        d3 = _lcb_zrgetformat(d3 long)
        hyphen3 = _lcb_zrgetformat(hyphen long)
   )
   (4
        h4 = _lcb_zrgetformat(h4 long)
        d4 = _lcb_zrgetformat(d4 long)
        hyphen4 = _lcb_zrgetformat(hyphen long)
    )
   (5
        h5 = _lcb_zrgetformat(h5 long)
        d5 = _lcb_zrgetformat(d5 long)
        hyphen5 = _lcb_zrgetformat(hyphen long)
    ) 
  ); endcase
  hyphen = "-"

); end for


  ; Only file writable should be zroutport
  sprintf(header "%s%s%s%s%s" h1 h2 h3 h4 h5)
  sprintf(data "%s%s%s%s%s" d1 d2 d3 d4 d5)
  sprintf(h "%s%s%s%s%s" hyphen1 hyphen2 hyphen3 hyphen4 hyphen5)
  fprintf(zroutport "%s\n" header)
  fprintf(zroutport "%s\n" h)
  fprintf(zroutport "%s\n\n" data)
  
  drain(zroutport)
  axlUIViewFileReuse(zrviewfile zrconnectionsfile zrconnectionsfile nil)


); end defun
;###########################################################
;#                                                         #
;#            End of _lcb_zrWriteToFile                    #
;#                                                         #
;###########################################################


;###########################################################
;#                                                         #
;#            _lcb_zrOpenFile                              #
;#                                                         #
;###########################################################
defun( _lcb_zrOpenFile (zrout)
  ;; ## Check to see if output file already open.
  ;; If it is then close it to make for way for new file.


  ;; Dehighlight the pins if the variable exists and if dbid is not out of scope.
  if(boundp('lcompindbids) && nthelem(1 lcompindbids)->objType then
    axlDehighlightObject(lcompindbids)
  ); endif
      

  if(fileused == "" then
   fileused = zrout
  else
   axlUIWPrint(nil " - Closing %L" zroutport)
   close(zroutport)
  ); endif

     sprintf(file_error "*** Error, cannot open or create file, ->%s<-." zrout)
     ;file_error = "*** Error, cannot open or create file."
     f1err = "    1.) Check spelling (maybe non-existent folder)."
     f2err = "2.) Check Permissions."
     sprintf(f3err "%s And/Or %s" f1err f2err)
  
  if(isFile(zrout) then
   axlUIWPrint(nil " - Opening file \"%s\" for appending." zrout)
   ; open it and get ready to append to the bottom of the file.
   ; We also need to read it first and merge the data in the
   ; file with the database.
    axlUIWPrint(nil " - Opening file \"%s\" for appending." zrout)
   zroutport = outfile(zrout "a")
   if(zroutport == nil then
     axlUIWPrint(nil file_error)
     ;axlUIWPrint(nil f1err)
     axlUIWPrint(nil f3err)
     if(boundp('prevzrconnfile) then
        zrout = prevzrconnfile
        ;axlFormSetField(zrconnections_Form "zroutputfile" zrout)
        zroutport = outfile(zrout "a")
        axlUIWPrint(nil " - ReOpening file \"%s\" for appending." zrout)
     ); endif     
   ); endif
  
  else
   ;; This will be a new file.
   axlUIWPrint(nil " - Opening file \"%s\" for writing." zrout)
   zroutport = outfile(zrout "a")
   if(zroutport == nil then
     axlUIWPrint(nil file_error)
     ;axlUIWPrint(nil f1err)
     axlUIWPrint(nil f3err)
     if(boundp('prevzrconnfile) then
        zrout = prevzrconnfile
        ;axlFormSetField(zrconnections_Form "zroutputfile" zrout)
        zroutport = outfile(zrout "a")
        axlUIWPrint(nil " - ReOpening file \"%s\" for appending." zrout)
     ); endif
   ); endif
  ); endif
  zrviewfile = axlUIViewFileCreate(zrout zrout nil list(62 5) '(se outer))
  zrconnectionsfile = zrout
  formfilename = nthelem(3 axlDMFileParts(zrout))
  axlFormSetField(zrconnections_Form "zroutputfile" formfilename)
  ;formfilename = zrout
  axlCancelEnterFun() ;; Allows the RMB Popup to have the Temp Group selection.
   _lcb_zrPopUp()

   ;; Reload the form with all nets for the current refdes selected.
      foreach(one lcomps
        if(one->name == defrefdes then
          axlFormListDeleteAll(zrconnections_Form "av_nets")
          _lcb_zrFindNets(one)
        ) ;endif
      ); end foreach
   ;; Reset the Selected Net Name field
   axlFormSetField(zrconnections_Form "selectednet" "")

  
); end defun
;###########################################################
;#                                                         #
;#            End of _lcb_zrOpenFile                       #
;#                                                         #
;###########################################################

;###########################################################
;#                                                         #
;#                 _lcb_zrCancel                           #
;#                                                         #
;###########################################################
defun( _lcb_zrCancel ()

  ;; Dehighlight the pins if the variable exists and if dbid is not out of scope.
  if(boundp('lcompindbids) && nthelem(1 lcompindbids)->objType then
    axlDehighlightObject(lcompindbids)
  ); endif

 if(nomini then
   axlFormClose(zrconnections_Form)
 ); endif
 notdone = nil
 axlCancelEnterFun()
 axlUIWClose(zrviewfile)
); end defun
;###########################################################
;#                                                         #
;#                 End of _lcb_zrCancel                    #
;#                                                         #
;###########################################################


;###########################################################
;#                                                         #
;#                 _lcb_zrPopUp                            #
;#                                                         #
;###########################################################
defun( _lcb_zrPopUp ()
      sprintf(pm1 "Exit and Save ->%s<-" formfilename)
   popupzr = axlUIPopupDefine( nil (list
      (list pm1 '_lcb_zrCancel)
      (list "Cancel (same as above)" '_lcb_zrCancel)
      ))
   axlUIPopupSet(popupzr)
); end defun
;###########################################################
;#                                                         #
;#               End of _lcb_zrPopUp                       #
;#                                                         #
;###########################################################


;###########################################################
;#                                                         #
;#            _lcb_zrinit                                  #
;#                                                         #
;###########################################################
defun( _lcb_zrinit ()
 
  
  lhighpinsdbids = list()
  lzrpins = list()
  zlog = "zrouter.log"
  line = ""
  compline = ""
  lpopstack = list()
  lpopcomp = list()
  fileused = ""
  allrefdes = list()
  lstackpopup = list()
  lcomponentpopup = list()
  llayers = list()
  lrefdes = list()

  ;### Check for logic in database ###
  root = axlDBGetDesign()
  lcomps = root->components
  if(lcomps == nil then
    ;## No logical netlist in database ##
    axlUIWPrint(nil "*** Error, No Reference Designators. Exiting ***")
    notdone = nil
    axlCancelEnterFun()
  else
    notdone = t
  ); endif
  

  ; Get layers
  etchparam = axlGetParam("paramLayerGroup:ETCH")
  l_layers = etchparam->groupMembers

  ; Create line for stackup popup in the form.
  fbegin = "POPUP <stackup>"
  fend = "."
  slash = " \\"
  poplinelength = 20
  _zr_refinit = "U1"
  _zr_layerinit = "SURFACE"

  zrlayerline = strcat(fbegin "\"" _zr_layerinit "\"\"" _zr_layerinit "\".")
  lpopstack = list(zrlayerline)
  
  foreach(lname l_layers

 
   ;; Build a list of list for axlFormBuildPopup to change items in the form
   ;; for Refdes and ToLayer.  This is because axlMiniStatusLoad does not re-read
   ;; the form file unless APD is brought down and back up.
   lstackpopup = append(lstackpopup list(list(lname lname)))
   llayers = cons(lname llayers)

  ); end foreach

  

  ; Create line for components popup in form.
  cbegin = "POPUP <components>"
  zrrefline = strcat(cbegin "\"" _zr_refinit "\"\"" _zr_refinit "\".")
  lpopcomp = list(zrrefline)

  foreach(refdes lcomps
    
   ;; Build a list of list for axlFormBuildPopup to change items in the form
   ;; for Refdes and ToLayer.  This is because axlMiniStatusLoad does re-read
   ;; the form file unless APD is brought down and back up.
   lcomponentpopup = append(lcomponentpopup list(list(refdes->name refdes->name)))
   lrefdes = cons(refdes->name lrefdes)

  ); end foreach

  ;; Sort refdes list
  lcomponentpopup = sortcar(lcomponentpopup 'alphalessp)
   
 
); end defun
;###########################################################
;#                                                         #
;#            End of _lcb_zrinit                           #
;#                                                         #
;###########################################################

;###########################################################
;#                                                         #
;#            _lcb_setup_zrconnectionsForm                 #
;#                                                         #
;###########################################################
defun( _lcb_setup_zrconnectionsForm ()


  ;; Use pervious form settings if samedesign
  if(boundp('zr_dname) then
    if(zr_dname == axlGetDrawingName() then
      samedesign = t
    else
      samedesign = nil
      pzr_dname = zr_dname
      zr_dname = axlGetDrawingName()
      m1 = "If Reference Designators"
      m2 = "or Cross-Section is different"
      m3 = "between: "
      m4 = "and: "
      m5 = "then exit APD to update the form"
      m6 = "in the Options tab of the Control Panel."
      ;;;                               m1  m2    m3        m4          m5  m6
      sprintf(warn "*** Warning! ***\n\n%s\n%s\n\n%s\n  %s\n%s\n  %s\n\n%s\n%s" m1 m2 m3 pzr_dname m4 zr_dname m5 m6)

     ;;The Warning message below is no longer needed.  Commenting it out.
      ;axlUIConfirm(warn) 
    ); endif
  else
    samedesign = nil
    zr_dname = axlGetDrawingName()
  ); endif
  
 if(samedesign then   
  ;; Use last sessions variables if they exist.
  if(boundp('deftargetlayer) == nil || member(deftargetlayer llayers) == nil then deftargetlayer = axlConductorTopLayer())
  if(boundp('zrconnectionsfile) == nil then zrconnectionsfile = "zrconnections.txt"
   formfilename = zrconnectionsfile
   else formfilename = nthelem(3 axlDMFileParts(zrconnectionsfile)))
  if(boundp('defrefdes) == nil || member(defrefdes lrefdes) == nil then defrefdes = nil)
  if(boundp('defminvia) == nil then defminvia = "1")
  if(boundp('defmaxvia) == nil then defmaxvia = "1")
  if(boundp('defxoffset) == nil then defxoffset = 0)
  if(boundp('defyoffset) == nil then defyoffset = 0)
  if(boundp('defvia2pad) == nil then defvia2pad = 0)
  if(boundp('defxgrid) == nil then defxgrid = 10)
  if(boundp('defygrid) == nil then defygrid = 10)
 else
  ;Get surface layer name
  deftargetlayer = axlConductorTopLayer()
  defrefdes = nil
  defminvia = "1"
  defmaxvia = "1"
  defxoffset = 0
  defyoffset = 0
  defvia2pad = 0
  defxgrid = 10
  defygrid = 10
  zrconnectionsfile = "zrconnections.txt"
  formfilename = zrconnectionsfile

); endif samedesign

  lcompdbids = list()
  


 if(defrefdes == nil then
  ;Get default refdes.  The one with the CLASS=IO property.
  foreach(comp lcomps
    if(comp->class == "IO" then
      pkg = comp
      defrefdes = pkg->name
    ); endif
   lcompdbids = append(lcompdbids list(list(comp->name comp)))
  ); end foreach
  if(defrefdes == nil then
    defrefdes = nthelem(1 lcomps)->name
    pkg = nthelem(1 lcomps)
    axlUIWPrint(nil "*** Warning, No Component with CLASS=IO property.")
  ); endif 

 else
  pkg = nil
  foreach(comp lcomps
    if(comp->name == defrefdes then
      pkg = comp
    ); endif
   lcompdbids = append(lcompdbids list(list(comp->name comp)))
  ); end foreach
  if(pkg then
   ; okay
  else
   ; Same design name could not find the last used defrefdes.
   ; Issue warning and pick one
   axlUIWPrint(nil "*** Warning, same design missing %s. Using first in list." defrefdes)
   defrefdes = nthelem(1 lcomps)->name
   pkg = nthelem(1 lcomps)
  ); endif
 ); end defrefdes  



 axlFormSetField(zrconnections_Form "refdes" defrefdes)
 axlFormSetField(zrconnections_Form "tolayer" deftargetlayer)
 axlFormSetField(zrconnections_Form "minvia" defminvia)
 axlFormSetField(zrconnections_Form "maxvia" defmaxvia)
 axlFormSetField(zrconnections_Form "xoffset" defxoffset)
 axlFormSetField(zrconnections_Form "yoffset" defyoffset)
 axlFormSetField(zrconnections_Form "viatopadspace" defvia2pad)
 axlFormSetField(zrconnections_Form "zroutputfile" formfilename)
 axlFormSetField(zrconnections_Form "xgrid" defxgrid)
 axlFormSetField(zrconnections_Form "ygrid" defygrid)

 axlFormColorize(zrconnections_Form "zroutputfile" 'text 'red)
 axlFormColorize(zrconnections_Form "zroutputfile" 'background 'yellow)
 axlFormColorize(zrconnections_Form "selectednet" 'text 'red)
 axlFormColorize(zrconnections_Form "selectednet" 'background 'button)


 ;## Open Output file for writing or appending.
 _lcb_zrOpenFile(zrconnectionsfile)

); end defun
;###########################################################
;#                                                         #
;#            End of _lcb_setup_zrconnectionsForm          #
;#                                                         #
;###########################################################

;###########################################################
;#                                                         #
;#            _lcb_zrFindNets                              #
;#                                                         #
;###########################################################
defun( _lcb_zrFindNets (part)


  /* Get a list of all net names on the component */
prevname = ""
final_lnetnames = list()
lnetnames = list()
lpins = part->pins
lnets = list()
foreach(pindbid lpins
  lnetnames = cons(pindbid->net->name lnetnames)
  if(pindbid->net->name != "" then
    lnets = cons(pindbid->net lnets)
    ;lnetspins = append(lnetspins list(list(pindbid->net->name list(pindbid))))  
    ;lpindbids = cons(pindbid lpindbids)
  ); endif
); end foreach
lnetnames = sort(lnetnames 'alphalessp)
foreach(name lnetnames
  if(name != prevname then
    final_lnetnames = cons(name final_lnetnames)
    prevname = name
  ); endif
); end foreach

; reverse the sort to list a-z for net names
final_lnetnames = reverse(final_lnetnames)

; Display final_lnetnames in form.
axlFormSetField(zrconnections_Form "av_nets" final_lnetnames); This sets the names in the form.
axlFormSetField(zrconnections_Form "av_nets" nil) ; This really displays the list in the form.

); end defun
;###########################################################
;#                                                         #
;#            End of _lcb_zrFindNets                       #
;#                                                         #
;###########################################################


;###########################################################
;#                                                         #
;#            _lcb_zrgetpicks                              #
;#                                                         #
;###########################################################
defun( _lcb_zrgetpicks ()

  axlSetFindFilter(?enabled list("noall" "pins") ?onButtons list("pins"))
  _lcb_zrPopUp()

   axlSelect()
   lzrpins = axlGetSelSet()
  

  ; Find only pins from refdes in form()
  ; Compare existing selected nets to available items.()
  ; Add only new pin's net names.()
  ; Add selected items to form()
  ; Add
  if(final_lnetnames then
    foreach(pin lzrpins
      if(pin->component->name != defrefdes then
       axlUIWPrint(nil "*** Warning, selected pin on %s instead of %s. Ignoring pin." pin->component->name defrefdes)
      else
        axlClearSelSet() ;; This will allow the pin to remain highlighted from next line.
        _lcb_zrSelectNetFromFormAndLayout(pin->net->name)
        ;; Remove selection from Nets in the Form.
        axlFormListDeleteAll(zrconnections_Form "av_nets")

        ;; Replace with new list
        axlFormSetField(zrconnections_Form "av_nets" final_lnetnames)
        axlFormSetField(zrconnections_Form "av_nets" nil)

      ); endif
    
    ); endforeach
  else
    axlUIWPrint(nil " - No more selections available on %s." defrefdes)   
  );endif 
  
); end defun
;###########################################################
;#                                                         #
;#            End of _lcb_zrgetpicks                       #
;#                                                         #
;###########################################################

;###########################################################
;#                                                         #
;#                  _lcb_zrgetformat                       #
;#                                                         #
;###########################################################
defun( _lcb_zrgetformat (msg longest)
 let( ()
   leadspaces = ""
   trailspaces = ""
   space = " "
   msglength = strlen(msg)
    ;leadspacinglength = (longest - 2 - msglength) / 2
    ;trailspacinglength = longest - 2 - leadspacinglength - msglength
    trailspacinglength = longest - 2  - msglength
    ;axlUIWPrint(nil " - trailspacinglength is: ->%L<-" trailspacinglength)
    ;for(i 1 leadspacinglength
    ;  leadspaces = strcat(space leadspaces)
    ;); endfor
    for(i 1 trailspacinglength
      trailspaces = strcat(space trailspaces)
    ); endfor
    ;sprintf(msgname "#%s%s%s#\n" leadspaces msg trailspaces)
    sprintf(msgname "%s%s" msg trailspaces)

 ) ;end let
); end defun
;###########################################################
;#                                                         #
;#                  End of _lcb_zrgetformat                #
;#                                                         #
;###########################################################



;###########################################################
;#                                                         #
;#                _createForm_zrconnections                #
;#                                                         #
;###########################################################
(defun _createForm_zrconnections (lstack lrefdes)
 let( ()
  zrconnections_form_file = "./zrconnections.form"
  zrconnections_form = outfile(zrconnections_form_file "w")
  fprintf(zrconnections_form "FILE_TYPE=FORM_DEFN VERSION=2\n")
  fprintf(zrconnections_form "FORM \n")
  fprintf(zrconnections_form "FIXED\n")
  fprintf(zrconnections_form "PORT 33 17\n")
  fprintf(zrconnections_form "HEADER \"name\"\n")
  fprintf(zrconnections_form "\n")
  foreach(one lstack
    fprintf(zrconnections_form "%s\n" one)
  ); end foreach
  foreach(one lrefdes
   fprintf(zrconnections_form "%s\n" one)
  ) ;end foreach
  fprintf(zrconnections_form "\n")
  fprintf(zrconnections_form "TILE\n")
  fprintf(zrconnections_form "TEXT \"Refdes\"\n")
  fprintf(zrconnections_form "TLOC 0 2\n")
  fprintf(zrconnections_form "TGROUP \"ZR_Connections_File\"\n")
  fprintf(zrconnections_form "ENDTEXT\n")
  fprintf(zrconnections_form "\n")
  fprintf(zrconnections_form "TEXT \"To Layer\"\n")
  fprintf(zrconnections_form "TLOC 6 2\n")
  fprintf(zrconnections_form "TGROUP \"ZR_Connections_File\"\n")
  fprintf(zrconnections_form "ENDTEXT\n")
  fprintf(zrconnections_form "\n")
  fprintf(zrconnections_form "TEXT \"MinVia\"\n")
  fprintf(zrconnections_form "TLOC 16 2\n")
  fprintf(zrconnections_form "TGROUP \"ZR_Connections_File\"\n")
  fprintf(zrconnections_form "ENDTEXT\n")
  fprintf(zrconnections_form "\n")
  fprintf(zrconnections_form "TEXT \"MaxVia\"\n")
  fprintf(zrconnections_form "TLOC 23 2\n")
  fprintf(zrconnections_form "TGROUP \"ZR_Connections_File\"\n")
  fprintf(zrconnections_form "ENDTEXT\n")
  fprintf(zrconnections_form "\n")
  fprintf(zrconnections_form "TEXT \"Selected Net Name:\"\n")
  fprintf(zrconnections_form "TLOC 1 6\n")
  fprintf(zrconnections_form "TGROUP \"ZR_Connections_File\"\n")
  fprintf(zrconnections_form "ENDTEXT\n")
  fprintf(zrconnections_form "\n")
  fprintf(zrconnections_form "TEXT\n")
  fprintf(zrconnections_form "TLOC 16 6\n")
  fprintf(zrconnections_form "INFO selectednet 30\n")
  fprintf(zrconnections_form "TGROUP \"ZR_Connections_File\"\n")
  fprintf(zrconnections_form "ENDTEXT\n")
  fprintf(zrconnections_form "\n")
  fprintf(zrconnections_form "\n")
  fprintf(zrconnections_form "TEXT \"X-Grid:\"\n")
  fprintf(zrconnections_form "TLOC 2 23\n")
  fprintf(zrconnections_form "TGROUP \"Run_ZRouter\"\n")
  fprintf(zrconnections_form "ENDTEXT\n")
  fprintf(zrconnections_form "\n")
  fprintf(zrconnections_form "TEXT \"Y-Grid:\"\n")
  fprintf(zrconnections_form "TLOC 2 25\n")
  fprintf(zrconnections_form "TGROUP \"Run_ZRouter\"\n")
  fprintf(zrconnections_form "ENDTEXT\n")
  fprintf(zrconnections_form "\n")
  fprintf(zrconnections_form "TEXT \"X-Offset:\"\n")
  fprintf(zrconnections_form "TLOC 2 27\n")
  fprintf(zrconnections_form "TGROUP \"Run_ZRouter\"\n")
  fprintf(zrconnections_form "ENDTEXT\n")
  fprintf(zrconnections_form "\n")
  fprintf(zrconnections_form "TEXT \"Y-Offset:\"\n")
  fprintf(zrconnections_form "TLOC 2 29\n")
  fprintf(zrconnections_form "TGROUP \"Run_ZRouter\"\n")
  fprintf(zrconnections_form "ENDTEXT\n")
  fprintf(zrconnections_form "\n")
  fprintf(zrconnections_form "TEXT \"Via-Pad:\"\n")
  fprintf(zrconnections_form "TLOC 2 31\n")
  fprintf(zrconnections_form "TGROUP \"Run_ZRouter\"\n")
  fprintf(zrconnections_form "ENDTEXT\n")
  fprintf(zrconnections_form "\n")
  fprintf(zrconnections_form "FIELD refdes\n")
  fprintf(zrconnections_form "FLOC 0 4\n")
  fprintf(zrconnections_form "FGROUP \"ZR_Connections_File\"\n")
  fprintf(zrconnections_form "ENUMSET 3\n")
  fprintf(zrconnections_form "POP \"components\"\n")
  fprintf(zrconnections_form "ENDFIELD\n")
  fprintf(zrconnections_form "\n")
  fprintf(zrconnections_form "FIELD tolayer\n")
  fprintf(zrconnections_form "FLOC 6 4\n")
  fprintf(zrconnections_form "FGROUP \"ZR_Connections_File\"\n")
  fprintf(zrconnections_form "ENUMSET 7\n")
  fprintf(zrconnections_form "POP \"stackup\"\n")
  fprintf(zrconnections_form "ENDFIELD\n")
  fprintf(zrconnections_form "\n")
  fprintf(zrconnections_form "FIELD minvia\n")
  fprintf(zrconnections_form "FLOC 16 4\n")
  fprintf(zrconnections_form "FGROUP \"ZR_Connections_File\"\n")
  fprintf(zrconnections_form "INTSLIDEBAR 3 3\n")
  fprintf(zrconnections_form "MIN 1\n")
  fprintf(zrconnections_form "MAX 100\n")
  fprintf(zrconnections_form "ENDFIELD\n")
  fprintf(zrconnections_form "\n")
  fprintf(zrconnections_form "FIELD maxvia\n")
  fprintf(zrconnections_form "FLOC 23 4\n")
  fprintf(zrconnections_form "FGROUP \"ZR_Connections_File\"\n")
  fprintf(zrconnections_form "INTSLIDEBAR 3 3\n")
  fprintf(zrconnections_form "MIN 1\n")
  fprintf(zrconnections_form "MAX 100\n")
  fprintf(zrconnections_form "ENDFIELD\n")
  fprintf(zrconnections_form "\n")
  fprintf(zrconnections_form "FIELD av_nets\n")
  fprintf(zrconnections_form "FLOC 1 8\n")
  fprintf(zrconnections_form "FGROUP \"ZR_Connections_File\"\n")
  fprintf(zrconnections_form "LIST \"\" 28 4\n")
  fprintf(zrconnections_form "ENDFIELD\n")
  fprintf(zrconnections_form "\n")
  fprintf(zrconnections_form "FIELD allavnets\n")
  fprintf(zrconnections_form "FLOC 26 16\n")
  fprintf(zrconnections_form "FGROUP \"ZR_Connections_File\"\n")
  fprintf(zrconnections_form "MENUBUTTON \"*\" 2 2\n")
  fprintf(zrconnections_form "ENDFIELD\n")
  fprintf(zrconnections_form "\n")
  fprintf(zrconnections_form "TEXT \"Connections File Name\"\n")
  fprintf(zrconnections_form "TLOC 1 16\n")
  fprintf(zrconnections_form "TGROUP \"ZR_Connections_File\"\n")
  fprintf(zrconnections_form "ENDTEXT\n")
  fprintf(zrconnections_form "\n")
  fprintf(zrconnections_form "\n")
  fprintf(zrconnections_form "FIELD zroutputfile\n")
  fprintf(zrconnections_form "FLOC 1 18\n")
  fprintf(zrconnections_form "STRFILLIN 20 100\n")
  fprintf(zrconnections_form "ENDFIELD\n")
  fprintf(zrconnections_form "\n")
  fprintf(zrconnections_form "FIELD fbrowse\n")
  fprintf(zrconnections_form "FLOC 23 18\n")
  fprintf(zrconnections_form "FGROUP \"ZR_Connections_File\"\n")
  fprintf(zrconnections_form "MENUBUTTON \"...\" 3 3\n")
  fprintf(zrconnections_form "ENDFIELD\n")
  fprintf(zrconnections_form "\n")
  fprintf(zrconnections_form "\n")
  fprintf(zrconnections_form "FIELD clearfile\n")
  fprintf(zrconnections_form "FLOC 1 20\n")
  fprintf(zrconnections_form "FGROUP \"ZR_Connections_File\"\n")
  fprintf(zrconnections_form "MENUBUTTON \"Clear Connections File\" 16 2\n")
  fprintf(zrconnections_form "ENDFIELD\n")
  fprintf(zrconnections_form "\n")
  fprintf(zrconnections_form "FIELD xgrid\n")
  fprintf(zrconnections_form "FLOC 9 23\n")
  fprintf(zrconnections_form "FGROUP \"Run_ZRouter\"\n")
  fprintf(zrconnections_form "REALFILLIN 4 4\n")
  fprintf(zrconnections_form "REALMIN 0.010000\n")
  fprintf(zrconnections_form "REALMAX 999999.990000\n")
  fprintf(zrconnections_form "DECIMAL 2\n")
  fprintf(zrconnections_form "ENDFIELD\n")
  fprintf(zrconnections_form "\n")
  fprintf(zrconnections_form "FIELD run\n")
  fprintf(zrconnections_form "FLOC 15 23\n")
  fprintf(zrconnections_form "MENUBUTTON \"Run\" 13 3\n")
  fprintf(zrconnections_form "ENDFIELD\n")
  fprintf(zrconnections_form "\n")
  fprintf(zrconnections_form "FIELD ygrid\n")
  fprintf(zrconnections_form "FLOC 9 25\n")
  fprintf(zrconnections_form "FGROUP \"Run_ZRouter\"\n")
  fprintf(zrconnections_form "REALFILLIN 4 4\n")
  fprintf(zrconnections_form "REALMIN 0.010000\n")
  fprintf(zrconnections_form "REALMAX 999999.990000\n")
  fprintf(zrconnections_form "DECIMAL 2\n")
  fprintf(zrconnections_form "ENDFIELD\n")
  fprintf(zrconnections_form "\n")
  fprintf(zrconnections_form "FIELD vzrlog\n")
  fprintf(zrconnections_form "FLOC 15 25\n")
  fprintf(zrconnections_form "FGROUP \"Run_ZRouter\"\n")
  fprintf(zrconnections_form "MENUBUTTON \"zrouter.log\" 13 3\n")
  fprintf(zrconnections_form "ENDFIELD\n")
  fprintf(zrconnections_form "\n")
  fprintf(zrconnections_form "FIELD xoffset\n")
  fprintf(zrconnections_form "FLOC 9 27\n")
  fprintf(zrconnections_form "FGROUP \"Run_ZRouter\"\n")
  fprintf(zrconnections_form "REALFILLIN 4 4\n")
  fprintf(zrconnections_form "REALMIN 0.000000\n")
  fprintf(zrconnections_form "REALMAX 999999.990000\n")
  fprintf(zrconnections_form "DECIMAL 2\n")
  fprintf(zrconnections_form "ENDFIELD\n")
  fprintf(zrconnections_form "\n")
  fprintf(zrconnections_form "FIELD yoffset\n")
  fprintf(zrconnections_form "FLOC 9 29\n")
  fprintf(zrconnections_form "FGROUP \"Run_ZRouter\"\n")
  fprintf(zrconnections_form "REALFILLIN 4 4\n")
  fprintf(zrconnections_form "REALMIN 0.000000\n")
  fprintf(zrconnections_form "REALMAX 999999.990000\n")
  fprintf(zrconnections_form "DECIMAL 2\n")
  fprintf(zrconnections_form "ENDFIELD\n")
  fprintf(zrconnections_form "\n")
  fprintf(zrconnections_form "FIELD lhelp\n")
  fprintf(zrconnections_form "FLOC 18 27\n")
  fprintf(zrconnections_form "FGROUP \"Run_ZRouter\"\n")
  fprintf(zrconnections_form "MENUBUTTON \"Help\" 10 3\n")
  fprintf(zrconnections_form "ENDFIELD\n")
  fprintf(zrconnections_form "\n")
  fprintf(zrconnections_form "FIELD viatopadspace\n")
  fprintf(zrconnections_form "FLOC 9 31\n")
  fprintf(zrconnections_form "FGROUP \"Run_ZRouter\"\n")
  fprintf(zrconnections_form "REALFILLIN 4 4\n")
  fprintf(zrconnections_form "REALMIN 0.000000\n")
  fprintf(zrconnections_form "REALMAX 999999.990000\n")
  fprintf(zrconnections_form "DECIMAL 2\n")
  fprintf(zrconnections_form "ENDFIELD\n")
  fprintf(zrconnections_form "\n")
  fprintf(zrconnections_form "FIELD close\n")
  fprintf(zrconnections_form "FLOC 15 31\n")
  fprintf(zrconnections_form "FGROUP \"Run_ZRouter\"\n")
  fprintf(zrconnections_form "MENUBUTTON \"Close\" 13 3\n")
  fprintf(zrconnections_form "ENDFIELD\n")
  fprintf(zrconnections_form "\n")
  fprintf(zrconnections_form "FIELD info\n")
  fprintf(zrconnections_form "FLOC 18 29\n")
  fprintf(zrconnections_form "FGROUP \"Run_ZRouter\"\n")
  fprintf(zrconnections_form "MENUBUTTON \"Info\" 10 3\n")
  fprintf(zrconnections_form "ENDFIELD\n")
  fprintf(zrconnections_form "\n")
  fprintf(zrconnections_form "GROUP \"ZR_Connections_File\"\n")
  fprintf(zrconnections_form "GLOC 0 0\n")
  fprintf(zrconnections_form "GSIZE 34 22\n")
  fprintf(zrconnections_form "ENDGROUP\n")
  fprintf(zrconnections_form "\n")
  fprintf(zrconnections_form "GROUP \"Run_ZRouter\"\n")
  fprintf(zrconnections_form "GLOC 0 21\n")
  fprintf(zrconnections_form "GSIZE 32 13\n")
  fprintf(zrconnections_form "ENDGROUP\n")
  fprintf(zrconnections_form "\n")
  fprintf(zrconnections_form "ENDTILE\n")
  fprintf(zrconnections_form "\n")
  fprintf(zrconnections_form "ENDFORM\n")
  close(zrconnections_form)
  ); end prog
); end defun
;###########################################################
;#                                                         #
;#            End of _createForm_zrconnections             #
;#                                                         #
;###########################################################

(defun zrconnections_info_createInfo ()
  zrconnections_info_helpfile = "./zrconnections_info_info.txt"
  zrconnections_info_info = outfile(zrconnections_info_helpfile "w")
  fprintf(zrconnections_info_info "################################################################################\n")
  fprintf(zrconnections_info_info "#                                                                              #\n")
  fprintf(zrconnections_info_info "#                      Command: zrconnections                                  #\n")
  fprintf(zrconnections_info_info "#                   Skill File: zrconnections.il                               #\n")
  fprintf(zrconnections_info_info "#                  How To Load: APD> (load(\"zrconnections.il\"))                #\n")
  fprintf(zrconnections_info_info "#               How To Execute: APD> zrconnections                             #\n")
  fprintf(zrconnections_info_info "#                                                                              #\n")
  fprintf(zrconnections_info_info "#                       Author: Larry Bowman, Cadence Design Systems           #\n")
  fprintf(zrconnections_info_info "#                        Email: bowman@cadence.com                             #\n")
  fprintf(zrconnections_info_info "#                    Telephone: 512-349-1109                                   #\n")
  fprintf(zrconnections_info_info "#                Creation Date: 10/31/2001                                     #\n")
  fprintf(zrconnections_info_info "#                                                                              #\n")
  fprintf(zrconnections_info_info "################################################################################\n")
  fprintf(zrconnections_info_info "\n")
  fprintf(zrconnections_info_info "################################################################################\n")
  fprintf(zrconnections_info_info "#                                                                              #\n")
  fprintf(zrconnections_info_info "# Revision Date:  November 05, 2001                                            #\n")
  fprintf(zrconnections_info_info "#            By:  Larry Bowman                                                 #\n")
  fprintf(zrconnections_info_info "#                                                                              #\n")
  fprintf(zrconnections_info_info "# Revision C:                                                                  #\n")
  fprintf(zrconnections_info_info "# ---------------------------------------------------------------------        #\n")
  fprintf(zrconnections_info_info "#     1.  Used axlFormBuildPopup which avoids the use of a long list for       #\n")
  fprintf(zrconnections_info_info "#         the ENUM field for \"Refdes\" and \"ToLayer\".  Thus the form is         #\n")
  fprintf(zrconnections_info_info "#         updated with the correct information in the lists should the         #\n")
  fprintf(zrconnections_info_info "#         Cross-section or Reference Designators change.                       #\n")
  fprintf(zrconnections_info_info "#     2.  Removed the Warning Dialog window should the user open a new         #\n")
  fprintf(zrconnections_info_info "#         database.  This is no longer needed based on fix 1. above.           #\n")
  fprintf(zrconnections_info_info "#     3.  Sorted the list of Reference Designators so the list will be         #\n")
  fprintf(zrconnections_info_info "#         displayed alphanumerically.                                          #\n")
  fprintf(zrconnections_info_info "#                                                                              #\n")
  fprintf(zrconnections_info_info "################################################################################\n")
  fprintf(zrconnections_info_info "\n")
  fprintf(zrconnections_info_info "################################################################################\n")
  fprintf(zrconnections_info_info "#                                                                              #\n")
  fprintf(zrconnections_info_info "# Revision Date:  November 02, 2001                                            #\n")
  fprintf(zrconnections_info_info "#            By:  Larry Bowman                                                 #\n")
  fprintf(zrconnections_info_info "#                                                                              #\n")
  fprintf(zrconnections_info_info "# Revision B:                                                                  #\n")
  fprintf(zrconnections_info_info "# ---------------------------------------------------------------------        #\n")
  fprintf(zrconnections_info_info "#     1.  Corrected the error: \"E- *Error* eval: unbound variable - zroutport\" #\n")
  fprintf(zrconnections_info_info "#                                                                              #\n")
  fprintf(zrconnections_info_info "################################################################################\n")
  fprintf(zrconnections_info_info "\n")
  fprintf(zrconnections_info_info "################################################################################\n")
  fprintf(zrconnections_info_info "#                                                                              #\n")
  fprintf(zrconnections_info_info "# Revision Date:  November 02, 2001                                            #\n")
  fprintf(zrconnections_info_info "#            By:  Larry Bowman                                                 #\n")
  fprintf(zrconnections_info_info "#                                                                              #\n")
  fprintf(zrconnections_info_info "# Revision A:                                                                  #\n")
  fprintf(zrconnections_info_info "# ---------------------------------------------------------------------        #\n")
  fprintf(zrconnections_info_info "#     1.  Added command line arguments to invoke the info message.             #\n")
  fprintf(zrconnections_info_info "#		(-h h help -help)                                              #\n")
  fprintf(zrconnections_info_info "#     2.  Added command line arguments to display the form standalone.         #\n")
  fprintf(zrconnections_info_info "#		(-nomini nomini no -no nomin -nomin)                           #\n")
  fprintf(zrconnections_info_info "#     3.  Modified the form fields and added some color to the form.           #\n")
  fprintf(zrconnections_info_info "#     4.  Dehighlighted pins when a new connections file was selected.         #\n")
  fprintf(zrconnections_info_info "#     5.  Dehighlighted pins when command was closed.                          #\n")
  fprintf(zrconnections_info_info "#                                                                              #\n")
  fprintf(zrconnections_info_info "################################################################################\n")
  fprintf(zrconnections_info_info "\n")
  fprintf(zrconnections_info_info "################################################################################\n")
  fprintf(zrconnections_info_info "#  DISCLAIMER:                                                                 #\n")
  fprintf(zrconnections_info_info "#       The user of this command assumes all responsibility and does not       #\n")
  fprintf(zrconnections_info_info "#       hold Cadence Design Systems nor the author of this code for any        #\n")
  fprintf(zrconnections_info_info "#       unwarranted results or problems due to the use of this code.           #\n")
  fprintf(zrconnections_info_info "#                                                                              #\n")
  fprintf(zrconnections_info_info "#       This is non-supported code and the user may modify it as needed.       #\n")
  fprintf(zrconnections_info_info "#                                                                              #\n")
  fprintf(zrconnections_info_info "################################################################################\n")
  fprintf(zrconnections_info_info "\n")
  fprintf(zrconnections_info_info "This program, zrconnections, is a graphical interface to create\n")
  fprintf(zrconnections_info_info "a connections file to be used by the ZROUTER feature in APD.\n")
  fprintf(zrconnections_info_info "\n")
  fprintf(zrconnections_info_info "It also includes the abilitiy to run the \"zrouter\" from the form.\n")
  fprintf(zrconnections_info_info "\n")
  fprintf(zrconnections_info_info "The format of the Zrouter connections input file is:\n")
  fprintf(zrconnections_info_info "# Refdes	Netname	To Layer	Min Via		Max Via\n")
  fprintf(zrconnections_info_info "\n")
  fprintf(zrconnections_info_info "This program will display a form seeded with the Refdes of the component\n")
  fprintf(zrconnections_info_info "with the CLASS=IO property.  The form will also be seeded with a To Layer\n")
  fprintf(zrconnections_info_info "of \"The Begin Layer\", Min and Max Via of 1, and the output file name of\n")
  fprintf(zrconnections_info_info "\"zrconnections.txt\".  The output file may be any name but must be a text\n")
  fprintf(zrconnections_info_info "file type.  If the output file name already exists in the current working\n")
  fprintf(zrconnections_info_info "directory then that file will be used and the data appended to the end of\n")
  fprintf(zrconnections_info_info "the file.\n")
  fprintf(zrconnections_info_info "\n")
  fprintf(zrconnections_info_info "USE MODEL\n")
  fprintf(zrconnections_info_info "-------------------\n")
  fprintf(zrconnections_info_info "The form in the Options Tab of the Control Panel will dispay a list of net\n")
  fprintf(zrconnections_info_info "names found on the Refdes selected.\n")
  fprintf(zrconnections_info_info "\n")
  fprintf(zrconnections_info_info "The user selectively picks a net name from the list (one at a time) which\n")
  fprintf(zrconnections_info_info "will add a line to the output file based on the settings in\n")
  fprintf(zrconnections_info_info "the REFDES, TO LAYER, MIN VIA, and MAX VIA fields.\n")
  fprintf(zrconnections_info_info "\n")
  fprintf(zrconnections_info_info "The user may also select net names graphically from the layout which will add\n")
  fprintf(zrconnections_info_info "a line to the output file, one for each netname.  If selecting graphically\n")
  fprintf(zrconnections_info_info "from the layout, the user may select by Window, by Temp Group,\n")
  fprintf(zrconnections_info_info "or by single pick.\n")
  fprintf(zrconnections_info_info "\n")
  fprintf(zrconnections_info_info "Before a net name is selected the user must ensure that the correct settings\n")
  fprintf(zrconnections_info_info "are in the REFDES, TO LAYER, MIN VIA, and MAX VIA fields.\n")
  fprintf(zrconnections_info_info "\n")
  fprintf(zrconnections_info_info "The CLOSE FORM button, the RMB-Done, and RMB-Cancel closes the form,\n")
  fprintf(zrconnections_info_info "closes the output file, and exits the command.  This allows the user to create\n")
  fprintf(zrconnections_info_info "a connections file WITHOUT actually running the Zrouter.\n")
  fprintf(zrconnections_info_info "\n")
  fprintf(zrconnections_info_info "The INFO button displays this program description.\n")
  fprintf(zrconnections_info_info "\n")
  fprintf(zrconnections_info_info "The Zrouter may be run from within this command by selecting the \"Run\"\n")
  fprintf(zrconnections_info_info "button at the bottom of the form.  It is the user's responsibility that\n")
  fprintf(zrconnections_info_info "there is a via(s) in the Physical Line constraint to allow connections\n")
  fprintf(zrconnections_info_info "between the pins of the selected reference designator and the\n")
  fprintf(zrconnections_info_info "\"ToLayer\" subclass.\n")
  fprintf(zrconnections_info_info "\n")
  fprintf(zrconnections_info_info "In addition the user must select an appropriate Xgrid, Ygrid, Xoffset, Yoffset,\n")
  fprintf(zrconnections_info_info "and Via-Pad spacing.  The default setting is 10, 10, 0, 0, 0 respectively.\n")
  fprintf(zrconnections_info_info "\n")
  fprintf(zrconnections_info_info "The existing form (Route->Zrouter...) may be used as well to run the Zrouter.\n")
  fprintf(zrconnections_info_info "\n")
  fprintf(zrconnections_info_info "KNOWN ISSUE\n")
  fprintf(zrconnections_info_info "--------------\n")
  fprintf(zrconnections_info_info "When using axlMiniStatusLoad function the form remembers its initial settings.\n")
  fprintf(zrconnections_info_info "To modify the form's list entries use axlFormBuildPopup function.\n")
  fprintf(zrconnections_info_info "\n")
  fprintf(zrconnections_info_info "\n")
  fprintf(zrconnections_info_info "\n")
  close(zrconnections_info_info)
  axlUIViewFileCreate(zrconnections_info_helpfile "Info" t list(82 20))
  deleteFile(zrconnections_info_helpfile)
); end defun
