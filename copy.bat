@echo off

::被复制的源文件夹
set sourceDir=project\project.srcs\
::目标文件夹
set tarDir=srcs\

::复制并覆盖文件及文件夹
xcopy %sourceDir% %tarDir% /s/y/E
