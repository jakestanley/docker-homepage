# Docker Homepage

A Docker Compose setup combining [Homepage](https://gethomepage.dev) dashboard with Speedtest Tracker.

This repo follows the homelab control-plane pattern: host ports and DNS names are allocated in `../homelab-infra/registry.yaml` and must not drift.

Internal TLS is not exposed from these containers; the edge proxy (nginx) terminates TLS and proxies to the upstream HTTP ports.

## Services

- **Homepage** - A modern, fully static, fast, secure fully proxied, highly customizable application dashboard
  - [GitHub](https://github.com/gethomepage/homepage) | [Docs](https://gethomepage.dev/latest/widgets/)
  - Upstream: `http://<adler_ip>:20017/` (host port from `services.homepage.upstream.port`)
  - Public: `https://home.stanley.arpa/` (edge proxy handles DNS/TLS)
- **Speedtest Tracker** - A self-hosted internet performance tracking application
  - [GitHub](https://github.com/alexjustesen/speedtest-tracker) | [Docs](https://docs.speedtest-tracker.dev/)
  - Upstream: `http://<adler_ip>:20016/` (host port from `services.speedtest.upstream.port`)
  - Public: `https://speedtest.stanley.arpa/` (edge proxy handles DNS/TLS)

## Setup

1. Copy example files:
   ```bash
   cp .env.example .env
   cp homepage.secrets.example homepage.secrets
   ```

2. Edit `.env` and `homepage.secrets` with your values:
   - Generate speedtest app key from https://speedtest-tracker.dev/
   - Add your API keys and credentials to homepage.secrets
   - Keep `HOMEPAGE_HOST_PORT` aligned to `../homelab-infra/registry.yaml` (`services.homepage.upstream.port`)
   - Ensure `HOMEPAGE_ALLOWED_HOSTS` includes `home.stanley.arpa`

3. Start services:
   ```bash
   ./scripts/up.sh
   ```

## Configuration

Homepage configuration files are in the `config/` directory:
- `services.yaml` - Service definitions and widgets
- `bookmarks.yaml` - Bookmark links
- `widgets.yaml` - Dashboard widgets
- `settings.yaml` - General settings

## Verification

```bash
curl -I http://10.92.8.6:20017/
curl -kI https://home.stanley.arpa/healthz
curl -kI https://home.stanley.arpa/
```

Or:
```bash
bash ./scripts/verify.sh
```

## Speedtest Tracker Setup

1. Navigate to http://localhost:8085/admin
2. Login with default credentials:
   - Email: admin@example.com
   - Password: password
3. Change default credentials immediately
