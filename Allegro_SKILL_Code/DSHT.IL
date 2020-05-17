
; Prerequisites: User property DATASHEET must be defined and assigned
; to components in the design. The format of the value of this property
; is a URL.
; When the command dsheet is running, selecting a component takes the 
; value of the user property DATASHEET and passes it to the axlHttp function
; 

procedure( dsht()
axlClearSelSet()
;set find filter to only components
axlSetFindFilter(?enabled
'("noall" "COMPONENTS")
?onButtons "COMPONENTS")
;startup find filter
axlSelect()	;Prompt the user for a selection.
url=nil
ds_comp=car(axlGetSelSet())
axlFinishEnterFun()
axlClearSelSet()
;The properties are stored in a list in the component definition.
l_comp_def_props=ds_comp->compdef->prop->??	;Extract the props from the compdef

foreach(ds_comp_prop l_comp_def_props	;check the list of properties
	sprintf(s_ds_comp_prop "%s", ds_comp_prop)	;convert to string
	prop_counter=1
	if( s_ds_comp_prop == "DATASHEET" then		;check property name
		url=nth(prop_counter l_comp_def_props)	;grab the URL value
		prop_counter++
		);endif
);end foreach
;test for url value on component and pass url to axlHTTP
if(url == nil then 
(print "No Datasheet attribute on component");need to exit if url is null
else
axlHttp(url)
)
);end proc

;Register the command dsheet as an Allegro command.
axlCmdRegister("dsheet" 'dsht ?cmdType "interactive")
