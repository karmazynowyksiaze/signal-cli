FROM python:3.11-slim

# Instalacja signal-cli i zależności
RUN apt-get update && apt-get install -y \
    openjdk-17-jre-headless \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Instalacja signal-cli
RUN wget  https://github.com/AsamK/signal-cli/releases/download/v0.13.18/signal-cli-0.13.18.tar.gz  \
    && tar xf signal-cli-0.13.18.tar.gz -C /opt \
    && ln -sf /opt/signal-cli-0.13.18/bin/signal-cli /usr/local/bin/

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY signal_webhook.py .
RUN mkdir -p /app/logs

EXPOSE 5000

CMD ["python", "signal_webhook.py"]