@echo off
REM Vulnerable Web Application Launch Script for Windows
REM This batch file sets up the environment and launches the Flask application

setlocal EnableDelayedExpansion

REM Get script directory and change to it
set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

REM Clean up any existing virtual environment state
echo 🧹 Cleaning existing virtual environment state...
if defined VIRTUAL_ENV (
    echo    ⚠️  Detected active virtual environment: %VIRTUAL_ENV%
    echo    🔄 Deactivating to ensure clean state...
    call deactivate >nul 2>&1
    set "VIRTUAL_ENV="
    set "PYTHONPATH="
)

echo.
echo 🔍 Execution Environment Debug Info:
echo    Script directory: %SCRIPT_DIR%
echo    Current working directory: %CD%
echo    User: %USERNAME%
echo    VIRTUAL_ENV: %VIRTUAL_ENV%
echo.

echo.
echo 🚨 VULNERABLE WEB APPLICATION LAUNCHER
echo ==========================================
echo ⚠️  WARNING: This application contains intentional security vulnerabilities!
echo    - CSRF vulnerabilities
echo    - SQL injection vulnerabilities
echo    - Session hijacking vulnerabilities  
echo    - Only use for educational purposes!
echo ==========================================
echo.

REM Function to find working Python
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

REM Check if pip is available
!PYTHON_CMD! -m pip --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Error: pip is not available with this Python installation
    echo Please reinstall Python with pip included
    pause
    exit /b 1
)

REM Enhanced virtual environment handling
echo 📦 Checking virtual environment...

REM Force removal of any existing venv with broken state
if exist "venv" (
    echo    📁 Found existing venv directory, checking for issues...
    
    REM Check if activation script exists but Python doesn't work
    if exist "venv\Scripts\activate.bat" (
        if exist "venv\Scripts\python.exe" (
            venv\Scripts\python.exe --version >nul 2>&1
            if !errorlevel! neq 0 (
                echo    ❌ Detected broken Python executable, removing entire venv directory
                rmdir /s /q venv
            ) else (
                echo    🔍 Existing venv appears functional, validating...
            )
        ) else (
            echo    ❌ Missing Python executable, removing entire venv directory
            rmdir /s /q venv
        )
    ) else (
        echo    ❌ Missing activation script, removing entire venv directory
        rmdir /s /q venv
    )
)

REM Create virtual environment if it doesn't exist
if not exist "venv" (
    echo 📦 Creating virtual environment...
    echo    🔧 Running: !PYTHON_CMD! -m venv venv
    !PYTHON_CMD! -m venv venv
    if !errorlevel! neq 0 (
        echo ❌ Failed to create virtual environment
        echo Please ensure Python venv module is available
        pause
        exit /b 1
    )
    echo    ✅ Virtual environment created successfully
)

REM Activate virtual environment
echo 🔧 Activating virtual environment...
if exist "venv\Scripts\activate.bat" (
    call venv\Scripts\activate.bat
    echo    ✅ Virtual environment activated successfully
    echo    🐍 Using Python: 
    python --version
    echo    📍 Python location: 
    where python
) else (
    echo ❌ Error: Virtual environment activation script not found
    echo Expected: venv\Scripts\activate.bat
    echo Please ensure the virtual environment was created successfully
    pause
    exit /b 1
)

REM Check if pip needs upgrading
echo 📦 Checking pip version...
for /f "tokens=2" %%i in ('pip --version') do set CURRENT_PIP=%%i
python -c "import requests; r=requests.get('https://pypi.org/pypi/pip/json'); latest=r.json()['info']['version']; current='%CURRENT_PIP%'; print('UPGRADE_NEEDED' if current != latest else 'UP_TO_DATE')" >pip_check.tmp 2>nul
set /p PIP_STATUS=<pip_check.tmp
del pip_check.tmp >nul 2>&1

if "%PIP_STATUS%"=="UPGRADE_NEEDED" (
    echo 📦 Upgrading pip...
    python -m pip install --upgrade pip
) else (
    echo ✅ Pip is already up to date
)

REM Install requirements with check
if exist "requirements.txt" (
    echo 📦 Checking and installing requirements...
    REM Check if packages are already satisfied
    pip check >nul 2>&1
    if !errorlevel! equ 0 (
        echo ✅ All requirements already satisfied
    ) else (
        echo 📦 Installing/updating missing requirements...
        pip install -r requirements.txt --quiet
        if !errorlevel! neq 0 (
            echo ❌ Failed to install requirements
            pause
            exit /b 1
        )
    )
) else (
    echo 📦 Checking Flask installation...
    python -c "import flask; print('Flask version:', flask.__version__)" >nul 2>&1
    if !errorlevel! neq 0 (
        echo 📦 Installing Flask...
        pip install Flask==2.3.3 Werkzeug==2.3.7
        if !errorlevel! neq 0 (
            echo ❌ Failed to install Flask
            pause
            exit /b 1
        )
    ) else (
        echo ✅ Flask is already installed
    )
)

REM Create instance directory
if not exist "instance" mkdir instance

REM Set Flask environment variables
set FLASK_APP=VulnerableApp
set FLASK_ENV=development
set FLASK_DEBUG=1

echo.
echo ✅ Environment setup complete!
echo.
echo 🚀 Starting Vulnerable Web Application...
echo 🌐 Server will be available at: http://localhost:4444
echo 🔑 Default credentials:
echo    Username: Johnnydepp, Password: Pirates
echo.
echo Press Ctrl+C to stop the server
echo.

REM Launch the application using flask run
flask run --host=0.0.0.0 --port=4444

REM Deactivate virtual environment when done  
call venv\Scripts\deactivate.bat

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
