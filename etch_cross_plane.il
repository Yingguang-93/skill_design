;load("etch_cross_plane.il")
;Revision:1.0
;Writen: WG2005
;date:2009-12-26
;���ܲ������߿�ƽ��
;��ʵ�����߿�ָ������ַ�������һ���ж��߶�ĳ���Ƿ���ͭƤ�ϡ�������ж��߶ε�box��ͭƤ�����Ƿ񲻵���1����������ƽ���ϣ�����box��ͭƤ����Ӧ����1��������������жϡ�
;��������ϸ�������õ�һ�ַ���ʵ�����߿�ָ�Ĳ��ҡ�

axlCmdRegister("ecp" 'create_etch_cross_form ) ;����ִ�д˳������������Ϊ��ecp��

(defun create_etch_cross_form () ;�������

    FORMFILE = outfile("./c_e_c.form")  ;������
    
    fprintf( FORMFILE "FILE_TYPE=FORM_DEFN VERSION=2\n")         ;���̶���ʽ
    fprintf( FORMFILE "FORM\n")                                  ;���̶���ʽ
    fprintf( FORMFILE "FIXED\n")                                 ;���̶���ʽ
    fprintf( FORMFILE "PORT 55 30\n")                        ;���������Ӵ�С
    fprintf( FORMFILE "HEADER \"Check Etch Cross Plane\"\n") ;��ʾ������
    fprintf( FORMFILE "\n")     
    fprintf( FORMFILE "TILE\n")                            ;���̶���ʽ
    
    fprintf( FORMFILE "TEXT \"Select Etch Layer:\"blue_a \n") ;�����ʾ���֡�Select Etch Layer�� ��������ʾ����ɫ ���ȥ��blue_a��ʾ���Ǵ�ͳ��ɫ
    fprintf( FORMFILE "TLOC  2 1\n")                          ;�������������ʾ��X��Y����
    fprintf( FORMFILE "ENDTEXT\n\n")                          ;�����˶��������
    
    fprintf( FORMFILE "FIELD etch_list\n")         ;��ʾEtch Layer ���ֱ��� �ˡ�etch_list�����ں�������е���
    fprintf( FORMFILE "FLOC 2 3\n")                ;�������������ʾ��X��Y����  
    fprintf( FORMFILE "LIST \"\" 20 8\n")          ;�������������ʾ���Ⱥͳ��ȷ�Χ 
    fprintf( FORMFILE "ENDFIELD\n\n")              ;�����˶α������ 
    
    fprintf( FORMFILE "TEXT \"Select Plane Layer:\"blue_b \n") ;��ʾ���֡�Select Plane Layer��
    fprintf( FORMFILE "TLOC  28 1\n")             ;����ͬ�ϣ���������������ͬ����������
    fprintf( FORMFILE "ENDTEXT\n\n")  
    
    fprintf( FORMFILE "FIELD Plane_list\n")       ;��ʾPlane Layer ���ֱ���  
    fprintf( FORMFILE "FLOC 28 3\n")
    fprintf( FORMFILE "LIST \"\" 20 8\n")
    fprintf( FORMFILE "ENDFIELD\n\n")    
        
   fprintf( FORMFILE "GROUP \"Display Select Layer\"  \n")  ;��ʾһ���� ����ΪDisplay Select Layer
   fprintf( FORMFILE "GLOC 2 20\n")            ;��ʾ���X��Y����
   fprintf( FORMFILE "GSIZE 45 8\n")          ;��ʾ��Ŀ��Ⱥͳ��ȷ�Χ  
   fprintf(  FORMFILE "ENDGROUP\n")  
   
   fprintf( FORMFILE "TEXT \"Etch Layer ->:\"blue_c \n") ;��ʾ���֡�Etch Layer ->:��
   fprintf( FORMFILE "TLOC  4 22\n")             
   fprintf( FORMFILE "ENDTEXT\n\n")  
    
    fprintf(FORMFILE "TEXT\n")        ;��ʾѡ�е�ETCH ������
    fprintf(FORMFILE "TLOC 15 22\n")
    fprintf(FORMFILE "INFO s_e_layer 30\n")  
    fprintf(FORMFILE "FSIZE 30 2\n")  
    fprintf(FORMFILE "ENDTEXT\n")   
    
   fprintf( FORMFILE "TEXT \"Plane Layer ->:\"blue_d \n") ;��ʾ���֡�Plane Layer ->:��
   fprintf( FORMFILE "TLOC  4 25\n")             
   fprintf( FORMFILE "ENDTEXT\n\n") 
    
    fprintf(FORMFILE "TEXT\n")       ;��ʾѡ�е�Plane ������
    fprintf(FORMFILE "TLOC 15 25\n")
    fprintf(FORMFILE "INFO s_p_layey 30\n")  
    fprintf(FORMFILE "FSIZE 30 2\n")  
    fprintf(FORMFILE "ENDTEXT\n")   
    
    
    
    fprintf( FORMFILE "FIELD sel_check\n")         ;Check��ť
    fprintf( FORMFILE "FLOC 10 32\n")
    fprintf( FORMFILE "MENUBUTTON \"Check\" 9 3\n")  ;��ʾCheck �����尴ť�ĳ��ȺͿ���
    fprintf( FORMFILE "ENDFIELD\n")
    
    fprintf( FORMFILE "FIELD exit\n")      ;�˳���ť
    fprintf( FORMFILE "FLOC 32 32\n")
    fprintf( FORMFILE "MENUBUTTON \"Exit\" 9 3\n")  ;��ʾExit
    fprintf( FORMFILE "ENDFIELD\n")
    
    fprintf( FORMFILE "\n")
    fprintf( FORMFILE "ENDTILE\n") ;����TILE
    fprintf( FORMFILE "\n")
    fprintf( FORMFILE "ENDFORM\n")  ;����FORM
    close( FORMFILE)                ;�ر�FORMFILE
    form = (axlFormCreate (gensym) "c_e_c.form" `("E" "OUTER") `c_etch_Callback t)   ;�������� ���������������c_etch_Callback��
    axlFormDisplay( form)       ;��ʾ����
    
    select_layername()      ;����������ȡPCB�������ֳ���
    
    axlFormColorize( form "blue_a" 'text 'blue) ;���������ʾ����������ɫ ���ݸ���ϰ�߿��Ը���
    axlFormColorize( form "blue_b" 'text 'blue) 
    axlFormColorize( form "blue_c" 'text 'blue)
    axlFormColorize( form "blue_d" 'text 'blue)
    
    axlFormColorize( form "s_e_layer" 'text 'red)   ;�������ѡ�е�ETCH���ú�ɫ��ʾ 
    axlFormColorize( form "s_p_layey" 'text 'red)   ;�������ѡ�е�PALNE���ú�ɫ��ʾ     
    
    etchlist = "ETCH/TOP"      ;�����ʼ���߲�ΪETCH/TOP
    planelist = "ETCH/BOTTOM"  ;�����ʼ���߲�ΪETCH/BOTTOM         
    
    axlUIWPrint(form "Writen : WG2005      Revision : REV2.0     date : 2009-12-26") ;����崰���������ʾһЩ��Ϣ
    
    deleteFile( "c_e_c.form")     ;ɾ������ļ�
    
);defun


(defun c_etch_Callback (form)  ;��������ָ���ĳ���form = (axlFormCreate (gensym) "c_e_c.form" `("E" "OUTER") `c_anti_Callback t) �ġ�c_anti_Callback��
(prog ()        
   case( form->curField   ; C������Ҳ�ᵽcase�÷������������ͬ ���Ĳ��ñ������壬��������ѡ����ƥ���ִ��     
              ("etch_list"       ;�������"etch_list"��Ҫִ��ʲô����
                etchlist = form->curValue                            
                axlFormSetField( form "s_e_layer" etchlist)   ;���ѡ��etch_list����һ���㽫��ʾ�����涨���s_e_layer��
                axlVisibleDesign(nil)           ;�ر����в���ʾ
                axlVisibleLayer( planelist t )  ;��ʾѡ��Plane����
                axlVisibleLayer( etchlist t )   ;��ʾѡ��Etch����
                axlVisibleUpdate(t)             ;ˢ����ʾ��                      
               t)     
              
              
               ("Plane_list"    ;�������"Plane_list"��Ҫִ��ʲô����
                planelist = form->curValue                 
                axlFormSetField( form "s_p_layey" planelist)    ;���ѡ��planelist����һ���㽫��ʾ�����涨���s_p_layey��
                axlVisibleDesign(nil)           ;�ر����в���ʾ            
                axlVisibleLayer( planelist t )  ;��ʾѡ��Plane����
                axlVisibleLayer( etchlist t )   ;��ʾѡ��Etch����
               axlVisibleUpdate(t)                 ;ˢ����ʾ��                 
                t) ;�����ڴ�����˼�ǣ�Plane������ ��ʾ�����涨���Plane_list�У����ѡ��etch_listһ����������ʾ���涨���s_p_layey��
                    
                
                ("sel_check"       ;���Check��Ӧ�İ�ť����
                  e_c_plane()      ;����Check Cline ��ƽ��������                            
                t)             
                
                                       
              ("exit"              ;���exit��Ӧ�İ�ť����     
                  axlFormClose( form)    ;�ر���崰��             
               t)
          
          
    );case
);prog
);defun

;������򽫵õ����� 
defun( select_layername ()  ;������������
prog( ()  
    etchparam = axlGetParam("paramLayerGroup:ETCH")     
    l_layers = etchparam->groupMembers   ;�õ�����     �� ("TOP" "GND02" "POWER03" "BOTTOM")
    
    etchlist = nil   ;����listΪnil
    planelist = nil
    
    foreach(nlayer l_layers         ;������������ѭ��������������ж���ƽ��㻹�����߲�
      layerlista = strcat("ETCH/" nlayer )   ;��������õ��Ĳ�������("TOP" "GND02" "POWER03" "BOTTOM") ����ͨ��strcat��"ETCH/"����layerlista�б��   ("ETCH/TOP" "ETCH/GND02" "ETCH/POWER03" "ETCH/BOTTOM")
      
      when(axlDBGetLayerType(layerlista)=="PLANE"     ;����when�﷨�ж�����õ��Ĳ���PLANE���ԵĽ������ַŵ�planelist�У������ڴ˳���ǰ����planelist = nil
        planelist = cons(layerlista planelist)        ;cons( item list )��������Ԫ�ز��뵽�б�����ǰ���Ϊ�б���һ��Ԫ�أ�
        );end when ����when PLANE�ж�
        
      when(axlDBGetLayerType(layerlista)=="CONDUCTOR"     ;�ж�����õ��Ĳ���CONDUCTOR���ԵĽ������ַŵ�etchlist�У������ڴ˳���ǰ����etchlist = nil
       etchlist = cons(layerlista etchlist)
        ) ;end when ����when CONDUCTOR�ж�      
      );foreach  ����foreach�ж�

      etchlist = reverse(etchlist)     ;reverse �������ַ������򣬱���ϰ�߿������������reverseҲ���Եģ�ֻ����ʾЧ����("ETCH/BOTTOM" "ETCH/TOP")
      planelist = reverse(planelist)   ;��ʾЧ����("ETCH/GND02" "ETCH/POWER03")
      
      axlFormSetField( form "etch_list" etchlist)       ;��������崰��etch_list��������ʾ�������߲�����
      axlFormSetField( form "Plane_list" planelist)     ;����崰��Plane_list��������ʾ����ƽ������� 
          
  );prog
);defun


;ִ�����߿�ƽ��������
(defun e_c_plane ()
(prog ()
  
  axlSetFindFilter(?enabled '(noall clinesegs) ?onButtons '(noall clinesegs))  ;����Find����� clinesegs ��ѡ�ϣ���clinesegs���в���  
  
  clines_a = axlGetSelSet(axlAddSelectAll())  ;ָ��clines_a = �����ѡ�����
  
  axlSetFindFilter(?enabled '(noall shapes) ?onButtons '(noall shapes))  ;����Find����� Shape 
  
  shape_a = axlGetSelSet(axlAddSelectAll())  ;ָ��shape_a = �����ѡ�����
  
  axlClearSelSet() ;�����ѡ��Ķ��� ��������ϰ�� ���������
  
  axlHighlightObject(clines_a) ;������������ �������˷�������
   
   foreach( Cline clines_a  ;���ѭ���ж�ÿ������   
   
     Clinc_xy = Cline->startEnd  ;���ÿ��Cline����ʼ���յ����� ��õ� Clinc_xy =("2009.12 2010.26" "2010.10 2010.26") 
         
     c_xy_a = car(Clinc_xy)   ;���ÿ��Cline��ʼ���� ��c_xy_a = ��"2009.12 2010.26"�� 
          
     c_xy_b = cadr(Clinc_xy)  ;���ÿ��Cline���յ����� ��c_xy_b = ��"2010.10 2010.26"��     
       
       foreach( shape shape_a  ;���ѭ��ÿ��ͭƤ  
             
          if(axlGeoPointInShape( c_xy_b shape)  && axlGeoPointInShape( c_xy_a shape)   ;�ж�shape����õ�����ʼ���յ������Ƿ������� 
          
               then  ;�������ļ������ ��ִ����������
               
                 axlDehighlightObject(Cline)      ;�������ļ������ ��ִ��ȥ����������  ����ôʣ�¸����Ĳ��־��ǿ�ָ������
                   
             );end if(axlGeoPointInShape( c_xy_b shape)  ����if���ж�
             
           );end foreach( Shape shape_a      ����foreac��ѭ��
 
          );end foreach( Cline clines_a
);prog  
);defun ��������� ����Ľ��Ϳ��ܲ��ǁ���ȫ������ܸ�������һ���İ�������ס��æ��һ�£���л��


