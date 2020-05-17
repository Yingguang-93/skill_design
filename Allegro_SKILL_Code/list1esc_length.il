/*
################################################################################
#                                                                              #
#                      Command: list1esc                                       #
#                   Skill File: list1esc_length.il                                 #
#                                                                              #
#                                                                              #
#                       Author: Ming Chou, Tony, Huang			       #
#                               Cadence Design Systems, Taiwan                 #
#                        Email: thuang@cadence.com                             #
#                Creation Date: Rev. 1.0	Nov. 8, 2005                #
#                                                                              #
#                                                                              #
#      This program will list the net first pin escape cline length.           #
#                                                                              #
################################################################################


################################################################################
#  DISCLAIMER:                                                                 #
#       The user of this command assumes all responsibility and does not       #
#       hold Cadence Design Systems nor the author of this code for any        #
#       unwarranted results or problems due to the use of this code.           #
#                                                                              #
#       This is non-supported code and the user may modify it as needed.       #
#                                                                              #
################################################################################
*/
axlCmdRegister("list1esc" 'list_net_1_esc_length)
/*
###########################################################
#  Function : list_net_1_esc_length ()
#  Descript : This function will report 1st pin escape length by net name
#  Input    : 
#                    
#  Output   : a report for 1st pin escape cline length
#
#
###########################################################
*/
defun(list_net_1_esc_length ()
let( (my_seg_len my_seg myrefdes mynumber)
myport=outfile("myreport1.txt")
fprintf(myport "\nRefdes")
fprintf(myport "\tpin num")
fprintf(myport "\t\tnet name")
fprintf(myport "\t1st pin ESC length\n")
myd=axlDBGetDesign()
mycs=myd->components         ;mycs is a list of components
mydns=myd->nets              ;mydns is a list of net
foreach(mypn mydns           ;mypn is a net
mypnbs=mypn->branches        ;mypnbs is a list of branch
foreach(mypnb mypnbs         ;mypnb is a branch of net
i=0                 
mypnbcs=mypnb->children
foreach(mypnbc mypnbcs                 ;mypnbcs is children of net branch
if(mypnbc->objType=="pin" then        ;only print out path objType
i=i+1
foreach(mypnbc1 mypnbcs                 ;mypnbcs is children of net branch
if(mypnbc1->objType=="path" then
mysegs=mypnbc1->segments
foreach(myseg1 mysegs
if( member(mypnbc->xy myseg1->startEnd) then 
my_seg_len=sum_segs_len(mypnbc1->segments)
my_seg=car(mypnbc1->segments)
myp2=mypnbc->xy
foreach(myc1 mycs
foreach(myp1 myc1->pins
if(myp1 == mypnbc then    
mynumber=myp1->number
myrefdes=myp1->component->name
);if(member(myp1->xy my_seg->startEnd) then
);foreach(myp1 myc1->pins
);foreach(myc1 mycs
);if( member(mypnbc->xy myseg1->startEnd) then 
);foreach(myseg1 mysegs
);if(mypnbc1->objType=="path" then
);foreach(mypnbc1 mypnbcs                 ;mypnbcs is children of net branch
fprintf(myport "\n%-9s" myrefdes)
fprintf(myport "%-9s" mynumber)
fprintf(myport "\t%-9s" mypn->name)
fprintf(myport "\t%6.3f\n" my_seg_len)
fprintf(myport "\t%L\n" myp2 )
);if(mypnbc->objType=="pin" then
);foreach(mypnbc mypnbcs
i=0
);foreach(mypnb mypnbs
;);if(mypn->nBranches==154 then
);foreach(mypn mydns
close(myport)
axlUIViewFileCreate("myreport1.txt" "Wirebonding with vertex" nil)
);let( (my_seg_len my_seg)
);defun(list_net_1_esc_length ()

/*
###########################################################
#  Function : p2p_d ()
#  Descript : This function will return dist of two point
#  Input    : p1 p2
#                    
#  Output   : a number of p2p distance
#
#
###########################################################
*/
defun(p2p_d (p1 p2)
let((x1 x2 y1 y2 deltax deltay len)
				x1 = xCoord(p1)
			        x2 = xCoord(p2)
			        y1 = yCoord(p1)
			        y2 = yCoord(p2)
			        deltax=abs(x2-x1)
			        deltay=abs(y2-y1)
			        len=sqrt((deltax*deltax)+(deltay*deltay))
			        len
);let()
);defun(p2p_d (p1 p2)
/*
###########################################################
#  Function : sum_segs_len ()
#  Descript : This function will return total length of segments
#  Input    : bbox
#                    
#  Output   : a number of p2p distance
#
#
###########################################################
*/
defun(sum_segs_len (myseg)
let((dist rad len x1 x2 y1 y2 deltax deltay cos_theta rad_sq len_sq)
dist=0
			      foreach(oneseg myseg
			        rad=oneseg->radius
			        len=p2p_d(car(oneseg->startEnd) cadr(oneseg->startEnd))
				  ;if radius is not nil, then it's an arc and need to calculate
				  ;the length for the arc.
			        if(rad!=nil then
			          rad_sq=rad*rad
			          len_sq=len*len
			          cos_theta=(2*rad_sq-len_sq)/(2*rad_sq)
			          theta=acos(cos_theta)
			          len=theta*rad
			        );endif(rad!=nil	
			        dist=dist+len
			      );end foreach(oneseg segs
dist
);let((dist rad len x1 x2 y1 y2 deltax deltay cos_theta rad_sq len_sq)
);defun(sum_segs_len (myseg)