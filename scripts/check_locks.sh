#!/usr/bin/env bash
set -euo pipefail
MIGRATION_FILE="$1"

psql "$SANDBOX_DB_URL" -c "
  DO \$\$
  BEGIN
    FOR i IN 1..200 LOOP
      PERFORM id FROM orders WHERE status = 'pending' LIMIT 10;
      PERFORM pg_sleep(0.01);
    END LOOP;
  END \$\$;
" &
TRAFFIC_PID=$!

if ! psql "$SANDBOX_DB_URL" -v ON_ERROR_STOP=1 \
  -c "SET lock_timeout = '200ms'; SET statement_timeout = '5s';" \
  -f "$MIGRATION_FILE"; then
  echo "[BLOCKED] AccessExclusiveLock or lock_timeout triggered."
  kill $TRAFFIC_PID 2>/dev/null || true
  exit 1
fi

wait $TRAFFIC_PID
echo "[PASS] Zero-downtime migration verified."
