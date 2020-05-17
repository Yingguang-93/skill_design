/*
DISCLAIMER:
      The user of this code assumes all responsibility and does not
      hold Cadence Design Systems nor the author of this code for any
      unwarranted results or problems due to the use of this code.

      This code is unsupported!

Date Created: Oct 13, 2004
Tested with Allegro Release:  15.2
Name of this file: nclegend_list.il
Written by Ron Guthrie (rong@cadence.com)

This code snippet is intended to show how to get a list of the drill
legend subclasses. Once the user has the list of subclasses they can
set the visibility etc.
Once this function is run the list l_legends will contain the legend subclasses
*/

defun(rbg_legend_layers ()
 l_legends=list()
 mfg_layer=axlGetParam("paramLayerGroup:MANUFACTURING")->groupMembers
 foreach(subclass mfg_layer
    rexCompile("NCLEGEND-")
    if(rexExecute(subclass) then
       l_legends=cons(subclass l_legends)
    );end-if
 );end-foreach
);end-defun
