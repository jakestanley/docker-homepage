# Dropbox Status API

Simple Flask API to check Dropbox status on the host system.

## Setup

```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Install systemd service
sudo cp dropbox-status.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable dropbox-status
sudo systemctl start dropbox-status
```

## Usage

- `GET /status` - Returns Dropbox status
- `GET /` - API info

Service runs on port 80.