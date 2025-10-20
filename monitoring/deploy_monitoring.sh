#!/bin/bash
set -e

LOG_FILE="$HOME/mini_shop/monitoring/deploy_monitoring_$(date +%Y%m%d_%H%M%S).log"
NETWORK_NAME="mini_shop_shopnet"
COMPOSE_FILE="$HOME/mini_shop/monitoring/docker-compose.monitoring.yml"

echo "🚀 Stage 6: Развёртывание мониторинга Prometheus + Grafana для mini_shop"
echo "----------------------------------------------------" | tee -a "$LOG_FILE"

cd "$HOME/mini_shop/monitoring"

# Проверка наличия сети
if ! docker network inspect "$NETWORK_NAME" >/dev/null 2>&1; then
  echo "🌐 Создание сети $NETWORK_NAME..." | tee -a "$LOG_FILE"
  docker network create --driver bridge "$NETWORK_NAME" | tee -a "$LOG_FILE"
else
  echo "✅ Сеть $NETWORK_NAME существует." | tee -a "$LOG_FILE"
fi

# Остановка старых контейнеров мониторинга
echo "🧹 Остановка старых контейнеров мониторинга..." | tee -a "$LOG_FILE"
docker compose -f "$COMPOSE_FILE" down --remove-orphans || true

# Запуск
echo "🏗️  Запуск новых контейнеров мониторинга..." | tee -a "$LOG_FILE"
docker compose -f "$COMPOSE_FILE" up -d --remove-orphans | tee -a "$LOG_FILE"

sleep 10
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep mini_shop_ | tee -a "$LOG_FILE"

echo "✅ Мониторинг запущен." | tee -a "$LOG_FILE"
