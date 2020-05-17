/*******************************************************************
* DISCLAIMER: The following code is provided for Cadence customers *
* to use at their own risk. The code may require modification to   *
* satisfy the requirements of any user. The code and any           *
* modifications to the code may not be compatible with current or  *
* future versions of Cadence products.                             *
* THE CODE IS PROVIDED "AS IS" AND WITH NO WARRANTIES, INCLUDING   *
* WITHOUT LIMITATION ANY EXPRESS WARRANTIES OR IMPLIED WARRANTIES  *
* OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR USE.              *
*******************************************************************/
; File: rm_nc_via.il
;
;
; Usage: Load this file rm_nc_via.il
;  Issue the command rmv on the Allegro command line.
;
; This utility will select all vias in the design and step through
; the list deleting all vias that are not on a net.
;
;
;Author: Ron Guthrie
;	Cadence Design Systems
; Version 1.2
; Date: Dec 22,2005
;
/*Revision history:
	1.0 Original file		June 20, 2005
	1.1 modified to remove vias that have only a single connection to a shape
		to a shape.			Dec 15, 2005 rbg
	1.2 added log file output. Dec 22, 2005 rbg
	1.3 modified to ignore testpoint vias. Feb 13, 2006 rbg
*/
procedure( _rm_nc_vias()
	let(list(l_vias, via via_count rm_ncvia_count rm_1cvia_count l_nc_vias repfile)
	repfile=axlDMOpenLog("deleted_vias")
	fprintf(repfile "Coordinates of deleted vias\n\n")
	  l_nc_vias=list()
	  via_count=0
	  rm_ncvia_count=0
	  rm_1cvia_count=0
	  axlClearSelSet()
	  axlSetFindFilter(?enabled '(noall vias invisible) ?onButtons '(vias))
	  axlAddSelectAll()	;select all of the vias in the design
	  l_vias=axlGetSelSet()	;put the vias in a list
	  via_count=axlGetSelSetCount()
	  printf("%d vias found in the design.\n" via_count)
	  axlClearSelSet()
	  ;step through the via list looking for unconnected vias.
	  foreach(via l_vias
	  	unless(via->testPoint
	    if(via->net->name==nil then
	      ;found an unconnected via
	    	via_loc=via->xy
	    	axlDeleteObject(via)
	    	fprintf(repfile "%L\n", via_loc)
	     	rm_ncvia_count++		;increment the counter
	    else
	    	via_cons=axlDBGetConnect(via t)
	    	via_con_count=length(via_cons)
	    	if(via_con_count==1 then
	    		;delete the via if it only connects to a shape
	    		if(car(via_cons)->objType=="shape" then
	    			via_loc=via->xy
	    			axlDeleteObject(via)
	    			fprintf(repfile "%L\n", via_loc)
	    			rm_1cvia_count++	;increment the single connect via counter
	    		);endif
	    	);endif
	    );endif
	  	);end unless
	  );end foreach
	  printf("%d unconnected vias removed.\n" rm_ncvia_count)
	  printf("%d vias with one connection removed.\n" rm_1cvia_count)
	  fprintf(repfile "%d unconnected vias removed.\n" rm_ncvia_count)
	  fprintf(repfile "%d vias with one connection removed.\n" rm_1cvia_count)
	  axlDMClose(repfile)
	);end let
);end proc
axlCmdRegister("rmv" '_rm_nc_vias)