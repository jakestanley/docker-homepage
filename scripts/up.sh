#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$repo_root"

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  cat <<'EOF'
Usage: ./scripts/up.sh [docker compose up args...]

Loads ports from ../homelab-infra/registry.yaml and runs:
  docker compose up -d
EOF
  exit 0
fi

eval "$(./scripts/registry-homepage-env.sh)"
eval "$(./scripts/registry-speedtest-env.sh)"

docker compose up -d "$@"
