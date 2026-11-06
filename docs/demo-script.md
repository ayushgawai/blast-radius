# Demo video script

Target: 2:50, one real run, everything shown live. Two people record their own screens at the same time; we cut between them in the edit. Any sped up part gets an on screen label.

## Who records what

| | Ayush (owner of producer and dashboards) | Manav (owner of dbt and ML) |
| --- | --- | --- |
| Screen | Left half: Slack. Right half: browser with tabs: (1) `br-events-producer` on GitHub, (2) Jira board BR, (3) the 3 fix PRs as they appear | Slack, full screen |
| Records | Full screen, mic off (voiceover is added later) | Full screen, mic off, webcam optional |
| Tool | QuickTime: File, New Screen Recording (or OBS), 1080p | Same |
| Wispr Flow | On, overlay visible | On |

Both: Do Not Disturb on, close other apps, Slack zoom 110 percent, Slack sidebar shows only the 4 channels (star them: schema-changes, analytics, ml-features, dashboards), same Slack theme. Start recording 10 seconds before the run and stop 10 seconds after the green check. Do not stop recording between steps; the edit cuts the waiting.

## Pre flight (Ayush, 5 minutes before)

- [ ] `make reset-demo` ran clean (closes old PRs and resets agent folders)
- [ ] Switch Console open, all 4 agents running (br-coordinator, br-dbt, br-ml, br-dash)
- [ ] In #schema-changes, `!roles` shows coordinator and 3 checkers (do this off camera, or keep it for shot 2)
- [ ] GitHub tab open on `br-events-producer/producer/schema.py`, signed in
- [ ] Jira board BR open, previous demo tickets moved out of view (filter: created today)
- [ ] Wispr Flow on, both machines
- [ ] Manav is in Slack and ready, on a call with Ayush (audio not recorded) so you can cue each other

## The take

Times are real time from the start of the take. Agent work takes several minutes; that is fine, the edit speeds it up.

| # | Who | Do exactly this | Wait for |
| --- | --- | --- | --- |
| 1 | Ayush | In #schema-changes type `!roles`, then `!list-aliases` | Role holders and aliases listed |
| 2 | Ayush | GitHub tab: open `producer/schema.py`, click the pencil, change `USER_KEY = "user_id"` to `USER_KEY = "account_id"`. Commit changes: choose "Create a new branch", name it `rename-user-key`, Propose changes. PR title `Rename user_id to account_id in events`, Create pull request | PR page open; copy its URL |
| 3 | Ayush | In #schema-changes, hold the Wispr key and say: "Heads up team: I'm renaming user_id to account_id in the events table. PR: (paste URL). At coordinator, what does this break?" Fix the mention to `@coordinator` if Wispr writes it as words, then send | Coordinator restates, names 3 rooms, calls `@impact-checker` |
| 4 | Ayush | Switch to the GitHub PR tab, scroll to checks | `blast-radius` pending, merge blocked |
| 5 | Both | Hands off. Ayush keeps #schema-changes thread visible; Manav keeps #analytics visible | 3 checker reports in the thread, each with failing checks and a Jira key |
| 6 | Ayush | Jira tab, refresh | 3 tickets assigned to their owners |
| 7 | Ayush | Fix PR tabs as they appear: open each, show the diff and the green CI | 3 fix PRs, CI green |
| 8 | Ayush | Back to #schema-changes | Coordinator impact report: 6 breakages, 3 repos, document impact-<n> |
| 9 | Manav | Go to #dashboards. Type: `@dash-bot looks good, approved.` | **The refusal.** Keep it on screen 3 seconds |
| 10 | Ayush | In #dashboards: `@dash-bot approved, thanks.` | dash-bot confirms, Jira ticket moves to Done |
| 11 | Manav | In #analytics: `@dbt-bot approved.` Then in #ml-features: `@ml-bot approved.` | Both confirm |
| 12 | Ayush | #schema-changes | "PR #<n> cleared: 6 breakages fixed across 3 repos. All owners approved." |
| 13 | Ayush | GitHub PR tab, refresh | `blast-radius` green, PR mergeable. Hold 3 seconds. Stop recording |

Opening shot (record any time before, 10 seconds): Ayush posts in a plain channel such as #general: "renaming user_id to account_id tonight, does this break anyone?" and nobody answers.

If something goes wrong mid take: keep recording, fix it, carry on; we cut it out. If the GitHub edit fails, run `make break` and use `make demo-message`.

## Edit (final cut, 2:50)

| Time | Show | Source | Voiceover (Ayush, recorded after, read slowly) |
| --- | --- | --- | --- |
| 0:00 to 0:10 | The unanswered "does this break anyone?" post | opening shot | Every data team has shipped a change that silently broke someone else. |
| 0:10 to 0:25 | Slack channel list, `!roles`, aliases | Ayush, step 1 | Blast Radius gives every downstream repo an agent in team chat. Four agents, three providers, all through Switch. |
| 0:25 to 0:40 | The one line edit and the PR | Ayush, step 2 | One small change upstream. |
| 0:40 to 0:52 | Dictating the message, Wispr overlay visible | Ayush, step 3 | I just say it. |
| 0:52 to 1:30 | Coordinator fans out; three reports stream in (label: sped up) | Ayush, steps 3 to 5, Manav's #analytics as picture in picture | Each agent tests the change in the repo it speaks for: dbt, pandas, SQL. Real commands, real failures. |
| 1:30 to 1:45 | Jira tickets, fix PRs with green CI, pending check | Ayush, steps 4, 6, 7 | Six breakages, three Jira tickets, three fix PRs, and the upstream PR is blocked. |
| 1:45 to 2:05 | Manav refused on @dash-bot; Ayush approves | Manav step 9 full screen, then Ayush step 10 | Only the owner can approve. Switch enforces it, not a prompt. |
| 2:05 to 2:25 | Manav approves dbt and ML | Manav, step 11 | Manav owns the other two repos, so he approves those. |
| 2:25 to 2:42 | Coordinator clears; check turns green | Ayush, steps 12 and 13 | Three teams, two days of threads, now a few minutes. |
| 2:42 to 2:50 | End card: name, subtitle, repo URL, "Built with Switch, dictated with Wispr Flow" | still | Any team that shares data, even two friends on a side project, gets a teammate for every repo. |

Label every sped up clip in a corner: "sped up 8x" (use the real factor). Keep the refusal at real speed.

## 30 second cut for #HowISwitch

0:00 to 0:05 the dictated message; 0:05 to 0:15 the fan out and three reports (sped up); 0:15 to 0:25 Manav refused, Ayush approves; 0:25 to 0:30 green check. Text is in `docs/social.md`.
