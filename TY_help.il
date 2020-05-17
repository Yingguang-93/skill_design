axlCmdRegister("TYnew" 'TYnew)
defun(TYnew ()
axlUIViewFileCreate("~/pcbenv/new.log" "what's new" nil)
);end defun

axlCmdRegister("TYabout" 'TYabout)
defun(TYabout ()
axlHttp(strcat(home "\\pcbenv\\about.jpg"))
);end defun


axlCmdRegister("Useless" 'load_kbedamenus)
defun(load_kbedamenus ()
Useless = nil
;axlVisibleUpdate(t)
);end defun