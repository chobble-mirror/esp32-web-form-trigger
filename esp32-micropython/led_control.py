import machine
import time
from config import LED_PIN

# Initialize the LED pin
led = machine.Pin(LED_PIN, machine.Pin.OUT)

def flash_led(times=1, duration=0.2):
    """
    Flash the onboard LED a specified number of times
    
    Args:
        times (int): Number of flashes (default: 1)
        duration (float): Duration of each flash in seconds (default: 0.2)
    """
    for _ in range(times):
        led.value(1)  # LED on
        time.sleep(duration)
        led.value(0)  # LED off
        time.sleep(duration)