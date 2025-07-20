from flask import Flask, request, jsonify
from dotenv import load_dotenv
import os
import subprocess

load_dotenv()

app = Flask(__name__)

SIGNAL_NUMBER = os.environ.get('SIGNAL_NUMBER')
SIGNAL_GROUP_ID = os.environ.get('SIGNAL_GROUP_ID')

@app.route('/send', methods=['POST'])
def send_signal_message():
    data = request.json
    if not data or 'message' not in data or 'recipient' not in data:
        return jsonify({'error': 'Missing message or recipient'}), 400

    message = data['message']

    try:
        subprocess.run([
            'signal-cli', '-u', SIGNAL_NUMBER, 'send', '-g', SIGNAL_GROUP_ID, '-m', message
        ], check=True)
        return jsonify({'status': 'Message sent'}), 200
    except subprocess.CalledProcessError as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)