#!/bin/bash

# Automated Penetration Testing Script
# IMPORTANT: Use this script responsibly and only on systems you have permission to test.

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Function to check if a command exists
command_exists () {
    type "$1" &> /dev/null ;
}

# Check for required tools
required_tools=("nmap" "nikto" "sqlmap" "dirb" "hydra")
for tool in "${required_tools[@]}"; do
    if ! command_exists "$tool"; then
        echo "Error: $tool is not installed. Please install it and try again."
        exit 1
    fi
done

# Get target from user input
read -p "Enter the target IP address or hostname: " TARGET

# Create output directory
OUTPUT_DIR="pentest_results_$(date +%Y%m%d_%H%M%S)"
mkdir "$OUTPUT_DIR"

echo "Starting automated penetration test on $TARGET..."

# 1. Reconnaissance
echo "Performing reconnaissance..."
nmap -sV -sC -O -oN "$OUTPUT_DIR/nmap_scan.txt" "$TARGET"

# 2. Web vulnerability scanning
echo "Scanning for web vulnerabilities..."
nikto -h "$TARGET" -output "$OUTPUT_DIR/nikto_scan.txt"

# 3. Directory bruteforcing
echo "Performing directory bruteforce..."
dirb "http://$TARGET" -o "$OUTPUT_DIR/dirb_results.txt"

# 4. SQL injection testing
echo "Testing for SQL injection vulnerabilities..."
sqlmap -u "http://$TARGET" --batch --forms --output-dir="$OUTPUT_DIR/sqlmap"

# 5. Basic password bruteforcing (example with FTP, adjust as needed)
echo "Attempting basic password bruteforce on FTP..."
hydra -L /usr/share/wordlists/metasploit/common_users.txt -P /usr/share/wordlists/metasploit/common_passwords.txt ftp://"$TARGET" -o "$OUTPUT_DIR/hydra_ftp.txt"

echo "Automated penetration test completed. Results are stored in the $OUTPUT_DIR directory."
echo "Please review the results carefully and perform additional manual testing as needed."
echo "Remember to operate within the scope of your engagement and with proper authorization."
