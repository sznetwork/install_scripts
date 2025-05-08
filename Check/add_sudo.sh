#!/bin/bash

echo "not tested"

# Function to display error messages
display_error() {
    echo "Error: $1"
    exit 1
}

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
    display_error "Please run this script as root"
fi

# Prompt for username
read -p "Enter the desired username: " username


# Add user to sudo group
usermod -aG sudo "$username"

# Verify sudo privileges
sudo -l -U "$username"

# Switch to user and test sudo
su "$username" -c "sudo apt update"

echo "Installation completed successfully."
