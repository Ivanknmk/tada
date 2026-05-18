# NEXT — read me first on a new session in `~/workspace/tada`

> Fresh Claude session in this repo: this is your starting point. Do this **before anything else**.

---

## TL;DR — end of session 2026-05-18 (afternoon)

`tada` skill is published at **https://github.com/Ivanknmk/tada** (MIT). Local install at `~/.claude/skills/tada/SKILL.md`. The skill now ships **two mechanisms** — banner (`display notification`) and dialog (`display dialog`) — with the agent picking per context. Banner = lightweight FYI / success. Dialog = failures, interactive ack, escalation.

This was a pivot off the previous (morning) NEXT.md plan, which said `display notification` was broken and we'd ship dialog-only. Empirically retested this session: banner **works on the user's Mac** (Script Editor already has Notification Center permission), so we restored banner as the default and kept dialog as the escalation/failure path.

| | |
|---|---|
| **GitHub** | https://github.com/Ivanknmk/tada |
| **Local install** | `~/.claude/skills/tada/` (symlink via `install.sh` or git clone) |
| **License** | MIT |
| **HEAD** | `feat: dual-mechanism alerts — banner (FYI) + dialog (escalation)` (89bcfc8) |

## Mechanism split

| Mechanism | osascript | Used for | UX |
|-----------|-----------|----------|----|
| Banner | `display notification "..." with title "..." sound name "Glass"` | Done / FYI / success | Top-right slide-in, auto-dismiss, no focus steal |
| Dialog | `display dialog "..." buttons {"OK"} default button "OK" with title "..."` | Failure / interactive / escalation | Modal, foreground, blocks until clicked |

Agent picks. No env var, no install config — context-driven.

### Caveat on banner

`display notification` only works if Script Editor has Notification Center permission. Most Macs already do (first run prompts, user clicks Allow once). If for some reason the permission never registers — confirmed possible on fresh Sequoia/Sonoma installs in some configs — the banner silent-fails (exit 0, no visible output). The skill's caveat section instructs the agent to fall back to dialog if that happens.

This is a real but rare failure mode. The user retested this session and banner worked fine on their box, so we treat banner as the default and document dialog as the fallback.

## What got done this session

1. Tested `display dialog` — works, no permission needed, looks like standard macOS modal.
2. Tested `display notification` — works on user's Mac (banner appears top-right, with Glass sound). Confirmed visually by user.
3. Pivoted SKILL.md and README.md from "dialog only" plan to "both mechanisms, agent picks":
   - SKILL.md documents both with a comparison table and when-to-use guidance
   - README.md leads with a side-by-side comparison of the two aesthetics
4. Committed + pushed `feat: dual-mechanism alerts` (89bcfc8). Live on GitHub.

## Open question — dialog can't match the banner aesthetic

The original banner mock (image in user's hand, rounded rect + emoji + mono text) is **only achievable via the notification banner**. `display dialog` is OS-rendered chrome — you can control title text, body text, button labels, and pick `note`/`caution`/`stop` icons, but **not** font, padding, button placement, or rounded corners. The dialog will always look like a standard macOS alert.

Closest dialog approximation includes 🎉 emoji in title:
```bash
osascript -e 'display dialog "Training finished — best
val_loss=0.0030 at epoch 22" with title "🎉 tada" buttons {"OK"} default button "OK"'
```

User accepted this trade-off. No further work needed unless we want to ship a Swift/SwiftUI binary for custom chrome — which means an install step, which the user has consistently rejected.

## Things to NOT do (still applies from prior NEXT.md)

- Don't add a `terminal-notifier` dep. User explicitly rejected ("not everyone will have it").
- Don't ship a pre-built `.app` bundle. User explicitly rejected ("too complicated, no app either").
- Don't ship a Swift binary even if it would give the custom dialog chrome. Same reason.
- Don't rename `tada`. Brand survives.

## Possible next moves (none urgent)

1. **Announcement push**. User has a draft pitch (Option A from morning session, still in conversation history). Could be tweeted / Slack-shared now that the repo is solid. Pitch needs minor tweak — "Mac alerts you" is more accurate than "fires a notification" given the dual mechanism.
2. **Banner permission detection**. Theoretically can check `defaults read com.apple.ncprefs apps` for Script Editor registration before calling `display notification`. If not registered, agent could fall back to dialog automatically. Not implemented — current SKILL.md documents the fallback as agent-discretion. Nice-to-have, not a v1 requirement.
3. **Linux backend**. `notify-send` for banner, `zenity` / `kdialog` for dialog. The README's Contributing section already names the right commands. Real work: detect OS in the skill body and select the right invocation. Out of scope for v1.
4. **Windows backend**. BurntToast for banner, PowerShell `MessageBox` for dialog. Same story as Linux.
5. **Re-render the banner image asset**. The current `~/Desktop/tada-banner.png` from the morning session is the aspirational marketing image. The README still uses ASCII mocks — no image embedded. If you want the README to pop more on GitHub, render and commit the banner PNG.

## Files in the repo

```
tada/
├── .gitignore
├── LICENSE         MIT
├── NEXT.md         this file
├── README.md       pitch + install — side-by-side mechanism comparison
├── SKILL.md        agent-facing instructions — both mechanisms documented
└── install.sh      symlinks into ~/.claude/skills/tada/
```

## Local dev recipe

```bash
# you're already in ~/workspace/tada
git status

# test the two mechanisms
osascript -e 'display notification "It works!" with title "tada" sound name "Glass"'
osascript -e 'display dialog "It works!" buttons {"OK"} default button "OK" with title "tada"'

# install (or re-install) the local skill
bash install.sh   # symlinks the repo into ~/.claude/skills/tada/
# Claude Code re-scans skills on each turn, no restart needed
```

## Memory pointers that apply here

- `[[feedback-commit-push-after-each-task]]` — one task = one commit, push immediately
- `[[feedback-session-handoff-protocol]]` — read NEXT.md on every new session
- `[[feedback-always-unit-test]]` — no real code to unit-test (shell + AppleScript); helper scripts (if any) get tests
- `[[feedback-milestone-test-scripts]]` — implementation is a one-liner; no separate test scripts needed
