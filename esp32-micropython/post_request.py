import urequests
from config import DEVICE_ID, SERVER_URL, API_PATH
from led_control import flash_led

# API endpoint for claiming credits
CLAIM_CREDIT_URL = SERVER_URL + API_PATH

def post_request(data=None):
    """Make a direct claim request to the API"""
    headers = {
        "Content-Type": "application/json"
    }
    
    try:
        # Always send the device_id in the request
        request_data = {"device_id": DEVICE_ID}
        
        # Add any additional data if provided
        if data is not None:
            import ujson
            request_data.update(data)
            
        import ujson
        resp = urequests.post(CLAIM_CREDIT_URL, 
                             headers=headers, 
                             data=ujson.dumps(request_data))
        
        print("Claim credit - server responded:", resp.status_code)
        
        try:
            body = resp.json()
        except:
            body = resp.text
            
        status_code = resp.status_code
        resp.close()

        # Flash LED based on response status:
        # 1 flash for 404, 2 flashes for 200
        if status_code == 404:
            flash_led(times=1)
        elif status_code == 200:
            flash_led(times=2)
        else:
            # For any other status, flash 3 times
            flash_led(times=3)

        return status_code, body
    except Exception as e:
        print("Claim credit request failed:", e)
        # Flash 5 times to indicate an error
        flash_led(times=5, duration=0.1)
        return None, None
