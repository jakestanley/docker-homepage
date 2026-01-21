#!/usr/bin/env bash
set -euo pipefail

format="export"
registry_path=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --format)
      format="${2:-}"
      shift 2
      ;;
    --registry)
      registry_path="${2:-}"
      shift 2
      ;;
    -h|--help)
      cat <<'EOF'
Usage: registry-jellyfin-env.sh [--registry PATH] [--format export|env]

Best-effort: reads services.jellyfin.upstream.port from ../homelab-infra/registry.yaml and prints JELLYFIN_HOST_PORT.

Examples:
  eval "$(./scripts/registry-jellyfin-env.sh)"       # exports JELLYFIN_HOST_PORT in current shell
  ./scripts/registry-jellyfin-env.sh --format env    # prints KEY=VALUE lines
EOF
      exit 0
      ;;
    *)
      echo "Unknown arg: $1" >&2
      exit 2
      ;;
  esac
done

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -z "$registry_path" ]]; then
  registry_path="${repo_root}/../homelab-infra/registry.yaml"
fi

if [[ ! -f "$registry_path" ]]; then
  echo "Warning: missing registry at ${registry_path}; leaving JELLYFIN_HOST_PORT unset." >&2
  exit 0
fi

upstream_port="$(
  awk '
    function ltrim(s) { sub(/^[ \t\r\n]+/, "", s); return s }
    function rtrim(s) { sub(/[ \t\r\n]+$/, "", s); return s }
    function trim(s) { return rtrim(ltrim(s)) }
    function indent_len(s,   m) { match(s, /^[ \t]*/); return RLENGTH }

    BEGIN {
      in_services=0
      in_service=0
      in_upstream=0
      service_indent=-1
      upstream_indent=-1
      upstream_port=""
    }

    /^[ \t]*#/ { next }
    /^[ \t]*$/ { next }

    { line=$0 }

    !in_services && line ~ /^[ \t]*services:[ \t]*$/ {
      in_services=1
      next
    }

    in_services && !in_service && match(line, /^[ \t]*jellyfin:[ \t]*$/) {
      in_service=1
      service_indent=indent_len(line)
      next
    }

    in_service {
      cur_indent=indent_len(line)

      if (cur_indent == service_indent && match(line, /^[ \t]*[A-Za-z0-9_-]+:[ \t]*$/) && line !~ /^[ \t]*jellyfin:[ \t]*$/) {
        in_service=0
        in_upstream=0
        next
      }

      if (match(line, /^[ \t]*upstream:[ \t]*$/)) {
        in_upstream=1
        upstream_indent=indent_len(line)
        next
      }

      if (in_upstream) {
        if (cur_indent <= upstream_indent && match(line, /^[ \t]*[A-Za-z0-9_-]+:[ \t]*$/)) {
          in_upstream=0
          next
        }

        if (match(line, /^[ \t]*port:[ \t]*/)) {
          sub(/^[ \t]*port:[ \t]*/, "", line)
          upstream_port=trim(line)
          next
        }
      }
    }

    END { print upstream_port }
  ' "$registry_path"
)"

if [[ -z "$upstream_port" ]]; then
  echo "Warning: could not read services.jellyfin.upstream.port from ${registry_path}; leaving JELLYFIN_HOST_PORT unset." >&2
  exit 0
fi

case "$format" in
  export)
    printf "export JELLYFIN_HOST_PORT=%q\n" "$upstream_port"
    ;;
  env)
    printf "JELLYFIN_HOST_PORT=%s\n" "$upstream_port"
    ;;
  *)
    echo "Invalid --format: $format (expected export|env)" >&2
    exit 2
    ;;
esac

