#!/usr/bin/env bash
set -euo pipefail

PROJECT="mini_shop"
VOLUME="${PROJECT}_db_data"
LOG_FILE="./deploy.log"

# === Функция для записи и отображения ===
log() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# === Очистка старого лога ===
: > "$LOG_FILE"

log "=== 🚀 Starting local deployment for project: $PROJECT ==="

# === Проверяем существование БД тома ===
if docker volume ls --format '{{.Name}}' | grep -q "^${VOLUME}$"; then
    log "⚠️  Found existing database volume: $VOLUME"
    read -p "Do you want to remove it (this will DELETE all DB data)? [y/N]: " CONFIRM
    if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
        log "🗑️  Removing volume and old containers..."
        docker compose down -v | tee -a "$LOG_FILE" || true
        docker volume rm "$VOLUME" | tee -a "$LOG_FILE" || true
    else
        log "✅ Keeping existing volume and data."
        docker compose down | tee -a "$LOG_FILE" || true
    fi
else
    log "ℹ️  No existing DB volume found — clean start."
    docker compose down | tee -a "$LOG_FILE" || true
fi

# === Пересборка контейнеров ===
log "🏗️  Building Docker images..."
docker compose build --no-cache 2>&1 | tee -a "$LOG_FILE"

# === Запуск контейнеров ===
log "🚀  Starting containers..."
docker compose up -d 2>&1 | tee -a "$LOG_FILE"

# === Небольшая задержка для инициализации ===
log "⏳ Waiting for backend to become ready..."
sleep 10

# === Проверка статуса ===
log "📋 Container status:"
docker compose ps | tee -a "$LOG_FILE"

# === Проверка доступности backend ===
log "🧠 Checking backend health..."
if curl -s http://localhost:5000/products >/dev/null 2>&1; then
    log "✅ Backend is responding correctly."
else
    log "❌ Backend did not respond — showing last logs:"
    docker compose logs backend --tail=40 | tee -a "$LOG_FILE"
fi

# === Проверка состояния БД томов ===
log "🧱 Active Docker volumes:"
docker volume ls | grep "$PROJECT" | tee -a "$LOG_FILE" || log "No volumes found."

log "🎯 Deployment completed successfully."
log "📁 Full log saved at: $(realpath $LOG_FILE)"
