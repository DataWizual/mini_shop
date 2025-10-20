#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "Stopping compose and removing containers, volumes and networks..."
docker compose down -v --remove-orphans || true

echo "Removing leftover images for mini_shop..."
docker images --format "{{.Repository}}:{{.Tag}} {{.ID}}" | awk '/mini_shop|mini-shop|mini_shop_backend/ {print $2}' | xargs -r docker rmi -f || true

echo "Pruning unused system resources..."
docker volume prune -f || true
docker network prune -f || true
docker system prune -f || true

echo "Removing local sqlite if exists..."
rm -f ./backend/instance/database.db || true

echo "Reset complete."
