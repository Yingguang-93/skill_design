/*
################################################################################
#                                                                              #
#                      Command: report3dl                                       #
#                   Skill File: 3d_length.il                                  #
#                                                                              #
#                                                                              #
#                       Author: Ming Chou, Tony, Huang			       #
#                               Cadence Design Systems, Taiwan                 #
#                        Email: thuang@cadence.com                             #
#                Creation Date: Rev. 0.2	Apr. 23, 2008                 #
#                                                                              #
#                                                                              #
#      This program will report 2d bonding wire to 3d length                #
#                                                                     #
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
/*
###########################################################
#  Function : report3dl1 ()
#  Descript : report cline branch by nets->->branches->children
#  Input    : none
#  Output   : file "skill/myreport1.txt"
#
#
###########################################################
*/

axlCmdRegister("report3dl" 'report3dl1)

defun(report3dl1 ()
ver=axlVersion('version)
myport=outfile("myreport1.txt")
fprintf(myport "\nRefdes")
fprintf(myport "\tpin num")
;fprintf(myport "\tnet name")
fprintf(myport "\t\t2d length")
fprintf(myport "\t\t3d length\n")
myd=axlDBGetDesign()
mycs=myd->components         ;mycs is a list of components
mydns=myd->nets              ;mydns is a list of net
foreach(mypn mydns           ;mypn is a net
mypnbs=mypn->branches        ;mypnbs is a list of branch
foreach(mypnb mypnbs
i=0                 ;mypnb is a branch of net
mypnbcs=mypnb->children
foreach(mypnbc mypnbcs                 ;mypnbcs is children of net branch
if(ver>15.7 then
	if(mypnbc->objType=="path" && mypnbc->layer=="CONDUCTOR/WIRE"  then        ;only print out path objType
	i=i+1
	my_seg=car(mypnbc->segments)
	foreach(myc1 mycs
	foreach(myp1 myc1->pins
	if(member(myp1->xy my_seg->startEnd) then     ;use coordinate to match pin number and pin name, doesn't make sense.
	mynumber=myp1->number
	myrefdes=myp1->component->name
	);if(member(myp->xy my_segg->startEnd) then
	);foreach(myp1 myc1->pins
	);foreach(myc1 mycs
	;fprintf(myport "\n%-9s" mypnbc->component->name)
	;fprintf(myport "\t%-9s" mypnbc->number)
	fprintf(myport "\n%-9s" myrefdes)
	fprintf(myport "%-9s" mynumber)
	;fprintf(myport "%-9s" mypn->name)
	;fprintf(myport "\t%L" my_seg->startEnd )
	fprintf(myport "\t%6.3f" p2p_d(my_seg->startEnd))
	fprintf(myport "\t\t%6.3f\n" Total3dl(my_seg->startEnd 80 30 350 200))
	);if(mypnbc->objType=="path" then
else
	if(mypnbc->objType=="path" && axlDBGetLayerType(mypnbc->layer)=="BONDING_WIRE"  then        ;only print out path objType
	i=i+1
	my_seg=car(mypnbc->segments)
	foreach(myc1 mycs
	foreach(myp1 myc1->pins
	if(member(myp1->xy my_seg->startEnd) then     ;use coordinate to match pin number and pin name, doesn't make sense.
	mynumber=myp1->number
	myrefdes=myp1->component->name
	);if(member(myp->xy my_segg->startEnd) then
	);foreach(myp1 myc1->pins
	);foreach(myc1 mycs
	;fprintf(myport "\n%-9s" mypnbc->component->name)
	;fprintf(myport "\t%-9s" mypnbc->number)
	fprintf(myport "\n%-9s" myrefdes)
	fprintf(myport "%-9s" mynumber)
	;fprintf(myport "%-9s" mypn->name)
	;fprintf(myport "\t%L" my_seg->startEnd )
	fprintf(myport "\t%6.3f" p2p_d(my_seg->startEnd))
	fprintf(myport "\t\t%6.3f\n" Total3dl(my_seg->startEnd 80 30 350 200))
	);if(mypnbc->objType=="path" then
)
);foreach(mypnbc mypnbcs
i=0
);foreach(mypnb mypnbs
;);if(mypn->nBranches==154 then
);foreach(mypn mydns
close(myport)
axlUIViewFileCreate("myreport1.txt" "Wirebonding with vertex" nil)
);defun(report3dl ()
/*
###########################################################
#  Function : Total3dl ()
#  Descript : This function will return total 3d length
#  Input    : startEnd list,alpha,beta,h1,h2
#
#  Output   : a number of 3d length
#
#
###########################################################
*/
defun(Total3dl (mystartEnd myalpha mybeta myh1 myh2)
let((d td x3 x4 y3 y4)
td=0
d=0
d=p2p_d(mystartEnd)
td=myh1*(1/sin(myalpha))
td=td+(d/8)
td=td+((d/2)*(1/cos(mybeta)))
x3=(d/8)+myh1*(1/tan(myalpha))
x4=myh1+myh2
y3=myh1+myh2
y4=(d/2)*tan(mybeta)
td=td+((x3-x4)**2+(y3-y4)**2)**0.5
td
);let((d td)
);defun(Total3dl (mypn1 alpha beta h1 h2)
/*
###########################################################
#  Function : p2p_d ()
#  Descript : This function will return total point to point length
#  Input    : bbox
#
#  Output   : a number of p2p distance
#
#
###########################################################
*/
defun(p2p_d (mystartEnd)
let((x1 y1 x2 y2 d)
if(mystartEnd!=nil then
x1=caar(mystartEnd)
y1=cadar(mystartEnd)
x2=caadr(mystartEnd)
y2=cadadr(mystartEnd)
d=((x1-x2)**2+(y1-y2)**2)**0.5
d
else
0
);if(mystartEnd!=nil then
);let(()
);defun(p2p_d (mystartEnd)

