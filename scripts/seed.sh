#!/usr/bin/env bash
# Publish the four demo repos from demo/ to github.com/$GH_USER. Safe to rerun.
set -euo pipefail

export GH_USER="${GH_USER:-$(gh api user -q .login)}"
export TEAMMATE="${TEAMMATE:-$GH_USER}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPOS="br-events-producer br-analytics-dbt br-ml-features br-dashboards-sql"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

for repo in $REPOS; do
  dir="$tmp/$repo"
  rsync -a --exclude .venv --exclude .upstream --exclude .reports --exclude target \
    --exclude logs --exclude data --exclude .user.yml --exclude __pycache__ --exclude .pytest_cache \
    "$ROOT/demo/$repo/" "$dir/"

  { grep -rlI -e ayushgawai -e Patel-manav20 "$dir" || true; } | while read -r f; do
    perl -pi -e 's/ayushgawai/$ENV{GH_USER}/g; s/Patel-manav20/$ENV{TEAMMATE}/g' "$f"
  done

  gh repo view "$GH_USER/$repo" >/dev/null 2>&1 || gh repo create "$GH_USER/$repo" --public

  git -C "$dir" init -q -b main
  git -C "$dir" add -A
  git -C "$dir" commit -qm "Initial commit"
  url="https://github.com/$GH_USER/$repo.git"
  auth=(-c credential.helper= -c 'credential.helper=!gh auth git-credential')
  # Skip the push when GitHub already has exactly this tree, so reruns keep main's history.
  if git -C "$dir" "${auth[@]}" fetch -q "$url" main 2>/dev/null &&
     [ "$(git -C "$dir" rev-parse 'FETCH_HEAD^{tree}')" = "$(git -C "$dir" rev-parse 'HEAD^{tree}')" ]; then
    echo "$repo: up to date"
  else
    git -C "$dir" "${auth[@]}" push -qf "$url" main
  fi
done

if [ "$TEAMMATE" != "$GH_USER" ]; then
  for repo in br-analytics-dbt br-ml-features; do
    gh api -X PUT "repos/$GH_USER/$repo/collaborators/$TEAMMATE" -f permission=push >/dev/null
  done
fi

gh api -X PUT "repos/$GH_USER/br-events-producer/branches/main/protection" --input - >/dev/null <<'JSON'
{
  "required_status_checks": {"strict": false, "contexts": ["blast-radius"]},
  "enforce_admins": false,
  "allow_force_pushes": true,
  "required_pull_request_reviews": null,
  "restrictions": null
}
JSON

for repo in $REPOS; do
  echo "https://github.com/$GH_USER/$repo"
done
