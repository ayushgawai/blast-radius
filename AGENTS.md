# AGENTS.md: handoff for any coding agent

Read this, then `SPEC.md` (the contract). The original plan is `Blast Radius Build Brief for the Lead Agent.md` in this folder (local only, gitignored). Writing rule: no em dashes or en dashes anywhere.

## What this is

Blast Radius, a Switch hackathon entry (Track 1 and 2, plus Code with Wispr, Best Blog, #HowISwitch). One upstream rename PR; four Switch agents on three providers test it in their own repos, file Jira tickets, open fix PRs, and the upstream `blast-radius` check turns green only after each repo owner approves in Slack.

Team: Ayush Gawai (GitHub `ayushgawai`, Slack `ayushsunilgawai`) and Manav Patel (GitHub `Patel-manav20`).

## State (2026-11-06)

Done and verified:
- `demo/`: the 4 demo repos, published to github.com/ayushgawai/br-* by `make seed`; CI green on all.
- `make verify` passes (local, no GitHub): 6 breakages on rename, green after fixes, no impact on device_type.
- `make seed`, `make reset-demo` run clean twice; `make break` and `make demo-message` work.
- Switch live on Ayush's Mac: local server in Switch Console, Slack connected (app "Agent Switch"), Atlassian connected, Jira project key BR on ayushsunilgawai.atlassian.net.
- Agents and rooms created from `switch/blast-radius.template.yaml` by switch-buddy-admin: br-coordinator (Claude), br-dbt (Claude), br-ml (Codex), br-dash (OpenCode); Slack channels schema-changes, analytics, ml-features, dashboards; links "depends on"; roles; aliases @coordinator @dbt-bot @ml-bot @dash-bot.
- Rehearsal 1 passed end to end on upstream PR #2: 6 breakages, Jira BR-4/5/6, 3 fix PRs green, 3 approvals, check green. Refusal of Manav on @dash-bot works.

Left:
- Main repo `blast-radius` not yet pushed to GitHub. README, docs/blog.md, docs/social.md, docs/submission.md, docs/build-notes.md in progress.
- Manav links his Slack account to a Switch user, so the refusal reads as "not permitted" instead of "not linked".
- Rehearsals 2 and 3: `make reset-demo`, `make break`, `make demo-message`, then the runbook in the brief.
- Video, Wispr usage cards, blog publish, #HowISwitch post (humans).

## Where things are

| Thing | Where |
| --- | --- |
| Agent working dirs (Switch created them) | `~/.switch/agents/localhost-61239/br-*` |
| Switch repo, read only reference | `~/Documents/GitHub/_ref/switch` (template language: `docs/TEMPLATES.md`, `core/switch_core/template_guide.py`) |
| Room and role instructions (source) | `switch/rooms/*.md`, `switch/roles/*.md`; regenerate the template with `python3 scripts/build_template.py` |
| Second Claude account key for workers | `.env` (`claude_code_api_key_manav`), gitignored; run workers as `ANTHROPIC_API_KEY=... claude -p` |
| Docker CLI | `/Applications/Docker.app/Contents/Resources/bin/docker` (not on PATH) |

## Gotchas learned (also feed docs/build-notes.md)

- Switch Console's local server has `GATEWAY_PUBLIC_URL=http://localhost:...`, so the GitHub connector (needs https) cannot be set up. Agents use the local `gh` login instead; GitHub references in Switch are pointers that tell agents to use `gh` and `git`.
- Template v2: a list item with a `value` key is read as an `{if, value}` conditional, and references have `value`. Wrap a room's references in one `- value: [...]` entry.
- Template `repo:` clone did not happen for 2 of 4 agents; cloned by hand. `make agent-dirs` fixes it.
- The bundled Mattermost needs Docker with "Allow the default Docker socket" on. We use Slack instead (works from a laptop through Socket Mode, teammate on his own laptop).
- Slack app manifest: copy it from the Switch docs as JSON.
- Jira projects get key KAN by default; we renamed it to BR.
- DuckDB 2.0 removed `relation.fetchone()`; use `con.execute(...).fetchone()`.
- The dbt bot fixed the rename by aliasing `account_id as user_id` in `stg_events` (1 file) instead of the spec's 3 file rename. Both are valid; verify.py checks the spec fix.
- Approval comments used the Slack handle; room instructions now ask for the owner name from the README.
