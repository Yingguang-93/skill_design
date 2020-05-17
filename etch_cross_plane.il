;load("etch_cross_plane.il")
;Revision:1.0
;Writen: WG2005
;date:2009-12-26
;功能查找走线跨平面
;可实现走线跨分割有两种方法，其一：判断线段某点是否在铜皮上。其二：判断线段的box内铜皮个数是否不等于1。走线如在平面上，他的box内铜皮个数应该是1，利用这个进行判断。
;本程序详细讲解利用第一种方法实现走线跨分割的查找。

axlCmdRegister("ecp" 'create_etch_cross_form ) ;定义执行此程序命令的名字为“ecp”

(defun create_etch_cross_form () ;创建面板

    FORMFILE = outfile("./c_e_c.form")  ;输出面板
    
    fprintf( FORMFILE "FILE_TYPE=FORM_DEFN VERSION=2\n")         ;面板固定格式
    fprintf( FORMFILE "FORM\n")                                  ;面板固定格式
    fprintf( FORMFILE "FIXED\n")                                 ;面板固定格式
    fprintf( FORMFILE "PORT 55 30\n")                        ;定义面板可视大小
    fprintf( FORMFILE "HEADER \"Check Etch Cross Plane\"\n") ;显示面板标题
    fprintf( FORMFILE "\n")     
    fprintf( FORMFILE "TILE\n")                            ;面板固定格式
    
    fprintf( FORMFILE "TEXT \"Select Etch Layer:\"blue_a \n") ;面板显示文字“Select Etch Layer” 并定义显示的颜色 如果去掉blue_a显示的是传统黑色
    fprintf( FORMFILE "TLOC  2 1\n")                          ;文字在面板上显示的X和Y坐标
    fprintf( FORMFILE "ENDTEXT\n\n")                          ;结束此段文字语句
    
    fprintf( FORMFILE "FIELD etch_list\n")         ;显示Etch Layer 名字表格 此“etch_list”将在后面程序中调用
    fprintf( FORMFILE "FLOC 2 3\n")                ;表格在面板上显示的X和Y坐标  
    fprintf( FORMFILE "LIST \"\" 20 8\n")          ;表格在面板上显示宽度和长度范围 
    fprintf( FORMFILE "ENDFIELD\n\n")              ;结束此段表格语句 
    
    fprintf( FORMFILE "TEXT \"Select Plane Layer:\"blue_b \n") ;显示文字“Select Plane Layer”
    fprintf( FORMFILE "TLOC  28 1\n")             ;内容同上，下如有内容意义同样不在描述
    fprintf( FORMFILE "ENDTEXT\n\n")  
    
    fprintf( FORMFILE "FIELD Plane_list\n")       ;显示Plane Layer 名字表格  
    fprintf( FORMFILE "FLOC 28 3\n")
    fprintf( FORMFILE "LIST \"\" 20 8\n")
    fprintf( FORMFILE "ENDFIELD\n\n")    
        
   fprintf( FORMFILE "GROUP \"Display Select Layer\"  \n")  ;显示一个框 标题为Display Select Layer
   fprintf( FORMFILE "GLOC 2 20\n")            ;显示框的X和Y坐标
   fprintf( FORMFILE "GSIZE 45 8\n")          ;显示框的宽度和长度范围  
   fprintf(  FORMFILE "ENDGROUP\n")  
   
   fprintf( FORMFILE "TEXT \"Etch Layer ->:\"blue_c \n") ;显示文字“Etch Layer ->:”
   fprintf( FORMFILE "TLOC  4 22\n")             
   fprintf( FORMFILE "ENDTEXT\n\n")  
    
    fprintf(FORMFILE "TEXT\n")        ;显示选中的ETCH 层名字
    fprintf(FORMFILE "TLOC 15 22\n")
    fprintf(FORMFILE "INFO s_e_layer 30\n")  
    fprintf(FORMFILE "FSIZE 30 2\n")  
    fprintf(FORMFILE "ENDTEXT\n")   
    
   fprintf( FORMFILE "TEXT \"Plane Layer ->:\"blue_d \n") ;显示文字“Plane Layer ->:”
   fprintf( FORMFILE "TLOC  4 25\n")             
   fprintf( FORMFILE "ENDTEXT\n\n") 
    
    fprintf(FORMFILE "TEXT\n")       ;显示选中的Plane 层名字
    fprintf(FORMFILE "TLOC 15 25\n")
    fprintf(FORMFILE "INFO s_p_layey 30\n")  
    fprintf(FORMFILE "FSIZE 30 2\n")  
    fprintf(FORMFILE "ENDTEXT\n")   
    
    
    
    fprintf( FORMFILE "FIELD sel_check\n")         ;Check按钮
    fprintf( FORMFILE "FLOC 10 32\n")
    fprintf( FORMFILE "MENUBUTTON \"Check\" 9 3\n")  ;显示Check 并定义按钮的长度和宽度
    fprintf( FORMFILE "ENDFIELD\n")
    
    fprintf( FORMFILE "FIELD exit\n")      ;退出按钮
    fprintf( FORMFILE "FLOC 32 32\n")
    fprintf( FORMFILE "MENUBUTTON \"Exit\" 9 3\n")  ;显示Exit
    fprintf( FORMFILE "ENDFIELD\n")
    
    fprintf( FORMFILE "\n")
    fprintf( FORMFILE "ENDTILE\n") ;结束TILE
    fprintf( FORMFILE "\n")
    fprintf( FORMFILE "ENDFORM\n")  ;结束FORM
    close( FORMFILE)                ;关闭FORMFILE
    form = (axlFormCreate (gensym) "c_e_c.form" `("E" "OUTER") `c_etch_Callback t)   ;创建窗口 并将程序带到下面c_etch_Callback中
    axlFormDisplay( form)       ;显示窗口
    
    select_layername()      ;调用下面提取PCB板层的名字程序
    
    axlFormColorize( form "blue_a" 'text 'blue) ;定义面板显示的文字用蓝色 根据个人习惯可以更改
    axlFormColorize( form "blue_b" 'text 'blue) 
    axlFormColorize( form "blue_c" 'text 'blue)
    axlFormColorize( form "blue_d" 'text 'blue)
    
    axlFormColorize( form "s_e_layer" 'text 'red)   ;定义面板选中的ETCH层用红色显示 
    axlFormColorize( form "s_p_layey" 'text 'red)   ;定义面板选中的PALNE层用红色显示     
    
    etchlist = "ETCH/TOP"      ;定义初始走线层为ETCH/TOP
    planelist = "ETCH/BOTTOM"  ;定义初始走线层为ETCH/BOTTOM         
    
    axlUIWPrint(form "Writen : WG2005      Revision : REV2.0     date : 2009-12-26") ;在面板窗体的下面显示一些信息
    
    deleteFile( "c_e_c.form")     ;删除面板文件
    
);defun


(defun c_etch_Callback (form)  ;连接上面指定的程序form = (axlFormCreate (gensym) "c_e_c.form" `("E" "OUTER") `c_anti_Callback t) 的“c_anti_Callback”
(prog ()        
   case( form->curField   ; C语言中也提到case用法，意义大致相同 中文不好表达意义，个人理想选择相匹配的执行     
              ("etch_list"       ;定义面板"etch_list"需要执行什么命令
                etchlist = form->curValue                            
                axlFormSetField( form "s_e_layer" etchlist)   ;如果选中etch_list里面一个层将显示到上面定义的s_e_layer中
                axlVisibleDesign(nil)           ;关闭所有层显示
                axlVisibleLayer( planelist t )  ;显示选中Plane层面
                axlVisibleLayer( etchlist t )   ;显示选中Etch层面
                axlVisibleUpdate(t)             ;刷新显示层                      
               t)     
              
              
               ("Plane_list"    ;定义面板"Plane_list"需要执行什么命令
                planelist = form->curValue                 
                axlFormSetField( form "s_p_layey" planelist)    ;如果选中planelist里面一个层将显示到上面定义的s_p_layey中
                axlVisibleDesign(nil)           ;关闭所有层显示            
                axlVisibleLayer( planelist t )  ;显示选中Plane层面
                axlVisibleLayer( etchlist t )   ;显示选中Etch层面
               axlVisibleUpdate(t)                 ;刷新显示层                 
                t) ;括号内大致意思是：Plane层名字 显示到上面定义的Plane_list中，如果选中etch_list一个层名将显示上面定义的s_p_layey中
                    
                
                ("sel_check"       ;面板Check对应的按钮命令
                  e_c_plane()      ;调用Check Cline 跨平面主程序                            
                t)             
                
                                       
              ("exit"              ;面板exit对应的按钮命令     
                  axlFormClose( form)    ;关闭面板窗口             
               t)
          
          
    );case
);prog
);defun

;下面程序将得到层名 
defun( select_layername ()  ;上面链接名字
prog( ()  
    etchparam = axlGetParam("paramLayerGroup:ETCH")     
    l_layers = etchparam->groupMembers   ;得到层名     如 ("TOP" "GND02" "POWER03" "BOTTOM")
    
    etchlist = nil   ;定义list为nil
    planelist = nil
    
    foreach(nlayer l_layers         ;将层的名字逐个循环，待后面进行判断是平面层还是走线层
      layerlista = strcat("ETCH/" nlayer )   ;由于上面得到的层名字是("TOP" "GND02" "POWER03" "BOTTOM") 所以通过strcat将"ETCH/"插入layerlista中变成   ("ETCH/TOP" "ETCH/GND02" "ETCH/POWER03" "ETCH/BOTTOM")
      
      when(axlDBGetLayerType(layerlista)=="PLANE"     ;利用when语法判断如果得到的层是PLANE属性的将层名字放到planelist中，必须在此程序前定义planelist = nil
        planelist = cons(layerlista planelist)        ;cons( item list )，将单个元素插入到列表的最前面成为列表的一个元素；
        );end when 结束when PLANE判断
        
      when(axlDBGetLayerType(layerlista)=="CONDUCTOR"     ;判断如果得到的层是CONDUCTOR属性的将层名字放到etchlist中，必须在此程序前定义etchlist = nil
       etchlist = cons(layerlista etchlist)
        ) ;end when 结束when CONDUCTOR判断      
      );foreach  结束foreach判断

      etchlist = reverse(etchlist)     ;reverse 将层名字反向排序，便于习惯看法，如果不加reverse也可以的，只是显示效果是("ETCH/BOTTOM" "ETCH/TOP")
      planelist = reverse(planelist)   ;显示效果是("ETCH/GND02" "ETCH/POWER03")
      
      axlFormSetField( form "etch_list" etchlist)       ;最终在面板窗口etch_list栏里面显示所有走线层名字
      axlFormSetField( form "Plane_list" planelist)     ;在面板窗口Plane_list栏里面显示所有平面层名字 
          
  );prog
);defun


;执行走线跨平面主程序
(defun e_c_plane ()
(prog ()
  
  axlSetFindFilter(?enabled '(noall clinesegs) ?onButtons '(noall clinesegs))  ;定义Find面板中 clinesegs 勾选上，对clinesegs进行操作  
  
  clines_a = axlGetSelSet(axlAddSelectAll())  ;指定clines_a = “获得选择对象”
  
  axlSetFindFilter(?enabled '(noall shapes) ?onButtons '(noall shapes))  ;定义Find面板中 Shape 
  
  shape_a = axlGetSelSet(axlAddSelectAll())  ;指定shape_a = “获得选择对象”
  
  axlClearSelSet() ;清除所选择的对象 养成良好习惯 避免误操作
  
  axlHighlightObject(clines_a) ;高亮所有走线 程序用了反高亮法
   
   foreach( Cline clines_a  ;逐个循环判断每段走线   
   
     Clinc_xy = Cline->startEnd  ;获得每段Cline的起始和终点坐标 如得到 Clinc_xy =("2009.12 2010.26" "2010.10 2010.26") 
         
     c_xy_a = car(Clinc_xy)   ;获得每段Cline起始坐标 如c_xy_a = （"2009.12 2010.26"） 
          
     c_xy_b = cadr(Clinc_xy)  ;获得每段Cline的终点坐标 如c_xy_b = （"2010.10 2010.26"）     
       
       foreach( shape shape_a  ;逐个循环每块铜皮  
             
          if(axlGeoPointInShape( c_xy_b shape)  && axlGeoPointInShape( c_xy_a shape)   ;判断shape上面得到的起始和终点坐标是否有走线 
          
               then  ;如果上面的假设成立 将执行下面命令
               
                 axlDehighlightObject(Cline)      ;如果上面的假设成立 将执行去亮所有走线  ；那么剩下高亮的部分就是跨分割的走线
                   
             );end if(axlGeoPointInShape( c_xy_b shape)  结束if的判断
             
           );end foreach( Shape shape_a      结束foreac的循环
 
          );end foreach( Cline clines_a
);prog  
);defun ；程序结束 上面的解释可能不是佷完全，如果能给您带来一点点的帮助，记住帮忙顶一下，多谢！



