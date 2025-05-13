import time

def activate_relay(relay_pin):
    print("Opening relay for 1 second!")
    relay_pin.value(1)
    time.sleep(1)
    relay_pin.value(0)
