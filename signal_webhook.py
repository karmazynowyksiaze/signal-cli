#!/usr/bin/env python3
import os
import subprocess
import logging
from datetime import datetime
from flask import Flask, request, jsonify
from dotenv import load_dotenv


logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('/app/logs/signal_webhook.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

load_dotenv()
SIGNAL_NUMBER = os.environ.get('SIGNAL_NUMBER')
SIGNAL_GROUP_ID = os.environ.get('SIGNAL_GROUP_ID')
API_KEY = os.environ.get('WEBHOOK_API_KEY')

app = Flask(__name__)

@app.route('/send', methods=['POST'])
def send_signal_message():
    # Check API key authorization
    api_key = request.headers.get('API_KEY')
    if not api_key or api_key != API_KEY:
        logger.warning(f"Unauthorized access attempt. Received: '{api_key}', Expected: '{API_KEY}'")
        return jsonify({'error': 'Unauthorized'}), 401
    
    data = request.json
    logger.info(f"Received data: {data}")

    if not data or 'message' not in data:
        logger.warning('Missing message')
        return jsonify({'error': 'Missing message'}), 400

    message = data['message']

    try:
        logger.info(f"Sending message to group: {SIGNAL_GROUP_ID}")
        args = ['signal-cli', '-u', SIGNAL_NUMBER, 'send', '-g', SIGNAL_GROUP_ID, '-m', message]

        subprocess.run(args, check=True)
        logger.info(f"Message sent successfully to group {SIGNAL_GROUP_ID}")
        return jsonify({'status': 'Message sent'}), 200

    except subprocess.CalledProcessError as e:
        logger.error(f"Error sending message to group: {e}")
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    logger.info("Starting Signal webhook server...")
    logger.info(f"API_KEY loaded: '{API_KEY}'")
    app.run(host='0.0.0.0', port=5000)