@echo off
:conSize  winWidth  winHeight  bufWidth  bufHeight
mode con: cols=%1 lines=%2
powershell -command "&{$H=get-host;$W=$H.ui.rawui;$B=$W.buffersize;$B.width=%3;$B.height=%4;$W.buffersize=$B;}"