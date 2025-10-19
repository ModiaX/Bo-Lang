@echo off
setlocal enabledelayedexpansion

set "ROOTDIR=%cd%"
set "SRC_DIR=%ROOTDIR%\src"
set "OUT_DIR=%ROOTDIR%\out"
set "RAW_DIR=%OUT_DIR%\raw"
set "BIN_DIR=%OUT_DIR%\bin"

echo.
echo === Cleaning and Preparing Output Directories ===

if exist "%RAW_DIR%" rmdir /s /q "%RAW_DIR%"
if exist "%BIN_DIR%" rmdir /s /q "%BIN_DIR%"

mkdir "%RAW_DIR%"
mkdir "%BIN_DIR%"

echo.
echo === Copying Source Files into out/raw ===
xcopy "%SRC_DIR%\*" "%RAW_DIR%\" /E /Y >nul

echo.
echo === Entering out/raw Directory ===
cd "%RAW_DIR%"

echo --- Compiling .bol files ---
for %%f in (*.bol) do (
    echo Compiling %%f...
    bolc %%~nf
)

echo.
echo --- Assembling .asm files ---
fasm main.asm bolc.exe

echo.
echo === Moving Executables to out/bin ===
echo Moving bolc.exe to bin...
move /Y "bolc.exe" "%BIN_DIR%\bolc.exe" >nul

cd "%ROOTDIR%"

echo.
echo === Build Complete! ===
echo Raw files: %RAW_DIR%
echo Executables: %BIN_DIR%
echo.
endlocal
