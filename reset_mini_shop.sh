#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "🧹 Stopping and cleaning up mini_shop environment..."
echo "------------------------------------------------------"

# 1. Остановить и удалить все контейнеры из docker-compose
docker compose down -v --remove-orphans || true
sleep 2

# 2. Убить возможные зависшие контейнеры по шаблону
echo "🔍 Checking for leftover containers..."
for c in $(docker ps -a --format '{{.Names}}' | grep -E 'mini_shop|mini-shop' || true); do
  echo "🧯 Removing container: $c"
  docker rm -f "$c" || true
  sleep 1
done

# 3. Удалить все сети mini_shop_*
echo "🌐 Removing networks..."
for n in $(docker network ls --format '{{.Name}}' | grep -E 'mini_shop|mini-shop' || true); do
  echo "🧨 Removing network: $n"
  docker network rm "$n" || true
  sleep 1
done

# 4. Удалить все тома mini_shop_*
echo "💾 Removing volumes..."
for v in $(docker volume ls --format '{{.Name}}' | grep -E 'mini_shop|mini-shop' || true); do
  echo "🧱 Removing volume: $v"
  docker volume rm "$v" || true
  sleep 1
done

# 5. Удалить все связанные образы
echo "🧩 Removing related images..."
docker images --format "{{.Repository}}:{{.Tag}} {{.ID}}" | \
  awk '/mini_shop|mini-shop/ {print $2}' | \
  xargs -r docker rmi -f || true
sleep 1

# 6. Принудительно очистить системные ресурсы
echo "🧽 Deep prune of system resources..."
docker system prune -af --volumes || true
sleep 2

# 7. Удалить локальную SQLite (если она есть)
echo "🗑️ Removing local SQLite file..."
rm -f ./backend/instance/database.db || true

echo "✅ Full reset complete."
