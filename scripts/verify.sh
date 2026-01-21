#!/usr/bin/env bash
set -euo pipefail

eval "$(./scripts/registry-homepage-env.sh)"

adler_ip="${ADLER_IP:-10.92.8.6}"
dns_name="home.stanley.arpa"

echo "Upstream check:"
curl -I "http://${adler_ip}:${HOMEPAGE_HOST_PORT}/"

echo
echo "Public (nginx) checks:"
curl -kI "https://${dns_name}/healthz"
curl -kI "https://${dns_name}/"

