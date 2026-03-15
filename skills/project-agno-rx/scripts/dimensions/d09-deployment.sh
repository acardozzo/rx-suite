#!/usr/bin/env bash
# d09-deployment.sh — Deployment readiness and observability
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PROJECT_ROOT="${1:-.}"
source "$SCRIPT_DIR/../lib/common.sh"

echo "── D09: Deployment ──"

# M9.1: AgentOS / FastAPI integration
agent_os=$(py_find -print0 | xargs -0 grep -cE 'from agno\.os|AgentOS|agent_os' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
fastapi=$(py_find -print0 | xargs -0 grep -cE 'from fastapi|FastAPI\s*\(' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
get_app=$(py_find -print0 | xargs -0 grep -cE 'get_app\s*\(|\.app\b' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
if [[ "$agent_os" -gt 0 ]]; then
  emit "M9.1" "PASS" "AgentOS=$agent_os FastAPI=$fastapi get_app=$get_app"
elif [[ "$fastapi" -gt 0 ]]; then
  emit "M9.1" "INFO" "FastAPI=$fastapi but no AgentOS (consider agno.os for standard serving)"
else
  emit "M9.1" "INFO" "No serving layer detected"
fi

# M9.2: Production storage (PostgresDb, migrations)
pg=$(py_find -print0 | xargs -0 grep -cE 'from agno\.db\.postgres|PostgresDb' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
sqlite=$(py_find -print0 | xargs -0 grep -cE 'from agno\.db\.sqlite|SqliteDb' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
mongo=$(py_find -print0 | xargs -0 grep -cE 'from agno\.db\.mongo|MongoDb' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
migrations=$(find "$ROOT" -type d -name 'migrations' -o -name 'alembic' 2>/dev/null | head -3 | wc -l | tr -d ' ')
if [[ "$pg" -gt 0 ]]; then
  emit "M9.2" "PASS" "Production DB: PostgresDb=$pg migrations=$migrations"
elif [[ "$sqlite" -gt 0 ]]; then
  emit "M9.2" "WARN" "SqliteDb=$sqlite (dev only — use PostgresDb for production)"
else
  emit "M9.2" "INFO" "Storage: pg=$pg sqlite=$sqlite mongo=$mongo migrations=$migrations"
fi

# M9.3: Secrets management
env_file=$(find "$ROOT" -maxdepth 2 -name '.env' -o -name '.env.example' 2>/dev/null | head -5 | wc -l | tr -d ' ')
hardcoded=$(py_find -print0 | xargs -0 grep -cE '(sk-|AKIA|ghp_|xoxb-)[A-Za-z0-9]{10,}' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
env_usage=$(py_find -print0 | xargs -0 grep -cE 'os\.environ|os\.getenv|dotenv|settings\.' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
if [[ "$hardcoded" -gt 0 ]]; then
  emit "M9.3" "FAIL" "HARDCODED SECRETS DETECTED ($hardcoded occurrences)"
elif [[ "$env_usage" -gt 0 ]]; then
  emit "M9.3" "PASS" "Env-based secrets: env_usage=$env_usage .env files=$env_file"
else
  emit "M9.3" "WARN" "No secrets management pattern detected"
fi

# M9.4: Tracing and observability
tracing=$(py_find -print0 | xargs -0 grep -cE 'tracing\s*=\s*True' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
langfuse=$(py_find -print0 | xargs -0 grep -cE 'langfuse|Langfuse' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
otel=$(py_find -print0 | xargs -0 grep -cE 'opentelemetry|OpenTelemetry|otel' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
metrics=$(py_find -print0 | xargs -0 grep -cE 'from agno\.metrics|metrics\.' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
if [[ "$tracing" -gt 0 || "$langfuse" -gt 0 || "$otel" -gt 0 ]]; then
  emit "M9.4" "PASS" "Observability: tracing=$tracing langfuse=$langfuse otel=$otel metrics=$metrics"
else
  emit "M9.4" "WARN" "No tracing or observability configured"
fi
