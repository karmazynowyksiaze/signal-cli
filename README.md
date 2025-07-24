# Signal Webhook Server

Serwer webhook napisany w Pythonie umożliwiający wysyłanie wiadomości Signal przez API REST przy użyciu signal-cli. Uruchamiony jest na porcie 5000 - standardowy port serwera Python Flask.

## Funkcjonalności

- **API REST** - endpoint `/send` do wysyłania wiadomości
- **Autoryzacja Bearer Token** - zabezpieczenie przed nieautoryzowanym dostępem
- **Integracja z signal-cli** - wykorzystuje signal-cli do komunikacji z Signal
- **Logowanie** - szczegółowe logi z rotacją do pliku i konsoli
- **Konfiguracja przez zmienne środowiskowe** - łatwa konfiguracja
- **Obsługa grup Signal** - wysyłanie wiadomości do grup
- **Obsługa błędów** - właściwe kody odpowiedzi HTTP

## Wymagania

### Systemowe
- Python 3.11+
- signal-cli (zainstalowany i skonfigurowany)
- Zarejestrowany numer Signal w signal-cli

### Pakiety Python
```bash
pip install flask python-dotenv
```

## Instalacja i konfiguracja

### 1. Przygotowanie signal-cli

```bash
# Instalacja signal-cli (jeśli nie jest zainstalowana)
# Zobacz instrukcje instalacji signal-cli

# Rejestracja numeru (jednorazowo)
signal-cli -u +48123456789 register
signal-cli -u +48123456789 verify VERIFICATION_CODE

# Test wysyłania wiadomości
signal-cli -u +48123456789 send -m "Test" +48987654321
```

### 2. Konfiguracja zmiennych środowiskowych

Utwórz plik `.env` w katalogu głównym projektu:

```bash
# Numer Signal zarejestrowany w signal-cli
SIGNAL_NUMBER=+48123456789

# ID grupy Signal (opcjonalne, jeśli wysyłasz do grup)
SIGNAL_GROUP_ID=your_group_id_here

# Klucz API do autoryzacji (może być lista oddzielona przecinkami)
WEBHOOK_API_KEY=your_secret_api_key
```

### 3. Struktura katalogów

```bash
mkdir -p /app/logs
chmod 755 /app/logs
```

### 4. Uruchomienie serwera

```bash
# Bezpośrednio
python3 signal_webhook.py



## Użycie API

### Endpoint: POST /send

Wysyła wiadomość do skonfigurowanej grupy Signal.

#### Nagłówki
```
Authorization: Bearer YOUR_API_KEY
Content-Type: application/json
```

#### Payload
```json
{
    "message": "Twoja wiadomość do wysłania"
}
```

#### Odpowiedzi API

**Sukces (200):**
```json
{
    "status": "Message sent"
}
```

**Błąd autoryzacji (401):**
```json
{
    "error": "Unauthorized"
}
```

**Brak wiadomości (400):**
```json
{
    "error": "Missing message"
}
```

**Błąd signal-cli (500):**
```json
{
    "error": "signal-cli error details"
}
```

## Wdrożenie produkcyjne

### Docker

**Dockerfile:**
```dockerfile
FROM python:3.9-slim

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
```

**docker-compose.yml:**
```yaml
version: '3.8'

services:
  signal-webhook:
    build: .
    ports:
      - "5000:5000"
    environment:
      - SIGNAL_NUMBER=${SIGNAL_NUMBER}
      - SIGNAL_GROUP_ID=${SIGNAL_GROUP_ID}
      - WEBHOOK_API_KEY=${WEBHOOK_API_KEY}
    volumes:
      - ./logs:/app/logs
      - ./signal-data:/root/.local/share/signal-cli
    restart: unless-stopped
```
