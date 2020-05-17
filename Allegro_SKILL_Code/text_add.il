/*
################################################################################
#                                                                              #
#                      Command: add_text                                       #
#                   Skill File: text_add.il                                    #
#                  How To Load: Command> skill load("text_add.il")             #
#               How To Execute: Command> add_text                              #
#               References Sourcelink Solution: 11305790                       #
#                                                                              #
#                       Author: Jatin Sasan , Cadence Design Systems           #
#                        Email: jsasan@cadence.com                             #
#                Creation Date: Jan 28, 2007                                   #
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
#  01/28/2007:  This utility will add text for -                               #
#                   Number of Pads in Design                                   #
#                   Filename and Location                                      #
#                   Date and Time                                              #
#                   Last Modified Date and Time                                #
#                   Scale factor for print                                     #
#  Revision history:                                                           #
#	1.0 Original file		                           Jan 28, 2007          #
#                                                                              #
#  Advantages:                                                                 #
#  a)Once text variables are placed in the Brd, subsequent add_text run would  #
#    automatically update the variable values if they have changed             #
#  Limitations:                                                                #
# a) None                                                                      #
#                                                                              #
################################################################################
*/

axlCmdRegister("add_text" 'add_text)

(defun add_text ()
      (let (l_comps count myorient pads_xy filename_xy cdate_xy lastd_xy print_xy)
            pads_xy = filename_xy = cdate_xy = lastd_xy = print_xy = nil
            if(!axlIsVisibleLayer("PIN/TOP") || !axlIsVisibleLayer("PIN/BOTTOM") then
              axlVisibleLayer("PIN/TOP" t)
              axlVisibleLayer("PIN/BOTTOM" t)
              axlVisibleUpdate(nil)
               ) ; end if
            if(!axlIsLayer("MANUFACTURING/FABDWG_TEXT") then
                 axlLayerCreateNonConductor("MANUFACTURING/FABDWG_TEXT")
            else
                 layer_index = axlVisibleGet()
                 axlVisibleDesign(nil)  axlUIWUpdate(nil)
                 axlVisibleLayer("MANUFACTURING/FABDWG_TEXT" t)
                 axlSetFindFilter(?enabled list("NOALL" "TEXT") ?onButtons list("ALL"))
                 axlClearSelSet() axlAddSelectAll()
                 l_text = axlGetSelSet()
                 axlClearSelSet()
                 foreach(text_t l_text
                       if(rexMatchp("^Pads in Design.*$" text_t->text) then
                                                   pads_xy = text_t->xy)
                       if(rexMatchp("^Filename.*$" text_t->text) then
                                                   filename_xy = text_t->xy)
                       if(rexMatchp("^Current Date and Time.*$" text_t->text) then
                                                   cdate_xy = text_t->xy)
                       if(rexMatchp("^Last Modified Date and Time.*$" text_t->text) then
                                                   lastd_xy = text_t->xy)
                       if(rexMatchp("^Scale Factor for print.*$" text_t->text) then
                                                   print_xy = text_t->xy)
                       axlDeleteObject(text_t)
                         ) ; end foreach
                 axlVisibleSet(layer_index)
                 axlUIWUpdate(nil)
               ) ; end if
              (setq count 0)
              axlSetFindFilter(?enabled list("NOALL" "SYMBOLS") ?onButtons list("ALL"))
              axlClearSelSet() axlAddSelectAll()
              l_comps = axlGetSelSet()
              axlClearSelSet()
            foreach(comp_t l_comps
                  foreach(pad_count comp_t->pins
                     count++      ; Determines the Number of pads in the design.
                         ) ; end foreach
                  ) ; end foreach
             unless(pads_xy
                 pads_xy = axlEnterPoint(?prompts "Pick grid point to place text for number of pads in design")
                    ) ; end unless
                 myorient = make_axlTextOrientation(?textBlock "8", ?rotation 0.,
                                                    ?mirrored nil, ?justify "center")
                 axlDBCreateText(sprintf(nil "Pads in Design: %L" count), pads_xy,
                                                     myorient, "MANUFACTURING/FABDWG_TEXT", nil)
             unless(filename_xy
                 filename_xy = axlEnterPoint(?prompts "Pick grid point to place text for Brd filename and Path")
                    ) ; end unless
                 axlDBCreateText(sprintf(nil "Filename & Location: %s" axlGetDrawingName()),filename_xy,
                                                     myorient, "MANUFACTURING/FABDWG_TEXT", nil)
             unless(cdate_xy
                  cdate_xy = axlEnterPoint(?prompts "Pick grid point to place text for Current Date and Time")
                    ) ; end unless
                  axlDBCreateText(sprintf(nil "Current Date and Time: %s" getCurrentTime()), cdate_xy,
                                                myorient, "MANUFACTURING/FABDWG_TEXT", nil)
             unless(lastd_xy
                  lastd_xy = axlEnterPoint(?prompts "Pick grid point to place text for Last Modified Date and Time")
                    ) ; end unless
                  axlDBCreateText(sprintf(nil "Last Modified Date and Time: %s"
                                                timeToString(fileTimeModified(axlGetDrawingName()))), lastd_xy,
                                                myorient, "MANUFACTURING/FABDWG_TEXT", nil)
             unless(print_xy
                  scale_factor = axlEnterString(?prompts "Enter scale factor for print")
                  print_xy = axlEnterPoint(?prompts "Pick grid point to place text for print scale factor")
                    ) ; end unless
                  axlDBCreateText(sprintf(nil "Scale Factor for print: %s" scale_factor), print_xy,
                                                myorient, "MANUFACTURING/FABDWG_TEXT", nil)
         ) ; let
); end defun