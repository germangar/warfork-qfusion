@echo off
setlocal

set VSWHERE="C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe"

for /f "usebackq tokens=*" %%i in (`%VSWHERE% -latest -products * -requires Microsoft.Component.MSBuild -property installationPath`) do (
  set VSPATH=%%i
)

if not defined VSPATH (
    echo Visual Studio not found!
    echo Please check your Visual Studio installation
    pause
    exit /b 1
)

set MSBUILD="%VSPATH%\MSBuild\Current\Bin\MSBuild.exe"

if not exist %MSBUILD% (
    echo MSBuild not found at %MSBUILD%
    echo Please check your Visual Studio installation
    pause
    exit /b 1
)

echo Configuring build with CMake...
cmake -B ./build -G "Visual Studio 16 2019" -A x64 -DBUILD_STEAMLIB=OFF -DUSE_CRASHPAD=OFF -DUSE_GRAPHICS_NRI=OFF -DCMAKE_POLICY_VERSION_MINIMUM=3.5

if %ERRORLEVEL% neq 0 (
    echo CMake configuration failed!
    pause
    exit /b 1
)

echo.
echo Building ONLY warfork_x64.exe, game.dll, and cgame.dll...
%MSBUILD% build\qfusion.sln /t:warfork;game;cgame -p:Configuration=RelWithDebInfo -maxcpucount:4

if %ERRORLEVEL% neq 0 (
    echo Build failed!
    pause
    exit /b 1
)

echo.
echo Build complete!
echo.
echo Output files are in: build\warfork-qfusion\RelWithDebugInfo\
echo   - warfork_x64.exe
echo   - basewf\game_x64.dll
echo   - basewf\cgame_x64.dll

pause
