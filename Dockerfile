FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Instalacja zależności systemowych
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    unzip \
    gnupg \
    software-properties-common \
    python3.11 \
    python3.11-venv \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Ustawienie aliasu python -> python3.11
RUN ln -sf /usr/bin/python3.11 /usr/bin/python

# Instalacja JDK 21 (Adoptium)
RUN mkdir -p /opt/java && \
    wget https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.1+12/OpenJDK21U-jre_x64_linux_hotspot_21.0.1_12.tar.gz -O /tmp/jdk.tar.gz && \
    tar -xzf /tmp/jdk.tar.gz -C /opt/java && \
    rm /tmp/jdk.tar.gz

# Ustawienie JAVA_HOME i ścieżki
ENV JAVA_HOME=/opt/java/jdk-21.0.1+12-jre
ENV PATH="$JAVA_HOME/bin:$PATH"

# Instalacja signal-cli
RUN wget https://github.com/AsamK/signal-cli/releases/download/v0.13.18/signal-cli-0.13.18.tar.gz  \
    && tar xf signal-cli-0.13.18.tar.gz -C /opt \
    && ln -sf /opt/signal-cli-0.13.18/bin/signal-cli /usr/local/bin/

# Ustawienie katalogu roboczego
WORKDIR /opt/signal-cli-0.13.18

# Kopiowanie plików
COPY requirements.txt .
RUN python -m pip install --no-cache-dir flask python-dotenv

COPY signal_webhook.py .

RUN mkdir -p /opt/signal-cli-0.13.18

EXPOSE 5000

CMD ["python", "signal_webhook.py"]
