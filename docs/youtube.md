# YouTube upload

**Visibility:** Unlisted

**Title**

Blast Radius: AI agents that catch your schema change's damage before you merge | Switch Hackathon

**Description**

Know what your schema change breaks before you merge it.

When one engineer renames a column, the teams downstream find out in production. Blast Radius gives every downstream repo an AI agent in team chat. When a breaking change is posted, each agent tests it in its own repo, reports the real failures in the thread, files a Jira ticket for its owner and opens the fix PR. The upstream PR stays blocked until every repo owner approves in Slack.

In this run: one line rename, 4 agents on 3 providers, 6 breakages found in 3 repos, 3 Jira tickets, 3 fix PRs with green CI, 3 owner approvals, and the blast-radius check turns green. When a teammate who does not own a repo tries to approve its fix, Switch refuses.

How it uses Switch:
Rooms as Slack channels, room links ("depends on"), an exclusive coordinator role and a shared checker role, GitHub and Jira references, room instructions, a room document for the impact report, aliases, per agent access rules (who can instruct each agent), the Atlassian connection, and an agent template that recreates the whole setup.

Tech stack: Switch, Claude Code, OpenAI Codex, OpenCode, Slack, Jira, GitHub Actions and gh, dbt, DuckDB, pandas, pytest. Built by voice with Wispr Flow.

Code and setup: https://github.com/ayushgawai/blast-radius

Built by Ayush Gawai and Manav Patel for the Flip the Switch hackathon by WeMakeDevs, Switch and DevTools Academy.

#HowISwitch #Switch #AIAgents #DataEngineering #ClaudeCode #Codex #WisprFlow #Hackathon

**Tags**

blast radius, switch, switch agents, ai agents, multi agent, claude code, openai codex, opencode, slack, jira, dbt, duckdb, data engineering, schema change, devtools, wemakedevs, hackathon, wispr flow

**Thumbnail text** (if you make one)

"1 change. 4 agents. 6 breakages caught."
