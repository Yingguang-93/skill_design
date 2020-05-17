;*****************************************************
;
; Interactive command for replace via padstack definitions.
;
;
; The "replace via" command allows the user to select
; multiple vias through a find by window.  If more than
; one via padstack name is found, the command will prompt
; the user for which via padstack name they wish to replace.
; The default text will be "***". This selection tells the
; command to replace all the vias found, regardless of the
; padstack name.  The command then prompts the user for
; the name of the new padstack.  It then replaces the vias.
;
;
;  Stephen Hellriegel, Cray Inc, Nov 16 1996 (steve@tera.com)
;      Released to public        Oct 28 2003 (steve@cray.com)
;
; For PSD14.0+ grouped all collections of original padstack types
; into lists, and passed the lists to the via replacemanet axl call.
; Allegro does an internal DRC check after each call to axlReplacePadstack
; regardless of the state of the online DRC flag in the UI.
; If a user selected a 1000 vias to replace, it would take the time
; to DRC the job 1000 times before the old skill code completed.
; The new code takes the time for N DRC runs, where N is the number
; of distinct original vias/pins stacks types that were selected.
;*****************************************************


axlCmdRegister("replace via"  'rplc_via)
axlCmdRegister("replace pin"  'rplc_pin)

;add group replace alias, but map to same, improved rplc_via
; (these aliases are present for historical purposes inside Cray)
axlCmdRegister("greplace via" 'rplc_via)
axlCmdRegister("greplace pin" 'rplc_pin)

RPV_pstk_name = nil
RPP_pstk_name = nil
RPV_work = nil

;=========================================================
;==================== MAIN ROUTINE =======================
;=========================================================


(defun rplc_via ()				  ;_Nov 16 96 steve 440
  (let ( grp vias status )
    
    axlClearSelSet()
    axlSetFindFilter(?enabled list("NOALL" "VIAS")
			     ?onButtons list("VIAS"))
   
    ; Use the generic select instead of box, so the user can use temp group
    axlSelect( );

    
    if( RPV_pstk_name then
		     RPV_pstk_name = upperCase(axlUIPrompt( "New Padstack Name:" RPV_pstk_name ))
		     else
		     RPV_pstk_name = upperCase(axlUIPrompt( "New Padstack Name:" ))
      )
    
    if( RPV_pstk_name then
		     vias = axlGetSelSet()
		     status = _RPVdoReplacement( vias )
      ) ; ** let **
    
    axlClearSelSet()
    axlFinishEnterFun()
    
  );let
) ; ** defun rplc_via **

(defun rplc_pin ()				  ;_Mar 15 97 steve 462
   (let ( pins status )

	axlClearSelSet()
	axlSetFindFilter(?enabled '("NOALL" "PINS")
			 ?onButtons '("PINS"))

        ; Use the generic select instead of box, so the user can use temp group
        axlSelect( );

	if( RPP_pstk_name then
	    RPP_pstk_name = upperCase(axlUIPrompt( "New Padstack Name:" RPP_pstk_name ))
	else
	    RPP_pstk_name = upperCase(axlUIPrompt( "New Padstack Name:" ))
	)

	if( RPP_pstk_name then
	    pins = axlGetSelSet()
	    status = _RPPdoReplacement( pins )
	)

	axlClearSelSet()
	axlFinishEnterFun()

   );let
) ;end-defun


; RPV_add_to_vias adds a viaid to an existing list of vias
; or creates a new list if this is the first occurance of the padstack type
(defun RPV_add_to_vias ( padstack viaid )
 let( (pt scan_t site new_vialist new_tuple )
   pt = exists( scan_t RPV_work equal( car(scan_t) padstack))
   if( pt != nil then
       site=car(pt)
       new_vialist = ncons(append( ncons(viaid) cadr(site)))
       rplacd( site new_vialist)
   else
     new_tuple = list( padstack ncons(viaid))
     RPV_work = cons( new_tuple RPV_work)
   );if
 );let
);defun


(defun _RPVdoReplacement ( vias )
 
 (prog (count prevPstk match_list match_name status RPV_tuple )

    count = 0
    match_name = "***"
    save_name = car(vias)->name
    match_list = cdr(vias)

    while( match_list
	if( ( car(match_list)->name != save_name ) then
	    match_name = upperCase(axlUIPrompt("Old Padstack Name:" "***"))
	    match_list = nil
	else
	    match_list = cdr(match_list)
	)
    )


    foreach( prevPstk vias

	if( (( match_name == "***" ) ||
	     ( match_name == upperCase(prevPstk->name) )) then
             RPV_add_to_vias( RPV_pstk_name, prevPstk)
             count=count+1
	)
    )
    ; call the replace padstack function, passing in the lists of vias
    ; the head of each list contains the old padstack name, the remained of the list
    ; is the list of dbids
    foreach( RPV_tuple RPV_work
      axlReplacePadstack( cadr(RPV_tuple) car(RPV_tuple))
    )

    axlClearSelSet()  
    axlFlushDisplay()
    if( count == 0 then
	axlMsgPut("No vias were replaced. Please check padstack names.")
    )
    if( count > 1 then
	axlMsgPut("%d vias were replaced." count)
    )
    return( t )

 ) ;prog
) ;end-defun



(defun _RPPdoReplacement ( pins )
 

 (prog (count prevPin save_xy save_name save_pinText match_list match_name status )


    count = 0
    match_name = "***"
    save_name = car(pins)->name
    match_list = cdr(pins)

    while( match_list
	if( ( car(match_list)->name != save_name ) then
	    match_name = upperCase(axlUIPrompt("Old Padstack Name:" "***"))
	    match_list = nil
	else
	    match_list = cdr(match_list)
	)
    )


    foreach( prevPin pins

	if( (( match_name == "***" ) ||
	     ( match_name == upperCase(prevPstk->name) )) then

	    save_name = prevPin->name
	    save_xy   = prevPin->xy
	    save_rotation = prevPin->rotation
	    save_number = prevPin->number

	    save_TextOrientation = make_axlTextOrientation(
			?textBlock "1", ?rotation 0.0,
                        ?mirrored nil, ?justify "center")
	    save_pinText = make_axlPinText(
			?number save_number,
			?offset 0:0,
                        ?text save_TextOrientation)
	    axlDeleteObject( prevPin )
	    status = axlDBCreatePin(RPP_pstk_name save_xy save_pinText save_rotation )

	    if( status == nil then
		axlMsgPut("Not able to add new padstack. Please check name.")
		status = axlDBCreatePin(save_name save_xy save_pinText save_rotation )
		return( nil )
	    else
		count = count + 1
	    )
	)
    )

    axlClearSelSet()  
    axlFlushDisplay()
    if( count == 0 then
	axlMsgPut("No pins were replaced. Please check padstack names.")
    )
    if( count > 1 then
	axlMsgPut("%d pins were replaced." count)
    )
    return( t )

 ) ;prog
) ;end-defun
