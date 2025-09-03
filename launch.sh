#!/bin/bash

# VulnerableVMIndexApp Launch Script
# This script launches the Flask web application

echo "Starting VulnerableVMIndexApp..."

# Set the Flask application environment variable
export FLASK_APP=app:create_app

# Optional: Set Flask environment to development for debugging
export FLASK_ENV=development

# Change to the application directory
cd "$(dirname "$0")"

# Check if Python virtual environment exists and activate it
if [ -d ".venv" ]; then
    echo "Activating virtual environment..."
    source .venv/bin/activate
fi

# Install requirements if requirements.txt exists
if [ -f "requirements.txt" ]; then
    echo "Installing/updating dependencies..."
    pip install -r requirements.txt
fi

# Launch the Flask application
echo "Launching Flask application on http://localhost:5000"
echo "Press Ctrl+C to stop the application"
flask run --host=0.0.0.0 --port=5000
