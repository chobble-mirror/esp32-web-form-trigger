# ESP32 Web Form Trigger

This MicroPython project allows an ESP32 to connect to your WiFi network, periodically check in with a server, and trigger a brief pulse on an output pin when either:
1. The server responds with a success code (HTTP 200)
2. The physical button on the ESP32 is pressed

## Monitoring and Debugging

You can connect to the ESP32 to view real-time logs using `rshell`:

```bash
# Install rshell
pip install rshell

# Connect to the ESP32 (replace with your port)
rshell -p /dev/ttyUSB0  # Linux
# or
rshell -p /dev/cu.SLAB_USBtoUART  # macOS
# or
rshell -p COM3  # Windows
```

### Finding Your Serial Port

- **Linux**: Run `ls /dev/tty*` and look for `/dev/ttyUSB0` or similar
- **macOS**: Run `ls /dev/cu.*` and look for `/dev/cu.SLAB_USBtoUART` or similar
- **Windows**: Check Device Manager under "Ports (COM & LPT)" for COM ports

### Viewing Live Logs

Once connected with rshell:

```
# Enter the REPL console to see live logs
repl
```

To exit the REPL, press `Ctrl+X`.

### Alternative: Using screen or minicom

For simpler logging (view only):

```bash
# Linux/macOS using screen
screen /dev/ttyUSB0 115200

# Exit with Ctrl+A followed by \
```

```bash
# Linux using minicom
minicom -D /dev/ttyUSB0 -b 115200

# Exit with Ctrl+A followed by X
```

### Executing Remote Commands

```
# List files on the ESP32
ls /pyboard

# Copy a file to the ESP32
cp local_file.py /pyboard/

# Open a Python shell on the ESP32
repl ~ from opto_control import activate_opto
```

## Hardware Setup

- ESP32 development board
- Output connected to pin defined in `config.py` (default: GPIO 18)
- Button connected to pin defined in `config.py` (default: GPIO 15)
- Status LED connected to pin defined in `config.py` (default: GPIO 2)

## Configuration

Edit the `config.py` file to set your:

- `DEVICE_ID`: Unique identifier for your device
- `OPTO_PIN`: GPIO pin connected to your output device
- `BUTTON_PIN`: GPIO pin connected to your physical button
- `LED_PIN`: GPIO pin connected to status LED
- `POST_INTERVAL`: How often to check in with server (in milliseconds)
- `PULSE_DURATION_MS`: Duration of the output pulse in milliseconds (default: 10ms)
- `SERVER_URL` and `API_PATH`: API endpoint for device check-in
- `WIFI_SSID` and `WIFI_PASSWORD`: Your WiFi credentials

## LED Status Codes

The onboard LED provides status information through flash patterns:

- **2 flashes**: Server responded with success (HTTP 200)
- **1 flash**: Server responded with not found (HTTP 404)
- **3 flashes**: Server responded with another status code
- **4 flashes**: Network error during communication
- **5 flashes**: General error during communication

## WiFi Setup

The device will try to connect to the configured WiFi network first. If that fails:

1. It will start an access point named "ESP32-[DEVICE_ID]"
2. Connect to this access point with your phone or computer
3. Open http://192.168.4.1 in your browser
4. Select your WiFi network and enter the password
5. The device will attempt to connect to the provided network

## Troubleshooting

If the device is not responding:

1. **Power**: Ensure the ESP32 is receiving adequate power
2. **WiFi**: Check if the status LED is flashing regularly (indicating successful server communication)
3. **Output**: Verify connections to your output device
4. **Configuration**: Double-check settings in `config.py`

## Error Handling

The firmware includes comprehensive error handling to prevent crashes:

- Network connectivity failures
- Server communication issues
- Hardware failures
- Unexpected errors

In most cases, the device will attempt to recover automatically. If it encounters a critical error, it will restart after 10 seconds.