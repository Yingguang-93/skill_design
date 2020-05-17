axlCmdRegister("set origin" 'setorigin)

defun(setorigin ()
axlDBChangeDesignOrigin(-xCoord(car(axlExtentLayout())):-yCoord(car(axlExtentLayout())))
axlUIWPrint(nil "^_^ origin completed successfully")
);end defun