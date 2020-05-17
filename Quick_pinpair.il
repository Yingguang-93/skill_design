/* 
├─ 
│ ├─        程序名称：Quick_pinpair.il
│ ├─        程序功能：快速创建选择BUS/CLASS对应的pin pair
│ ├─        创建时间：2014年10月31日 
│ ├─        作    者：kevin wong
│ ├─        Q      Q：263350809
├─ 


1，2014.10.31开始构建主函数思路；
2，2014.11.07完成初步功能，测试通过；
3，2014.12.31修改添加部分按钮，提示；

*/ 


axlCmdRegister( "quickpinpair" 'Quick_PinPair)
axlSetAlias("cpp" "quickpinpair")
   

   ; load("Quick_pinpair.il")



defun(Quick_PinPair ()
      let( (one allclass)
	  allclass = axlDBGetDesign()->netclass
	  alleleclass_name =  list()
      foreach(one allclass
	          if(one->electrical
			     then
				 alleleclass_name = cons(list(one->name one) alleleclass_name)
				 )
			  )
	  if(allbus = axlDBGetDesign()->bus
	     foreach(one allbus
		         alleleclass_name = cons(list(one->name one) alleleclass_name)
		         )
		 )
      Quick_pinpairform()	  
	  ))
	  

defun(Quick_pinpairform ()
        let( (curclass)
        Formfile = "./pinpairform.form"
		formport = outfile(Formfile "w")
		fprintf(formport "FILE_TYPE=FORM_DEFN VERSION=2\n")
        fprintf(formport "FORM\n") 
        fprintf(formport "FIXED\n")
		fprintf(formport "PORT 25 1\n")
        fprintf(formport "HEADER \"\264\264\275\250PinPair - kevin\"\n")
        fprintf(formport "TILE\n")   	
		
		fprintf(formport "\n")
		fprintf(formport "TEXT \"\307\353\321\241\324\361\322\324\317\302BUS/CLASS\"\n")
		fprintf(formport "TLOC 2 1\n")
		fprintf(formport "ENDTEXT\n")
				
		fprintf(formport "\n")
		fprintf(formport "TEXT \"\312\271\323\303\320\350\317\310\264\264\275\250BUS/CLASS\"\n")
		fprintf(formport "TLOC 2 2\n")
		fprintf(formport "ENDTEXT\n")
		
        x =2 
		y = 4
		foreach(curclass alleleclass_name
		         fieldname = car(curclass)
		fprintf( formport "FIELD %s\n" fieldname)
		fprintf( formport "FLOC %d %d\n" x y)
		fprintf( formport "CHECKLIST \" %s\"\n" fieldname)		
		fprintf( formport "ENDFIELD\n\n")
		y= y+2
		       )
			   
        fprintf(formport "FIELD sel\n")
        fprintf(formport "FLOC %d %d\n" x y)
        fprintf(formport "MENUBUTTON \"\310\253\321\241\" 10 2\n")
        fprintf(formport "ENDFIELD \n\n")	
		
        fprintf(formport "FIELD desel\n")
        fprintf(formport "FLOC %d %d\n" x+12 y)
        fprintf(formport "MENUBUTTON \"\310\241\317\373\" 10 2\n")
        fprintf(formport "ENDFIELD \n\n")

        fprintf(formport "FIELD create\n")
        fprintf(formport "FLOC %d %d\n" x y+2)
        fprintf(formport "MENUBUTTON \"\264\264\275\250\" 10 3\n")
        fprintf(formport "ENDFIELD \n\n")	
		
        fprintf(formport "FIELD cacel\n")
        fprintf(formport "FLOC %d %d\n" x+12 y+2)
        fprintf(formport "MENUBUTTON \"\315\313\263\366\" 10 3\n")
        fprintf(formport "ENDFIELD \n\n")
		

		fprintf(formport "ENDTILE\n")
        fprintf(formport "ENDFORM\n") 
        close(formport)
		
		displayform = axlFormCreate((gensym) Formfile '(ne inner) 'createpinpairact t)
		axlFormDisplay(displayform)
		
		foreach(curclass alleleclass_name
	            axlFormSetField(displayform car(curclass) t)
				)
;		axlUIWPrint(displayform "Kevin Wong") 
		deleteFile("pinpairform.form")
     )
	)
defun(createpinpairact (displayform)
	  let( (membersel curclass onecl one alldp2net)
	  allclass = axlDBGetDesign()->netclass
	  alleleclass_name =  list()
      foreach(one allclass
	          if(one->electrical
			     then
				 alleleclass_name = cons(list(one->name one) alleleclass_name)
				 )
			  )
	  if(allbus = axlDBGetDesign()->bus
	     foreach(one allbus
		         alleleclass_name = cons(list(one->name one) alleleclass_name)
		         )
		 )
	  
	  membersel = displayform->curField
      case(membersel
	       ("sel" 
		        foreach(curclass alleleclass_name
	            axlFormSetField(displayform car(curclass) t)
				axlUIWPrint(displayform "Select All") 
				)		   
		   )
		   ("desel"
		        foreach(curclass alleleclass_name
	            axlFormSetField(displayform car(curclass) nil)
				axlUIWPrint(displayform "Deselect All") 
				)		   
		   )
		   ("create"
		    axlUIWPrint(displayform "Create the pinpair of selected BUS/Class") 
		    foreach(onecl alleleclass_name
			    alldp2net = cadr(onecl)->groupMembers
				  foreach(one alldp2net
				          if(one->type == "DIFF_PAIR" 
						     alldp2net = append(remove(one alldp2net) one->groupMembers)
							 )
						  )
			
			       if(axlFormGetField(displayform car(onecl))
			        then
			         curMGname = strcat("MG_" car(onecl))
				     allpinslist = list()
				     foreach(one alldp2net   
				         allpinslist = append1(allpinslist axlPinsOfNet(one 'pin))
						 )

				 get_min_pinlist(allpinslist)  
				     if(length(result) == 1
					      then
						  axlUIConfirm(strcat("there is some thing wrong with the BUS/Class " car(onecl)))
					    else
						  if(length(result) == 2
						    then
						    get_main_pinlist()
							Creat_Match_Group()
							else
							if(length(result) >= 3
							then
							  choice = axlUIMultipleChoice("\307\353\321\241\324\361\322\273\270\366\306\367\274\376\327\367\316\252\324\274\312\370\306\360\265\343" 
							                       result strcat("\307\353\321\241\324\361_" car(onecl)))
							  maindev = nth(choice result)
						        get_main_pinlist()
							    Creat_Match_Group()							  
							  )
							
							)
						)
				 )
				 )
             axlUIWPrint(displayform "Create the pinpair successfully!")			 
			)
		   ("cacel"
		        axlUIWPrint(displayform "Exit")
                axlFormClose(displayform)
                deleteFile(Formfile)		   
		   )
		   
		   
	       ) 

		 ) )       
	  
		  

defun( get_min_pinlist (allpinslist) 
      let( (one mlist pin2netlist i j curlist okflag)
	   mlist = list()
	      foreach(one nth(0 allpinslist)
		          mlist= cons(one->component->name mlist)   ;list(U1 U2)
				  )	  
       result = mlist   
	   foreach(pin2netlist allpinslist
	             curlist = pin2netlist 
				 
				 i = 0
	            while( (i < length(mlist))
				    j = nth(i mlist)
                     okflag = 0	
					  foreach(one curlist  
							  if(j == one->component->name
							     okflag++
							     )
							  ) 
							  
				        if(okflag == 0
					       result = remove(j result)   
					       ) 
					  i++
					  )  
					  
			   )  
			 ))
	          
defun( get_main_pinlist ()	

     	let( (curcalcu pinid containflag)	
	 pinneedres = list()	
     foreach(curcalcu allpinslist
			curcalcu = car(allpinslist)
			allpinslist = remove(curcalcu allpinslist)
			  foreach(pinid curcalcu
					 containflag = 0
					  foreach(one result
					          if(pinid->component->name == one
							     containflag++
							    )
							  )
					     if(containflag == 0
					        curcalcu = remove(pinid curcalcu)	)	
					 )
              if(length(result)>=3
                 then			 
				 foreach(one curcalcu
				         if(one->component->name == maindev
						    
							curcalcu = cons(one remove(one curcalcu))
							)
						 )
			      pinneedres = append1(pinneedres curcalcu)
			      else	
			  
			      pinneedres = append1(pinneedres curcalcu)
			  )
			  )
	  ))

	  
	  
defun( Creat_Match_Group ()
      let( (lastpinlist onepinlist lastpins onespin onelist curpinpair ref one onepin)
	  lastpinlist = list()
	  foreach(onepinlist pinneedres
	              lastpins = list()
	              foreach(one onepinlist
	                      onespin = strcat(strcat(one->component->name ".") one->number)
						  lastpins = append1(lastpins onespin)
			             )
			   lastpinlist = cons(lastpins lastpinlist)
			  )
	  if(length(result) == 2
	     then
		 axlMatchGroupDelete(curMGname)
		 axlMatchGroupCreate(curMGname)
		 
		 foreach(onelist lastpinlist
		         curpinpair = axlPinPair(car(onelist) cadr(onelist))
				 axlMatchGroupAdd(curMGname curpinpair)
				 )
		 else   
		 if(length(result)>=3
		 then
		 groupneedsuf = remove(maindev result)
		 foreach(ref groupneedsuf
		         axlMatchGroupDelete(strcat(strcat(curMGname "_") ref))
		         axlMatchGroupCreate(strcat(strcat(curMGname "_") ref))
				 )  
				 
		 foreach(one lastpinlist  
		         pinpre = car(one)  
				 pinsuflist = cdr(one)
				 
				 foreach(onepin pinsuflist
						 curpinpair = axlPinPair(pinpre onepin)
						 car(parseString(onepin "."))
						 axlMatchGroupAdd(strcat(strcat(curMGname "_") car(parseString(onepin "."))) curpinpair)
						 )
				 )
		 
		 
		   )
		 )

	  ))
	
	




