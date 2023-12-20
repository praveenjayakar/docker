
import requests
from requests.auth import HTTPBasicAuth
import json

url = "https://pjdevops.atlassian.net/rest/api/3/issue"

api_token = "ATATT3xFfGF0eqxeyEMTYUa5YMh072atvZ0b1v3QJ52d-JihFy9gfgyDccgqL5SRMM1rcERrwiAmEBX5CMLk7WbMAoxeMk3F3AcAtJHhd1hZ6aUdS-vPw1BFskWENxpEixcBTnkrMDfvAteR1XwUO8Pr9AJ2jNq-IECIwBOvxAtfszZ89pytiAc=AC66E855"

auth = HTTPBasicAuth("praveenjayakar7@gmail.com", api_token)

headers = {
  "Accept": "application/json",
  "Content-Type": "application/json"
}

payload = json.dumps( {
  "fields": {
    "description": {
      "content": [
        {
          "content": [
            {
              "text": "issue created on jira.",
              "type": "text"
            }
          ],
          "type": "paragraph"
        }
      ],
      "type": "doc",
      "version": 1
    },
    "issuetype": {
      "id": "10001"
    },
    "project": {
      "key": "FPP"
    },
    "summary": "First JIRA Ticket",
  },
  "update": {}
} )

response = requests.request(
   "POST",
   url,
   data=payload,
   headers=headers,
   auth=auth
)

print(json.dumps(json.loads(response.text), sort_keys=True, indent=4, separators=(",", ": ")))
