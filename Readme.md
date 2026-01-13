# Docker Homepage

A Docker Compose setup combining [Homepage](https://gethomepage.dev) dashboard with Speedtest Tracker.

## Services

- **Homepage** - A modern, fully static, fast, secure fully proxied, highly customizable application dashboard
  - [GitHub](https://github.com/gethomepage/homepage) | [Docs](https://gethomepage.dev/latest/widgets/)
  - Accessible at http://localhost (port configurable via `HOMEPAGE_HOST_PORT`, default `80`)
- **Speedtest Tracker** - A self-hosted internet performance tracking application
  - [GitHub](https://github.com/alexjustesen/speedtest-tracker) | [Docs](https://docs.speedtest-tracker.dev/)
  - Accessible at http://localhost:8085

## Setup

1. Copy example files:
   ```bash
   cp .env.example .env
   cp homepage.secrets.example homepage.secrets
   ```

2. Edit `.env` and `homepage.secrets` with your values:
   - Generate speedtest app key from https://speedtest-tracker.dev/
   - Add your API keys and credentials to homepage.secrets
   - Optional: set `HOMEPAGE_HOST_PORT` (if changed, access Homepage at `http://localhost:<port>`)

3. Start services:
   ```bash
   docker compose up -d
   ```

## Configuration

Homepage configuration files are in the `config/` directory:
- `services.yaml` - Service definitions and widgets
- `bookmarks.yaml` - Bookmark links
- `widgets.yaml` - Dashboard widgets
- `settings.yaml` - General settings

## Speedtest Tracker Setup

1. Navigate to http://localhost:8085/admin
2. Login with default credentials:
   - Email: admin@example.com
   - Password: password
3. Change default credentials immediately
