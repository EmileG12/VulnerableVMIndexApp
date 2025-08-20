# VulnerableVMIndexApp

## Overview

**VulnerableVMIndexApp** is a Flask-based web application designed to serve as an index and launcher for penetration testing exercises on a virtual machine (VM). Its primary purpose is to provide students with an easy-to-use interface for selecting and launching vulnerable applications, each representing a different penetration testing scenario.

## Features

- **Exercise Index:** Automatically lists all available exercises by scanning the `Exercises` folder for subdirectories.
- **Exercise Selection:** Students can select an exercise from a dropdown menu.
- **Daemonization:** Upon selection, the application will daemonize (background-launch) the corresponding vulnerable application by executing its `command.sh` script.
- **Task Display:** After launching the vulnerable application, the web app can display the tasks and instructions associated with the selected exercise.

## How It Works

1. **Exercise Discovery:** The app scans the `Exercises` directory for subfolders, each representing a different exercise.
2. **User Selection:** Students choose an exercise from the web interface.
3. **Application Launch:** The app runs the `command.sh` script found in the selected exercise's folder, starting the vulnerable application as a background process.
4. **Task Presentation:** The app then displays the relevant tasks and instructions for the exercise.

## Intended Use

This application is intended to be deployed on a VM used for penetration testing training. It acts as a central hub for students, allowing them to easily select and launch exercises without needing to manually start vulnerable applications or navigate the filesystem.


## Folder Structure

```
VulnerableVMIndexApp/
├── app/
│   ├── main.py
│   ├── rundaemon.py
│   └── ...
├── Exercises/
│   ├── Exercise1/
│   │   ├── command.sh
│   │   └── VulnerableApp/
│   ├── Exercise2/
│   │   ├── command.sh
│   │   └── VulnerableApp/
│   └── ...
├── templates/
│   └── index.html
└── README.md
```

## Getting Started

1. **Install dependencies:**  
   `pip install -r requirements.txt`

2. **Set up the VM:**  
   Place your exercises in the `Exercises` folder, each with its own `command.sh` script and vulnerable application.

   Please make sure that any requirements for additional exercises are also installed on the VM

3. **Run the application inside the VM:**  
   ```
   export FLASK_APP=app:create_app
   flask run
   ```

4. **Access the web interface:**  
   On another VM connected to the hub, open your browser and navigate to `http://localhost:5000`.

## License

This project is intended for educational use only.