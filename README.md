# signal-cli

signal-cli to nieoficjalny interfejs wiersza poleceń dla komunikatora [Signal](https://signal.org/), umożliwiający rejestrację, weryfikację, wysyłanie i odbieranie wiadomości z poziomu terminala.

## Opis działania

signal-cli wykorzystuje [zpatchowaną bibliotekę libsignal-service-java](https://github.com/Turasa/libsignal-service-java), wyodrębnioną z [kodu źródłowego Signal-Android](https://github.com/signalapp/Signal-Android/tree/main/libsignal-service). Program został zaprojektowany głównie do użytku na serwerach w celu powiadamiania administratorów o ważnych wydarzeniach.

### Funkcjonalności

- Rejestracja numeru telefonu (SMS/połączenie głosowe)
- Weryfikacja numeru za pomocą kodu
- Wysyłanie wiadomości tekstowych i załączników
- Odbieranie wiadomości
- Zarządzanie grupami (tworzenie, usuwanie, zarządzanie członkami)
- Zarządzanie profilami użytkowników


### Interfejsy

signal-cli oferuje interfejs wiersza poleceń. Dzięki niemu po rejestracji numeru, możliwe jest wykorzystanie komend bezporśednio z terminalu systemu operacyjnego.

1. **Interfejs wiersza poleceń** - bezpośrednie wykonywanie komend

## Wymagania systemowe

- **Java Runtime Environment (JRE) 21** lub nowszy
- **Biblioteka natywna**: libsignal-client (dołączona dla x86_64 Linux, Windows i macOS)
- **Numer telefonu** do rejestracji (może odbierać SMS lub połączenia głosowe)

**Ważne**: Zgodnie z dokumentacją signal-cli musi być regularnie aktualizowany, ponieważ oficjalni klienci Signal wygasają po trzech miesiącach, a serwer może wprowadzać niekompatybilne zmiany.

## Instalacja

### Pobieranie gotowych plików binarnych

```bash
# Pobierz najnowszą wersję
export VERSION=<najnowsza_wersja>  # format "x.y.z"
wget https://github.com/AsamK/signal-cli/releases/download/v"${VERSION}"/signal-cli-"${VERSION}".tar.gz

# Rozpakuj do /opt
sudo tar xf signal-cli-"${VERSION}".tar.gz -C /opt

# Utwórz symlink
sudo ln -sf /opt/signal-cli-"${VERSION}"/bin/signal-cli /usr/local/bin/
```

## Inicjalizacja

### 1. Rejestracja numeru telefonu

 **Ważne**: Numer telefonu (ACCOUNT) musi być w formacie międzynarodowym ze znakiem "+" na początku.

#### Rejestracja przez SMS
```bash
signal-cli -u +48123456789 register
```

#### Rejestracja przez połączenie głosowe (dla numerów stacjonarnych)
```bash
# Krok 1: Spróbuj rejestrację SMS (otrzymasz błąd 400 - to normalne)
signal-cli -u +48123456789 register

# Krok 2: Poczekaj 60 sekund

# Krok 3: Spróbuj weryfikacji głosowej
signal-cli -u +48123456789 register --voice
```

### 2. Weryfikacja numeru

```bash
# Wprowadź kod otrzymany przez SMS lub połączenie głosowe
signal-cli -u +48123456789 verify KOD_WERYFIKACYJNY

# Jeśli masz ustawiony PIN w Signal, dodaj opcję --pin
signal-cli -u +48123456789 verify KOD_WERYFIKACYJNY --pin TwójPIN
```

### 3. Rozwiązywanie CAPTCHA

W przypadku problemów z rejestracją może być wymagane rozwiązanie CAPTCHA - sprawdź [Registration with captcha](https://github.com/AsamK/signal-cli/wiki/Registration-with-captcha).

## Podstawowe użycie

### Wysyłanie wiadomości

```bash
# Wysłanie prostej wiadomości
signal-cli -u +48123456789 send -m "Witaj świecie!" +48987654321

# Wysłanie wiadomości z załącznikiem
signal-cli -u +48123456789 send -m "Zobacz to zdjęcie" -a /ścieżka/do/pliku.jpg +48987654321

# Wysłanie wiadomości do grupy
signal-cli -u +48123456789 send -m "Wiadomość grupowa" -g ID_GRUPY


### Odbieranie wiadomości

```bash
# Jednorazowe odbieranie wiadomości
signal-cli -u +48123456789 receive

# Tryb nasłuchiwania (daemon)
signal-cli -u +48123456789 daemon

# Odbieranie z formatowaniem JSON
signal-cli -u +48123456789 receive --output=json
```

### Zarządzanie grupami

```bash
# Tworzenie grupy
signal-cli -u +48123456789 updateGroup -n "Nazwa grupy" -m +48111111111 +48222222222

# Wyświetlenie listy grup
signal-cli -u +48123456789 listGroups

# Dodanie członka do grupy
signal-cli -u +48123456789 updateGroup -g ID_GRUPY -m +48333333333

# Usunięcie członka z grupy
signal-cli -u +48123456789 updateGroup -g ID_GRUPY -r +48333333333
```

### Zarządzanie profilem

```bash
# Ustawienie nazwy profilu
signal-cli -u +48123456789 updateProfile --name "Moja Nazwa"

# Ustawienie zdjęcia profilowego
signal-cli -u +48123456789 updateProfile --uvatar /ścieżka/do/zdjęcia.jpg

# Usunięcie zdjęcia profilowego
signal-cli -u +48123456789 updateProfile --remove-avatar
```

## Pliki konfiguracyjne

Hasła i klucze kryptograficzne są przechowywane w:
- `$XDG_DATA_HOME/signal-cli/data/` (jeśli ustawione)
- `$HOME/.local/share/signal-cli/data/` (domyślnie)

```

## Licencja

signal-cli jest licencjonowany na licencji GPLv3: http://www.gnu.org/licenses/gpl-3.0.html

```

# Signal Webhook Server

Serwer webhook napisany w Pythonie umożliwiający wysyłanie wiadomości Signal przez API REST przy użyciu signal-cli. Idealny do integracji z systemami zewnętrznymi, alertami monitoringowymi i automatyzacji powiadomień.

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
- Python 3.7+
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