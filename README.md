# VulnerableVMIndexApp

## Overview

**VulnerableVMIndexApp** is a Flask-based web application designed to serve as an index and launcher for penetration testing exercises on a virtual machine (VM). Its primary purpose is to provide students with an easy-to-use interface for selecting and launching vulnerable applications, each representing a different penetration testing scenario.

---

# Part A: Instructor Setup Guide

This section is for **instructors** who need to set up a new Ubuntu VM with the VulnerableVMIndexApp from scratch.

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
│   └── main.py
├── Exercises/
│   ├── Exercise1/
│   │   ├── command.sh
│   │   ├── FTPExercise.md
│   │   └── VulnerableApp/
│   └── ...
├── templates/
│   └── index.html
├── launch.sh
└── README.md
```

## Instructor Setup Instructions

### 1. Install Dependencies on Ubuntu VM
```bash
cd /path/to/VulnerableVMIndexApp
sudo apt update
sudo apt install python3 python3-pip python3-venv
```

### 2. Set up Virtual Environment (Recommended)
```bash
python3 -m venv venv
source venv/bin/activate
pip install flask
```

### 3. Configure Exercises
- Place your exercises in the `Exercises` folder
- Each exercise should have its own `command.sh` script and vulnerable application
- Ensure any additional requirements for exercises are installed on the VM

### 4. Use the Launch Script
The application includes a `launch.sh` script that automatically:
- Sets up and activates the Python virtual environment
- Installs required dependencies (Flask)
- Starts the Flask application on all network interfaces (0.0.0.0:5000)
- Provides proper error handling and logging

**To use the launch script:**
```bash
chmod +x launch.sh
./launch.sh
```

The script will output the application URL and can be accessed from other VMs on the same network.

### 5. Firewall Configuration (if needed)
```bash
sudo ufw allow 5000
sudo ufw allow 4444  # For exercise applications
```

---

# Part B: Student Setup Guide

This section is for **students** who need to set up their VMs to access an existing VulnerableVMIndexApp package.

## Prerequisites

- VirtualBox installed on your host machine
- Ubuntu VM image (with VulnerableVMIndexApp already installed)
- Kali Linux VM image (for penetration testing)
- At least 8GB RAM on host machine

## Step 1: VM Resource Allocation

### Ubuntu VM Settings (Application Server)
1. **Right-click** the Ubuntu VM in VirtualBox Manager → **Settings**
2. **System** tab:
   - **Base Memory**: Allocate 2-4GB RAM (2048-4096 MB)
   - **Processors**: Assign 2 CPU cores
   - **Enable PAE/NX**: Check this option
3. **Display** tab:
   - **Video Memory**: Set to 64-128 MB
4. Click **OK** to save settings

### Kali Linux VM Settings (Penetration Testing)
1. **Right-click** the Kali Linux VM in VirtualBox Manager → **Settings**
2. **System** tab:
   - **Base Memory**: Allocate 2-4GB RAM (2048-4096 MB)
   - **Processors**: Assign 2 CPU cores
   - **Enable PAE/NX**: Check this option
3. **Storage** tab:
   - Ensure enough disk space is allocated
4. **Display** tab:
   - **Video Memory**: Set to 128 MB
5. Click **OK** to save settings

## Step 2: Network Configuration (Simple Setup)

### Set Up Network for Ubuntu VM
1. **Right-click** your Ubuntu VM → **Settings**
2. Click **Network** tab
3. **Adapter 1** tab:
   - Check **"Enable Network Adapter"**
   - Change **"Attached to"** dropdown to **"Host-only Adapter"**
   - Leave everything else as default
4. Click **OK**

### Set Up Network for Kali Linux VM
1. **Right-click** your Kali Linux VM → **Settings**
2. Click **Network** tab
3. **Adapter 1** tab:
   - Check **"Enable Network Adapter"**
   - Change **"Attached to"** dropdown to **"Host-only Adapter"**
   - Leave everything else as default
4. Click **OK**

> **Note**: VirtualBox will automatically create a host-only network if one doesn't exist. Both VMs will be able to talk to each other on this private network.

## Step 3: Start and Configure VMs

### Start Ubuntu VM
1. **Start** the Ubuntu VM
2. Log in to the system
3. Open terminal and check network configuration:
```bash
ip addr show
# Note down the IP address assigned (likely 192.168.56.xxx)
```

### Start Kali Linux VM
1. **Start** the Kali Linux VM
2. Log in to the system
3. Open terminal and check network configuration:
```bash
ip addr show
# Verify you have an IP in the same subnet (192.168.56.xxx)
```

## Step 4: Network Discovery and Application Access

### Discover Ubuntu VM from Kali Linux
1. On the **Kali Linux VM**, open terminal
2. Scan the host-only network to discover the Ubuntu machine:
```bash
# Scan the entire host-only subnet
nmap -sn 192.168.56.0/24
```
3. **Identify the Ubuntu VM** IP address from the scan results
4. **Verify connectivity**:
```bash
# Replace X.X.X.X with the Ubuntu VM's IP
ping 192.168.56.X
```

### Launch the Application on Ubuntu VM
1. On the **Ubuntu VM**, open a terminal and navigate to the application directory:
```bash
cd VulnerableVMIndexApp/
```
2. **Start the application** with:
```bash
./launch.sh
```
3. The application should start and display:
```
 * Running on http://127.0.0.1:5000
 * Running on all addresses (0.0.0.0)
 * Running on http://192.168.56.X:5000
```
4. **Note the IP address** shown in the output

### Access Web Application from Kali Linux
1. On the **Kali Linux VM**, open a web browser (Firefox)
2. Navigate to the Ubuntu VM's IP address:
```
http://192.168.56.X:5000
```
   (Replace X with the actual IP address from previous steps)
3. You should see the **VulnerableVMIndexApp** main page with exercise selection dropdown

### Verify Exercise Access
1. **Select an exercise** from the dropdown (e.g., "Exercise1")
2. Click **"Select Exercise"**
3. Click **"Launch Exercise"** to start the vulnerable application
4. The exercise will launch on port 4444:
```
http://192.168.56.X:4444
```

## Troubleshooting

### Resource Issues
- **VM running slowly**: Increase RAM allocation or reduce other running applications
- **Application won't start**: Ensure sufficient disk space and memory allocated to Ubuntu VM

### Application Issues
- **Port conflicts**: Ensure no other services are using ports 5000 or 4444
- **Exercise won't launch**: Check application logs and ensure all dependencies are installed

## Security Note

This setup is designed for **educational purposes only** in an isolated environment. The host-only network adapter ensures that the vulnerable applications are not accessible from outside your local machine, providing a safe learning environment for penetration testing exercises.

## License

This project is intended for educational use only.