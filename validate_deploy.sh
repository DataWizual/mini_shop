#!/usr/bin/env bash
set -euo pipefail

# === CONFIG ===
PROJECT_DIR=~/mini_shop
MONITORING_DIR=$PROJECT_DIR/monitoring
LOG_FILE="$PROJECT_DIR/validation_$(date +%Y%m%d_%H%M%S).log"

# === HEADER ===
{
echo "==============================================================="
echo "🧪 DEPLOYMENT VALIDATION STARTED — $(date)"
echo "==============================================================="
echo "📘 Log file: $LOG_FILE"
echo "---------------------------------------------------------------"
} | tee -a "$LOG_FILE"

# === FUNCTION: health check ===
check_service() {
  local name="$1"
  local url="$2"
  echo -n "🔍 Checking $name ($url)... " | tee -a "$LOG_FILE"
  if curl -fs --max-time 5 "$url" > /dev/null; then
    echo "✅ OK" | tee -a "$LOG_FILE"
  else
    echo "❌ FAIL" | tee -a "$LOG_FILE"
  fi
}

# === STEP 1: Verify containers ===
echo "🔎 Checking Docker containers..." | tee -a "$LOG_FILE"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | tee -a "$LOG_FILE"

REQUIRED_CONTAINERS=(mini_shop_backend mini_shop_db mini_shop_grafana mini_shop_prometheus)
for c in "${REQUIRED_CONTAINERS[@]}"; do
  if docker ps --format '{{.Names}}' | grep -q "^$c$"; then
    echo "✅ Container $c is running." | tee -a "$LOG_FILE"
  else
    echo "❌ Container $c is NOT running." | tee -a "$LOG_FILE"
  fi
done

# === STEP 2: Check service availability ===
echo "---------------------------------------------------------------" | tee -a "$LOG_FILE"
echo "🌐 Checking HTTP endpoints..." | tee -a "$LOG_FILE"

check_service "Backend UI" "http://localhost:5000"
check_service "Backend API" "http://localhost:5000/products"
check_service "Grafana" "http://localhost:3000"
check_service "Prometheus" "http://localhost:9090"

# === STEP 3: Check DB connectivity ===
echo "---------------------------------------------------------------" | tee -a "$LOG_FILE"
echo "🗄️  Checking database connection..." | tee -a "$LOG_FILE"
if docker exec mini_shop_db pg_isready -U postgres &>/dev/null; then
  echo "✅ Database is ready." | tee -a "$LOG_FILE"
else
  echo "❌ Database connection failed." | tee -a "$LOG_FILE"
fi

# === STEP 4: Prometheus job health ===
echo "---------------------------------------------------------------" | tee -a "$LOG_FILE"
echo "📊 Checking Prometheus targets..." | tee -a "$LOG_FILE"

PROM_TARGETS=$(curl -s http://localhost:9090/api/v1/targets | jq -r '.data.activeTargets[] | [.labels.job, .health] | @tsv' || true)

if [[ -n "$PROM_TARGETS" ]]; then
  echo "$PROM_TARGETS" | tee -a "$LOG_FILE"
  DOWN_COUNT=$(echo "$PROM_TARGETS" | grep -c "down" || true)
  if [[ $DOWN_COUNT -gt 0 ]]; then
    echo "⚠️  Some Prometheus targets are down: $DOWN_COUNT" | tee -a "$LOG_FILE"
  else
    echo "✅ All Prometheus targets are UP." | tee -a "$LOG_FILE"
  fi
else
  echo "❌ Unable to fetch Prometheus targets (check Prometheus API)." | tee -a "$LOG_FILE"
fi

# === STEP 5: Backend log check ===
echo "---------------------------------------------------------------" | tee -a "$LOG_FILE"
echo "🧾 Checking backend logs for errors..." | tee -a "$LOG_FILE"

if docker logs mini_shop_backend 2>&1 | grep -q "OperationalError"; then
  echo "❌ Database OperationalError detected in backend logs." | tee -a "$LOG_FILE"
else
  echo "✅ No critical errors in backend logs." | tee -a "$LOG_FILE"
fi

# === SUMMARY ===
{
echo "==============================================================="
echo "🎯 Validation completed — $(date)"
echo "📘 Log saved to: $LOG_FILE"
echo "==============================================================="
} | tee -a "$LOG_FILE"
