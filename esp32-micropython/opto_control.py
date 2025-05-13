import time

def activate_opto(opto_pin, duration=1.0):
    """
    Activate the opto-isolator for the specified duration
    
    Args:
        opto_pin: The Pin object connected to the opto-isolator
        duration: Time in seconds to keep the opto-isolator activated
    """
    print(f"Activating opto-isolator for {duration} seconds!")
    opto_pin.value(1)  # Turn on opto-isolator
    time.sleep(duration)
    opto_pin.value(0)  # Turn off opto-isolator