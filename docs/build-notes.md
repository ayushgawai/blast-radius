# Build notes

A running log of what was hard and what worked while building Blast Radius. Source for the "what you liked and would improve" answer in `docs/submission.md`.

## 2026-11-05

Friction:
- **Bundled Mattermost needs Docker's default socket.** It needs Docker with "Allow the default Docker socket" on. We moved to Slack instead.
- **Slack app manifest.** Copy it from the Switch docs as JSON.
- **No GitHub connector on the local server.** Switch Console's local server has `GATEWAY_PUBLIC_URL=http://localhost:...`, and the GitHub connector needs https. Agents use the local `gh` login; the GitHub references in Switch are pointers that tell agents to use `gh` and `git`.
- **Jira key.** New Jira projects get the key `KAN`. We renamed ours to `BR`.
- **DuckDB 2.0** removed `relation.fetchone()`; use `con.execute(...).fetchone()`.

Worked:
- Switch Console local server running on Ayush's Mac, with Claude Code, Codex and OpenCode as providers.
- Slack connected (app "Agent Switch") over Socket Mode, from a laptop, with the teammate on his own laptop.
- Atlassian connected through Switch, so agents use Jira with no token script.
- `make verify` passes locally: 6 breakages on the rename, green after the fixes, no impact on `device_type`.
- `make seed` and `make reset-demo` ran clean twice; `make break` and `make demo-message` work. CI green on all 4 demo repos.

## 2026-11-06

Friction:
- **Template references.** In template v2, a list item with a `value` key is read as an `{if, value}` conditional, and every reference has a `value`. Fix: wrap a room's references in one `- value: [...]` entry.
- **Template `repo:` clone** did not happen for 2 of the 4 agents. Cloned by hand; `make agent-dirs` now clones or resets every agent dir.
- **Approval comments** used the Slack handle. The room instructions now ask for the owner name from the README.
- **Refusal wording.** Manav's Slack account is not linked to a Switch user yet, so the refusal on `@dash-bot` reads "not linked" instead of "not permitted".

Worked:
- Agents, rooms, group, "depends on" links, roles and aliases all created from `switch/blast-radius.template.yaml` by switch-buddy.
- Rehearsal 1 passed end to end on upstream PR #2: 6 breakages, Jira BR-4, BR-5, BR-6, 3 fix PRs (br-analytics-dbt#1, br-ml-features#1, br-dashboards-sql#1) with green CI, 3 owner approvals, and the `blast-radius` check green with "6 breakages fixed across 3 repos".
- The refusal of Manav on `@dash-bot` works.
- The dbt bot found its own fix: one alias `account_id as user_id` in `stg_events` instead of the planned 3 file rename. Both are valid; `make verify` checks the planned one.
