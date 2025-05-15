import machine
import time
from config import LED_PIN

# Initialize the LED pin with error handling
try:
    led = machine.Pin(LED_PIN, machine.Pin.OUT)
except Exception as e:
    print("Warning: Could not initialize LED - indicator flashes won't work")
    # Create a dummy led object that won't crash when called
    class DummyLED:
        def value(self, val):
            pass
    led = DummyLED()

def flash_led(times=1, duration=0.2):
    """
    Flash the onboard LED a specified number of times

    Args:
        times (int): Number of flashes (default: 1)
        duration (float): Duration of each flash in seconds (default: 0.2)
    """
    try:
        # Ensure times is at least 1 and not too large to prevent lockups
        actual_times = max(1, min(times, 10))
        actual_duration = max(0.05, min(duration, 0.5))  # Constrain duration

        for _ in range(actual_times):
            try:
                led.value(1)  # LED on
            except Exception as e:
                print("LED flash error")
                return

            # Wait for on duration
            try:
                time.sleep(actual_duration)
            except Exception as e:
                # If sleep fails, try to turn LED off anyway
                pass

            try:
                led.value(0)  # LED off
            except Exception as e:
                return

            try:
                time.sleep(actual_duration)
            except Exception as e:
                pass

    except Exception as e:
        print("Could not flash status LED")
        # Try to ensure LED is off
        try:
            led.value(0)
        except:
            pass