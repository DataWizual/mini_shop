#!/usr/bin/env bash
set -euo pipefail

# === CONFIG ===
PROJECT_DIR=~/mini_shop
MONITORING_DIR=$PROJECT_DIR/monitoring
LOG_FILE="$PROJECT_DIR/deploy_all_$(date +%Y%m%d_%H%M%S).log"

# === LOG HEADER ===
{
echo "==============================================================="
echo "🚀 FULL DEPLOYMENT PIPELINE STARTED — $(date)"
echo "==============================================================="
echo "📘 Log file: $LOG_FILE"
echo "---------------------------------------------------------------"
} | tee -a "$LOG_FILE"

# === DEPENDENCY CHECK ===
echo "🔍 Checking dependencies..." | tee -a "$LOG_FILE"

for cmd in docker curl bash; do
  if ! command -v $cmd &>/dev/null; then
    echo "❌ Missing dependency: $cmd" | tee -a "$LOG_FILE"
    exit 1
  fi
done

# Проверка docker compose (v2) или docker-compose (v1)
if docker compose version &>/dev/null; then
  COMPOSE_CMD="docker compose"
elif command -v docker-compose &>/dev/null; then
  COMPOSE_CMD="docker-compose"
else
  echo "❌ Missing dependency: docker compose or docker-compose" | tee -a "$LOG_FILE"
  exit 1
fi

echo "✅ All dependencies found." | tee -a "$LOG_FILE"

# === 🧠 SAFETY CHECK — удаление БД с подтверждением ===
if docker volume inspect mini_shop_db_data >/dev/null 2>&1; then
  echo "⚠️  Обнаружен volume базы данных: mini_shop_db_data" | tee -a "$LOG_FILE"
  read -p "❓ Удалить БД (данные будут потеряны)? [y/N]: " confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo "🗑️  Удаляем volume БД..." | tee -a "$LOG_FILE"
    docker volume rm -f mini_shop_db_data >> "$LOG_FILE" 2>&1 || true
  else
    echo "💾 Volume mini_shop_db_data сохранён." | tee -a "$LOG_FILE"
  fi
else
  echo "ℹ️  Volume mini_shop_db_data не найден." | tee -a "$LOG_FILE"
fi

# === CLEANUP (без удаления БД) ===
echo "🧹 Cleaning up old containers and networks..." | tee -a "$LOG_FILE"

# Останавливаем и удаляем только ненужные контейнеры monitoring и backend
$COMPOSE_CMD -f $PROJECT_DIR/docker-compose.yml down --remove-orphans >> "$LOG_FILE" 2>&1 || true
if [ -f "$MONITORING_DIR/docker-compose.monitoring.yml" ]; then
  $COMPOSE_CMD -f $MONITORING_DIR/docker-compose.monitoring.yml down --remove-orphans >> "$LOG_FILE" 2>&1 || true
fi

# Удаляем старые dangling-сети, но НЕ удаляем mini_shop_shopnet
docker network prune -f >> "$LOG_FILE" 2>&1 || true
echo "✅ Cleanup complete." | tee -a "$LOG_FILE"

# === DEPLOY LOCAL APP ===
echo "---------------------------------------------------------------"
echo "🏗️  Running local deployment (Stage 5)..." | tee -a "$LOG_FILE"

if [ -x "$PROJECT_DIR/deploy_local.sh" ]; then
  "$PROJECT_DIR/deploy_local.sh" | tee -a "$LOG_FILE"
else
  echo "❌ deploy_local.sh not found or not executable in $PROJECT_DIR" | tee -a "$LOG_FILE"
  exit 1
fi

echo "✅ Local deployment completed." | tee -a "$LOG_FILE"

# === DEPLOY MONITORING ===
echo "---------------------------------------------------------------"
echo "📊 Running monitoring deployment (Stage 6)..." | tee -a "$LOG_FILE"

if [ -x "$MONITORING_DIR/deploy_monitoring.sh" ]; then
  "$MONITORING_DIR/deploy_monitoring.sh" | tee -a "$LOG_FILE"
else
  echo "❌ deploy_monitoring.sh not found or not executable in $MONITORING_DIR" | tee -a "$LOG_FILE"
  exit 1
fi

echo "✅ Monitoring deployment completed." | tee -a "$LOG_FILE"

# === FINAL SUMMARY ===
{
echo "==============================================================="
echo "🎯 All stages completed successfully — $(date)"
echo "📘 Log saved to: $LOG_FILE"
echo "==============================================================="
} | tee -a "$LOG_FILE"
