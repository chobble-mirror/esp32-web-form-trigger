esptool.py --baud 460800 erase_flash
esptool.py --baud 460800 write_flash 0x1000 ESP32_GENERIC-20250415-v1.25.0.bin
