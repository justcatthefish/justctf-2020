set DOSBOX="c:\Program Files (x86)\DOSBox-0.74-2\DOSBox.exe" 
set MASM=c:\tools\MASM6.1\bin

cd dos-stub
wsl.exe python3 encode.py
del DOSSTUB.exe
cd ..

%DOSBOX% ^
-c "mount d: ." ^
-c "mount c: %MASM%" ^
-c "c:" ^
-c "masm d:\dos-stub\DOSSTUB.asm" ^
-c "link DOSSTUB.OBJ,DOSSTUB.EXE,,,," ^
-c "copy DOSSTUB.EXE d:\dos-stub"
