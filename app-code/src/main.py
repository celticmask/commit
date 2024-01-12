#!/usr/bin/env python3
"""
Sends a JSON formatted POST request to server URL and writes response to S3 bucket

Parameters:
--url, SERVER_URL - server URL (required)
--bucket, BUCKET_NAME - S3 bucket name (required)
"""

import requests
import argparse
import boto3
import json
import os
import argparse
from datetime import date

today = date.today()

parser = argparse.ArgumentParser()
parser.add_argument(
    '--url', required='SERVER_URL' not in os.environ, default=os.environ.get('SERVER_URL'),
    help='Server URL. Overrides environment variable SERVER_URL.')
parser.add_argument(
    '--bucket', required='BUCKET_NAME' not in os.environ, default=os.environ.get('BUCKET_NAME'),
    help='S3 bucket name')
args = parser.parse_args()

data = {'current_date': today.strftime("%d-%m-%Y"), 
        'hostname': os.uname()[1]}
json_data = json.dumps(data)
headers = {'Content-type': 'application/json'}

response = requests.post(args.url, headers=headers, data=json_data)

# Print the response
print(response.text)

s3 = boto3.client("s3")
s3.put_object(
    Bucket = args.bucket,
    Key = "response.txt",
    Body=response.text
)
