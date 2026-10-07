#!/usr/bin/env bash
# Scheduled job: refresh ../homelab-infra, then regenerate
# config/bookmarks.yaml from its registry. Homepage picks the file up live.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

infra="$repo_root/../homelab-infra"
if [ -d "$infra/.git" ]; then
  if [ -n "$(git -C "$infra" status --porcelain)" ]; then
    echo "WARNING: $infra has uncommitted changes - not pulling, using it as-is." >&2
  elif ! git -C "$infra" pull --ff-only --quiet; then
    echo "WARNING: could not fast-forward $infra - using it as-is." >&2
  fi
fi

docker compose --profile jobs run --rm --build bookmarks-sync
