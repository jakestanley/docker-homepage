#!/usr/bin/env bash
set -euo pipefail

format="export"
registry_path=""
adler_ip="${ADLER_IP:-}"

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
    --adler-ip)
      adler_ip="${2:-}"
      shift 2
      ;;
    -h|--help)
      cat <<'EOF'
Usage: registry-homepage-env.sh [--registry PATH] [--format export|env] [--adler-ip IP]

Reads services.homepage from ../homelab-infra/registry.yaml and prints HOMEPAGE_HOST_PORT and HOMEPAGE_ALLOWED_HOSTS.

Examples:
  eval "$(./scripts/registry-homepage-env.sh)"        # exports vars in current shell
  ./scripts/registry-homepage-env.sh --format env     # prints KEY=VALUE lines
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
  cat >&2 <<EOF
Missing registry: ${registry_path}

This repo expects the authoritative registry at ../homelab-infra/registry.yaml.
Add a services.homepage entry there (dns: home.stanley.arpa, upstream.host: adler, upstream.port: 20017, upstream.scheme: http).
EOF
  exit 1
fi

expected_dns="home.stanley.arpa"
expected_upstream_host="adler"
expected_upstream_scheme="http"
expected_upstream_port="20017"

awk_result="$(
  awk '
    function ltrim(s) { sub(/^[ \t\r\n]+/, "", s); return s }
    function rtrim(s) { sub(/[ \t\r\n]+$/, "", s); return s }
    function trim(s) { return rtrim(ltrim(s)) }
    function indent_len(s,   m) { match(s, /^[ \t]*/); return RLENGTH }

    BEGIN {
      in_services=0
      in_homepage=0
      in_upstream=0
      services_indent=-1
      homepage_indent=-1
      upstream_indent=-1
      dns=""
      upstream_host=""
      upstream_port=""
      upstream_scheme=""
    }

    /^[ \t]*#/ { next }
    /^[ \t]*$/ { next }

    {
      line=$0
    }

    !in_services && line ~ /^[ \t]*services:[ \t]*$/ {
      in_services=1
      services_indent=indent_len(line)
      next
    }

    in_services && !in_homepage && match(line, /^[ \t]*homepage:[ \t]*$/) {
      in_homepage=1
      homepage_indent=indent_len(line)
      next
    }

    in_homepage {
      cur_indent=indent_len(line)

      if (cur_indent == homepage_indent && match(line, /^[ \t]*[A-Za-z0-9_-]+:[ \t]*$/) && line !~ /^[ \t]*homepage:[ \t]*$/) {
        in_homepage=0
        in_upstream=0
        next
      }

      if (match(line, /^[ \t]*dns:[ \t]*/)) {
        sub(/^[ \t]*dns:[ \t]*/, "", line)
        dns=trim(line)
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

        if (match(line, /^[ \t]*host:[ \t]*/)) {
          sub(/^[ \t]*host:[ \t]*/, "", line)
          upstream_host=trim(line)
          next
        }
        if (match(line, /^[ \t]*port:[ \t]*/)) {
          sub(/^[ \t]*port:[ \t]*/, "", line)
          upstream_port=trim(line)
          next
        }
        if (match(line, /^[ \t]*scheme:[ \t]*/)) {
          sub(/^[ \t]*scheme:[ \t]*/, "", line)
          upstream_scheme=trim(line)
          next
        }
      }
    }

    END {
      print dns "\t" upstream_host "\t" upstream_port "\t" upstream_scheme
    }
  ' "$registry_path"
)"

dns="$(cut -f1 <<<"$awk_result")"
upstream_host="$(cut -f2 <<<"$awk_result")"
upstream_port="$(cut -f3 <<<"$awk_result")"
upstream_scheme="$(cut -f4 <<<"$awk_result")"

if [[ -z "$dns" || -z "$upstream_host" || -z "$upstream_port" || -z "$upstream_scheme" ]]; then
  cat >&2 <<EOF
Could not read services.homepage from ${registry_path}

Expected:
services:
  homepage:
    dns: ${expected_dns}
    upstream:
      host: ${expected_upstream_host}
      port: ${expected_upstream_port}
      scheme: ${expected_upstream_scheme}
EOF
  exit 1
fi

if [[ "$dns" != "$expected_dns" || "$upstream_host" != "$expected_upstream_host" || "$upstream_scheme" != "$expected_upstream_scheme" || "$upstream_port" != "$expected_upstream_port" ]]; then
  cat >&2 <<EOF
Registry mismatch in ${registry_path} for services.homepage:
  dns:            ${dns} (expected ${expected_dns})
  upstream.host:  ${upstream_host} (expected ${expected_upstream_host})
  upstream.port:  ${upstream_port} (expected ${expected_upstream_port})
  upstream.scheme:${upstream_scheme} (expected ${expected_upstream_scheme})

Update ../homelab-infra/registry.yaml to match the control-plane allocation.
EOF
  exit 1
fi

case "$format" in
  export)
    printf "export HOMEPAGE_HOST_PORT=%q\n" "$upstream_port"
    ;;
  env)
    printf "HOMEPAGE_HOST_PORT=%s\n" "$upstream_port"
    ;;
  *)
    echo "Invalid --format: $format (expected export|env)" >&2
    exit 2
    ;;
esac

allowed_hosts=(
  "$dns"
  "${dns}:443"
  localhost
  "127.0.0.1"
)

if [[ -n "$adler_ip" ]]; then
  allowed_hosts+=("$adler_ip" "${adler_ip}:${upstream_port}")
fi

if [[ -n "${HOMEPAGE_ALLOWED_HOSTS_EXTRA:-}" ]]; then
  IFS=',' read -r -a extra_hosts <<<"${HOMEPAGE_ALLOWED_HOSTS_EXTRA}"
  for h in "${extra_hosts[@]}"; do
    h="${h#"${h%%[![:space:]]*}"}"
    h="${h%"${h##*[![:space:]]}"}"
    [[ -n "$h" ]] && allowed_hosts+=("$h")
  done
fi

allowed_hosts_csv="$(
  printf '%s\n' "${allowed_hosts[@]}" | awk '
    BEGIN { FS="\n" }
    {
      gsub(/^[ \t]+|[ \t]+$/, "", $0)
      if ($0 != "" && !seen[$0]++) out = out (out=="" ? "" : ",") $0
    }
    END { print out }
  '
)"

case "$format" in
  export)
    printf "export HOMEPAGE_ALLOWED_HOSTS=%q\n" "$allowed_hosts_csv"
    ;;
  env)
    printf "HOMEPAGE_ALLOWED_HOSTS=%s\n" "$allowed_hosts_csv"
    ;;
  *)
    echo "Invalid --format: $format (expected export|env)" >&2
    exit 2
    ;;
esac
