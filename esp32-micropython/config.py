DEVICE_ID = "A1B2C3D4E5F6"

# Board stuff
OPTO_PIN = 18  # Using the same pin that was used for relay
BUTTON_PIN = 15
LED_PIN = 2  # Onboard LED on most ESP32 boards

# Server stuff (probably doesn't need changing)
POST_INTERVAL = 2000 # 2 seconds between attempts
SERVER_URL = "https://example.com"
API_PATH = "/api/v1/credits/claim"

# Known wifi stuff
WIFI_SSID = 'Your Network'
WIFI_PASSWORD = 'Your password'

# Credits stuff
PULSE_DURATION_MS = 10  # Duration of output pulse in milliseconds
