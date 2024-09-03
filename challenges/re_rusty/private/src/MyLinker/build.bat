set BUILD_TYPE=%1
set MSBUILD="c:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\MSBuild.exe" 
%MSBUILD% "MyLinker\MyLinker.sln" -p:Configuration=%BUILD_TYPE%