import network
import socket
import time
from config import WIFI_SSID, WIFI_PASSWORD

def get_available_ssids(wlan):
    scan_results = wlan.scan()
    available = []
    for entry in scan_results:
        try:
            ssid = entry[0].decode('utf-8')
            # Print full scan entry for debugging
            print(f"Found network: {ssid}, Signal: {entry[3]}dBm")
        except Exception as e:
            print(f"Error decoding SSID: {e}")
            ssid = str(entry[0])
        available.append(ssid)
    print("Available SSIDs:", available)
    return available

def wifi_init():
    # Start with a clean slate - reset WiFi completely
    wlan = network.WLAN(network.STA_IF)
    wlan.active(False)
    time.sleep(1)
    wlan.active(True)
    time.sleep(1)

    # Try connecting directly with hardcoded credentials
    print(f"Trying to connect to '{WIFI_SSID}'...")
    try:
        # Make sure we're disconnected first
        wlan.disconnect()
        time.sleep(1)

        # Direct connection with hardcoded strings
        print(f"Connecting to: '{WIFI_SSID}' with password: '{WIFI_PASSWORD}'")
        wlan.connect(WIFI_SSID, WIFI_PASSWORD)

        # Check connection status
        for i in range(20):
            print(f"Waiting for connection... {i+1}/20")
            if wlan.isconnected():
                connected_ssid = wlan.config('essid')
                print(f"Connected to '{connected_ssid}'")
                print("Network config:", wlan.ifconfig())
                return
            time.sleep(0.5)

        print(f"Failed to connect to '{WIFI_SSID}' - will try AP mode.")
    except OSError as e:
        print(f"Exception during connect: {e}")
    except Exception as e:
        print(f"Other exception: {e}")

    # If we get here, connection failed
    while True:
        # Get fresh scan of available networks for the AP mode
        ap = start_ap_mode()
        wlan = network.WLAN(network.STA_IF)
        wlan.active(False)
        time.sleep(1)
        wlan.active(True)
        time.sleep(1)

        # Get a fresh list of available SSIDs
        available_networks = get_available_ssids(wlan)
        sel_ssid, sel_password = web_server(available_networks)
        ap.active(False)
        print("Attempting to connect to:", sel_ssid)
        # Try a clean connect after completely resetting wifi state
        wlan.disconnect()
        time.sleep(1)
        wlan.connect(sel_ssid, sel_password)
        for _ in range(20):  # Try for ~10 seconds
            if wlan.isconnected() and wlan.config('essid') == sel_ssid:
                print(f"Connected to '{sel_ssid}' via user input.")
                print("Network config:", wlan.ifconfig())
                # Optionally save this SSID/PW here for next boot!
                return
            time.sleep(0.5)
        print("Failed to connect--restarting AP for another try.")


def start_ap_mode():
    ap = network.WLAN(network.AP_IF)
    ap.active(True)
    ap.config(essid='ESP32_Setup', authmode=network.AUTH_WPA_WPA2_PSK, password="esp32setup")
    print('AP Mode started, connect to SSID: ESP32_Setup, password: esp32setup')
    return ap

def serve_html(ssid_list):
    html = """<html><body>
    <h2>Select WiFi Network</h2>
    <form action="/" method="post">
        <select name="ssid">
            %s
        </select><br>
        WiFi Password: <input type="password" name="password"><br>
        <input type="submit" value="Connect">
    </form>
    </body></html>""" % ("\n".join(['<option value="%s">%s</option>' % (ssid, ssid) for ssid in ssid_list]))
    return html

def parse_post(data):
    import ure
    ssid = ''
    password = ''
    m_ssid = ure.search(b"ssid=([^&]+)", data)
    m_pwd = ure.search(b"password=([^&]+)", data)
    if m_ssid:
        ssid = m_ssid.group(1).decode().replace('+', ' ')
    if m_pwd:
        password = m_pwd.group(1).decode().replace('+', ' ')
    return ssid, password

def web_server(ssid_list):
    addr = socket.getaddrinfo('0.0.0.0', 80)[0][-1]
    s = socket.socket()
    s.bind(addr)
    s.listen(1)
    print('Web server running, go to http://192.168.4.1/')

    while True:
        cl, addr = s.accept()
        request = cl.recv(1024)
        # Detect if POST request
        if b'POST' in request:
            ssid, password = parse_post(request)
            cl.send('HTTP/1.0 200 OK\r\nContent-type: text/html\r\n\r\n')
            cl.send(b'Received, trying to connect...')
            cl.close()
            s.close()
            return ssid, password
        else:
            response = serve_html(ssid_list)
            cl.send('HTTP/1.0 200 OK\r\nContent-type: text/html\r\n\r\n')
            cl.send(response)
            cl.close()
