import pickle
import yaml
import requests
import sys

if len(sys.argv) < 3:
  print("TOKEN, LAB_NAME, BACKEND_URL and FILEPATH must be provided")
  sys.exit(0)

TOKEN       = sys.argv[1] 
LAB_NAME    = sys.argv[2] 
BACKEND_URL = sys.argv[3]
FILEPATH    = sys.argv[4]

headers = {
        "Authorization": TOKEN
}

def fake_callback():
    file = open(FILEPATH, 'rb')
    payload = pickle.load(file)
    url = BACKEND_URL + "/callback/lava/test?lab_name=" + LAB_NAME + "&status=2&status_string=complete"
    response = requests.post(url, headers=headers, json=payload)
    print(response)

if __name__ == "__main__":
    fake_callback()
    sys.exit(0)
