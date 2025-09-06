@echo off
REM VulnerableVMIndexApp Launch Script for Windows
REM This batch file launches the Flask web application

setlocal EnableDelayedExpansion

echo 🚀 Starting VulnerableVMIndexApp...

REM Change to the application directory
cd /d "%~dp0"

REM Clean up any existing virtual environment state
echo 🧹 Cleaning existing virtual environment state...
if defined VIRTUAL_ENV (
    echo    ⚠️  Detected active virtual environment: %VIRTUAL_ENV%
    echo    🔄 Deactivating to ensure clean state...
    call deactivate >nul 2>&1
    set "VIRTUAL_ENV="
    set "PYTHONPATH="
)

REM Set the Flask application environment variable
set FLASK_APP=app:create_app

REM Optional: Set Flask environment to development for debugging
set FLASK_ENV=development

REM Function to find working Python installation
call :findPython PYTHON_CMD
if "!PYTHON_CMD!"=="" (
    echo ❌ Error: No working Python installation found
    echo Please install Python 3.7+ from https://www.python.org/downloads/
    echo Make sure to check "Add Python to PATH" during installation
    echo Searched for: python, py -3, python3
    pause
    exit /b 1
)

echo 🐍 Using Python: !PYTHON_CMD!
!PYTHON_CMD! --version

REM Enhanced virtual environment handling
echo 📦 Checking virtual environment...

REM Force removal of any existing .venv with broken state
if exist ".venv" (
    echo    📁 Found existing .venv directory, checking for issues...
    
    REM Check if activation script exists but Python doesn't work
    if exist ".venv\Scripts\activate.bat" (
        if exist ".venv\Scripts\python.exe" (
            .venv\Scripts\python.exe --version >nul 2>&1
            if !errorlevel! neq 0 (
                echo    ❌ Detected broken Python executable, removing entire .venv directory
                rmdir /s /q .venv
            ) else (
                echo    🔍 Existing .venv appears functional, validating...
                call :validateVenv VENV_STATUS
            )
        ) else (
            echo    ❌ Missing Python executable, removing entire .venv directory
            rmdir /s /q .venv
            set VENV_STATUS=1
        )
    ) else (
        echo    ❌ Missing activation script, removing entire .venv directory
        rmdir /s /q .venv
        set VENV_STATUS=1
    )
) else (
    set VENV_STATUS=1
)

REM Create virtual environment if needed
if !VENV_STATUS! equ 1 (
    echo 📦 Creating virtual environment...
    echo    🔧 Running: !PYTHON_CMD! -m venv .venv
    !PYTHON_CMD! -m venv .venv
    if !errorlevel! neq 0 (
        echo ❌ Failed to create virtual environment
        echo Please ensure Python venv module is available
        pause
        exit /b 1
    )
    echo    ✅ Virtual environment created successfully
) else if !VENV_STATUS! equ 2 (
    echo 📦 Virtual environment appears corrupted, recreating...
    rmdir /s /q .venv
    !PYTHON_CMD! -m venv .venv
    if !errorlevel! neq 0 (
        echo ❌ Failed to recreate virtual environment
        pause
        exit /b 1
    )
    echo    ✅ Virtual environment recreated successfully
) else (
    echo ✅ Virtual environment is valid
)

REM Activate virtual environment
echo 🔧 Activating virtual environment...
if exist ".venv\Scripts\activate.bat" (
    call .venv\Scripts\activate.bat
    echo    ✅ Virtual environment activated successfully
    echo    🐍 Using Python: 
    python --version
    echo    📍 Python location: 
    where python
) else (
    echo ❌ Error: Virtual environment activation script not found
    echo Expected: .venv\Scripts\activate.bat
    echo Please ensure the virtual environment was created successfully
    pause
    exit /b 1
)

REM Install requirements if requirements.txt exists
if exist "requirements.txt" (
    echo 📦 Installing/updating dependencies...
    pip install -r requirements.txt
    if !errorlevel! neq 0 (
        echo ❌ Failed to install requirements
        pause
        exit /b 1
    )
    echo ✅ Dependencies installed successfully
) else (
    echo 📦 No requirements.txt found, skipping dependency installation
)

REM Launch the Flask application
echo.
echo 🚀 Launching Flask application...
echo 🌐 Server will be available at: http://localhost:5000
echo 💡 Press Ctrl+C to stop the application
echo.

flask run --host=0.0.0.0 --port=5000

REM Deactivate virtual environment when done
call .venv\Scripts\deactivate.bat

echo.
echo Press any key to exit...
pause >nul

goto :eof

REM Function to find working Python installation
:findPython
set PYTHON_CANDIDATES=python py -3 python3 C:\Python39\python.exe C:\Python310\python.exe C:\Python311\python.exe C:\Python312\python.exe

for %%P in (%PYTHON_CANDIDATES%) do (
    %%P --version >nul 2>&1
    if !errorlevel! equ 0 (
        set "%~1=%%P"
        goto :eof
    )
)

REM If no working Python found, return empty
set "%~1="
goto :eof

REM Function to validate virtual environment
:validateVenv
set VENV_PATH=.venv

REM Check if basic structure exists
if not exist "%VENV_PATH%" (
    set "%~1=1"
    goto :eof
)

REM Check for activation script
if not exist "%VENV_PATH%\Scripts\activate.bat" (
    echo    ❌ Virtual environment missing activation script
    set "%~1=2"
    goto :eof
)

REM Check for Python executable
if not exist "%VENV_PATH%\Scripts\python.exe" (
    echo    ❌ Virtual environment missing Python executable
    set "%~1=2"
    goto :eof
)

REM Check for pip
if not exist "%VENV_PATH%\Scripts\pip.exe" (
    echo    ❌ Virtual environment missing pip
    set "%~1=2"
    goto :eof
)

REM Test if Python actually works in the venv
%VENV_PATH%\Scripts\python.exe -c "import sys; print('Python OK')" >nul 2>&1
if !errorlevel! neq 0 (
    echo    ❌ Virtual environment Python executable is broken
    set "%~1=2"
    goto :eof
)

REM Valid virtual environment
set "%~1=0"
goto :eof
