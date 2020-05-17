defun(rbg_build_ver ()
	sprintf(vers "%.1f " axlVersion('version))
	vers=strcat(axlVersion('displayName) " " vers)
	vers=strcat(vers axlVersion('release) " ")
	vers=strcat(vers axlVersion('internalVersion))
	
	printf("%s.\n", vers)
	if(isFile("ccs_support.txt") then
		printf("Writing to file\n")
		ccs_file=outfile("ccs_support.txt")
		fprintf(ccs_file "\n %s \n" vers)
		close(ccs_file)
	)
)
axlCmdRegister("build" 'rbg_build_ver)
	