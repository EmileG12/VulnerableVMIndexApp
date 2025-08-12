import os
import sqlite3
from pathlib import Path
from flask import Blueprint, render_template, render_template_string, request
from flask_login import login_required
from .rundaemon import run_exercise_command
from . import db

main = Blueprint('main', __name__)
exercise_path = str(Path.cwd() /'Exercises')

def list_exercise_folders(exercise_path):
    """
    Returns a list of absolute paths to each folder directly inside the Exercises folder.
    Only includes directories, not files, and does not traverse above or below.
    """
    exercise_dir = Path(exercise_path)
    if not exercise_dir.is_dir():
        raise FileNotFoundError(f"'{exercise_path}' is not a valid directory.")
    return [str(p.resolve()) for p in exercise_dir.iterdir() if p.is_dir()]

@main.route('/select_exercise', methods=['POST'])
def select_exercise():
    selected_exercise = request.form.get('exercise')
    script_path = Path(selected_exercise) / 'command.sh'
    if not os.path.isfile(script_path):
        raise FileNotFoundError(f"Command script not found at: {script_path}")
    command = open(script_path).read()
    if not selected_exercise or not script_path.is_file():
        return render_template_string("No exercise selected or command script not found.")
    if not selected_exercise:
        return render_template_string("No exercise selected.")
    # Run the command script
    try:
        run_exercise_command(
            f"bash {script_path}",
            cwd=Path(selected_exercise)
        )
    except Exception as e:
        return render_template_string(f"Error running command: {e}")

    # Here you can add logic to handle the selected exercise, e.g., redirecting to a specific page
    return str(exercise_path)

@main.route('/index')
def index():
    exercise_folders = list_exercise_folders(exercise_path)
    return render_template('index.html', exercises=exercise_folders)