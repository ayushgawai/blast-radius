#!/usr/bin/env bash
# Close demo PRs, delete demo branches, reset the agent dirs. Safe when there is nothing to reset.
set -euo pipefail

export GH_USER="${GH_USER:-$(gh api user -q .login)}"

# Close open PRs on $1 whose head branch starts with $2, then delete any branches left with that prefix.
reset() {
  local repo="$GH_USER/$1" prefix="$2"
  gh pr list -R "$repo" --state open --json number,headRefName \
    -q ".[] | select(.headRefName | startswith(\"$prefix\")) | .number" | while read -r n; do
    gh pr close -R "$repo" "$n" --delete-branch
  done
  gh api "repos/$repo/git/matching-refs/heads/$prefix" -q '.[].ref' | while read -r ref; do
    gh api -X DELETE "repos/$repo/git/$ref"
  done
}

for repo in br-analytics-dbt br-ml-features br-dashboards-sql; do
  reset "$repo" fix/
done
reset br-events-producer rename-user-key
reset br-events-producer add-device-type

"$(dirname "$0")/agent_dirs.sh"
