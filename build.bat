@echo off

if "%1"=="" goto help
if not "%1"=="" goto other

:help
want help
goto exit

:other
want %1
goto exit

:exit