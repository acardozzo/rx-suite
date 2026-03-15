#!/usr/bin/env bash
# D7: 12-Factor Compliance
# M7.1 Codebase/Deps/Build | M7.2 Config/Backing/Port | M7.3 Process/Concurrency/Disposability | M7.4 Dev-Prod/Logs/Admin
source "$(dirname "$0")/../lib/common.sh"

echo "## D7: 12-FACTOR COMPLIANCE"
echo ""

# M7.1: Codebase, deps, build
section "M7.1: Codebase, dependencies & build"
echo "Lockfile:"
for lf in package-lock.json pnpm-lock.yaml yarn.lock go.sum Cargo.lock poetry.lock Pipfile.lock packages.lock.json; do
  [ -f "$ROOT/$lf" ] && echo "  YES: $lf"
done
echo "Build script:"
if [ "$STACK" = "node" ] && [ -f "$ROOT/package.json" ]; then
  grep -q '"build"' "$ROOT/package.json" 2>/dev/null && echo "  YES: package.json build script" || echo "  NO build script"
fi
echo "Monorepo:"
find "$ROOT" -maxdepth 1 -type f \( -name "turbo.json" -o -name "nx.json" -o -name "lerna.json" -o -name "pnpm-workspace.yaml" \) 2>/dev/null | head -3
echo ""

# M7.2: Config, backing services, port binding
section "M7.2: Config, backing services & port binding"
echo "Env var reads:"
echo "  $(src_count '(process\.env|os\.Getenv|os\.environ|Environment\.GetEnvironmentVariable)')"
echo "Config validation:"
src_list "(envSchema|configSchema|z\.object.*env|Joi\.object.*env|validateConfig|class-validator.*config)" 5
echo "Port binding:"
src_list "(listen\(|\.PORT|:3000|:8080|:8000|Addr.*:)" 5
echo ""

# M7.3: Process, concurrency, disposability
section "M7.3: Processes, concurrency & disposability"
echo "Graceful shutdown:"
src_list "(SIGTERM|SIGINT|graceful.*shutdown|signal\.Notify|atexit|beforeExit|process\.on.*exit)" 5
echo ""

# M7.4: Dev/prod parity, logs, admin
section "M7.4: Dev/prod parity, logs & admin"
echo "Docker compose (dev parity):"
find "$ROOT" -name "docker-compose*" -o -name "compose.y*ml" 2>/dev/null | head -5
echo "Stdout logging:"
echo "  files: $(src_list '(transport.*stdout|stream.*stdout|pino\(\)|console\.log)' 999 | wc -l | tr -d ' ')"
echo "Admin/one-off scripts:"
find "$ROOT" -type d \( -name "scripts" -o -name "tasks" -o -name "commands" -o -name "cli" -o -name "bin" \) -maxdepth 2 2>/dev/null | head -5
echo ""
