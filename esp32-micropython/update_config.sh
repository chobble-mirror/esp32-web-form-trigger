#!/usr/bin/env bash

# Script to update device ID and pulse duration in config.py

# Print header
echo "ESP32 Configuration Updater"
echo "==========================="

# Set up Python virtual environment and install rshell
echo "Setting up Python environment..."
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

# Update config.py file
echo "Updating config.py..."
# Handle sed differences between GNU (Linux) and BSD (macOS) versions
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS (BSD) version requires extension for -i
    sed -i '' "s/DEVICE_ID = \".*\"/DEVICE_ID = \"$device_id\"/" config.py
    sed -i '' "s/PULSE_DURATION_MS = [0-9]*/PULSE_DURATION_MS = $pulse_duration/" config.py
else
    # Linux (GNU) version
    sed -i "s/DEVICE_ID = \".*\"/DEVICE_ID = \"$device_id\"/" config.py
    sed -i "s/PULSE_DURATION_MS = [0-9]*/PULSE_DURATION_MS = $pulse_duration/" config.py
fi

echo "Updated config.py with Device ID: $device_id and Pulse Duration: ${pulse_duration}ms"

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