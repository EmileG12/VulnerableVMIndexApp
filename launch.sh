#!/bin/bash

# VulnerableVMIndexApp Launch Script
# This script launches the Flask web application

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting VulnerableVMIndexApp...${NC}"

# Set the Flask application environment variable
export FLASK_APP=app:create_app

# Optional: Set Flask environment to development for debugging
export FLASK_ENV=development

# Change to the application directory
cd "$(dirname "$0")"

# Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    if ! command -v python &> /dev/null; then
        echo -e "${RED}❌ Error: Python is not installed or not in PATH${NC}"
        echo "Please install Python 3.7+ and try again"
        exit 1
    else
        PYTHON_CMD="python"
    fi
else
    PYTHON_CMD="python3"
fi

echo -e "${BLUE}🐍 Using Python: $($PYTHON_CMD --version)${NC}"

# Function to validate virtual environment
validate_venv() {
    local venv_path=".venv"
    
    # Check if basic structure exists
    if [ ! -d "$venv_path" ]; then
        return 1  # Doesn't exist
    fi
    
    # Check for activation script
    if [ ! -f "$venv_path/bin/activate" ]; then
        echo -e "${RED}❌ Virtual environment missing activation script${NC}"
        return 2  # Corrupted
    fi
    
    # Check for Python executable
    if [ ! -f "$venv_path/bin/python" ] && [ ! -f "$venv_path/bin/python3" ]; then
        echo -e "${RED}❌ Virtual environment missing Python executable${NC}"
        return 2  # Corrupted
    fi
    
    # Check for pip
    if [ ! -f "$venv_path/bin/pip" ] && [ ! -f "$venv_path/bin/pip3" ]; then
        echo -e "${RED}❌ Virtual environment missing pip${NC}"
        return 2  # Corrupted
    fi
    
    # Test if Python actually works in the venv
    if ! "$venv_path/bin/python" -c "import sys; print('Python OK')" >/dev/null 2>&1; then
        echo -e "${RED}❌ Virtual environment Python executable is broken${NC}"
        return 2  # Corrupted
    fi
    
    return 0  # Valid
}

# Create or recreate virtual environment
echo -e "${YELLOW}📦 Checking virtual environment...${NC}"
validate_venv
venv_status=$?

if [ $venv_status -eq 1 ]; then
    # Doesn't exist, create it
    echo -e "${YELLOW}📦 Creating virtual environment...${NC}"
    $PYTHON_CMD -m venv .venv
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Failed to create virtual environment${NC}"
        echo "Trying to install python3-venv package..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y python3-venv
            $PYTHON_CMD -m venv .venv
        elif command -v yum &> /dev/null; then
            sudo yum install -y python3-venv
            $PYTHON_CMD -m venv .venv
        else
            echo -e "${RED}❌ Could not install python3-venv package${NC}"
            exit 1
        fi
    fi
elif [ $venv_status -eq 2 ]; then
    # Corrupted, remove and recreate
    echo -e "${YELLOW}📦 Virtual environment appears corrupted, recreating...${NC}"
    rm -rf .venv
    $PYTHON_CMD -m venv .venv
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Failed to recreate virtual environment${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✅ Virtual environment is valid${NC}"
fi

# Activate virtual environment
echo -e "${YELLOW}🔧 Activating virtual environment...${NC}"
if [ -f ".venv/bin/activate" ]; then
    source .venv/bin/activate
    
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
    exit 1
fi

# Install requirements if requirements.txt exists
if [ -f "requirements.txt" ]; then
    echo -e "${YELLOW}📦 Installing/updating dependencies...${NC}"
    pip install -r requirements.txt
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Failed to install requirements${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Dependencies installed successfully${NC}"
fi

# Launch the Flask application
echo -e "${GREEN}🚀 Launching Flask application...${NC}"
echo -e "${BLUE}🌐 Server will be available at: http://localhost:5000${NC}"
echo -e "${YELLOW}Press Ctrl+C to stop the application${NC}"
echo ""
flask run --host=0.0.0.0 --port=5000
