@echo off

IF "%1"=="fu" (goto FreeplayUnlock)
IF "%1"=="dbg" (goto Debug)
IF "%1"=="chart" (goto Charter)

goto Normal

:Charter
echo Arguments: [debug, CHARTING]
lime test windows -debug -DCHARTING
pause
exit

:Debug
echo Arguments: [debug]
lime test windows -debug
pause
exit

:FreeplayUnlock
echo Arguments: [FREEPLAY_UNLOCK]
lime test windows -DFREEPLAY_UNLOCK
pause 
exit

:Normal
echo Arguments: []
lime test windows
pause
exit