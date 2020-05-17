/*
################################################################################
#                                                                              #
#                      Command: dfac                                           #
#                   Skill File: dfa_assembly.il                                #
#                  How To Load: Command> (load("dfa_assembly.il"))             #
#               How To Execute: Command> dfac                                  #
#               Sourcelink Solution Reference : 11297768                       #
#                                                                              #
#                       Author: Jatin Sasan , Cadence Design Systems           #
#                        Email: jsasan@cadence.com                             #
#                    Telephone: 512-342-5107                                   #
#                Creation Date: 08/14/2006                                     #
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
#  08/16/2006:  Reports DFA violations w.r.t Assembly subclass                 #
#  Revision history:                                                           #
#	1.0 Original file		                 Aug 14,2006           #
#     1.1 Declared clearance as real field               Aug 16,2006           #
#     1.2 Took Assembly outline line_width into account  Aug 17,2006           #
#     2.0 a) Restores original Visibility of design after dfa run
#         b) Fixed Viewlog problem. Clicking on Viewlog will always
#            display logfile now.
#         c) Set the form defaults to * and *            Dec 09,2007           #
#                                                                              #
#  Advantages:                                                                 #
# a) Support Regular expression character *                                    #
# b) Calculates the clearance by creating a best fit bounding box on the       #
#    Assembly outline.No need for Assembly outline to be a perfect rectangle   #
#    or shape.                                                                 #
#                                                                              #
#  Limitations:                                                                #
# a) Doesnt Support Circular boundaries.                                       #
# b) Computational intensive for big Boards with large number of components    #
# c) Clearance for rotated components would be incorrect.                      #
################################################################################
*/

axlCmdRegister("dfac" 'dfac)

procedure(dfac()
  _makeForm_dfa_assembly()
   axlFormDisplay(_DFA_Form)
); end procedure

;###########################################################
;#                                                         #
;#                FORM CREATION                            #
;#                                                         #
;###########################################################

(defun _makeForm_dfa_assembly ()
   _DFA_Form=outfile("./DFA_Form.form" "w")
   fprintf(_DFA_Form "FILE_TYPE=FORM_DEFN VERSION=2\n")
   fprintf(_DFA_Form "FORM\n")
   fprintf(_DFA_Form "FIXED\n")
   fprintf(_DFA_Form "PORT 65 15\n")
   fprintf(_DFA_Form "HEADER \"DFA Assembly Checks\" \n")
   fprintf(_DFA_Form "POPUP <PROPS_VALUE> \"ASSEMBLY_TOP\" \"ASSEMBLY_TOP\",\"ASSEMBLY_BOTTOM\" \"ASSEMBLY_BOTTOM\". \n")
   fprintf(_DFA_Form "TILE\n")

   fprintf(_DFA_Form "TEXT \"Select the Assembly Subclass:\"\n")
   fprintf(_DFA_Form "TLOC 8 2\n")
   fprintf(_DFA_Form "ENDTEXT\n")   

   fprintf(_DFA_Form "FIELD PROPS_VALUE\n")
   fprintf(_DFA_Form "FLOC 32 2\n")
   fprintf(_DFA_Form "ENUMSET 16 \n")
   fprintf(_DFA_Form "POP PROPS_VALUE\n")
   fprintf(_DFA_Form "ENDFIELD\n")   

   fprintf(_DFA_Form  "TEXT \"Minimum clearance value:\"\n")
   fprintf(_DFA_Form  "TLOC 8 5\n")
   fprintf(_DFA_Form  "ENDTEXT\n")   

   fprintf(_DFA_Form  "FIELD CLEARANCE\n")
   fprintf(_DFA_Form  "FLOC 32 5\n")
   fprintf(_DFA_Form "REALFILLIN 5 5\n")
   fprintf(_DFA_Form "DECIMAL 3 \n")
   fprintf(_DFA_Form  "ENDFIELD\n")   

   fprintf(_DFA_Form  "TEXT \"Design Units:\"\n")
   fprintf(_DFA_Form "TLOC 40 5\n")
   fprintf(_DFA_Form "ENDTEXT\n")

   fprintf(_DFA_Form "FIELD DESIGN_UNITS \n")
   fprintf(_DFA_Form "FLOC 52 5\n")
   fprintf(_DFA_Form "STRFILLIN 10 10\n")
   fprintf(_DFA_Form "INFO_ONLY \n")
   fprintf(_DFA_Form "ENDFIELD\n")
  
   fprintf(_DFA_Form  "TEXT \"Component1 Selection:\"\n")
   fprintf(_DFA_Form "TLOC 8 8\n")
   fprintf(_DFA_Form "ENDTEXT\n")   

   fprintf(_DFA_Form "FIELD COMP1\n")
   fprintf(_DFA_Form "FLOC 32 8\n")
   fprintf(_DFA_Form "STRFILLIN 20 20\n")
   fprintf(_DFA_Form "ENDFIELD\n")

   fprintf(_DFA_Form "FIELD COMP1_BR\n")
   fprintf(_DFA_Form "FLOC 55 8 \n")
   fprintf(_DFA_Form "MENUBUTTON \"Browse\" 10 3\n")
   fprintf(_DFA_Form "ENDFIELD\n")

   fprintf(_DFA_Form "TEXT \"Component2 Selection:\"\n")
   fprintf(_DFA_Form "TLOC 8 11\n")
   fprintf(_DFA_Form "ENDTEXT\n")   

   fprintf(_DFA_Form "FIELD COMP2\n")
   fprintf(_DFA_Form "FLOC 32 11\n")
   fprintf(_DFA_Form "STRFILLIN 20 20\n")
   fprintf(_DFA_Form "ENDFIELD\n")

   fprintf(_DFA_Form "FIELD COMP2_BR\n")
   fprintf(_DFA_Form "FLOC 55 11 \n")
   fprintf(_DFA_Form "MENUBUTTON \"Browse\" 10 3\n")
   fprintf(_DFA_Form "ENDFIELD\n")

   fprintf(_DFA_Form "FIELD RUN\n")
   fprintf(_DFA_Form "FLOC 8 15 \n")
   fprintf(_DFA_Form "MENUBUTTON \"Run\" 10 3\n")
   fprintf(_DFA_Form "ENDFIELD\n")

   fprintf(_DFA_Form "FIELD CLOSE\n")
   fprintf(_DFA_Form "FLOC 30 15\n")
   fprintf(_DFA_Form "MENUBUTTON \"Close\" 10 3\n")
   fprintf(_DFA_Form "ENDFIELD\n")

   fprintf(_DFA_Form "FIELD LOG\n")
   fprintf(_DFA_Form "FLOC 50 15\n")
   fprintf(_DFA_Form "MENUBUTTON \"ViewLog\" 10 3\n")
   fprintf(_DFA_Form "ENDFIELD\n")

   fprintf(_DFA_Form "ENDTILE\n")
   fprintf(_DFA_Form "ENDFORM\n")
   close(_DFA_Form)
   _DFA_Form = axlFormCreate( (gensym) "DFA_Form.form" '(e inner) 'DFA_clearance_Form_Action t)

); end defun  _makeForm_dfa_assembly

(defun DFA_clearance_Form_Action (myform)
        case( myform->curField
                ("PROPS_VALUE" 
                   prop_value = myform->curValue
                 )
                ("CLEARANCE"
                   grid_inc = myform->curValue
                   design_value = car(axlDBGetDesignUnits())
                   axlFormSetField(myform "DESIGN_UNITS" design_value)
                   axlFormSetField(myform "COMP1" "*")
                   axlFormSetField(myform "COMP2" "*")
                   (setq comp1 "*") (setq comp2 "*")
                 )
                ("COMP1" 
                   comp1 = myform->curValue
                 )
                ("COMP2"
                   comp2 = myform->curValue
                 )
                 ("DESIGN_UNITS" 
                      /* NOTHING TO DO */     
                 )
                 ("COMP1_BR"
                       comp1 = car(axlUIDataBrowse('REFDES '(EXAMINE_DATABASE RETRIEVE_NAME) "Select Refdes" t))
                       axlFormSetField(myform "COMP1" comp1)
                 )
                 ("COMP2_BR"
                       comp2 = car(axlUIDataBrowse('REFDES '(EXAMINE_DATABASE RETRIEVE_NAME) "Select Refdes" t))
                       axlFormSetField(myform "COMP2" comp2)
                 )
                ("RUN" 
                       dfa_check_log=axlDMOpenLog("dfa_assembly_check")
                       fprintf(dfa_check_log "\t DFA ASSEMBLY VIOLATIONS log.\n\n")
                       v_layer_index = store_layer_index() ; To preserve which layers are currently visible.
                       status = clrn(comp1 comp2 grid_inc prop_value dfa_check_log)
                       if(status !=0 then
                           sprintf(msg_test,"%L violations reported. Click Viewlog for Details\n", status)
                           axlUIConfirm(msg_test)
                       else
                           axlUIConfirm("No DFA Violations reported")
                          ) ; end if
                       (setq windowcount 0)
                        foreach(layer_v v_layer_index
                          axlVisibleLayer(layer_v t)
                               )
                        axlUIWUpdate(nil)
                 )
                 ("CLOSE"
                    axlFormClose(myform)
                    axlCancelEnterFun()
                    axlTempFileRemove("DFA_Form.form")
                 )
                 ("LOG"
                     unless(status>0
		            fprintf(dfa_check_log "No DFA Violations found.\n")
	                     );end unless
                     if(windowcount < 1 then
	                 fprintf(dfa_check_log "\n\tEnd of report.\n")
                       axlDMClose(dfa_check_log)
                       ) ; end if
                        logname = get_filename(dfa_check_log)
                        w_msg = axlUIViewFileCreate(logname "DFA VIOLATIONS Log" nil)
                        windowcount++  
                 )
             ) ; end case
); end defun


;###########################################################
;#                                                         #
;#                Main Program clrn                        #
;#                                                         #
;###########################################################

procedure( clrn(comp1 comp2 grid_inc prop_value dfa_check_log)
         prog( ( gn_dbid l_path_dbids nsegs_path ref_des symbol_dbid xy_loc refdes2 seg2 error_count refdes_c1 refdes_c2)
         bbox_table = makeTable("test_table" nil)
         bbox_set = makeTable("set_table" nil)
         seg_nsegs1 = refdes2 = nil
         axlVisibleDesign(nil)
         axlVisibleLayer(strcat("PACKAGE GEOMETRY/" prop_value) t)
         axlSetFindFilter(?enabled '(NOALL SHAPES LINES LINESEGS) ?onButtons '(SHAPES LINES LINESEGS)) 
         axlClearSelSet()
         axlAddSelectAll()
         l_paths=axlGetSelSet()
         axlClearSelSet()
         foreach( l_path_dbids l_paths
            unless(l_path_dbids->parent == nil
              case(l_path_dbids->objType
                    ("polygon"
                      cond(
                          (l_path_dbids->nSegs == 1     seg_nsegs1 = append(seg_nsegs1 list(l_path_dbids)) )
                          (l_path_dbids->isRect  && member(l_path_dbids->parent->refdes refdes2) == nil    
                                                        seg2 = append(seg2 list(l_path_dbids))
                                                        refdes2 = append(refdes2 list(l_path_dbids->parent->refdes)) )
                          )
                    )
                    ("path"
                      cond(
                          (l_path_dbids->nSegs == 1     seg_nsegs1 = append(seg_nsegs1 list(l_path_dbids))
                           )
                          (l_path_dbids->nSegs > 1      seg2 = append(seg2 list(l_path_dbids))     
                                                        unless(member(l_path_dbids->parent->refdes refdes2) != nil
                                                          refdes2 = append(refdes2 list(l_path_dbids->parent->refdes))
                                                               )
                          )
                          )
                    )
                   ("shape"
                          seg2 = append(seg2 list(l_path_dbids))
                          unless(member(l_path_dbids->parent->refdes refdes2) != nil
                                refdes2 = append(refdes2 list(l_path_dbids->parent->refdes))
                                )
                   )
                  ) ; end case 
                 ) ; end unless  
               ) ; end foreach
     

   ; Add only unique Refdes to the list and store their Dbids.
                      foreach(p_seg1 seg_nsegs1
                           seg2 = append(seg2 list(p_seg1))
                           unless(member(p_seg1->parent->refdes refdes2) != nil
                               refdes2 = append(refdes2 list(p_seg1->parent->refdes))
                                  ) ; end unless
                             ) ; end foreach

      bbox_table = assembly_bBox(seg2) ; Create Assembly Bounding Box.

      cond(
          (rexMatchp("^\\([A-Za-z][0-9]+\\)\\*" comp1)   comp1 = strcat(upperCase(rexSubstitute("\\1")) ".")  
                                                          refdes_c1 = rexMatchList(comp1 refdes2)    )
          (rexMatchp("\\([A-Za-z]+\\)\\*" comp1)                  comp1 = strcat(upperCase(rexSubstitute("\\1")) ".") 
                                                                  refdes_c1 = rexMatchList(comp1 refdes2)    )
          (comp1 == "*"                                   refdes_c1 = refdes2                        )
          (t                                             unless(member(comp1 refdes2) == nil
                                                            refdes_c1 = list(upperCase(comp1))  )               )
          )

      cond(
          (rexMatchp("^\\([A-Za-z][0-9]+\\)\\*" comp2)  comp2 = strcat(upperCase(rexSubstitute("\\1")) ".") 
                                                          refdes_c2 = rexMatchList(comp2 refdes2)    )
          (rexMatchp("\\([A-Za-z]+\\)\\*" comp2)          comp2 = strcat(upperCase(rexSubstitute("\\1")) ".") 
                                                          refdes_c2 = rexMatchList(comp2 refdes2)    )
          (comp2 == "*"                                   refdes_c2 = refdes2                        )
          (t                                             unless(member(comp2 refdes2) == nil
                                                            refdes_c2 = list(upperCase(comp2))  )               )
          )

          if( refdes_c1 == nil || refdes_c2 == nil then
                axlUIConfirm("Specified refdes for one of the Component selection not evaluated. Either its a circular geometry Or components dont belong to same Assembly Subclass")
          else
               bbox_set = set_bBox_Right(bbox_table) ; Set the bBox coordinates to Bottom-Left and Top-Right
               error_count = clearance_check(refdes_c1 refdes_c2 bbox_set grid_inc dfa_check_log seg2)
               return(error_count)
             ) ; end if

           ) ; end prog
); end proc

;###########################################################
;#                                                         #
;#             create_bBox Function                        #
;# Function creates a new Bounding box based on clearance  #
;###########################################################

(defun create_bBox (check grid_inc line_width1 line_width2)
    prog( ( key clear_bbox1 clear_bbox2)
      bbox_clear = makeTable("c_table" nil)
             key = check
                  clear_bbox1 = list((caar(bbox_set[ key ]) - grid_inc - line_width1/2 - line_width2/2)
                                     (cadar(bbox_set[ key ]) - grid_inc - line_width1/2 - line_width2/2))
                  clear_bbox2  = list((caadr(bbox_set[ key ]) + grid_inc + line_width1/2 + line_width2/2)
                                      (cadadr(bbox_set[ key ]) + grid_inc+ line_width1/2 + line_width2/2))
                  bbox_clear[ key ] = list(clear_bbox1 clear_bbox2)
                  return(bbox_clear)
       ) ; end prog
); end defun

;##########################################################################
;#                                                                        #
;#             assembly_bBox Function                                     #
;# Form the Bounding box for all the selected Dbids from the Assembly_top.#
;##########################################################################

(defun assembly_bBox (seg2)
    prog( ( assem_box key line_bBox1 line_bBox2 line_count refdes_list bbox_table bbox_set error_count dbid_multiple bbox_dbid temp_line temp_line1 bottom_left top_right assem_dup line_bBox refdes2 dbid_count)
     bbox_table = makeTable("a_table" nil)
     bbox_set = makeTable("s1_table" nil)
     line_bBox1 = line_bBox2 = refdes2 = temp = nil
     foreach(assem_box seg2
       dbid_multiple = nil
       unless(member(assem_box->parent->refdes refdes2) !=nil
       foreach(assem_dup seg2
            unless(assem_dup->parent->refdes != assem_box->parent->refdes
               dbid_multiple = append(dbid_multiple list(assem_dup))
                   ) ; end unless
             ) ; end foreach
        refdes2 = append(refdes2 list(assem_box->parent->refdes))
        line_bBox = nil temp_line = nil dbid_count = 0
        foreach(bbox_dbid dbid_multiple
        dbid_count++
        case(bbox_dbid->objType
         ("polygon"  
             bbox_table[bbox_dbid->parent->refdes] = bbox_dbid->bBox
             line_bBox = append(line_bBox list(bbox_dbid->bBox))
         )
         ("shape"
             bbox_table[bbox_dbid->parent->refdes] = bbox_dbid->bBox
             line_bBox = append(line_bBox list(bbox_dbid->bBox))
          )
         ("path"
            line_count = 0
            foreach(seg_box bbox_dbid->segments
            cond(
             (evenp(bbox_dbid->nSegs)
              if(bbox_dbid->nSegs == 2 then
              cond(
                (line_count == 0           line_bBox1 = car(seg_box->startEnd))
	          (line_count == (bbox_dbid->nSegs)-1 line_bBox2 = cadr(seg_box->startEnd) )
		      )
              else
              cond(
                (line_count == 0           line_bBox1 = cadr(seg_box->startEnd) )
		    (line_count == (bbox_dbid->nSegs)-1 line_bBox2 = car(seg_box->startEnd) ) 
                   )
                 ) ; end if
                ) 
              (oddp(bbox_dbid->nSegs)
               if(bbox_dbid->nSegs == 1 then
                 line_bBox1 = car(seg_box->startEnd)
		     line_bBox2 = cadr(seg_box->startEnd)
               else
              cond(
                (line_count == 0           line_bBox1 = car(seg_box->startEnd) temp = car(seg_box->startEnd)   )
                (line_count == (bbox_dbid->nSegs)-3           temp_seg3  = car(seg_box->startEnd) )
		    (line_count == (bbox_dbid->nSegs)-1 
                             if(axlDistance(temp cadr(seg_box->startEnd)) == 0.0 then
                                   line_bBox2 = temp_seg3
                             else  line_bBox2 = car(seg_box->startEnd)
                                ) ; end if
                 ) 
                   )
              ) ; end if
               )
             ) ; end cond
               line_count++
                 ) ; end foreach
               line_bBox = append(line_bBox list(list(line_bBox1 line_bBox2)))
               line_count = 0
             ) ; end path
            ); end case
             ) ;end foreach
          if(dbid_count == 1 then
                 bbox_table[assem_box->parent->refdes] = nth(0 line_bBox)
          else
           for( i 0 length(line_bBox)-1
             if(temp_line == nil then
                temp_line = set_bBox_point(nth(i line_bBox))
                bottom_left = car(temp_line)
                top_right = cadr(temp_line)
             else
                temp_line1 = set_bBox_point(nth(i line_bBox))
               unless(axlDistance(car(temp_line1) cadr(temp_line1)) == 0.0 
                if(caar(temp_line) <= caar(temp_line1) then
                   if(cadar(temp_line) <= cadar(temp_line1) then
                      bottom_left = car(temp_line)
                    else
                      bottom_left = list(caar(temp_line) cadar(temp_line1))
                     ) ; end if
                 else
                   if(cadar(temp_line) <= cadar(temp_line1) then
                      bottom_left = list(caar(temp_line1) cadar(temp_line))
                    else
                      bottom_left = list(caar(temp_line1) cadar(temp_line1))
                     ) ; end if
                    ) ; end if
                if(caadr(temp_line) > caadr(temp_line1) then
                   if(cadadr(temp_line) >= cadadr(temp_line1) then
                      top_right = cadr(temp_line)
                    else
                      cond(
                          (cadr(bottom_left) == cadadr(temp_line1) 
                                      top_right = list(caadr(temp_line) cadadr(temp_line))  )
                          (t          top_right = list(caadr(temp_line) cadadr(temp_line1)) )  
                          ) ; end cond
                     ) ; end if
                 else
                   if(cadadr(temp_line) > cadadr(temp_line1) then
                      cond(
                          (car(bottom_left) == caadr(temp_line1) 
                                   top_right = list(caadr(temp_line) cadadr(temp_line)) )
                          (t    top_right = list(caadr(temp_line1) cadadr(temp_line)))
                          ) ; end cond
                    else
                      cond(
                          (cadr(bottom_left) == cadadr(temp_line1) 
                                   top_right = list(caadr(temp_line1) cadadr(temp_line)) )
                          (t    top_right = list(caadr(temp_line1) cadadr(temp_line1)) )
                          ) ; end cond
                     ) ; end if
                    ) ; end if
                  ); end unless
                ) ; end if
                    temp_line = list(bottom_left top_right)
                 ); end for
                 bbox_table[assem_box->parent->refdes] = temp_line
            ) ; end if
                ) ; end unless
           ) ; end foreach
             return(bbox_table)
     ); end prog
) ; end defun

;##########################################################################
;#                                                                        #
;#             clearance_check Function                                   #
;# Checks whether any component is violating the clearance                #
;##########################################################################

(defun clearance_check (refdes_c1 refdes_c2 bbox_set grid_inc dfa_check_log seg2)
 prog( ( check key2 bbox_check bbox_clear duplicate1 duplicate2 error_count dbid_key dbid_key2 seg_refdes line_width1 line_width2)
       duplicate1 = nil
       error_count = line_width1 = line_width2 = 0
       bbox_clear = makeTable("c2_table" nil)
       foreach( key refdes_c1
             foreach(key2 refdes_c2
               duplicate2 = strcat(key2 key)
               unless(key2 == key
                if(member(duplicate2 duplicate1) == nil then
                   foreach(seg_refdes seg2
                         if( seg_refdes->parent->refdes == key then
                           unless(seg_refdes->objType != "path" 
                               line_width1 = car(seg_refdes->segments)->width
                                  ); end unless
                           ) ; end if
                         if( seg_refdes->parent->refdes == key2 then 
                             unless(seg_refdes->objType != "path"
                               line_width2 = car(seg_refdes->segments)->width
                                  ) ; end unless 
                           ) ; end if
                         ) ; end foreach
                 bbox_clear = create_bBox(key grid_inc line_width1 line_width2)
                 duplicate1 = append(duplicate1 list(strcat(key key2)))
                if(axlIsPointInsideBox(car(bbox_set[ key2 ]) bbox_clear[ key ]) ||
                   axlIsPointInsideBox(cadr(bbox_set[ key2 ]) bbox_clear[ key ]) ||
                   axlIsPointInsideBox(car(bbox_clear[ key ]) bbox_set[ key2 ]) ||
                   axlIsPointInsideBox(cadr(bbox_clear[ key ]) bbox_set[ key2 ]) then
                   dbid_key = car(axlDBCreateRectangle(bbox_set[ key ] nil "Package Geometry/Soldermask_Top"))
                   dbid_key2= car(axlDBCreateRectangle(bbox_set[ key2 ] nil "Package Geometry/Soldermask_Top"))
                   airgap = cadr(cdr(axlAirGap(dbid_key dbid_key2)))
                   airgap = airgap - (line_width1/2) - (line_width2/2)
                   unless( airgap >= grid_inc
                    fprintf(dfa_check_log "ERROR (DFA_clearance_audit):\n ")
                    fprintf(dfa_check_log "Violation reported between components %s and %s\n",key key2)
                    fprintf(dfa_check_log "Clearance between components  %L\n",airgap)
                    fprintf(dfa_check_log "Minimum clearance required : %L\n\n\n",grid_inc)
                    error_count++
                         ) ; end unless
                    axlDeleteObject(list(dbid_key dbid_key2))
                     line_width1 = line_width2 = 0
                   ) ; end if
                     ) ; end unless
                    ) ; end if
                    ) ; end foreach
           remove(key bbox_check)
               ); end foreach
     return(error_count)        
  ) ; end prog
) ; end defun

;##########################################################################
;#                                                                        #
;#             set_bBox_Right  Function                                   #
;# Sets the bBox to Bottom left and Top_Right for all keys of Association #
;# table                                                                  #
;##########################################################################

(defun set_bBox_Right (bbox_table)
 prog( ( key bottom_left top_right bbox_tmp bbox_set)
     bbox_tmp = makeTable("tmp_table" nil)
     bbox_set = makeTable("s_table" nil)
     bbox_tmp = bbox_table
     foreach( key bbox_tmp
        cond(
              (caar(bbox_tmp[ key ]) > caadr(bbox_tmp[ key ]) && cadar(bbox_tmp[ key ]) < cadadr(bbox_tmp[ key ]) 
                  bottom_left = list(caadr(bbox_tmp[ key ]) cadar(bbox_tmp[ key ]))
                  top_right   = list(caar(bbox_tmp[ key ])  cadadr(bbox_tmp[ key ]))
                  bbox_set[ key ] = list(bottom_left top_right)
              )
              (caar(bbox_tmp[ key ]) > caadr(bbox_tmp[ key ]) && cadar(bbox_tmp[ key ]) > cadadr(bbox_tmp[ key ])                 
                  bottom_left = list(caadr(bbox_tmp[ key ]) cadadr(bbox_tmp[ key ]))
                  top_right   = list(caar(bbox_tmp[ key ])  cadar(bbox_tmp[ key ]))
                  bbox_set[ key ] = list(bottom_left top_right)
              )
              (caar(bbox_tmp[ key ]) < caadr(bbox_tmp[ key ]) && cadar(bbox_tmp[ key ]) > cadadr(bbox_tmp[ key ])
                  bottom_left = list(caar(bbox_tmp[ key ]) cadadr(bbox_tmp[ key ]))
                  top_right   = list(caadr(bbox_tmp[ key ])  cadar(bbox_tmp[ key ]))
                  bbox_set[ key ] = list(bottom_left top_right)
              )
              (t
                  bbox_set[ key ] =  bbox_tmp[ key ] 
              )
            ) ; end cond
           ); end foreach
      return(bbox_set)
  ) ; end prog
); end defun

;##########################################################################
;#                                                                        #
;#             set_bBox_point  Function                                   #
;# Sets the bBox to Bottom left and Top_Right a given Dbid                #
;#                                                                        #
;##########################################################################

(defun set_bBox_point (bbox_point)
 prog( ( bottom_left top_right bbox_set)
        cond(
              (caar(bbox_point) > caadr(bbox_point) && cadar(bbox_point) < cadadr(bbox_point) 
                  bottom_left = list(caadr(bbox_point) cadar(bbox_point))
                  top_right   = list(caar(bbox_point)  cadadr(bbox_point))
                  bbox_set = list(bottom_left top_right)
              )
              (caar(bbox_point) > caadr(bbox_point) && cadar(bbox_point) > cadadr(bbox_point)                 
                  bottom_left = list(caadr(bbox_point) cadadr(bbox_point))
                  top_right   = list(caar(bbox_point)  cadar(bbox_point))
                  bbox_set = list(bottom_left top_right)
              )
              (caar(bbox_point) < caadr(bbox_point) && cadar(bbox_point) > cadadr(bbox_point)
                  bottom_left = list(caar(bbox_point) cadadr(bbox_point))
                  top_right   = list(caadr(bbox_point)  cadar(bbox_point))
                  bbox_set = list(bottom_left top_right)
              )
              (t
                  bbox_set =  bbox_point 
              )
            ) ; end cond
      return(bbox_set)
  ) ; end prog
); end defun

;##########################################################################
;#                                                                        #
;#             Find Layer visibility function                             #
;# Finds the currently visible layers in the design                       #
;#                                                                        #
;##########################################################################

(defun store_layer_index ()
 prog( ( dbid_layergp _active_layers test_layer v_layer_index)
            dbid_layergp = axlGetParam("paramLayerGroup")
            foreach(layergp dbid_layergp->groupMembers
               test_layer = strcat("paramLayerGroup:" layergp)
               dbid_layer= axlGetParam(test_layer)
                     foreach(_layers dbid_layer->groupMembers
                           _active_layers = strcat(layergp "/" _layers)
                            if(axlIsVisibleLayer(_active_layers) then
                                v_layer_index = append(list(_active_layers) v_layer_index)
                               ); end if
                             ) ; end foreach
                      ) ; end foreach
     return(v_layer_index)
        ) ; end prog
 ) ; end defun
                            

