@echo off
REM Build and link rusty

set BUILD_TYPE=release

:MyLinker
call MyLinker\build.bat %BUILD_TYPE%

:Fire
call dos-stub\build.bat %BUILD_TYPE%

:rusty
call rusty\build.bat %BUILD_TYPE%

del ..\bin\rusty.exe
xcopy rusty\target\x86_64-pc-windows-msvc\%BUILD_TYPE%\rusty.exe ..\bin /Y

@pause