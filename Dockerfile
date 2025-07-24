FROM python:3.11-slim

# Instalacja signal-cli i zależności
RUN apt-get update && apt-get install -y \
    openjdk-17-jre-headless \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Instalacja signal-cli
RUN wget -O signal-cli.tar.gz https://github.com/AsamK/signal-cli/releases/latest/download/signal-cli-0.12.0.tar.gz \
    && tar xf signal-cli.tar.gz -C /opt \
    && ln -sf /opt/signal-cli-*/bin/signal-cli /usr/local/bin/

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY signal_webhook.py .
RUN mkdir -p /app/logs

EXPOSE 5000

CMD ["python", "signal_webhook.py"]