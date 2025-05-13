import network
import socket
import time
from config import WIFI_PASSWORDS

def get_available_ssids(wlan):
    scan_results = wlan.scan()
    available = []
    for entry in scan_results:
        try:
            ssid = entry[0].decode()
        except Exception:
            ssid = str(entry[0])
        available.append(ssid)
    print("Available SSIDs:", available)
    return available

def wifi_init():
    wlan = network.WLAN(network.STA_IF)
    wlan.active(True)
    found_ssids = get_available_ssids(wlan)
    for ssid, password in WIFI_PASSWORDS:
        if ssid in found_ssids:
            print(f"SSID '{ssid}' found, trying to connect...")
            try:
                wlan.disconnect()
                time.sleep(0.1)
                wlan.connect(ssid, password)
                for _ in range(20):
                    if wlan.isconnected() and wlan.config('essid') == ssid:
                        print(f"Connected to '{ssid}'")
                        print("Network config:", wlan.ifconfig())
                        return
                    time.sleep(0.5)
            except OSError as e:
                print(f"Exception during connect to '{ssid}': {e}")
            except Exception as e:
                print(f"Other exception: {e}")
            print(f"Failed to connect to '{ssid}' (wrong password or network issue).")
        else:
            print(f"SSID '{ssid}' not found in current scan, skipping.")
    while True:
        ap = start_ap_mode()
        wlan = network.WLAN(network.STA_IF)
        wlan.active(True)
        sel_ssid, sel_password = web_server(found_ssids)
        ap.active(False)
        print("Attempting to connect to:", sel_ssid)
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
