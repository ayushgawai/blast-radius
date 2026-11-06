#!/usr/bin/env bash
# Open the upstream PR on br-events-producer: `break.sh rename` or `break.sh device`.
set -euo pipefail

GH_USER="${GH_USER:-$(gh api user -q .login)}"
REPO="$GH_USER/br-events-producer"

# Same producer/schema.py edits as scripts/verify.py.
case "${1:-}" in
  rename)
    branch=rename-user-key
    title="Rename user_id to account_id in events"
    old='USER_KEY = "user_id"'
    new='USER_KEY = "account_id"'
    ;;
  device)
    branch=add-device-type
    title="Add nullable device_type column to events"
    old=$'    ("revenue_usd", "DOUBLE"),\n'
    new=$'    ("revenue_usd", "DOUBLE"),\n    ("device_type", "VARCHAR"),\n'
    ;;
  *) echo "usage: $0 rename|device" >&2; exit 2 ;;
esac

open="$(gh pr list -R "$REPO" --head "$branch" --state open --json url -q '.[0].url // empty')"
if [ -n "$open" ]; then
  echo "$open"
  exit 0
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
gh repo clone "$REPO" "$tmp" -- -q
cd "$tmp"
git checkout -qb "$branch"
python3 -c '
import sys, pathlib
p = pathlib.Path("producer/schema.py")
s = p.read_text()
edited = s.replace(sys.argv[1], sys.argv[2])
assert edited != s, "schema.py edit did not apply"
p.write_text(edited)
' "$old" "$new"
git commit -qam "$title"
git -c credential.helper= -c 'credential.helper=!gh auth git-credential' push -qf origin "$branch"
gh pr create -R "$REPO" --base main --head "$branch" --title "$title" \
  --body "Changes \`producer/schema.py\` on \`$branch\`. @coordinator will check the blast radius."
