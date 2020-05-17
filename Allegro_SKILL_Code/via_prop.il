/*
################################################################################
#                                                                              #
#                      Command: add_prop_via                                   #
#                   Skill File: via_prop.il                                    #
#                  How To Load: Command> skill load("via_prop.il")             #
#               How To Execute: Command> add_prop_via                          #
#               Sourcelink Solution Reference : 11297750, 11266604             #
#                                                                              #
#                       Author: Jatin Sasan , Cadence Design Systems           #
#                        Email: jsasan@cadence.com                             #
#                    Telephone: 512-342-5107                                   #
#                Creation Date: June 28,2006                                   #
#                                                                              #
################################################################################

################################################################################
#                                                                              #
#  DISCLAIMER:                                                                 #
# THIS CODE IS UNSUPPORTED AND HAS HAD MINIMAL TESTING.                        #
# The following code is provided for Cadence customers                         #
# to use at their own risk. The code may require modification to               #
# satisfy the requirements of any user. The code and any                       #
# modifications to the code may not be compatible with current or              #
# future versions of Cadence products.                                         #
# THE CODE IS PROVIDED "AS IS" AND WITH NO WARRANTIES, INCLUDING               #
# WITHOUT LIMITATION ANY EXPRESS WARRANTIES OR IMPLIED WARRANTIES              #
# OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR USE.                          #
#                                                                              #
################################################################################

################################################################################
#                                                                              #
#  06/28/2006:  Adds Via property to all vias on a net                         #
#  Revision history:                                                           #
#	1.0 Original file		                           June 28,2006          #
#     2.0 Added Form Support                             Dec 01,2006           #
#                                                                              #
#  Advantages:                                                                 #
# a) Easily add property to all vias on a net                                  #
#                                                                              #
#  Limitations:                                                                #
# a) Vias must exist on the net                                                #
# b) Valid property value must be assigned to property.                        #
#                                                                              #
################################################################################
*/

axlCmdRegister("add_prop_via" 'add_prop_form_net) ; axlSkill cmd Registration

(setq add_prop_via_status nil)
(setq break_loop 0)
prop_check_list = '("BACKDRILL_OVERRIDE" "DYN_CLEARANCE_OVERSIZE" "DYN_FIXED_THERM_WIDTH" "DYN_MAX_THERMAL_CONNS"
                    "DYN_MIN_THERMAL_CONNS" "DYN_OVERSIZE_THERM_WIDTH")
con_type        = '("ORTHOGONAL" "DIAGONAL" "FULL_CONTACT" "NONE" "8_WAY")
clearance_type  = '("DRC_VALUE" "ANTI_THERMAL" "NO_VOID")
true_type       = '("ALIGNED" "BACKDRILL_EXCLUDE" "BOND_PAD" "DEGAS_NO_VOID" "DYN_THERMAL_BEST_FIT" "FIXED" "NO_DRC" "NO_SHAPE_CONNECT"
                    "NO_VIA_CONNECT" "NO_DRC_VIAS_OUTSIDE_KEEPIN")
idf_type        = '("MCAD" "ECAD")

procedure(add_prop_form_net()
  _makeForm_via_prop_add()
   axlFormDisplay(_via_prop_add)
); end procedure

;###########################################################
;#                                                         #
;#                FORM CREATION                            #
;#                                                         #
;###########################################################

(defun _makeForm_via_prop_add ()
   _VIA_PROP_ADD=outfile("./via_prop_add.form" "w")
   fprintf(_VIA_PROP_ADD "FILE_TYPE=FORM_DEFN VERSION=2\n")
   fprintf(_VIA_PROP_ADD "FORM\n")
   fprintf(_VIA_PROP_ADD "FIXED\n")
   fprintf(_VIA_PROP_ADD "PORT 58 15\n")
   fprintf(_VIA_PROP_ADD "HEADER \"Add Property to all Vias on a net\" \n")
   fprintf(_VIA_PROP_ADD "POPUP <VIA_PROPS_NAME> \"ALIGNED\" \"ALIGNED\",\"BACKDRILL_EXCLUDE\" \"BACKDRILL_EXCLUDE\",\"BACKDRILL_OVERRIDE\" \"BACKDRILL_OVERRIDE\",\"BOND_PAD\" \"BOND_PAD\",\"COMMENT\" \"COMMENT\",\"DEGAS_NO_VOID\" \"DEGAS_NO_VOID\",\"DYN_CLEARANCE_OVERSIZE\" \"DYN_CLEARANCE_OVERSIZE\",\"DYN_CLEARANCE_TYPE\" \"DYN_CLEARANCE_TYPE\",\"DYN_FIXED_THERM_WIDTH\" \"DYN_FIXED_THERM_WIDTH\",\"DYN_MAX_THERMAL_CONNS\"  \"DYN_MAX_THERMAL_CONNS\",\"DYN_MIN_THERMAL_CONNS\"  \"DYN_MIN_THERMAL_CONNS\",\"DYN_OVERSIZE_THERM_WIDTH\" \"DYN_OVERSIZE_THERM_WIDTH\",\"DYN_THERMAL_BEST_FIT\" \"DYN_THERMAL_BEST_FIT\",\"DYN_THERMAL_CON_TYPE\" \"DYN_THERMAL_CON_TYPE\",\"FIXED\" \"FIXED\",\"IDF_OWNER\" \"IDF_OWNER\",\"NET_SHORT\" \"NET_SHORT\", \"NO_DRC\" \"NO_DRC\",\"NO_DRC_VIAS_OUTSIDE_KEEPIN\" \"NO_DRC_VIAS_OUTSIDE_KEEPIN\",\"NO_SHAPE_CONNECT\" \"NO_SHAPE_CONNECT\",\"NO_VIA_CONNECT\" \"NO_VIA_CONNECT\". \n")

   fprintf(_VIA_PROP_ADD "POPUP <VIA_PROPS_VALUE> \"8_WAY\" \"8_WAY\",\"ANTI_THERMAL\" \"ANTI_THERMAL\", \"DIAGONAL\" \"DIAGONAL\",\"DRC_VALUE\" \"DRC_VALUE\",\"ECAD\" \"ECAD\",\"FULL_CONTACT\" \"FULL_CONTACT\",\"MCAD\" \"MCAD\",\"NONE\" \"NONE\", \"NO_VOID\" \"NO_VOID\",\"ORTHOGONAL\" \"ORTHOGONAL\",\"TRUE\" \"TRUE\". \n")
   fprintf(_VIA_PROP_ADD "TILE\n")

   fprintf(_VIA_PROP_ADD  "TEXT \"Browse for the net:\"\n")
   fprintf(_VIA_PROP_ADD "TLOC 2 2\n")
   fprintf(_VIA_PROP_ADD "ENDTEXT\n")

   fprintf(_VIA_PROP_ADD "FIELD NET1\n")
   fprintf(_VIA_PROP_ADD "FLOC 22 2\n")
   fprintf(_VIA_PROP_ADD "STRFILLIN 20 100\n")
   fprintf(_VIA_PROP_ADD "ENDFIELD\n")

   fprintf(_VIA_PROP_ADD "FIELD NET1_BR\n")
   fprintf(_VIA_PROP_ADD "FLOC 45 2 \n")
   fprintf(_VIA_PROP_ADD "MENUBUTTON \"Browse\" 10 3\n")
   fprintf(_VIA_PROP_ADD "ENDFIELD\n")

   fprintf(_VIA_PROP_ADD "TEXT \"Specify Via Property Name:\"\n")
   fprintf(_VIA_PROP_ADD "TLOC 2 5\n")
   fprintf(_VIA_PROP_ADD "ENDTEXT\n")

   fprintf(_VIA_PROP_ADD "FIELD VIA_PROPS_NAME\n")
   fprintf(_VIA_PROP_ADD "FLOC 22 5 \n")
   fprintf(_VIA_PROP_ADD  "ENUMSET 25 \n")
   fprintf(_VIA_PROP_ADD  "POP VIA_PROPS_NAME\n")
   fprintf(_VIA_PROP_ADD  "STRFILLIN 20 100\n")
   fprintf(_VIA_PROP_ADD  "ENDFIELD\n")

   fprintf(_VIA_PROP_ADD  "TEXT \"Specify Via Property Value:\"\n")
   fprintf(_VIA_PROP_ADD  "TLOC 2 8\n")
   fprintf(_VIA_PROP_ADD  "ENDTEXT\n")

   fprintf(_VIA_PROP_ADD  "FIELD VIA_PROPS_VALUE\n")
   fprintf(_VIA_PROP_ADD "FLOC 22 8\n")
   fprintf(_VIA_PROP_ADD  "ENUMSET 20 \n")
   fprintf(_VIA_PROP_ADD  "POP VIA_PROPS_VALUE\n")
   fprintf(_VIA_PROP_ADD  "STRFILLIN 20 100\n")
   fprintf(_VIA_PROP_ADD  "ENDFIELD\n")

   fprintf(_VIA_PROP_ADD "FIELD ADD_PROP\n")
   fprintf(_VIA_PROP_ADD "FLOC 10 12 \n")
   fprintf(_VIA_PROP_ADD "MENUBUTTON \"Add Prop\" 10 3\n")
   fprintf(_VIA_PROP_ADD "ENDFIELD\n")

   fprintf(_VIA_PROP_ADD "FIELD CLOSE\n")
   fprintf(_VIA_PROP_ADD "FLOC 30 12\n")
   fprintf(_VIA_PROP_ADD "MENUBUTTON \"Close\" 10 3\n")
   fprintf(_VIA_PROP_ADD "ENDFIELD\n")

   fprintf(_VIA_PROP_ADD "ENDTILE\n")
   fprintf(_VIA_PROP_ADD "ENDFORM\n")
   close(_VIA_PROP_ADD)
   _via_prop_add = axlFormCreate( (gensym) "via_prop_add.form" '(e inner) 'Via_prop_add_Form_Action t)

); end defun  _makeForm_via_prop_add


(defun Via_prop_add_Form_Action (myform)
        case( myform->curField
                ("NET1"
                   net_name = myform->curValue
                 )
                ("NET1_BR"
                      net_name = car(axlUIDataBrowse('NET '(EXAMINE_DATABASE RETRIEVE_NAME) "Select Net" t))
                      axlFormSetField(myform "NET1" net_name)
                 )
                ("VIA_PROPS_NAME"
                   prop_name = myform->curValue
                 )
                ("VIA_PROPS_VALUE"
                   prop_value= myform->curValue
                 )
                ("ADD_PROP"
                    if(member(prop_name prop_check_list) then
                        if(!rexMatchp("[0-9]+" prop_value) then
                          sprintf(msg_test,"Property %s can only have integer values.\n", upperCase(prop_name))
                          axlUIConfirm(msg_test)
                          break_loop++
                          ) ; end if
                       ); end if
                      if((prop_name == "DYN_THERMAL_CON_TYPE") then
                         if(!member(prop_value con_type) then
                            sprintf(msg_test,"Property %s can only have ORTHOGONAL, DIAGONAL, FULL_CONTACT,8_WAY or NONE as values .\n",
                                              upperCase(prop_name))
                            axlUIConfirm(msg_test)
                            break_loop++
                            ) ; end if
                         ) ; end if
                      if((prop_name == "DYN_CLEARANCE_TYPE") then
                         if(!member(prop_value clearance_type) then
                            sprintf(msg_test,"Property %s can only have DRC_VALUE, ANTI_THERMAL or NO_VOID as values .\n",
                                              upperCase(prop_name))
                            axlUIConfirm(msg_test)
                            break_loop++
                            ) ; end if
                         ) ; end if
                      if(member(prop_name true_type) then
                         if(prop_value != "TRUE" then
                            sprintf(msg_test,"Property %s can only have Boolean value TRUE .\n",
                                              upperCase(prop_name))
                            axlUIConfirm(msg_test)
                            break_loop++
                            ) ; end if
                         ) ; end if
                      if(prop_name == "IDF_OWNER" then
                         if(!member(prop_value idf_type) then
                            sprintf(msg_test,"Property %s can only have value as MCAD or ECAD .\n",
                                              upperCase(prop_name))
                            axlUIConfirm(msg_test)
                            break_loop++
                            ) ; end if
                         ) ; end if
                    if(break_loop == 0 then
                    status = add_prop_via_net(net_name prop_name prop_value)
                    if(add_prop_via_status then
                     if(status > 0 then
                       sprintf(msg_test,"%s added successfully on %L vias on net %s\n",upperCase(prop_name),
                                         status,upperCase(net_name))
                       axlUIConfirm(msg_test)
                       (setq add_prop_via_status nil) (setq break_loop 0)
                     else
                       sprintf(msg_test,"Property not added as No vias found on net %s.\n", upperCase(net_name))
                       axlUIConfirm(msg_test)
                       (setq add_prop_via_status nil) (setq break_loop 0)
                       ) ; end if
                    else
                       sprintf(msg_test,"Property definition for %s doesnt exist. Add_prop failed. Add property using Setup->Property Definitions first and then run this program\n", upperCase(prop_name))
                       axlUIConfirm(msg_test)
                       (setq add_prop_via_status nil) (setq break_loop 0)
                        ) ; end if
                     else
                       (setq break_loop 0)
                         ); end if
                 )
                 ("CLOSE"
                    axlFormClose(myform)
                    axlCancelEnterFun()
                    axlTempFileRemove("via_prop_add.form")
                 )
             ) ; end case
); end defun

;###########################################################
;#                                                         #
;#                Main Program add_prop_via_net            #
;#                                                         #
;###########################################################


(defun add_prop_via_net (net_name prop_name prop_value)
      prog( (count l_net_branch group_dbid count )
           (setq group_dbid nil)
           axlSetFindFilter(?enabled list("noall" "nets") ?onButtons list("all"))   ; Enable selection of nets only
           axlSingleSelectName("NET" list(net_name))           ; Select the net in question
           l_net_branch = axlGetSelSet()
           axlClearSelSet()
           (setq count 0)
           foreach( net_branch l_net_branch
              foreach( net_child net_branch->branches
                   foreach(Child net_child->children
                           if(Child->objType == "via" then
                               count++
                               group_dbid = append(group_dbid list(Child))
                              ) ; end if
                          ) ; end foreach
                     ) ; end foreach
                  ) ; end foreach
         if(group_dbid then
           add_prop_via_status = axlDBAddProp(group_dbid list(prop_name prop_value)) ;Add property to vias on the net.
         else
           (setq add_prop_via_status t) ;No vias but property is valid
            ) ; end if
    return(count)
         ) ; let
); end defun