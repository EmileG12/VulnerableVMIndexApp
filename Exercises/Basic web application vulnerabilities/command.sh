#!/bin/bash

# Vulnerable Web Application Launch Script for Linux/Unix
# This script sets up the environment and launches the Flask application

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Ensure we're in the correct directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Clean up any existing virtual environment state from shell
echo -e "${BLUE}🧹 Cleaning existing virtual environment state...${NC}"
if [ -n "$VIRTUAL_ENV" ]; then
    echo -e "${YELLOW}   ⚠️  Detected active virtual environment: $VIRTUAL_ENV${NC}"
    echo -e "${YELLOW}   🔄 Deactivating to ensure clean state...${NC}"
    deactivate 2>/dev/null || true
    unset VIRTUAL_ENV
    unset PYTHONPATH
fi

# Print debug info for subprocess execution
echo -e "${BLUE}🔍 Execution Environment Debug Info:${NC}"
echo "   Script directory: $SCRIPT_DIR"
echo "   Current working directory: $(pwd)"
echo "   User: $(whoami)"
echo "   Shell: $SHELL"
echo "   PATH: $PATH"
echo "   Python in PATH: $(which python3 2>/dev/null || which python 2>/dev/null || echo 'NOT FOUND')"
echo "   VIRTUAL_ENV: ${VIRTUAL_ENV:-'(not set)'}"

echo -e "${RED}🚨 VULNERABLE WEB APPLICATION LAUNCHER${NC}"
echo "=========================================="
echo -e "${YELLOW}⚠️  WARNING: This application contains intentional security vulnerabilities!${NC}"
echo "   - CSRF vulnerabilities"
echo "   - SQL injection vulnerabilities" 
echo "   - Session hijacking vulnerabilities"
echo -e "${YELLOW}   - Only use for educational purposes!${NC}"
echo "=========================================="

# Function to find working Python
find_python() {
    # Try different Python commands in order of preference
    for cmd in python3 python python3.12 python3.11 python3.10 python3.9; do
        if command -v "$cmd" >/dev/null 2>&1; then
            if "$cmd" --version >/dev/null 2>&1; then
                echo "$cmd"
                return 0
            fi
        fi
    done
    
    # If no working Python found, try absolute paths
    for path in /usr/bin/python3 /usr/bin/python /usr/local/bin/python3; do
        if [ -x "$path" ] && "$path" --version >/dev/null 2>&1; then
            echo "$path"
            return 0
        fi
    done
    
    return 1
}

# Find a working Python executable
PYTHON_CMD=$(find_python)
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Error: No working Python installation found${NC}"
    echo "Please ensure Python 3.7+ is installed and accessible"
    echo "Searched for: python3, python, python3.12, python3.11, python3.10, python3.9"
    echo "Also checked: /usr/bin/python3, /usr/bin/python, /usr/local/bin/python3"
    exit 1
fi

echo -e "${BLUE}🐍 Using Python: $($PYTHON_CMD --version) at $(which $PYTHON_CMD)${NC}"

# Function to validate virtual environment
validate_venv() {
    local venv_path=".venv"
    
    echo -e "${BLUE}🔍 Debugging virtual environment validation...${NC}"
    
    # Check if basic structure exists
    if [ ! -d "$venv_path" ]; then
        echo -e "${YELLOW}   Directory $venv_path does not exist${NC}"
        return 1  # Doesn't exist
    fi
    echo -e "${GREEN}   ✓ Directory $venv_path exists${NC}"
    
    # Show the complete structure
    echo -e "${BLUE}   📁 Virtual environment structure:${NC}"
    if command -v tree >/dev/null 2>&1; then
        tree "$venv_path" -L 2
    else
        find "$venv_path" -type f -name "python*" -o -name "pip*" -o -name "activate" | head -20
    fi
    
    # Check for activation script
    if [ ! -f "$venv_path/bin/activate" ]; then
        echo -e "${RED}❌ Virtual environment missing activation script${NC}"
        echo -e "${YELLOW}   Checked for: $venv_path/bin/activate${NC}"
        ls -la "$venv_path/bin/" 2>/dev/null || echo -e "${RED}   bin directory doesn't exist${NC}"
        return 2  # Corrupted
    fi
    echo -e "${GREEN}   ✓ Activation script exists${NC}"
    
    # Check for Python executable and determine which one to use
    local venv_python=""
    echo -e "${BLUE}   🔍 Looking for Python executables...${NC}"
    
    # Check if python exists and is working
    if [ -e "$venv_path/bin/python" ]; then
        if [ -L "$venv_path/bin/python" ]; then
            local target=$(readlink "$venv_path/bin/python")
            echo -e "${BLUE}   📎 python is a symlink to: $target${NC}"
            if [ -x "$venv_path/bin/python" ] && "$venv_path/bin/python" --version >/dev/null 2>&1; then
                venv_python="$venv_path/bin/python"
                echo -e "${GREEN}   ✓ Found working: $venv_python${NC}"
            else
                echo -e "${YELLOW}   ⚠️  python symlink is broken${NC}"
            fi
        elif [ -x "$venv_path/bin/python" ] && "$venv_path/bin/python" --version >/dev/null 2>&1; then
            venv_python="$venv_path/bin/python"
            echo -e "${GREEN}   ✓ Found working: $venv_python${NC}"
        fi
    fi
    
    # Check if python3 exists and is working
    if [ -z "$venv_python" ] && [ -e "$venv_path/bin/python3" ]; then
        if [ -L "$venv_path/bin/python3" ]; then
            local target=$(readlink "$venv_path/bin/python3")
            echo -e "${BLUE}   📎 python3 is a symlink to: $target${NC}"
            if [ -x "$venv_path/bin/python3" ] && "$venv_path/bin/python3" --version >/dev/null 2>&1; then
                venv_python="$venv_path/bin/python3"
                echo -e "${GREEN}   ✓ Found working: $venv_python${NC}"
            else
                echo -e "${YELLOW}   ⚠️  python3 symlink is broken${NC}"
            fi
        elif [ -x "$venv_path/bin/python3" ] && "$venv_path/bin/python3" --version >/dev/null 2>&1; then
            venv_python="$venv_path/bin/python3"
            echo -e "${GREEN}   ✓ Found working: $venv_python${NC}"
        fi
    fi
    
    # If no working python found, check for other python versions
    if [ -z "$venv_python" ]; then
        echo -e "${YELLOW}   🔍 Looking for alternative Python executables...${NC}"
        for py in "$venv_path/bin/python3."*; do
            if [ -x "$py" ] && "$py" --version >/dev/null 2>&1; then
                venv_python="$py"
                echo -e "${GREEN}   ✓ Found working alternative: $venv_python${NC}"
                break
            fi
        done
    fi
    
    if [ -z "$venv_python" ]; then
        echo -e "${RED}❌ Virtual environment missing working Python executable${NC}"
        echo -e "${YELLOW}   Checked for: $venv_path/bin/python and $venv_path/bin/python3${NC}"
        echo -e "${YELLOW}   Contents of bin directory:${NC}"
        ls -la "$venv_path/bin/" 2>/dev/null || echo -e "${RED}   bin directory doesn't exist${NC}"
        echo -e "${YELLOW}   This appears to be a broken symlink issue. Recreating virtual environment...${NC}"
        return 2  # Corrupted
    fi
    
    # Check if the executable is actually executable
    if [ ! -x "$venv_python" ]; then
        echo -e "${RED}❌ Python executable is not executable${NC}"
        echo -e "${YELLOW}   File permissions: $(ls -la "$venv_python")${NC}"
        return 2  # Corrupted
    fi
    echo -e "${GREEN}   ✓ Python executable has correct permissions${NC}"
    
    # Check for pip executable
    local venv_pip=""
    echo -e "${BLUE}   🔍 Looking for pip executables...${NC}"
    
    if [ -f "$venv_path/bin/pip" ]; then
        venv_pip="$venv_path/bin/pip"
        echo -e "${GREEN}   ✓ Found: $venv_pip${NC}"
    elif [ -f "$venv_path/bin/pip3" ]; then
        venv_pip="$venv_path/bin/pip3"
        echo -e "${GREEN}   ✓ Found: $venv_pip${NC}"
    else
        echo -e "${RED}❌ Virtual environment missing pip${NC}"
        echo -e "${YELLOW}   Checked for: $venv_path/bin/pip and $venv_path/bin/pip3${NC}"
        return 2  # Corrupted
    fi
    
    # Test if Python actually works in the venv
    echo -e "${BLUE}   🧪 Testing Python executable...${NC}"
    if ! "$venv_python" -c "import sys; print('Python OK')" >/dev/null 2>&1; then
        echo -e "${RED}❌ Virtual environment Python executable is broken${NC}"
        echo -e "${YELLOW}   Tested: $venv_python${NC}"
        echo -e "${YELLOW}   Error output:${NC}"
        "$venv_python" -c "import sys; print('Python OK')" 2>&1 || true
        return 2  # Corrupted
    fi
    echo -e "${GREEN}   ✓ Python executable works${NC}"
    
    # Test if pip works in the venv
    echo -e "${BLUE}   🧪 Testing pip functionality...${NC}"
    if ! "$venv_python" -m pip --version >/dev/null 2>&1; then
        echo -e "${RED}❌ Virtual environment pip is broken${NC}"
        echo -e "${YELLOW}   Tested: $venv_python -m pip${NC}"
        echo -e "${YELLOW}   Error output:${NC}"
        "$venv_python" -m pip --version 2>&1 || true
        return 2  # Corrupted
    fi
    echo -e "${GREEN}   ✓ Pip works${NC}"
    
    # Check if site-packages directory exists and is writable
    echo -e "${BLUE}   🔍 Checking site-packages directory...${NC}"
    if [ ! -d "$venv_path/lib" ] || [ ! -w "$venv_path/lib" ]; then
        echo -e "${RED}❌ Virtual environment lib directory is missing or not writable${NC}"
        echo -e "${YELLOW}   Lib directory status:${NC}"
        ls -la "$venv_path/" | grep lib || echo -e "${RED}   No lib directory found${NC}"
        return 2  # Corrupted
    fi
    echo -e "${GREEN}   ✓ Site-packages directory is accessible${NC}"
    
    echo -e "${GREEN}🎉 Virtual environment validation completed successfully${NC}"
    return 0  # Valid
}

# Function to create virtual environment with retry logic
create_venv() {
    echo -e "${YELLOW}📦 Creating virtual environment...${NC}"
    
    local venv_dir="$SCRIPT_DIR/.venv"
    
    # Remove any existing .venv directory first
    if [ -d "$venv_dir" ]; then
        echo -e "${YELLOW}📦 Removing existing virtual environment at $venv_dir...${NC}"
        rm -rf "$venv_dir"
        echo -e "${GREEN}   ✓ Removed existing .venv directory${NC}"
    fi
    
    # Show what Python we're using
    echo -e "${BLUE}🐍 Creating venv with: $PYTHON_CMD${NC}"
    echo -e "${BLUE}   Python version: $($PYTHON_CMD --version)${NC}"
    echo -e "${BLUE}   Python path: $(which $PYTHON_CMD)${NC}"
    
    # Check current directory permissions
    echo -e "${BLUE}📁 Current directory: $(pwd)${NC}"
    echo -e "${BLUE}   Directory permissions: $(ls -ld . | awk '{print $1, $3, $4}')${NC}"
    
    # Ensure we're in the script directory
    cd "$SCRIPT_DIR"
    
    # Try creating virtual environment with explicit paths
    echo -e "${YELLOW}🔧 Running: $PYTHON_CMD -m venv .venv (in $SCRIPT_DIR)${NC}"
    if $PYTHON_CMD -m venv .venv 2>&1; then
        echo -e "${GREEN}✅ Virtual environment creation command completed successfully${NC}"
    else
        echo -e "${RED}❌ Failed to create virtual environment with $PYTHON_CMD${NC}"
        
        # Check if venv module is available
        echo -e "${BLUE}🔍 Testing venv module availability...${NC}"
        if ! $PYTHON_CMD -m venv --help >/dev/null 2>&1; then
            echo -e "${RED}❌ Python venv module is not available${NC}"
            echo -e "${YELLOW}Module test output:${NC}"
            $PYTHON_CMD -m venv --help 2>&1 || true
            echo ""
            echo "Please install python3-venv package:"
            echo "  sudo apt-get update && sudo apt-get install python3-venv"
            
            # Try alternative: create venv using system python directly
            echo -e "${YELLOW}🔧 Trying alternative method with system Python...${NC}"
            if [ -x "/usr/bin/python3" ]; then
                if /usr/bin/python3 -m venv .venv 2>&1; then
                    echo -e "${GREEN}✅ Alternative method succeeded${NC}"
                    PYTHON_CMD="/usr/bin/python3"
                else
                    echo -e "${RED}❌ Alternative method also failed${NC}"
                    return 1
                fi
            else
                return 1
            fi
        else
            echo -e "${YELLOW}Venv module is available, but creation failed. Checking other issues...${NC}"
            
            # Check if it's a permissions issue
            if [ ! -w "." ]; then
                echo -e "${RED}❌ Current directory is not writable${NC}"
                echo "Please ensure you have write permissions in the current directory"
                return 1
            fi
            
            # Check available disk space
            echo -e "${BLUE}💾 Disk space:${NC}"
            df -h . | tail -1
            return 1
        fi
    fi
    
    # Fix any broken symlinks that might have been created
    echo -e "${BLUE}🔧 Checking and fixing potential symlink issues...${NC}"
    local venv_bin="$SCRIPT_DIR/.venv/bin"
    
    # Get the actual system Python path
    local system_python=$(readlink -f $(which $PYTHON_CMD))
    echo -e "${BLUE}   System Python resolves to: $system_python${NC}"
    
    if [ -L "$venv_bin/python3" ]; then
        local target=$(readlink "$venv_bin/python3")
        echo -e "${BLUE}   python3 symlink points to: $target${NC}"
        if [ ! -e "$venv_bin/python3" ]; then
            echo -e "${YELLOW}   ⚠️  Fixing broken python3 symlink${NC}"
            rm -f "$venv_bin/python3"
            ln -sf "$system_python" "$venv_bin/python3"
            echo -e "${GREEN}   ✓ Created new symlink: python3 -> $system_python${NC}"
        fi
    fi
    
    if [ -L "$venv_bin/python" ]; then
        local target=$(readlink "$venv_bin/python")
        echo -e "${BLUE}   python symlink points to: $target${NC}"
        if [ ! -e "$venv_bin/python" ]; then
            echo -e "${YELLOW}   ⚠️  Fixing broken python symlink${NC}"
            rm -f "$venv_bin/python"
            if [ -x "$venv_bin/python3" ]; then
                ln -sf python3 "$venv_bin/python"
                echo -e "${GREEN}   ✓ Created new symlink: python -> python3${NC}"
            else
                ln -sf "$system_python" "$venv_bin/python"
                echo -e "${GREEN}   ✓ Created new symlink: python -> $system_python${NC}"
            fi
        fi
    fi
    
    # Ensure pip is working too
    if [ -f "$venv_bin/pip3" ] && [ ! -L "$venv_bin/pip" ]; then
        ln -sf pip3 "$venv_bin/pip"
        echo -e "${GREEN}   ✓ Created pip symlink: pip -> pip3${NC}"
    fi
    
    # Show what was created immediately after creation
    echo -e "${GREEN}✅ Virtual environment creation command completed${NC}"
    echo -e "${BLUE}📁 Checking what was created...${NC}"
    
    if [ -d ".venv" ]; then
        echo -e "${GREEN}   ✓ .venv directory exists${NC}"
        echo -e "${BLUE}   📂 Directory size: $(du -sh .venv | cut -f1)${NC}"
        
        if [ -d ".venv/bin" ]; then
            echo -e "${GREEN}   ✓ bin directory exists${NC}"
            echo -e "${BLUE}   🔧 Contents of .venv/bin:${NC}"
            ls -la .venv/bin/ | grep -E "(python|pip|activate)" || echo -e "${YELLOW}   No python/pip/activate files found${NC}"
        else
            echo -e "${RED}   ❌ bin directory missing${NC}"
            echo -e "${BLUE}   Contents of .venv:${NC}"
            ls -la .venv/ || echo -e "${RED}   Cannot list .venv contents${NC}"
        fi
    else
        echo -e "${RED}❌ .venv directory was not created${NC}"
        exit 1
    fi
    
    # Try to understand why validation might fail
    echo -e "${BLUE}🧪 Pre-validation checks...${NC}"
    
    # Check for python executables specifically
    for pyexe in .venv/bin/python .venv/bin/python3; do
        if [ -f "$pyexe" ]; then
            echo -e "${GREEN}   ✓ Found: $pyexe${NC}"
            echo -e "${BLUE}     Permissions: $(ls -l "$pyexe" | awk '{print $1}')${NC}"
            echo -e "${BLUE}     Points to: $(readlink -f "$pyexe" 2>/dev/null || echo "regular file")${NC}"
        else
            echo -e "${YELLOW}   ✗ Not found: $pyexe${NC}"
        fi
    done
    
    # Verify the virtual environment was created properly
    echo -e "${YELLOW}🔍 Running full validation...${NC}"
    if validate_venv; then
        echo -e "${GREEN}✅ Virtual environment created and validated successfully${NC}"
        return 0
    else
        echo -e "${RED}❌ Virtual environment creation failed validation${NC}"
        echo -e "${YELLOW}   Will attempt to continue anyway...${NC}"
        return 1
    fi
}

# Create or recreate virtual environment
echo -e "${YELLOW}📦 Checking virtual environment...${NC}"

# TEMPORARY BYPASS: Skip virtual environment validation and try to use system Python directly
echo -e "${BLUE}🚧 TEMPORARY BYPASS: Attempting to run with system Python to debug the issue${NC}"

# Check if we can run Flask directly with system Python
if $PYTHON_CMD -c "import flask; print(f'Flask {flask.__version__} available')" 2>/dev/null; then
    echo -e "${GREEN}✅ Flask is available in system Python${NC}"
    
    # Set Flask environment variables for system Python
    export FLASK_APP=VulnerableApp
    export FLASK_ENV=development
    export FLASK_DEBUG=1
    
    # Create instance directory
    mkdir -p instance
    
    echo -e "${GREEN}🚀 Starting Vulnerable Web Application with system Python...${NC}"
    echo -e "${BLUE}🌐 Server will be available at: http://localhost:4444${NC}"
    echo ""
    
    # Launch the application using system Flask
    $PYTHON_CMD -m flask run --host=0.0.0.0 --port=4444
    
    echo -e "${YELLOW}🚧 System Python method completed${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠️  Flask not available in system Python, proceeding with virtual environment method...${NC}"
fi

# Original virtual environment logic (only runs if system Python doesn't have Flask)
validate_venv
venv_status=$?

echo -e "${BLUE}🔍 Virtual environment status: $venv_status${NC}"

if [ $venv_status -eq 1 ]; then
    # Doesn't exist, create it
    echo -e "${YELLOW}📦 Virtual environment doesn't exist, creating new one...${NC}"
    create_venv
elif [ $venv_status -eq 2 ]; then
    # Corrupted, remove and recreate
    echo -e "${YELLOW}📦 Virtual environment appears corrupted, recreating...${NC}"
    create_venv
else
    echo -e "${GREEN}✅ Virtual environment is valid${NC}"
fi

echo -e "${BLUE}🔍 Post-creation validation...${NC}"
validate_venv
final_status=$?
if [ $final_status -ne 0 ]; then
    echo -e "${RED}❌ Virtual environment is still not working after creation/recreation${NC}"
    echo -e "${RED}   Final status: $final_status${NC}"
    echo -e "${YELLOW}🚧 Attempting fallback to system Python installation...${NC}"
    
    # Try to install Flask to system Python as fallback
    if command -v pip3 >/dev/null 2>&1; then
        echo -e "${YELLOW}📦 Installing Flask to system Python...${NC}"
        pip3 install Flask Werkzeug --user
        
        if $PYTHON_CMD -c "import flask; print('Flask installed successfully')" 2>/dev/null; then
            echo -e "${GREEN}✅ Flask installed to system Python${NC}"
            
            # Set Flask environment variables
            export FLASK_APP=VulnerableApp
            export FLASK_ENV=development
            export FLASK_DEBUG=1
            
            # Create instance directory
            mkdir -p instance
            
            echo -e "${GREEN}🚀 Starting with system Python + Flask...${NC}"
            $PYTHON_CMD -m flask run --host=0.0.0.0 --port=4444
            exit 0
        fi
    fi
    
    echo -e "${RED}❌ All methods failed. Cannot start application.${NC}"
    exit 1
fi

# Activate virtual environment
echo -e "${YELLOW}🔧 Activating virtual environment...${NC}"
if [ -f ".venv/bin/activate" ]; then
    source .venv/bin/activate
    # After activation, use 'python' instead of the original PYTHON_CMD
    # as virtual environments typically provide 'python' regardless of the original command
    PYTHON_CMD="python"
    
    # Verify activation worked
    if ! command -v python >/dev/null 2>&1; then
        echo -e "${RED}❌ Error: Virtual environment activation failed${NC}"
        echo "Python command not available after activation"
        exit 1
    fi
    
    # Verify we're using the virtual environment's Python
    CURRENT_PYTHON=$(which python)
    if [[ "$CURRENT_PYTHON" != *".venv"* ]]; then
        echo -e "${RED}❌ Error: Not using virtual environment Python${NC}"
        echo "Current Python: $CURRENT_PYTHON"
        echo "Expected to contain: .venv"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Virtual environment activated successfully${NC}"
    echo -e "${BLUE}🐍 Using Python: $(python --version) at $CURRENT_PYTHON${NC}"
else
    echo -e "${RED}❌ Error: Virtual environment activation script not found${NC}"
    echo "Expected: .venv/bin/activate"
    echo "Please ensure the virtual environment was created successfully"
    exit 1
fi

# Check if pip needs upgrading
echo -e "${YELLOW}📦 Checking pip version...${NC}"
CURRENT_PIP=$(pip --version | awk '{print $2}')
if command -v curl &> /dev/null; then
    LATEST_PIP=$(curl -s https://pypi.org/pypi/pip/json | grep -o '"version":"[^"]*"' | head -1 | cut -d'"' -f4 2>/dev/null || echo "$CURRENT_PIP")
elif command -v wget &> /dev/null; then
    LATEST_PIP=$(wget -qO- https://pypi.org/pypi/pip/json | grep -o '"version":"[^"]*"' | head -1 | cut -d'"' -f4 2>/dev/null || echo "$CURRENT_PIP")
else
    LATEST_PIP="$CURRENT_PIP"  # Skip check if no curl/wget
fi

if [ "$CURRENT_PIP" != "$LATEST_PIP" ] && [ "$LATEST_PIP" != "$CURRENT_PIP" ]; then
    echo -e "${YELLOW}📦 Upgrading pip from $CURRENT_PIP to $LATEST_PIP...${NC}"
    pip install --upgrade pip
else
    echo -e "${GREEN}✅ Pip is already up to date ($CURRENT_PIP)${NC}"
fi

# Install requirements with smart checking
if [ -f "requirements.txt" ]; then
    echo -e "${YELLOW}📦 Checking requirements...${NC}"
    
    # Check if all packages are already satisfied
    if pip check >/dev/null 2>&1; then
        # Double-check by trying to import key packages
        if python -c "import flask, flask_sqlalchemy, flask_login, requests" >/dev/null 2>&1; then
            echo -e "${GREEN}✅ All requirements already satisfied${NC}"
        else
            echo -e "${YELLOW}📦 Installing missing requirements...${NC}"
            pip install -r requirements.txt --quiet
            if [ $? -ne 0 ]; then
                echo -e "${RED}❌ Failed to install requirements${NC}"
                exit 1
            fi
        fi
    else
        echo -e "${YELLOW}📦 Installing/updating requirements...${NC}"
        pip install -r requirements.txt --quiet
        if [ $? -ne 0 ]; then
            echo -e "${RED}❌ Failed to install requirements${NC}"
            exit 1
        fi
    fi
else
    echo -e "${YELLOW}📦 Checking Flask installation...${NC}"
    if python -c "import flask; print('Flask version:', flask.__version__)" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Flask is already installed${NC}"
    else
        echo -e "${YELLOW}📦 Installing Flask manually...${NC}"
        pip install Flask==2.3.3 Werkzeug==2.3.7
        if [ $? -ne 0 ]; then
            echo -e "${RED}❌ Failed to install Flask${NC}"
            exit 1
        fi
    fi
fi

# Create instance directory
mkdir -p instance

# Set Flask environment variables
export FLASK_APP=VulnerableApp
export FLASK_ENV=development
export FLASK_DEBUG=1

echo -e "${GREEN}✅ Environment setup complete!${NC}"
echo ""
echo -e "${GREEN}🚀 Starting Vulnerable Web Application...${NC}"
echo -e "${BLUE}🌐 Server will be available at: http://localhost:4444${NC}"
echo ""
echo -e "${YELLOW}Press Ctrl+C to stop the server${NC}"
echo ""

# Launch the application using flask run
flask run --host=0.0.0.0 --port=4444

# Deactivate virtual environment when done
deactivate
