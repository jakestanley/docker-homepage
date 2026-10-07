#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  cat <<'EOF'
Usage: ./scripts/up.sh [docker compose up args...]

Loads ports from ../homelab-infra/registry.yaml and runs:
  docker compose up -d
then regenerates config/bookmarks.yaml from the registry and (re)installs
the bookmarks-sync cron line. Safe to re-run.

Env:
  CRON_SCHEDULE   cron schedule for bookmarks-sync (default "17 3 * * *")
EOF
  exit 0
fi

eval "$(./scripts/registry-homepage-env.sh)"
eval "$(./scripts/registry-speedtest-env.sh)"
eval "$(./scripts/registry-jellyfin-env.sh)"

docker compose up -d "$@"

./scripts/sync-bookmarks.sh

# Idempotent: drop any previous line carrying our tag, then add the current one.
cron_tag="# homelab-homepage-bookmarks"
cron_schedule="${CRON_SCHEDULE:-17 3 * * *}"
if [ "$(echo "$cron_schedule" | wc -w)" -ne 5 ]; then
  echo "ERROR: CRON_SCHEDULE must have 5 fields, got: $cron_schedule" >&2
  exit 1
fi
log_dir="$repo_root/data/logs"
mkdir -p "$log_dir"
cron_line="$cron_schedule $repo_root/scripts/sync-bookmarks.sh >> $log_dir/bookmarks-sync.log 2>&1 $cron_tag"
{ crontab -l 2>/dev/null | grep -vF "$cron_tag" || true; echo "$cron_line"; } | crontab -
echo "Installed cron: $cron_line"
