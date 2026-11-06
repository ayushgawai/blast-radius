# Demo recording script

You two perform one real run and each record your own screen in one long, uninterrupted recording. You do not edit anything. Claude cuts, trims, speeds up the waiting, adds labels and the voiceover, and makes the final 2:50 video.

Read the whole script once before starting. Steps are in order. Each step says who does it. **Never do a step before the step marked WAIT before it is finished.**

## Part 1: before recording (both, 5 minutes)

**Both machines**
- Do Not Disturb on. Close every other app and browser tab.
- Slack: zoom 110 percent (Cmd and +). Star the 4 channels so they sit at the top: `schema-changes`, `analytics`, `ml-features`, `dashboards`.
- Wispr Flow on.
- Get on a voice call with each other (phone is fine) so you can say "your turn". The call audio is not used.
- Recorder: QuickTime Player, File, New Screen Recording, Options: microphone None, record the entire screen. (OBS is fine too.)

**Ayush only**
- Run `make reset-demo` in the `Blast-Radius` folder. It must finish without errors.
- Switch Console open; all 4 agents show running.
- Screen layout: Slack on the left half. Browser on the right half with 2 tabs: (1) https://github.com/ayushgawai/br-events-producer/blob/main/producer/schema.py (2) Jira project BR: https://ayushsunilgawai.atlassian.net/browse/BR (open its board).
- Switch Console open in its own window (used in step 8).

**Manav only**
- Slack full screen, open on `#analytics`.

## Part 2: the run

| Step | Who | Do exactly this | Then |
| --- | --- | --- | --- |
| 0 | **BOTH** | Start recording. | Say "recording" on the call. |
| 1 | **AYUSH** | In `#switch-test` send: `sync`. | **Manav:** before Ayush sends it, open `#switch-test` on your Slack, so your recording catches the message arriving. Then go back to `#analytics`. Claude lines the two videos up on this moment. |
| 2 | **AYUSH** | In `#general` send: `renaming user_id to account_id tonight, does this break anyone?` | Nobody replies. Wait 5 seconds. |
| 3 | **AYUSH** | In `#schema-changes` send `!roles`, wait for the reply, then `!list-aliases`, then `!list-references`. | Wait for all 3 replies (roles, aliases, GitHub and Jira references). |
| 4 | **AYUSH** | Browser tab 1 (`schema.py` on GitHub): click the pencil icon. On the line `USER_KEY = "user_id"` change `user_id` to `account_id`. Click **Commit changes**, pick **Create a new branch**, name it `rename-user-key`, click **Propose changes**. Title: `Rename user_id to account_id in events`. Click **Create pull request**. Copy the PR URL. | |
| 5 | **AYUSH** | In `#schema-changes`, hold the Wispr key and say: "Heads up team, I'm renaming user underscore id to account underscore id in the events table. PR" then paste the URL, then say "at coordinator, what does this break?" Fix the text so it reads exactly: `Heads up team: I'm renaming user_id to account_id in the events table. PR: <URL>. @coordinator what does this break?` and send. | |
| 6 | **AYUSH** | Wait. Keep the `#schema-changes` thread on screen. | Coordinator replies, then `@dbt-bot`, `@ml-bot`, `@dash-bot` each report failures and a Jira key. This takes a few minutes. |
| 7 | **AYUSH** | Browser: open the PR tab, scroll to the checks. Then the Jira tab, refresh. Then open each fix PR link the bots posted, show the green check. | |
| 8 | **AYUSH** | Switch Console: open agent **br-dash**, settings, "Who can talk to your agent", hold 3 seconds on the owner only setting, close without changing anything. Back to `#schema-changes`. | Wait for the coordinator's line starting `Impact report for PR #`. Then say "Manav, your turn" on the call. |
| | **WAIT** | **Manav does nothing until Ayush says "your turn". All 3 fix PRs and the impact report must exist first.** | |
| 9 | **MANAV** | Go to `#dashboards`. Send: `@dash-bot looks good, approved.` | dash-bot **refuses** you. Leave it on screen 5 seconds. Say "done" on the call. |
| | **WAIT** | **Ayush waits for Manav's "done".** | |
| 10 | **AYUSH** | Go to `#dashboards`. Send: `@dash-bot approved, thanks.` | Wait for dash-bot to confirm. Say "your turn" on the call. |
| | **WAIT** | **Manav waits for "your turn".** | |
| 11 | **MANAV** | Go to `#analytics`. Send: `@dbt-bot approved.` Wait for dbt-bot to confirm. | |
| 12 | **MANAV** | Go to `#ml-features`. Send: `@ml-bot approved.` Wait for ml-bot to confirm. | Say "done" on the call. Then go to `#schema-changes` and wait there. |
| 13 | **AYUSH** | Go to `#schema-changes`. | Wait for `PR #<n> cleared: 6 breakages fixed across 3 repos.` Then send `!list-documents` to show the `impact-<n>` report. |
| 14 | **AYUSH** | Browser: PR tab, refresh. Then Jira tab, refresh. | `blast-radius` is green and the 3 tickets are Done. Hold 5 seconds. |
| 15 | **BOTH** | Stop recording. | |

If something goes wrong: do not stop recording. Say what happened on the call, fix it, continue. Claude cuts it out. If the GitHub edit in step 4 fails, Ayush runs `make break` and `make demo-message` in the terminal and pastes that message in step 5.

## Part 3: hand over

Put both files in `Blast-Radius/recordings/` (this folder is gitignored):
- `ayush.mov`
- `manav.mov` (send it to Ayush by AirDrop, Drive or WeTransfer)

Also give Claude an ElevenLabs API key (free tier works) for the voiceover. Without one, Claude uses a built in macOS voice.

## Part 4: the cut (Claude does this)

Sync both recordings on the `sync` message from step 1. Sped up clips get a corner label with the real factor, for example "sped up 8x". The refusal plays at real speed.

| Time | Show | Source | Voiceover |
| --- | --- | --- | --- |
| 0:00 to 0:10 | The unanswered "does this break anyone?" post | Ayush, step 2 | Every data team has shipped a change that silently broke someone else. |
| 0:10 to 0:25 | Channel list, `!roles`, aliases | Ayush, step 3 | Blast Radius gives every downstream repo an agent in team chat. Four agents, three providers, all through Switch. |
| 0:25 to 0:40 | The one line edit and the PR | Ayush, step 4 | One small change upstream. |
| 0:40 to 0:52 | Dictating the message, Wispr overlay visible | Ayush, step 5 | I just say it. |
| 0:52 to 1:30 | Coordinator fans out; three reports stream in (sped up) | Ayush, step 6, with Manav's screen picture in picture | Each agent tests the change in the repo it speaks for: dbt, pandas, SQL. Real commands, real failures. |
| 1:30 to 1:45 | Pending check, Jira tickets, fix PRs with green CI | Ayush, step 7 | Six breakages, three Jira tickets, three fix PRs, and the upstream PR is blocked. |
| 1:45 to 2:05 | Manav refused; Ayush approves | Manav step 9, Ayush step 10 | Only the owner can approve. Switch enforces it, not a prompt. |
| 2:05 to 2:25 | Manav approves dbt and ML | Manav, steps 11 and 12 | Manav owns the other two repos, so he approves those. |
| 2:25 to 2:42 | Coordinator clears; check green; tickets Done | Ayush, steps 13 and 14 | Three teams, two days of threads, now a few minutes. |
| 2:42 to 2:50 | End card: Blast Radius, "Know what your schema change breaks before you merge it.", repo URL, "Built with Switch, dictated with Wispr Flow" | generated | Any team that shares data, even two friends on a side project, gets a teammate for every repo. |

Also cut: a 30 second version for #HowISwitch (dictated message, fan out, refusal and approval, green check).
