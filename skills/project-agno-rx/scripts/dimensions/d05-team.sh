#!/usr/bin/env bash
# d05-team.sh — Team coordination patterns
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export PROJECT_ROOT="${1:-.}"
source "$SCRIPT_DIR/../lib/common.sh"

echo "── D05: Team ──"

# M5.1: Team() instantiation and mode
n_teams=$(count_teams)
team_files=$(py_list 'Team\s*(' | head -30)
mode_usage=$(py_find -print0 | xargs -0 grep -ohE 'mode\s*=\s*["\x27]?\w+' 2>/dev/null | sort | uniq -c | sort -rn | head -5 | tr '\n' '; ')
if [[ "$n_teams" -gt 0 ]]; then
  emit "M5.1" "PASS" "Teams: $n_teams | modes: $mode_usage"
else
  emit "M5.1" "INFO" "No Team() instantiations found"
fi

# M5.2: Multiple agents with distinct name= and role=
named_agents=$(py_find -print0 | xargs -0 grep -cE 'Agent\s*\([^)]*name=' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
role_agents=$(py_find -print0 | xargs -0 grep -cE 'Agent\s*\([^)]*role=' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
if [[ "$named_agents" -gt 2 && "$role_agents" -gt 0 ]]; then
  emit "M5.2" "PASS" "Multi-agent: named=$named_agents with_role=$role_agents"
elif [[ "$named_agents" -gt 0 ]]; then
  emit "M5.2" "WARN" "Agents named=$named_agents but role=$role_agents (consider adding role= for teams)"
else
  emit "M5.2" "INFO" "No multi-agent patterns detected"
fi

# M5.3: Shared resources in teams
shared_db=$(py_find -print0 | xargs -0 grep -cE 'Team\s*\([^)]*db=' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
shared_kb=$(py_find -print0 | xargs -0 grep -cE 'Team\s*\([^)]*knowledge=' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
team_hist=$(py_find -print0 | xargs -0 grep -cE 'enable_team_history\s*=\s*True' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
if [[ "$shared_db" -gt 0 || "$shared_kb" -gt 0 || "$team_hist" -gt 0 ]]; then
  emit "M5.3" "PASS" "Shared resources: db=$shared_db knowledge=$shared_kb team_history=$team_hist"
else
  [[ "$n_teams" -gt 0 ]] && emit "M5.3" "WARN" "Teams exist but no shared db/knowledge/history" \
                          || emit "M5.3" "INFO" "No team shared resources"
fi

# M5.4: Team instructions and delegation
team_instr=$(py_find -print0 | xargs -0 grep -cE 'Team\s*\([^)]*instructions=' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
delegation=$(py_find -print0 | xargs -0 grep -cE 'delegate|transfer_to|handoff' 2>/dev/null | awk -F: '{s+=$2}END{print s+0}')
if [[ "$team_instr" -gt 0 ]]; then
  emit "M5.4" "PASS" "Team instructions=$team_instr delegation_patterns=$delegation"
else
  [[ "$n_teams" -gt 0 ]] && emit "M5.4" "WARN" "Teams without explicit instructions" \
                          || emit "M5.4" "INFO" "No team instruction patterns"
fi
