;Version - 1.1
;This SKILL code makes a list of all the thermal flashes used in a padstack library
;    Updated June 24,2007 by Ilya Zevin, EDA Integrity Solutions, LTD (ilya@eda.co.il)
;               Changed the code to look at the "extracta" command instead old stile "extract"
; Tested on Allegro PCB Editor 15.7 s067 (v15-7-42CU) [5/18/2007] i86
axlCmdRegister( "flashes" 'findThermalFlashes)

procedure( findThermalFlashes()
;Make a list of all the thermal flashes used in a padstack library.
  prog((dirName padList)

    ;Get the library directory from the user.
    dirName = getFileSystemDir()

    ;Get list of .pad files in dirName
    padList = setof(x getDirFiles(dirName) rexMatchp(".pad$" x))

    ;Open a file for result output
    unless( outPort=outfile("./thermalpads.log")
      println("Could open an output file")
      return()
    );unless

    ;create extract command file
    unless( exFile = outfile("./pad_def.txt")
      println("Can not create extract command file in working directory.")
      return()
    )
    fprintf(exFile "PAD_DEF\n")
    close(exFile)

    foreach(padstack padList
      outputThermals( strcat( dirName "/" padstack) outPort)
    );

    close( outPort )

    axlUIViewFileCreate("./thermalpads.log" "Thermal Flash Report" nil)

    when( isWritable("./pad_def.txt")
      deleteFile("./pad_def.txt")
    )
  );prog
);procedure


procedure( outputThermals( padstack outPort)
;accept a padstack filename and output the thermal pad information to outPort
  let((line parsedLine flash prevLine)
    if( isReadable( padstack )
    then
;modified by Ilya Zevin: changed "extract" to "extracta"
      sh( strcat("extracta " padstack " ./pad_def.txt " "paddef.txt"))
    else
      printf("Could not find %s." padstack)
    )

    when(inPort=infile( "./paddef.txt" )
      while( gets( line inPort )
        when( substring(line 1 1) == "S" &&
              (flash=nth(18 MLCparseString(line list("!")))) != ""
          layer = nth(3 MLCparseString(line list("!")))
          padname = nth(1 MLCparseString(line list("!")))
          fprintf( outPort "\n%-25s %-20s %s" padname layer flash)
        );when
      prevLine = line
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


