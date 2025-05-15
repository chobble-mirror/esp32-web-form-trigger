import time
from config import PULSE_DURATION_MS

def activate_opto(opto_pin, duration=None):  # Use configured duration
    """
    Send a brief pulse through the opto-isolator

    Args:
        opto_pin: The Pin object connected to the opto-isolator
        duration: Time in seconds for pulse duration (defaults to PULSE_DURATION_MS from config)
    """
    try:
        # If no duration specified, use the configured value
        if duration is None:
            duration = PULSE_DURATION_MS / 1000.0  # Convert from ms to seconds

        print(f"Sending {int(duration*1000)}ms pulse")
        try:
            opto_pin.value(1)  # Activate output
        except Exception as e:
            print("Could not activate pulse output")
            return False
            
        # Wait for brief pulse duration
        try:
            time.sleep(duration)
        except Exception as e:
            # If sleep is interrupted, still try to turn off the pin
            pass
            
        # Always try to turn off the pin to avoid leaving it on indefinitely
        try:
            opto_pin.value(0)  # Turn off output
        except Exception as e:
            print("Could not deactivate pulse output")
            return False
            
        return True
        
    except Exception as e:
        print("Pulse activation failed")
        # Try one more time to ensure the output is off
        try:
            opto_pin.value(0)
        except:
            pass
        return False