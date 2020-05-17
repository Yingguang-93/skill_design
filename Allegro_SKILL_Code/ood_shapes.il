
;  DISCLAIMER:
;       The user of this command assumes all responsibility and does not
;       hold Cadence Design Systems nor the author of this code for any
;       unwarranted results or problems due to the use of this code.
;
;       This code is unsupported!

; Date Created: March 1, 2004
; Tested with Allegro Release:  15.1, 15.2, 15.5
; Name of this file: ood_shapes.il
; Written by Ron Guthrie (rong@cadence.com)
;
; Updated:
;	Feb. 07, 2005
;  Included code to report shapes that may be unfilled and are not marked as out of date.
;
;	August 12, 2005
;	Modified to handle shapes not on a net.
;
; Usage:
; To use this file load it from the APD/Allegro command line and then issue the command
;  ood shape
;
/*
Notes:

This code is intended as an example of how to report on shapes that are marked as being
out of date based on the fillOOD attribute attached to the shape.
No attempts have been made for error checking so this code may fail to run on some designs
if an error condition occurs.
This utility will also report what it considers to be suspect shapes. These are shapes that have a
fillOOD attribute of nil as well as no voids and the shapeAuto attribute equal to nil
*/

procedure( RBG_out_of_date()
let( (ood_shape l_all_shapes shape ood_shapexy ood_shape_cnt)
	axlSetFindFilter(?enabled '(noall shapes invisible) ?onButtons '(noall shapes))
	axlClearSelSet()
	axlAddSelectAll()
	ood_shape=list()
	ood_shape_cnt=0
	suspect_shape=list()
	suspect_shape_cnt=0
	l_all_shapes=axlGetSelSet()
	axlClearSelSet()
	ood_log=axlDMOpenLog("ood_shape")
	fprintf(ood_log "\tOut of date Shape log.\n\n")
	foreach(shape l_all_shapes
		if(car(parseString(shape->layer "/"))=="BOUNDARY" then
			if(shape->fillOOD then
				axlHighlightObject(shape)
				ood_shape_cnt++
				ood_shapexy=shape->bBox
				ood_shapenet=shape->net->name
				unless(ood_shapenet
					ood_shapenet="Not on a net"
				);unless ood_shapenet
				if(ood_shapenet=="" then
					ood_shapenet="Dummy net"
				);if ood_shapenet
				ood_shapelayer=shape->layer
				fprintf(ood_log "Layer=%s\tNet: %s Bounding box: %L\n" ood_shapelayer ood_shapenet ood_shapexy)
				ood_shape=cons(shape ood_shape)
			else
				unless(shape->shapeAuto
					unless(shape->voids
						;suspect shape is not out of date but
						;has no voids and shapeAuto attribute is nil
						suspect_shape_cnt++
						suspect_shapexy=shape->bBox
						suspect_shapenet=shape->net->name
						suspect_shapelayer=shape->layer
						fprintf(ood_log "Possible shape problem on net %s at %L\n" suspect_shapenet suspect_shapexy)
						fprintf(ood_log "\tClass/subclass: %s\n\n" suspect_shapelayer)
					);end unless voids
				);end unless shapeAuto
			);endif shape->fillOOD
		);endif car(parseString
	);foreach shape
	unless(ood_shape_cnt>0
		fprintf(ood_log "No out of date shapes.\n")
	);end unless
	fprintf(ood_log "\n\tEnd of report.\n")
	axlDMClose(ood_log)
	if(ood_shape_cnt==1 then
		axlWindowBoxSet(ood_shapexy)
		axlVisibleLayer(ood_shapelayer t)
	);endif
	if(ood_shape_cnt==0&&suspect_shape_cnt==1 then
		axlWindowBoxSet(suspect_shapexy)
		axlVisibleLayer(suspect_shapelayer t)
	);endif

	axlUIViewFileCreate("ood_shape.log" "Out of Date Shapes Log" nil)
);endlet
);endproc


axlCmdRegister("ood shape" 'RBG_out_of_date ?cmdType "interactive")