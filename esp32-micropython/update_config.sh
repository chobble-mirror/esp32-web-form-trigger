#!/usr/bin/env bash

# Script to update device ID and pulse duration in config.py

# Print header
echo "ESP32 Configuration Updater"
echo "==========================="

# Check for Python installation
check_python() {
    if ! command -v python3 &> /dev/null; then
        echo "Python 3 is not installed or not in the PATH."
        echo "Please install Python 3 and try again."
        exit 1
    fi

    # Check for venv module
    if ! python3 -c "import venv" &> /dev/null; then
        echo "Python 'venv' module not available. Please install it and try again."
        echo "On Debian/Ubuntu: sudo apt-get install python3-venv"
        echo "On Fedora: sudo dnf install python3-libs"
        echo "On macOS: brew install python3"
        exit 1
    fi
}

# Set up Python virtual environment and install rshell
echo "Setting up Python environment..."
check_python
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi

# Activate virtual environment
if [[ "$OSTYPE" == "darwin"* ]] || [[ "$OSTYPE" == "linux-gnu"* ]]; then
    source venv/bin/activate
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    source venv/Scripts/activate
else
    echo "Unsupported OS type: $OSTYPE"
    exit 1
fi

# Install rshell if not already installed
if ! pip list | grep -q "rshell"; then
    echo "Installing rshell..."
    pip install rshell
fi

# Get device ID
read -p "Enter Device ID: " device_id
if [ -z "$device_id" ]; then
    echo "Error: Device ID cannot be empty"
    exit 1
fi

# Get pulse duration
read -p "Enter Pulse Duration (milliseconds): " pulse_duration
if ! [[ "$pulse_duration" =~ ^[0-9]+$ ]]; then
    echo "Error: Pulse duration must be a positive number"
    exit 1
fi

# Get WiFi SSID
read -p "Enter WiFi SSID: " wifi_ssid
if [ -z "$wifi_ssid" ]; then
    echo "Error: WiFi SSID cannot be empty"
    exit 1
fi

# Get WiFi password
read -sp "Enter WiFi Password: " wifi_password
echo # Add newline after password input
if [ -z "$wifi_password" ]; then
    echo "Error: WiFi password cannot be empty"
    exit 1
fi

# Update config.py file
echo "Updating config.py..."
# Handle sed differences between GNU (Linux) and BSD (macOS) versions
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS (BSD) version requires extension for -i
    sed -i '' "s/DEVICE_ID = \".*\"/DEVICE_ID = \"$device_id\"/" config.py
    sed -i '' "s/PULSE_DURATION_MS = [0-9]*/PULSE_DURATION_MS = $pulse_duration/" config.py
    # Escape special characters in WiFi SSID and password
    escaped_ssid=$(echo "$wifi_ssid" | sed 's/[\/&]/\\&/g')
    escaped_password=$(echo "$wifi_password" | sed 's/[\/&]/\\&/g')
    sed -i '' "s/WIFI_SSID = '.*'/WIFI_SSID = '$escaped_ssid'/" config.py
    sed -i '' "s/WIFI_PASSWORD = '.*'/WIFI_PASSWORD = '$escaped_password'/" config.py
else
    # Linux (GNU) version
    sed -i "s/DEVICE_ID = \".*\"/DEVICE_ID = \"$device_id\"/" config.py
    sed -i "s/PULSE_DURATION_MS = [0-9]*/PULSE_DURATION_MS = $pulse_duration/" config.py
    # Escape special characters in WiFi SSID and password
    escaped_ssid=$(echo "$wifi_ssid" | sed 's/[\/&]/\\&/g')
    escaped_password=$(echo "$wifi_password" | sed 's/[\/&]/\\&/g')
    sed -i "s/WIFI_SSID = '.*'/WIFI_SSID = '$escaped_ssid'/" config.py
    sed -i "s/WIFI_PASSWORD = '.*'/WIFI_PASSWORD = '$escaped_password'/" config.py
fi

echo "Updated config.py with:"
echo "  Device ID: $device_id"
echo "  Pulse Duration: ${pulse_duration}ms"
echo "  WiFi SSID: $wifi_ssid"
echo "  WiFi Password: $(echo "$wifi_password" | sed 's/./*/g')"

# Ask before copying to device
read -p "Copy files to device? (y/n): " copy_confirm
if [ "$copy_confirm" = "y" ] || [ "$copy_confirm" = "Y" ]; then
    echo "Copying files to device..."
    ./copy_files_to_device
    if [ $? -eq 0 ]; then
        echo "Files copied successfully!"
    else
        echo "Error copying files to device"
        exit 1
    fi
else
    echo "Files not copied. You can manually run ./copy_files_to_device when ready."
fi