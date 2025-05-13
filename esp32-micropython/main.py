import machine
import time
import urequests

from wifi import wifi_init
from opto_control import activate_opto
from post_request import post_request
from config import (
    OPTO_PIN,
    BUTTON_PIN,
    POST_INTERVAL,
)

opto = machine.Pin(OPTO_PIN, machine.Pin.OUT)
button = machine.Pin(BUTTON_PIN, machine.Pin.IN, machine.Pin.PULL_UP)

def button_isr(pin):
    global should_trigger
    should_trigger = True

button.irq(trigger=machine.Pin.IRQ_FALLING, handler=button_isr)

wifi_init()

should_trigger = False
last_post_time = 0

while True:
    now = time.ticks_ms()
    if time.ticks_diff(now, last_post_time) >= POST_INTERVAL:
        response_code, response_body = post_request()
        print("Server responded:", response_code)
        if response_code == 200:
            activate_opto(opto)
        last_post_time = now

    if should_trigger:
        print("Button pressed")
        activate_opto(opto)
        while button.value() == 0:
            time.sleep(0.02)
        should_trigger = False

    time.sleep(0.01)

