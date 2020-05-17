
;  DISCLAIMER:
;       The user of this command assumes all responsibility and does not
;       hold Cadence Design Systems nor the author of this code for any
;       unwarranted results or problems due to the use of this code.
;
;       This code is unsupported!

; Date Created: April 26, 2005
; Tested with Allegro Release:  15.2
; Name of this file: del_ood_shapes.il
; Written by Ron Guthrie (rong@cadence.com)
;
; Modified ood_shape.il to delete out of date shapes instead of just reporting them
;
; 
;
; Usage:
; To use this file load it from the APD/Allegro command line and then issue the command
;  del ood_shape
;
/* This code is intended to report on shapes that are marked as being out of date based
on the fillOOD attribute attached to the shape. It will then delete the shape.
It will also report what it considers to be suspect shapes. These are shapes that have a
fillOOD attribute of nil as well as no voids and the shapeAuto attribute equal to nil */

procedure( RBG_del_out_of_date()
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
	ood_log=axlDMOpenLog("del_ood_shape")
	fprintf(ood_log "\tDeleted out of date shapes log.\n\n")
	foreach(shape l_all_shapes
		if(car(parseString(shape->layer "/"))=="BOUNDARY" then
			if(shape->fillOOD then
				axlHighlightObject(shape)
				ood_shape_cnt++
				ood_shapexy=shape->bBox
				ood_shapenet=shape->net->name
				ood_shapelayer=shape->layer
				fprintf(ood_log "%n Deleted out of date shape on net %s at %L\n", 
						ood_shape_cnt ood_shapenet ood_shapexy)
				fprintf(ood_log "\tClass/subclass: %s\n\n" ood_shapelayer)
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
					);unless
				);unless
			);if
		);endif
	);foreach
	
	unless(ood_shape_cnt>0
		fprintf(ood_log "No out of date shapes.\n")
	);end unless
	fprintf(ood_log "\t%d out of date shapes deleted.\n", ood_shape_cnt)
	fprintf(ood_log "\tEnd of report.\n")
	axlDMClose(ood_log)
	if(ood_shape_cnt==1 then
		axlWindowBoxSet(ood_shapexy)
		axlVisibleLayer(ood_shapelayer t)
	);endif
	if(ood_shape_cnt==0&&suspect_shape_cnt==1 then
		axlWindowBoxSet(suspect_shapexy)
		axlVisibleLayer(suspect_shapelayer t)
	);endif
	printf("Out of date shapes deleted.\n")
	axlDeleteObject(ood_shape)
	
	axlUIViewFileCreate("del_ood_shape.log" "Out of Date Shapes Log" nil)
);endlet
);endproc


axlCmdRegister("del ood_shape" 'RBG_del_out_of_date ?cmdType "interactive")