import os
import subprocess
from time import sleep


def list_script_filepaths():
    """
    Lists all file paths inside the 'scripts' directory located one level above the current working directory.

    Returns:
        List[str]: A list of absolute paths to each file in the 'scripts' directory.
    """
    parent_dir = os.path.abspath(os.path.join(os.getcwd()))
    scripts_dir = os.path.join(parent_dir, 'Exercises')

    if not os.path.exists(scripts_dir):
        raise FileNotFoundError(f"'Exercises' directory not found at: {scripts_dir}")

    filepaths = []
    for root, folders, files in os.walk(scripts_dir):
        for folder in folders:
            filepaths.append(os.path.join(root, folder))

    return filepaths

import socket

def find_free_port():
    """
    Finds and returns a free port on localhost.
    Returns:
        int: An available port number.
    """
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.bind(('', 0))
        return s.getsockname()[1] 

def run_exercise(folderpath):
    filepath= os.path.join(folderpath, 'command.sh')
    if not os.path.isfile(filepath):
        raise FileNotFoundError(f"Bash script not found at: {filepath}")
    try:
        # Find a user port that is available
        port = find_free_port()
        if port is None:
            raise RuntimeError("No free port found to run the Flask application.")
        # Start Flask directly without nohup and background process
        process = subprocess.Popen(
            ['flask', 'run', '-h', 'localhost', '-p', str(port)],
            cwd=folderpath,
            env={**os.environ, 'FLASK_APP': 'VulnerableApp'},
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        print(f"Flask server started with PID: {process.pid}")
        
        # Give the process a moment to start
        sleep(2)
        
        # Check if the process is still running
        if process.poll() is None:
            print(f"Flask process is running successfully on PID {process.pid}")
            return process
        else:
            # If process exited, capture the output to see why
            stdout, stderr = process.communicate()
            print(f"Flask process exited with return code: {process.returncode}")
            if stdout:
                print(f"STDOUT: {stdout.decode()}")
            if stderr:
                print(f"STDERR: {stderr.decode()}")
            return None
            
    except Exception as e:
        print(f"Error starting Flask process: {e}")
        raise

def run_exercise_command(command_str, cwd=None):
    """
    Runs a given bash command string in a subprocess.

    Args:
        command_str (str): The bash command to execute.
        cwd (str, optional): The working directory for the command.

    Returns:
        subprocess.Popen: The process object if started successfully, None otherwise.
    """
    try:
        env = os.environ.copy()
        env['FLASK_APP'] = 'VulnerableApp'
        process = subprocess.Popen(
            command_str,
            shell=True,
            cwd=cwd,
            env=env,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        print(f"Command started with PID: {process.pid}")

        sleep(2)

        if process.poll() is None:
            print(f"Process is running successfully on PID {process.pid}")
            return process
        else:
            stdout, stderr = process.communicate()
            print(f"Process exited with return code: {process.returncode}")
            if stdout:
                print(f"STDOUT: {stdout.decode()}")
            if stderr:
                print(f"STDERR: {stderr.decode()}")
            return None

    except Exception as e:
        print(f"Error starting process: {e}")
        raise

print(list_script_filepaths())
process = run_exercise(list_script_filepaths()[0])
if process:
    print(f"Keeping Flask process {process.pid} alive for 60 seconds...")
    # sleep(60)
    # print("Terminating Flask process...")
    # process.terminate()
    # process.wait()
    # print("Flask process terminated.")
else:
    print("Failed to start Flask process.")