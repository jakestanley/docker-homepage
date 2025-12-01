# adler: docker-compose

This folder contains a docker compose file with all services currently running on ADLER.

It is required to create a `.env` file containing a few properties and a convenience script is here for, well, convenience in getting it all running as best I can.

## services

- homepage [git](https://github.com/gethomepage/homepage), [docs](https://gethomepage.dev/latest/widgets/)
- speedtest-tracker [git](https://github.com/alexjustesen/speedtest-tracker), [docs](https://docs.speedtest-tracker.dev/)
- [gluetun]
- [qbittorrent]

## .env file

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

