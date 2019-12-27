@echo off
setlocal EnableDelayedExpansion

set libName=mathgl
set version=2.4.4

set libFolder=!libName!-!version!
set localTarFile=!libFolder!.tar
set localGzFile=!localTarFile!.gz

cd /d "%~dp0"

if /i "%~1" == "--uninstall" (
  del /q /f lib\win32\mgl*.lib 2>nul
  del /q /f lib\win64\mgl*.lib 2>nul
  pushd dls
  rmdir /q /s !libFolder! 2>nul
  del /q /f !localTarFile! 2>nul
  del /q /f !localGzFile! 2>nul
  popd
  exit /b 0
)

set bits=%~1
if not "!bits!" == "32" (
  if not "!bits!" == "64" (
    set thisFile=%~n0
    echo Usage: !thisFile! ^<32 ^| 64^> ^| --uninstall
    exit /b 1
  )
)

if exist lib\win!bits!\mgl*.lib (
  echo !libName! !bits!-bit already installed, skipping
  exit /b 0
)

if not exist dls\!libFolder! (
  pushd dls
  del /q /f !localTarFile! 2>nul
  del /q /f !localGzFile! 2>nul

  set remoteFile=https://downloads.sourceforge.net/project/mathgl/mathgl/mathgl%%20!version!/mathgl-!version!.tar.gz
  echo Downloading !libName! from !remoteFile!
  PowerShell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (New-Object Net.WebClient).DownloadFile('!remoteFile!', '!localGzFile!')"
  if !errorlevel! neq 0 exit /b !errorlevel!

  "C:\Program Files\7-Zip\7z.exe" x -bsp0 !localGzFile!
  if !errorlevel! neq 0 exit /b !errorlevel!
  "C:\Program Files\7-Zip\7z.exe" x -bsp0 !localTarFile!
  if !errorlevel! neq 0 exit /b !errorlevel!

  popd
)

call "%~dp0..\build\vc_paths.bat"
if !errorlevel! neq 0 exit /b !errorlevel!
set PATH=%PATH%;C:\Program Files\CMake\bin

cd dls\!libFolder!
if !errorlevel! neq 0 exit /b !errorlevel!

set buildFolder=build!bits!
if not exist !buildFolder! (
  mkdir !buildFolder!
  if !errorlevel! neq 0 exit /b !errorlevel!
)
cd !buildFolder!
if !errorlevel! neq 0 exit /b !errorlevel!

if "!bits!" == "64" (
  set CMAKE_PLATFORM=x64
) else (
  set CMAKE_PLATFORM=Win32
)

cmake -G !VS_CMAKE_GENERATOR! -A !CMAKE_PLATFORM! -DCMAKE_GENERATOR_INSTANCE="!VS_INSTALL_PATH!" -Denable-zlib=OFF -Denable-png=OFF ..
if !errorlevel! neq 0 exit /b !errorlevel!

echo Building !libName! !bits!
cmake --build . --config Release --target mgl --target mgl-static
if !errorlevel! neq 0 exit /b !errorlevel!

echo Copying !bits!-bit !libName! libraries
copy /y src\Release\*.lib ..\..\..\lib\win!bits!
if !errorlevel! neq 0 exit /b !errorlevel!
