import network
import socket
import time
from config import WIFI_SSID, WIFI_PASSWORD, DEVICE_ID

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
    try:
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
            print(f"Connecting to: '{WIFI_SSID}'")
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

            print(f"Could not connect to WiFi - will try setup mode")
        except OSError as e:
            print(f"WiFi connection problem - check your network settings")
        except Exception as e:
            print(f"Unexpected problem with WiFi connection")

        # If we get here, connection failed
        while True:
            try:
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
                print("Could not connect - please check your WiFi password")
            except Exception as e:
                print("Problem with WiFi setup - restarting access point")
                time.sleep(3)  # Short delay before retrying
    except Exception as e:
        print("Critical WiFi error - the device will restart in 10 seconds")
        time.sleep(10)
        import machine
        machine.reset()


def start_ap_mode():
    ap = network.WLAN(network.AP_IF)
    ap.active(True)
    ap_name = f'ESP32-{DEVICE_ID}'
    ap.config(essid=ap_name, authmode=network.AUTH_OPEN)
    print(f'AP Mode started, connect to SSID: {ap_name} (no password required)')
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
    try:
        m_ssid = ure.search(b"ssid=([^&]+)", data)
        m_pwd = ure.search(b"password=([^&]+)", data)

        if m_ssid:
            try:
                ssid = m_ssid.group(1).decode().replace('+', ' ')
            except:
                print("Could not decode WiFi name properly")
                ssid = str(m_ssid.group(1)).replace('+', ' ')

        if m_pwd:
            try:
                password = m_pwd.group(1).decode().replace('+', ' ')
            except:
                print("Could not decode WiFi password properly")
                # Don't use str() here to avoid exposing the password in logs
                password = ""

        return ssid, password
    except Exception as e:
        print("Problem processing form data")
        return "", ""

def web_server(ssid_list):
    try:
        addr = socket.getaddrinfo('0.0.0.0', 80)[0][-1]
        s = socket.socket()
        s.bind(addr)
        s.listen(1)
        print('Web server running, go to http://192.168.4.1/')

        # Set a timeout for the socket to prevent hanging
        s.settimeout(300)  # 5 minutes timeout for setup

        while True:
            try:
                cl, addr = s.accept()
                try:
                    request = cl.recv(1024)
                    # Detect if POST request
                    if b'POST' in request:
                        try:
                            ssid, password = parse_post(request)
                            cl.send('HTTP/1.0 200 OK\r\nContent-type: text/html\r\n\r\n')
                            cl.send(b'Received, trying to connect...')
                            cl.close()
                            s.close()
                            return ssid, password
                        except Exception as e:
                            print("Could not process form data")
                            cl.send('HTTP/1.0 200 OK\r\nContent-type: text/html\r\n\r\n')
                            cl.send(b'Error processing your request. Please try again.')
                            cl.close()
                    else:
                        response = serve_html(ssid_list)
                        cl.send('HTTP/1.0 200 OK\r\nContent-type: text/html\r\n\r\n')
                        cl.send(response)
                        cl.close()
                except Exception as e:
                    print("Error communicating with connected client")
                    try:
                        cl.close()
                    except:
                        pass
            except socket.timeout:
                print("Web server timed out - restarting setup process")
                try:
                    s.close()
                except:
                    pass
                # Return empty values to trigger a retry
                return "", ""
            except Exception as e:
                print("Error accepting connection")
                time.sleep(1)
    except Exception as e:
        print("Could not start web server - will restart in 10 seconds")
        time.sleep(10)
        import machine
        machine.reset()
