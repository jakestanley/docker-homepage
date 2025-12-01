#!/usr/bin/env bash

homepage_secrets_file="homepage.secrets"
if [ ! -f "$homepage_secrets_file" ]; then
    echo "Error: $homepage_secrets_file does not exist."
    exit 1
fi

homepage_config_dir="$HOME/homepage/config"
homepage_services_file="$homepage_config_dir/services.yaml"
if [ ! -f "$homepage_services_file" ]; then
    echo "Error $homepage_services_file does not exist."
    exit 1
fi

mkdir -p ~/homepage/config

set -x
if [ $# -eq 0 ]; then
	HOMEPAGE_CONFIG_DIR="$homepage_config_dir" PID=$(id -u) GID=$(id -g) docker compose up -d
else

	HOMEPAGE_CONFIG_DIR="$homepage_config_dir" PID=$(id -u) GID=$(id -g) docker compose "$@"
fi
