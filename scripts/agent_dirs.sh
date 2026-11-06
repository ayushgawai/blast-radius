#!/usr/bin/env bash
# Clone (or reset to origin/main) the working dir of each Switch agent.
set -euo pipefail

GH_USER="${GH_USER:-$(gh api user -q .login)}"
# Default: the folder Switch Console created the agents in, else ~/blast-radius-agents.
switch_dir="$(dirname "$(ls -d "$HOME"/.switch/agents/*/br-coordinator 2>/dev/null | head -n1)")"
[ "$switch_dir" = . ] && switch_dir="$HOME/blast-radius-agents"
AGENTS_DIR="${AGENTS_DIR:-$switch_dir}"
mkdir -p "$AGENTS_DIR"

sync_dir() {
  local dir="$AGENTS_DIR/$1" repo="$GH_USER/$2"
  if [ -d "$dir/.git" ]; then
    git -C "$dir" fetch -q --prune origin
    git -C "$dir" checkout -qf main
    git -C "$dir" reset -q --hard origin/main
    git -C "$dir" for-each-ref --format='%(refname:short)' refs/heads/fix/ | while read -r b; do
      git -C "$dir" branch -qD "$b"
    done
  else
    gh repo clone "$repo" "$dir" -- -q
  fi
  echo "$dir <- $repo"
}

sync_dir br-coordinator br-events-producer
sync_dir br-dbt br-analytics-dbt
sync_dir br-ml br-ml-features
sync_dir br-dash br-dashboards-sql
