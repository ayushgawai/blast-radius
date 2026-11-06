#!/usr/bin/env bash
# Print the step 2 chat message with the live upstream PR URL: `demo_message.sh [device]`.
set -euo pipefail

GH_USER="${GH_USER:-$(gh api user -q .login)}"

if [ "${1:-}" = device ]; then
  branch=add-device-type target=break-device
else
  branch=rename-user-key target=break
fi

url="$(gh pr list -R "$GH_USER/br-events-producer" --head "$branch" --state open --json url -q '.[0].url // empty')"
if [ -z "$url" ]; then
  echo "No open PR from $branch on $GH_USER/br-events-producer. Run \`make $target\` first." >&2
  exit 1
fi

if [ "$branch" = add-device-type ]; then
  echo "Adding a nullable device_type column to events. PR: $url. @coordinator what does this break?"
else
  echo "Heads up team: I'm renaming user_id to account_id in the events table. PR: $url. @coordinator what does this break?"
fi
