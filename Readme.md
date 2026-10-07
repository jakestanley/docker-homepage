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
   ```

2. Edit `.env` with your values:
   - Generate Speedtest Tracker `APP_KEY` from https://speedtest-tracker.dev/
   - Set any `HOMEPAGE_VAR_*` values referenced by `config/*.yaml`
   - `HOMEPAGE_VAR_JELLYFIN_PORT` is set automatically from `../homelab-infra/registry.yaml` when starting via `./scripts/up.sh` (fallback `8096`)
   - Host ports are allocated in `../homelab-infra/registry.yaml` (do not override locally)
   - `./scripts/up.sh` exports `HOMEPAGE_ALLOWED_HOSTS` automatically (from registry DNS); optionally set `ADLER_IP` to also allow the LAN IP

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

1. Navigate to http://localhost:20016/admin
2. Login with default credentials:
   - Email: admin@example.com
   - Password: password
3. Change default credentials immediately

## Homelab bookmarks (generated)

`config/bookmarks.yaml` is **generated** (git-ignored) - every service in
`../homelab-infra/registry.yaml` with a `dns` name becomes a link in the
"Homelab" bookmarks group. Hand-written bookmarks go in
`config/bookmarks.static.yaml` and are appended after it.

- Job: `jobs/bookmarks-sync` (Docker, no network), run via
  `./scripts/sync-bookmarks.sh`, which first fast-forwards
  `../homelab-infra` (skipped with a warning if it's dirty).
- Schedule: `./scripts/up.sh` runs the sync once and (re)installs a cron
  line tagged `# homelab-homepage-bookmarks` (default `17 3 * * *`,
  override with `CRON_SCHEDULE`). Idempotent.
- Logs: `data/logs/bookmarks-sync.log`.
- Manual: `./scripts/sync-bookmarks.sh`, or preview with
  `DRY_RUN=true docker compose --profile jobs run --rm bookmarks-sync`.
- Leave services out with `BOOKMARKS_EXCLUDE=key1,key2` in `.env`.
- Homepage reloads the file live; no restart needed.
