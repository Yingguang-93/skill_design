;  slots.il
;
; The purpose of this file is to extract the drill data from the slots in the directory
; that you specify when prompted. For extracting the data from the current directory 
; just put a . (dot) in the fillin
;
; Usage: On the Allegro command line enter 
;   slots
;
; Current known limitations.
; 1. No(!) error checking.
;
;
;********************************************************************
;* DISCLAIMER: The following code is provided for Cadence customers *
;* to use at their own risk. The code may require modification to   *
;* satisfy the requirements of any user. The code and any           *
;* modifications to the code may not be compatible with current or  *
;* future versions of Cadence products.                             *
;* THE CODE IS PROVIDED "AS IS" AND WITH NO WARRANTIES, INCLUDING   *
;* WITHOUT LIMITATION ANY EXPRESS WARRANTIES OR IMPLIED WARRANTIES  *
;* OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR USE.              *
;********************************************************************
;
;
; Author:
; Rik Lee 
; Cadence
; Silicon Package Board Division
;
; Version 1.0 March 2005 
;
;

axlCmdRegister( "slots" 'findSlots)

procedure( findSlots()
;Make a list of all the Slots used in a padstack library.
  prog((dirName padList)

    ;Get the library directory from the user.
    dirName = getFileSystemDir()
 
    ;Get list of .pad files in dirName
    padList = setof(x getDirFiles(dirName) rexMatchp(".pad$" x))

    ;Open a file for result output
    unless( outPort=outfile("./slots.log")
      println("Could open an output file")
      return()
    );unless
    fprintf( outPort "\n %-12s %-15s %-8s %-8s %-15s %s\n\n" "Padstack" "Slot Type" "X dim" "Y dim" "Drill Figure" "Drill Character")

    ;create extract command file
    unless( exFile = outfile("./pad_def.txt")
      println("Can not create extract command file in working directory.")
      return()
    )
    fprintf(exFile "PAD_DEF\n")
    close(exFile)

    foreach(padstack padList
      outputSlots( strcat( dirName "/" padstack) outPort)
    );

    close( outPort )
    close( inPort )

    axlUIViewFileCreate("./slots.log" "Slot Report" nil)

    when( isWritable("./pad_def.txt")
      deleteFile("./pad_def.txt")
    )
  );prog
);procedure
;
;What we need from the pad_def extract. Records numbers start at 0
PAD_NAME  = 1
;~DRILL    = 3
PADWIDTH  = 7	;--- X Dimension
PADHGHT   = 8	;--- Y Dimension
PADFLASH  = 11	;--- Drill Figure
TRELSHAPE1= 13	;--- Drill Character
APADSHAPE1= 20	;--- Type

procedure( outputSlots( padstack outPort)
;accept a padstack filename and output the drill information to outPort
  let((line parsedLine slot size_x size_y figure slot_type pad_stack character)
    if( isReadable( padstack )
    then
      sh( strcat("extracta " padstack " ./pad_def.txt " "paddef.txt"))
    else
      printf("Could not find %s." padstack)
    )

    when(inPort=infile( "./paddef.txt" )
      while( gets( line inPort )
        fs_parseString=MLCparseString(line list("!"))
        when( substring(line 1 1) == "S" &&
              (slot=nth(3 fs_parseString)) == "~DRILL"

          size_x = nth(PADWIDTH fs_parseString)		; X dimension of the slot
          size_y = nth(PADHGHT fs_parseString)		; Y dimension of the slot
          figure = nth(PADFLASH fs_parseString)		; Drill Figure
          slot_type = nth(APADSHAPE1 fs_parseString)	; Slot Type
          pad_stack = nth(PAD_NAME fs_parseString)	; Padstack name
          character = nth(TRELSHAPE1 fs_parseString)	; Drill Character(s)
    if(nindex(slot_type "SLOT") then
          fprintf( outPort "\n %-12s %-15s %-8s %-8s %-20s %s"
          	pad_stack	;<-     |    |    |     |   |
          	slot_type	;<------     |    |     |   |
          	size_x		;<-----------     |     |   |
          	size_y		;<----------------      |   |
          	figure		;<----------------------    |
          	character)	;<--------------------------
    );if      	
        );when
      );while
    );when
  );let
);

procedure( getFileSystemDir()
;Get a filesystem name from the user and make sure it is readable.
  let((dirName legalDir)
    dirName = axlUIPrompt("Please enter the directory where the padstacks exist")   
    legalDir = isDir(dirName) && isReadable(dirName)
    while( !legalDir
      axlUIConfirm(sprintf(nil "%s is either unreadable or does not exist."
                               dirName))
      dirName = axlUIPrompt("Please enter the directory where the padstacks exist")
      legalDir = isDir(dirName) && isReadable(dirName)
    );while
    dirName
  );let
);procedure

defun( MLCparseString ( line l_dlim ) 
prog( ( l_prsstr c_str t_chr x) 
 
	l_prsstr = nil
	c_str = ""   
	t_chr = ""
	x = 1
	mlc_char = getchar( line x)  
 
 
	while( mlc_char != nil && charToInt( mlc_char) != 10
		sprintf( t_char "%s" mlc_char)
		if( member( t_char l_dlim) == nil then 
			c_str = strcat( c_str t_char)  
		else
			l_prsstr = append1( l_prsstr c_str)
			c_str = ""  
		);end-if 

		x++
		mlc_char = getchar( line x) 
	);end-while  
	if( c_str != "" l_prsstr = append1( l_prsstr c_str))
	return( l_prsstr )
))/* End Of MLCparseString */


