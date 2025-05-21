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

# Check if config.py exists
if [ ! -f "config.py" ]; then
    echo "Warning: config.py does not exist. Creating a new one."
    # Set default values
    current_device_id="NEW_DEVICE"
    current_pulse_duration="10"
    current_wifi_ssid="Your Network"
    current_wifi_password="Your password"
else
    # Extract current values from config.py
    current_device_id=$(grep -o 'DEVICE_ID = "[^"]*"' config.py 2>/dev/null | cut -d'"' -f2 || echo "NEW_DEVICE")
    current_pulse_duration=$(grep -o 'PULSE_DURATION_MS = [0-9]*' config.py 2>/dev/null | cut -d' ' -f3 || echo "10")
    current_wifi_ssid=$(grep -o "WIFI_SSID = '[^']*'" config.py 2>/dev/null | cut -d"'" -f2 || echo "Your Network")
    current_wifi_password=$(grep -o "WIFI_PASSWORD = '[^']*'" config.py 2>/dev/null | cut -d"'" -f2 || echo "Your password")
fi

# Get device ID (use current as default)
read -p "Enter Device ID [$current_device_id]: " device_id
device_id=${device_id:-$current_device_id}

# Get pulse duration (use current as default)
read -p "Enter Pulse Duration in milliseconds [$current_pulse_duration]: " pulse_duration
pulse_duration=${pulse_duration:-$current_pulse_duration}
if ! [[ "$pulse_duration" =~ ^[0-9]+$ ]]; then
    echo "Error: Pulse duration must be a positive number"
    exit 1
fi

# Get WiFi SSID (use current as default)
read -p "Enter WiFi SSID [$current_wifi_ssid]: " wifi_ssid
wifi_ssid=${wifi_ssid:-$current_wifi_ssid}

# Get WiFi password (use current as default)
read -p "Enter WiFi Password [$current_wifi_password]: " wifi_password
wifi_password=${wifi_password:-$current_wifi_password}

# Update config.py file
echo "Updating config.py..."

# Escape special characters in WiFi SSID and password
escaped_ssid=$(echo "$wifi_ssid" | sed 's/[\/&]/\\&/g')
escaped_password=$(echo "$wifi_password" | sed 's/[\/&]/\\&/g')

# Check if config.py exists
if [ ! -f "config.py" ]; then
    # Create a new config.py file
    cat > config.py << EOF
DEVICE_ID = "$device_id"

# Board stuff
OPTO_PIN = 18  # Using the same pin that was used for relay
BUTTON_PIN = 15
LED_PIN = 2  # Onboard LED on most ESP32 boards

# Server stuff (probably doesn't need changing)
POST_INTERVAL = 2000 # 2 seconds between attempts
SERVER_URL = "https://esp32.chobble.com"
API_PATH = "/api/v1/credits/claim"

# Known wifi stuff
WIFI_SSID = '$escaped_ssid'
WIFI_PASSWORD = '$escaped_password'

# Credits stuff
PULSE_DURATION_MS = $pulse_duration  # Duration of output pulse in milliseconds
EOF
    echo "Created new config.py file"
else
    # Update existing config.py file
    # Handle sed differences between GNU (Linux) and BSD (macOS) versions
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS (BSD) version requires extension for -i
        sed -i '' "s/DEVICE_ID = \".*\"/DEVICE_ID = \"$device_id\"/" config.py
        sed -i '' "s/PULSE_DURATION_MS = [0-9]*/PULSE_DURATION_MS = $pulse_duration/" config.py
        sed -i '' "s/WIFI_SSID = '.*'/WIFI_SSID = '$escaped_ssid'/" config.py
        sed -i '' "s/WIFI_PASSWORD = '.*'/WIFI_PASSWORD = '$escaped_password'/" config.py
    else
        # Linux (GNU) version
        sed -i "s/DEVICE_ID = \".*\"/DEVICE_ID = \"$device_id\"/" config.py
        sed -i "s/PULSE_DURATION_MS = [0-9]*/PULSE_DURATION_MS = $pulse_duration/" config.py
        sed -i "s/WIFI_SSID = '.*'/WIFI_SSID = '$escaped_ssid'/" config.py
        sed -i "s/WIFI_PASSWORD = '.*'/WIFI_PASSWORD = '$escaped_password'/" config.py
    fi
fi

echo "Updated config.py with:"
echo -n "  Device ID: $device_id"
[ "$device_id" = "$current_device_id" ] && echo " (unchanged)" || echo ""

echo -n "  Pulse Duration: ${pulse_duration}ms"
[ "$pulse_duration" = "$current_pulse_duration" ] && echo " (unchanged)" || echo ""

echo -n "  WiFi SSID: $wifi_ssid"
[ "$wifi_ssid" = "$current_wifi_ssid" ] && echo " (unchanged)" || echo ""

echo -n "  WiFi Password: $wifi_password"
[ "$wifi_password" = "$current_wifi_password" ] && echo " (unchanged)" || echo ""

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