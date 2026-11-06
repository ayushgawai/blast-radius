# Blast Radius SPEC

The contract every part of this project is built against. If code and this file disagree, this file wins until it is changed on purpose.

## People

| Person | GitHub | Jira | Owns |
| --- | --- | --- | --- |
| Ayush Gawai | `ayushgawai` | Ayush Gawai | `br-events-producer`, `br-dashboards-sql` |
| Manav Patel | `Patel-manav20` | Manav Patel | `br-analytics-dbt`, `br-ml-features` |

## Repos

`GH_USER` defaults to `ayushgawai`. `make seed GH_USER=<you> TEAMMATE=<handle>` publishes the four demo repos from `demo/` to `github.com/<GH_USER>/<repo>`.

| Repo | Owner | Stack |
| --- | --- | --- |
| `br-events-producer` | Ayush | Python, DuckDB |
| `br-analytics-dbt` | Manav | dbt-duckdb |
| `br-ml-features` | Manav | pandas, pytest |
| `br-dashboards-sql` | Ayush | SQL files, duckdb, pytest |

Every demo repo has: `Makefile` with `test`, `README.md` naming its owner, `CODEOWNERS`, `.github/workflows/ci.yml` running `make test`, `pyproject.toml`, `.python-version` (`3.12`). Python runs through `uv run`.

## The data contract

`br-events-producer` writes `data/events.parquet`: 10,000 events, 500 users, seed 42, byte identical across runs.

| Column | Type | Notes |
| --- | --- | --- |
| `event_id` | VARCHAR | `e00001` to `e10000`, unique |
| `user_id` | VARCHAR | `u001` to `u500`; name comes from `USER_KEY` |
| `session_id` | VARCHAR | each session belongs to exactly one user |
| `event_type` | VARCHAR | `page_view`, `click`, `purchase` |
| `event_ts` | TIMESTAMP | October 2026 |
| `page` | VARCHAR | one of 8 pages |
| `revenue_usd` | DOUBLE | `> 0` for purchases, `0.0` otherwise |

The user key name lives in exactly one place, `producer/schema.py`:

```python
USER_KEY = "user_id"
```

Generate: `uv run python -m producer.generate --out data/events.parquet`.

## The changes

| Change | Branch | Edit | Expected |
| --- | --- | --- | --- |
| Rename (the demo) | `rename-user-key` | `USER_KEY = "account_id"` | 6 breakages in 3 repos |
| Add column (no impact) | `add-device-type` | add nullable `device_type VARCHAR` as last column | 0 breakages |

Upstream PR titles: `Rename user_id to account_id in events` and `Add nullable device_type column to events`.

## Upstream fetch (every downstream repo)

`scripts/fetch_upstream.sh` prints the absolute path of a freshly generated `events.parquet` and nothing else on stdout.

- `UPSTREAM_REPO`: env, default `https://github.com/<GH_USER>/br-events-producer.git`. May be a local path.
- `UPSTREAM_REF`: env; if unset, the first line of the file `upstream.ref`; `upstream.ref` contains `main` on `main`. Any branch, SHA or `pull/<n>/head`.
- Clones into `.upstream/` (gitignored), fetches the ref, checks out `FETCH_HEAD`, runs the generator.

A fix PR sets `upstream.ref` to the upstream branch it adapts to (`rename-user-key`), so its CI tests against that branch. After the upstream PR merges, it goes back to `main`.

## Make targets

Demo repos: `make test` exits 0 when everything passes and non zero otherwise. It writes machine readable results:

| Repo | Command | Results file |
| --- | --- | --- |
| `br-events-producer` | `pytest` | `.reports/junit.xml` |
| `br-analytics-dbt` | `dbt build` | `target/run_results.json` |
| `br-ml-features` | `pytest` | `.reports/junit.xml` |
| `br-dashboards-sql` | `pytest` | `.reports/junit.xml` |

Main repo:

| Target | Does | Exit 0 when |
| --- | --- | --- |
| `make verify` | `scripts/verify.py`, fully local, no GitHub | main green, exactly the 6 breakages below on rename, all green after the fixes, all green on `add-device-type` |
| `make demo-local` | `verify.py --verbose`: same, and prints the failing output | same |
| `make seed GH_USER= TEAMMATE=` | `scripts/seed.sh` | 4 repos exist and are pushed; reruns clean |
| `make break` | `scripts/break.sh rename` | upstream PR is open |
| `make break-device` | `scripts/break.sh device` | upstream PR is open |
| `make demo-message` | `scripts/demo_message.sh` | prints the step 2 chat message with the live PR URL |
| `make reset-demo` | `scripts/reset_demo.sh` | no open demo PRs, no `fix/*`, `rename-user-key` or `add-device-type` branches |

## The 6 breakages (exact)

| # | Repo | Fails | Error |
| --- | --- | --- | --- |
| 1 | `br-analytics-dbt` | model `fct_sessions` | Binder Error: column `user_id` not found |
| 2 | `br-analytics-dbt` | model `dim_users` | Binder Error: column `user_id` not found |
| 3 | `br-ml-features` | `test_user_aggregates` | KeyError: `user_id` |
| 4 | `br-ml-features` | `test_feature_matrix_shape` | KeyError: `user_id` |
| 5 | `br-dashboards-sql` | query `daily_active_users` | Binder Error: column `user_id` not found |
| 6 | `br-dashboards-sql` | query `revenue_by_user` | Binder Error: column `user_id` not found |

Must keep passing on the rename: producer tests, `stg_events` and its tests, `test_load_events`, `test_event_type_counts`, queries `sessions_per_day`, `top_pages`, `event_mix`.

dbt counts model nodes with status `error` (tests skipped under a failed model are not counted). pytest counts test cases with a failure or error.

## The fixes (exact files)

Each fix renames `user_id` to `account_id` in these files only, plus `upstream.ref` set to `rename-user-key`:

| Repo | Files |
| --- | --- |
| `br-analytics-dbt` | `models/marts/fct_sessions.sql`, `models/marts/dim_users.sql`, `models/marts/schema.yml` |
| `br-ml-features` | `features/build.py` |
| `br-dashboards-sql` | `queries/daily_active_users.sql`, `queries/revenue_by_user.sql` |

Fix branch: `fix/<upstream-pr-number>`. PR title: `[<JIRA-KEY>] Adapt to account_id rename (blast radius of <owner>/br-events-producer#<n>)`.

## Switch

Chat app: Slack workspace connected to the local Switch server (Switch Console, "On this computer"). Commands use the `!` form.

| Agent name | Alias | Provider | Role | Rooms | Working dir | Who can instruct |
| --- | --- | --- | --- | --- | --- | --- |
| `br-coordinator` | `@coordinator` | Claude Code | `impact-coordinator` (exclusive) | schema-changes | `<agents dir>/br-coordinator` (clone of `br-events-producer`) | Ayush, the other three agents |
| `br-dbt` | `@dbt-bot` | Claude Code | `impact-checker` (shared) | schema-changes, analytics | `<agents dir>/br-dbt` (clone of `br-analytics-dbt`) | Manav, Ayush, `br-coordinator` |
| `br-ml` | `@ml-bot` | Codex | `impact-checker` (shared) | schema-changes, ml-features | `<agents dir>/br-ml` (clone of `br-ml-features`) | Manav, Ayush, `br-coordinator` |
| `br-dash` | `@dash-bot` | OpenCode | `impact-checker` (shared) | schema-changes, dashboards | `<agents dir>/br-dash` (clone of `br-dashboards-sql`) | Ayush, `br-coordinator` only |

Rooms (Slack channels): `schema-changes`, `analytics`, `ml-features`, `dashboards`, in one group `blast-radius`. Links from `schema-changes` to each team room, label `depends on`.

`<agents dir>` is where Switch Console creates agents (`~/.switch/agents/<server>/`); `make agent-dirs` and `make reset-demo` reset each to `origin/main`.

Room instructions: `switch/rooms/<room>.md`. Role instructions: `switch/roles/<role>.md`. Template: `switch/blast-radius.template.yaml`.

Room document: `impact-<pr-number>` in `schema-changes`, one row per breakage: repo, file, failing check, owner, Jira ticket, fix PR, status.

Commit status on the upstream PR head: context `blast-radius`. `pending` with `Waiting on <N> owners` when the fan out starts, `success` with `<k> breakages fixed across <m> repos` when every owner has approved. Set with `gh api repos/<owner>/br-events-producer/statuses/<sha> -f state=... -f context=blast-radius -f description=...`. `main` of `br-events-producer` requires this check.

## Jira

Through the Switch Atlassian connection. Site `ayushsunilgawai.atlassian.net`, project key `BR` (if the key is still `KAN`, use `KAN`).

- The coordinator creates one parent issue per upstream PR: `Blast radius: <PR title> (#<n>)`, assigned to the upstream owner.
- Each checker that finds a breakage creates one issue for its repo, linked to the parent, assigned to the repo owner, listing failing checks; the issue key goes in the fix PR title.
- On owner approval in chat: the checker moves its issue to Done and comments `approved by <owner> in Switch` on both the issue and the PR.
- When all are Done, the coordinator moves the parent to Done.

## Writing rules

No em dashes or en dashes anywhere in this project. No secrets in any repo. Each demo repo stays small enough to read in two minutes.
