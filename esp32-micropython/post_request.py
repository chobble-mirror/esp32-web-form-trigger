import urequests
from config import DEVICE_ID, SERVER_URL, API_PATH

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
            
        resp.close()
        return resp.status_code, body
    except Exception as e:
        print("Claim credit request failed:", e)
        return None, None
