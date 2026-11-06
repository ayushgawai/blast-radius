# Demo recording script

Each of you records your own full screen in one long take. Stay on a call and go one step at a time. Do not do your step until the step before it is done. If something goes wrong, keep recording and carry on; Claude cuts it out.

## Keep open before you start

**Ayush**
- Slack
- Switch Console (all 4 agents running)
- Browser tab 1: https://github.com/ayushgawai/br-events-producer/blob/main/producer/schema.py
- Browser tab 2: https://github.com/ayushgawai/br-events-producer/pulls
- Browser tab 3: https://ayushsunilgawai.atlassian.net/browse/BR
- Wispr Flow on

**Manav**
- Slack
- Wispr Flow on

**Both:** Do Not Disturb on, other apps closed. Record with QuickTime (File, New Screen Recording, full screen, no microphone).

## Steps

1. Both: start recording.
2. Manav: open Slack channel `#switch-test`.
3. Ayush: Slack `#switch-test`, type `sync`
4. Manav: go to Slack channel `#analytics` and stay there.
5. Ayush: Slack `#general`, type `renaming user_id to account_id tonight, does this break anyone?`
6. Ayush: Slack `#schema-changes`, type `!roles`
7. Ayush: Slack `#schema-changes`, type `!list-aliases`
8. Ayush: Slack `#schema-changes`, type `!list-references`
9. Ayush: browser tab 1, click the pencil, change `user_id` to `account_id` in the line `USER_KEY = "user_id"`, click Commit changes, choose Create a new branch, name it `rename-user-key`, click Propose changes, title `Rename user_id to account_id in events`, click Create pull request. Copy the PR link.
10. Ayush: Slack `#schema-changes`, dictate with Wispr and send: `Heads up team: I'm renaming user_id to account_id in the events table. PR: <paste PR link>. @coordinator what does this break?`
11. Ayush: wait in `#schema-changes` until `@dbt-bot`, `@ml-bot` and `@dash-bot` have all replied and the coordinator posts `Impact report for PR #...`. This takes a few minutes.
12. Ayush: browser tab 2, open the PR, scroll down to the `blast-radius` check (pending).
13. Ayush: browser tab 3, refresh, show the 3 new tickets.
14. Ayush: in Slack, click each fix PR link the bots posted and show the green check on each.
15. Ayush: Switch Console, open agent `br-dash`, show "Who can talk to your agent" (owner only). Do not change it.
16. Ayush: tell Manav "your turn".
17. Manav: Slack `#dashboards`, type `@dash-bot looks good, approved.` Wait for the refusal. Tell Ayush "done".
18. Ayush: Slack `#dashboards`, type `@dash-bot approved, thanks.` Wait for the reply. Tell Manav "your turn".
19. Manav: Slack `#analytics`, type `@dbt-bot approved.` Wait for the reply.
20. Manav: Slack `#ml-features`, type `@ml-bot approved.` Wait for the reply. Tell Ayush "done".
21. Ayush: Slack `#schema-changes`, wait for `PR #... cleared: 6 breakages fixed across 3 repos.`
22. Ayush: Slack `#schema-changes`, type `!list-documents`
23. Ayush: browser tab 2, refresh the PR, show the green `blast-radius` check.
24. Ayush: browser tab 3, refresh, show the 3 tickets Done.
25. Both: stop recording.

If step 9 fails: run `make break` and `make demo-message` in Terminal (in the `Blast-Radius` folder) and paste that message in step 10.

## After recording

Put the two files in `Blast-Radius/recordings/` as `ayush.mov` and `manav.mov`, and give Claude an ElevenLabs API key for the voiceover (optional; without it Claude uses a macOS voice).

## For Claude: the cut (2:50)

Sync both videos on the `sync` message (step 3). Label sped up clips with the real factor; play the refusal at real speed. Layout (split screen, picture in picture) is decided in the edit.

| Time | Show (steps) | Voiceover |
| --- | --- | --- |
| 0:00 to 0:10 | unanswered post (5) | Every data team has shipped a change that silently broke someone else. |
| 0:10 to 0:25 | roles, aliases, references (6 to 8) | Blast Radius gives every downstream repo an agent in team chat. Four agents, three providers, all through Switch. |
| 0:25 to 0:40 | the one line edit and PR (9) | One small change upstream. |
| 0:40 to 0:52 | dictating with Wispr (10) | I just say it. |
| 0:52 to 1:30 | fan out and three reports, sped up (11), Manav's screen alongside | Each agent tests the change in the repo it speaks for: dbt, pandas, SQL. Real commands, real failures. |
| 1:30 to 1:45 | pending check, Jira tickets, green fix PRs (12 to 14) | Six breakages, three Jira tickets, three fix PRs, and the upstream PR is blocked. |
| 1:45 to 2:05 | owner only setting, refusal, owner approves (15 to 18) | Only the owner can approve. Switch enforces it, not a prompt. |
| 2:05 to 2:25 | Manav approves dbt and ML (19, 20) | Manav owns the other two repos, so he approves those. |
| 2:25 to 2:42 | cleared, impact document, green check, tickets Done (21 to 24) | Three teams, two days of threads, now a few minutes. |
| 2:42 to 2:50 | end card: Blast Radius, "Know what your schema change breaks before you merge it.", repo URL, "Built with Switch, dictated with Wispr Flow" | Any team that shares data, even two friends on a side project, gets a teammate for every repo. |

Also cut a 30 second version for #HowISwitch.
