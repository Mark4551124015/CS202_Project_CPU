@echo off
echo "Please Delete project/ first, Press Enter to generate"
pause
call vivado -mode batch  -source tcl/project.tcl
echo Done.
pause
del -F vivado.log && del -F vivado.jou && del -F .Xil/