# Submission form answers

Paste each answer into the [submission form](https://www.wemakedevs.org/hackathons/switch/submit). Numbers are from rehearsal 1 (upstream PR #2); update them if a later run differs.

## Project title (required)

Blast Radius

## Tracks (required)

Best Business Workflow, Best Personal or Creative Workflow

## Project description (required)

When one engineer changes a shared schema, other teams find out in production. Blast Radius gives every downstream repo an AI agent in team chat. When a breaking change is posted in Slack, each agent tests it in its own repo, reports the real failures in the thread, files a Jira ticket assigned to the repo owner, and opens a fix PR that only that owner can approve. The upstream PR's required check turns green only after every affected owner has approved. It is for data, ML and platform teams, and for any small team that shares data across repos.

## GitHub repository (required)

https://github.com/ayushgawai/blast-radius

## Demo video (required)

TODO: YouTube unlisted URL, under 3 minutes.

## Live demo (optional)

Blank.

## Pull requests (optional)

Blank (we did not enter Track 3).

## Blog post (optional)

TODO: published blog URL (source: `docs/blog.md`).

## Wispr usage card (for Code with Wispr)

TODO: one card per person (Ayush and Manav). Wispr Flow desktop app, Insights, Your usage, Share.

## #HowISwitch post (optional)

TODO: post URL (draft: `docs/social.md`).

## How did you use Switch (required)

We run four agents on three providers through Switch Console on a local server: br-coordinator (Claude Code), br-dbt (Claude Code), br-ml (Codex) and br-dash (OpenCode), with the aliases @coordinator, @dbt-bot, @ml-bot and @dash-bot. They live in a Slack workspace connected to Switch, in four rooms grouped as blast-radius: #schema-changes, linked with the label "depends on" to the team rooms #analytics, #ml-features and #dashboards. The coordinator holds the exclusive impact-coordinator role; the three repo agents share the impact-checker role, so one @impact-checker mention fans out to all of them. Room instructions and role instructions define the workflow, GitHub references point each agent at its repo, a Jira reference and the Switch Atlassian connection let agents file and close tickets, and the coordinator writes the impact report as a room document. Each agent's addressing setting decides who may instruct it: @dash-bot takes instructions only from Ayush and his agents, so when Manav tries to approve the dashboards fix, Switch refuses. The whole setup is one agent template, switch/blast-radius.template.yaml, that a judge can run from Console (Templates, Import template) or by asking switch-buddy.

In rehearsal 1, on upstream PR #2, one line rename upstream led to: 3 agents finding all 6 breakages across 3 repos, Jira tickets BR-4, BR-5 and BR-6, 3 fix PRs (br-analytics-dbt#1, br-ml-features#1, br-dashboards-sql#1) with green CI, 3 owner approvals in Slack, and the blast-radius check on the upstream PR set to success with "6 breakages fixed across 3 repos".

## What you liked and would improve (required)

Liked: rooms, room links, roles and aliases map directly onto how a real team works, so the workflow is mostly configuration, not code. One shared role mention reaching three agents on three different providers is the core of our demo and it just worked. Addressing gives us an ownership check that is enforced by Switch, not by a prompt. Slack over Socket Mode worked from a laptop with a teammate on his own laptop, and the Atlassian connection gave agents Jira access with no token handling. Having the whole setup in one template made it reproducible.

Would improve:
1. The GitHub connector needs https, but the Console local server's GATEWAY_PUBLIC_URL is http://localhost, so it cannot be set up locally. Our agents use the local gh login instead, and the GitHub references are only pointers.
2. The template's repo: clone did not happen for 2 of our 4 agents; we cloned by hand and wrote a script for it.
3. In template v2, a list item with a value key is read as an {if, value} conditional, and every reference has a value, so references must be wrapped in one "- value: [...]" entry. This was hard to find; a clear error or a doc note would help.
4. The bundled Mattermost needs Docker with "Allow the default Docker socket" on, which was not obvious. We used Slack instead.
5. Addressing has owner, owner-agents, anyone and anyone_in, but no option for a named list of people, so for two of our agents "only the owner approves" lives in room instructions.
6. When a person has not linked their Slack account to a Switch user, a refusal says "not linked" rather than "not permitted"; a hint to link the account would help.
