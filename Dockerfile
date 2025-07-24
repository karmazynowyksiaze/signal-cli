FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
COPY signal-webhook.py .

RUN pip install --no-cache-dir -r requirements.txt

CMD ["python3", "main.py"]