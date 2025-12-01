# gethomepage

Configuration and Docker setup for my [gethomepage](http://gethomepage.dev) deployment.

This repository contains both the homepage configuration files and the Docker Compose setup to run the services.

## Configuration Files

- `bookmarks.yaml` - Homepage bookmarks
- `services.yaml` - Service definitions and widgets
- `settings.yaml` - Homepage settings
- `widgets.yaml` - Widget configurations
- `docker.yaml`, `kubernetes.yaml`, `proxmox.yaml` - Infrastructure service configs
- `custom.css`, `custom.js` - Custom styling and scripts

## Docker Services

- homepage [git](https://github.com/gethomepage/homepage), [docs](https://gethomepage.dev/latest/widgets/)
- speedtest-tracker [git](https://github.com/alexjustesen/speedtest-tracker), [docs](https://docs.speedtest-tracker.dev/)
- [gluetun]
- [qbittorrent]

## Setup

1. Create a `.env` file with required environment variables
2. Ensure `homepage.secrets` contains your API keys and tokens
3. Run `./start.sh` or `docker-compose up -d`

### .env file

Requires the following exports:
```
# generate a key from https://speedtest-tracker.dev/
SPEEDTEST_TRACK_APP_KEY="base64:abcdef..."
# wireguard gubbins
WIREGUARD_PRIVATE_KEY="..."
# these can be acquired from MullvadVPN's website. when you import or create 
#  a private key you have the option to generate a config file. extract the 
#  IPs from there
WIREGUARD_ADDRESSES="..."
```

## Quickstart: Speedtest

- Navigate to http://adler.local:8085/admin
- Log in with credentials. [Defaults](https://docs.speedtest-tracker.dev/security/authentication) are:
    - admin@example.com
    - password

## Notes

Secrets can be added to `settings.yaml` so the default was committed for compatibility but changes will not be detected in the work tree thanks to [this stack overflow answer](https://stackoverflow.com/a/39776107)