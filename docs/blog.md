# Giving every repo an agent in Slack: building Blast Radius on Switch

Every data team has shipped a change that quietly broke someone else. You rename a column upstream, your own tests stay green, and two days later the dbt models, the ML features and a dashboard are all failing in someone else's repo.

For the Flip the Switch hackathon, Manav Patel and I (Ayush Gawai) built **Blast Radius**: every downstream repo gets an AI agent that speaks for it in team chat. When someone posts a breaking change, each agent tests it in its own repo, reports the real failures in the thread, files a Jira ticket, and opens a fix PR that only its human owner can approve. The upstream PR's required check turns green only after every owner has said yes in Slack.

This post is a walkthrough for someone who has never used Switch. It covers every step we took, with the exact commands, and the things that surprised us.

Repo: https://github.com/ayushgawai/blast-radius

## What we built

Four small demo repos, published to GitHub:

| Repo | Owner | What breaks on the rename |
| --- | --- | --- |
| `br-events-producer` | Ayush | Nothing; its own tests stay green, which is the point |
| `br-analytics-dbt` | Manav | models `fct_sessions`, `dim_users` |
| `br-ml-features` | Manav | `test_user_aggregates`, `test_feature_matrix_shape` |
| `br-dashboards-sql` | Ayush | queries `daily_active_users`, `revenue_by_user` |

The upstream change is one line in `producer/schema.py`: `USER_KEY = "user_id"` becomes `USER_KEY = "account_id"`. That causes exactly 6 breakages across 3 repos.

On the Switch side, four agents on three providers:

| Agent | Alias | Provider | Role | Rooms |
| --- | --- | --- | --- | --- |
| `br-coordinator` | `@coordinator` | Claude Code | `impact-coordinator` (exclusive) | schema-changes |
| `br-dbt` | `@dbt-bot` | Claude Code | `impact-checker` (shared) | schema-changes, analytics |
| `br-ml` | `@ml-bot` | Codex | `impact-checker` (shared) | schema-changes, ml-features |
| `br-dash` | `@dash-bot` | OpenCode | `impact-checker` (shared) | schema-changes, dashboards |

In our first full rehearsal, on upstream PR #2, the agents found all 6 breakages, filed Jira tickets BR-4, BR-5 and BR-6, opened 3 fix PRs with green CI, and the coordinator cleared the PR with "6 breakages fixed across 3 repos" after 3 owner approvals.

![TODO screenshot: the #schema-changes thread with all three checker reports]()

## Step 1: install Switch Console

Switch Console is the desktop app that runs a Switch server and the agents. Download it from the [latest release](https://github.com/sandbox-quantum/switch/releases/latest):

- Apple silicon: `switch-console-arm64.dmg`
- Intel Mac: `switch-console-x64.dmg`

Install Docker Desktop too. The local server runs on it.

## Step 2: start a local server

In Console: **Get started**, then **On this computer**, then **Start**. Wait for "Local server is running".

Then sign in the agent providers you want to use. We used three: Claude Code, Codex and OpenCode. Power switch-buddy (the built in helper agent) with one of them; we used Claude Code.

![TODO screenshot: Console showing "Local server is running"]()

One thing to know now, because it shapes the rest: the local server's public URL is `http://localhost:...`. Some connectors need https (more on that below).

## Step 3: connect Slack

Switch puts agents into a chat app, and each channel becomes a **room**. We picked Slack because it works from a laptop: Switch opens the connection outwards over Socket Mode, so nothing needs to be publicly reachable, and Manav could join from his own laptop.

1. Go to https://api.slack.com/apps, **Create New App**, **From an app manifest**, choose your workspace.
2. Paste the manifest from the Switch docs page [Connect Slack](https://docs.switchagents.ai/switch-rooms/deploy/messaging-apps/index). Copy it as **JSON**. Our app is named "Agent Switch".
3. In the app, **Basic Information**, **App-Level Tokens**: generate a token with the `connections:write` scope. It starts with `xapp-`.
4. **Install App** to your workspace and copy the **Bot User OAuth Token**. It starts with `xoxb-`.
5. Note your workspace id. It starts with `T` and is the first path segment of any Slack message link.
6. In Console, open your server's **Home**, **Messaging apps**, **Connect**, choose **Slack**, and paste the bot token, the app token and the workspace id.
7. When Console asks which Slack account is yours, pick yourself and select **This is me**. Your teammate links their own account too (see "who can instruct an agent" below for why this matters).

![TODO screenshot: the Slack connection form in Console]()

Tip from Console itself: under **Connect a messaging app**, **Use your own app instead**, **Slack**, Console opens Slack with the app already filled in and checks your tokens as you paste them.

## Step 4: connect Atlassian (Jira)

We wanted a real ticket for every breakage, assigned to the repo owner, so Jira is part of the flow.

1. Create a free Atlassian Cloud site and a Jira project. Ours is `ayushsunilgawai.atlassian.net`.
2. New projects get the key `KAN`. We renamed ours to `BR` in the project settings.
3. In Console: **Settings**, **Connections**, **Atlassian**, and sign in.

Agents get access through `connections: [atlassian]` in the template, so no API token script is needed.

![TODO screenshot: Atlassian connected in Console]()

## Step 5: publish the demo repos and log in to GitHub

```
gh auth login
git clone https://github.com/ayushgawai/blast-radius
cd blast-radius
make verify                                         # fully local check, no GitHub needed
make seed GH_USER=<you> TEAMMATE=<teammate github>  # publishes the 4 demo repos
```

`make verify` should end with `6 breakages across 3 repos on the rename; expected 6.` and `VERIFY PASSED`. `make seed` is safe to rerun.

We tried to set up the GitHub connector in Switch and could not: it needs https, and the local server is on localhost. So the agents use the local `gh` login on the Mac they run on. That works fine.

## Step 6: run the template

You can create rooms, roles and agents one by one by chatting with switch-buddy. We put the whole setup in one file instead, so a judge (or you) can recreate it: [`switch/blast-radius.template.yaml`](https://github.com/ayushgawai/blast-radius/blob/main/switch/blast-radius.template.yaml).

Two ways to run it:

- Console: **Templates**, **Import template**, pick the file, fill in `gh_user` and `teammate` (your teammate's Slack user), run it.
- Or ask switch-buddy in chat: "Run the template in blast-radius/switch/blast-radius.template.yaml".

![TODO screenshot: the template form in Console with gh_user and teammate]()

What the template creates:

- **A group** `blast-radius` with four **rooms**: `schema-changes`, `analytics`, `ml-features`, `dashboards`. Each becomes a Slack channel.
- **Room links** from `schema-changes` to each team room, labelled `depends on`. The coordinator reads these to know who to ask.
- **Four agents**, each with a provider, a working directory under `~/.switch/agents/<server>/`, and the repo to clone into it.
- **Roles** in `schema-changes`: `impact-coordinator` (exclusive, one holder) and `impact-checker` (shared). Mentioning `@impact-checker` reaches all three checkers at once.
- **Room instructions** for each room and **role instructions** for each role. In our repo they live as Markdown in `switch/rooms/` and `switch/roles/`, and `python3 scripts/build_template.py` writes them into the template.
- **References**: a GitHub reference per repo and a Jira reference for project `BR`.
- **Aliases**, so people can type `@dbt-bot` instead of `@br-dbt`.
- **A kickoff message** in #schema-changes that asks each agent to take its role and say which repo it speaks for.

After it runs, make sure every agent has its repo cloned (the template's `repo:` clone did not happen for 2 of our 4 agents):

```
make agent-dirs
```

## Step 7: aliases and roles

Aliases come from the template. To set or check them by hand, in a room:

```
!set-alias @br-dbt @dbt-bot
!list-aliases
!roles
```

`!roles` in #schema-changes should show `br-coordinator` on `impact-coordinator` and the three checkers on `impact-checker`.

![TODO screenshot: !roles output in #schema-changes]()

## Step 8: who can instruct an agent

This is the part that makes the workflow trustworthy. Each agent has an `addressing` setting that decides who may talk to it. In the template:

| Agent | `addressing` | Means |
| --- | --- | --- |
| `br-coordinator` | `owner-agents` | Ayush (the deployer) and his other agents |
| `br-dbt` | `anyone_in: [schema_changes, analytics]` | Ayush, and anyone in those rooms |
| `br-ml` | `anyone_in: [schema_changes, ml_features]` | Ayush, and anyone in those rooms |
| `br-dash` | `owner-agents` | Ayush and his other agents, not Manav |

So when Manav tries to approve the dashboards fix, Switch refuses before the agent ever sees the message. Switch enforces it, not a prompt.

Two things we learned:

- The options are `owner`, `owner-agents`, `anyone` and `anyone_in`. There is no "these two people" option in the template, so for the dbt and ML bots the rule "only the repo owner approves" lives in the room instructions.
- Each person should link their Slack account to a Switch user. While Manav's account was not linked, the refusal said he was "not linked" instead of "not permitted". It still refused, but the message is clearer once the account is linked.

## Step 9: the run

```
make reset-demo     # clean slate
make break          # opens the rename PR on br-events-producer
make demo-message   # prints the message to post
```

Post the message in #schema-changes:

> Heads up team: I'm renaming user_id to account_id in the events table. PR: <PR URL>. @coordinator what does this break?

What happens next:

1. `@coordinator` restates the change, names the linked rooms, addresses `@impact-checker`, creates the Jira parent issue and sets a pending `blast-radius` status on the PR.
2. Each checker runs `UPSTREAM_REF=rename-user-key make test` in its own repo and reports the failing models or tests with the error lines.
3. Each checker files a Jira ticket for its repo, makes the fix on branch `fix/<n>`, reruns the tests until green, opens a PR, and posts it in its team room.
4. `@coordinator` writes the `impact-<n>` room document and posts the impact report.
5. Manav tries "@dash-bot looks good, approved." in #dashboards and is refused.
6. Ayush approves in #dashboards; Manav approves in #analytics and #ml-features. Each bot comments "approved by <owner> in Switch" on its PR and ticket and moves the ticket to Done.
7. `@coordinator` sets the status to success: "6 breakages fixed across 3 repos". The upstream PR's required check is green.

![TODO screenshot: the refusal in #dashboards]()

![TODO screenshot: green blast-radius check on the upstream PR]()

There is also a no impact case, so the agents do not cry wolf: `make break-device` adds a nullable `device_type` column, and every checker should answer "no impact" with the command it ran.

## What surprised us

- **No GitHub connector on a local server.** The local server's `GATEWAY_PUBLIC_URL` is `http://localhost:...`, and the GitHub connector needs https. Agents use the local `gh` login; the GitHub references in Switch are pointers that tell agents to use `gh` and `git`.
- **Template references need a wrapper.** In template v2, a list item with a `value` key is read as an `{if, value}` conditional, and every reference has a `value`. Wrap a room's references in one `- value: [...]` entry.
- **The `repo:` clone did not happen for 2 of 4 agents.** We cloned by hand, then wrote `make agent-dirs`.
- **The bundled Mattermost needs Docker's default socket.** It needs "Allow the default Docker socket" on in Docker. We switched to Slack.
- **Copy the Slack manifest as JSON** from the Switch docs.
- **Jira's default key is `KAN`.** Rename it if you want a nicer key.
- **Agents find their own fixes.** The dbt bot fixed the rename with one alias in `stg_events` (`account_id as user_id`) instead of renaming the column in 3 files as we had planned. Both are valid. Our `make verify` checks our version; the real test is that the bot's PR was green.
- **Write the owner's name, not the handle.** Approval comments first used the Slack handle; the room instructions now ask for the owner name from the repo README.

## Try it

Everything is in https://github.com/ayushgawai/blast-radius. Start with `make verify`, then follow the README. If you get stuck on Switch, start with the [Switch docs](https://docs.switchagents.ai/) and the [WeMakeDevs Discord](https://discord.gg/E2rWw2Yhsm), where the Switch team answers questions.
