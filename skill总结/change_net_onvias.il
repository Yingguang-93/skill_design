;*****************************************************
;
; Interactive command for change net of vias
;
;  Allows selecting either a single via or a window of vias
;
;  The net select for the via is advisory. The Via must be
;  able to connect to a member of that net to remain on the
;  net selected. 
;  For example, A via is outside the board and on Dummy Net. 
;  It will always remain on the dummy net.
;
;*****************************************************


axlCmdRegister("change_net_onvias"  `rplc_netvia)

; unless( boundp('_rpcLastNet)
    ;_rpcLastNet = ""
;)

;=========================================================
;==================== MAIN ROUTINE =======================
;=========================================================


procedure( rplc_netvia()
  (let ( mypopup vias net )
    
    axlClearSelSet()
    axlSetFindFilter(?enabled `("NOALL" "VIAS")
			     ?onButtons `("VIAS"))
   
    mypopup = axlUIPopupDefine( nil
                 (list (list "Done" 'axlFinishEnterFun)
                 (list "Cancel" 'axlCancelEnterFun)))
    axlUIPopupSet( mypopup)

    ; Use the generic select instead of box, so the user can use temp group
    axlSelect(?prompt "Select vias by pick or window.");
    
    vias = axlGetSelSet()
xxx = vias
    when(vias

	; simple prompt for net
      	;netname = axlUIPrompt( "New Net Name:" _rpcLastNet )

	; Use a data browser
      	net = cadr(axlUIDataBrowse('NET '(RETRIEVE_OBJECT) "New Net Name" t))
yyy = net
	when(net
	    ; Cloak improves performance when multiple vias are involved
     	    axlDBCloak('_RPVdoNetReplacement( vias net ) 'shape)
	)
    )
    
    axlClearSelSet()
    axlFinishEnterFun()
    t
))

procedure( _RPVdoNetReplacement( vias net )
 (let (count )

    count = 0
    foreach( via vias
      axlChangeNet( via net)
      count++
    )

    if( count > 1 then
	axlMsgPut("%d vias were changed to net %s." count net->name)
    )
    t
))

