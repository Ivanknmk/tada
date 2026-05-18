---
name: tada
description: Make the user's machine say "ta-da!" when a long-running task finishes — a native macOS alert. Two mechanisms: a Notification Center banner (lightweight, non-blocking, the default) and a modal dialog (front-and-center, requires a click, for failures or things that need acknowledgement). Use when the user asks to be "pinged", "notified", "alerted" when a long-running task finishes, or any time you'd like to surface a state change without requiring them to be looking at the terminal. macOS works out of the box (uses built-in `osascript` — no install needed).
---

# tada

Native desktop alert when a long-running task finishes. macOS today
via `osascript` (zero deps). Linux/Windows backends on the roadmap.

The skill name comes from "ta-da!" — the universal "your thing is
done" cue. Mac's classic notification sound is even called Tada.aiff
in older system installs.

## Two mechanisms

| Mechanism | What it looks like | When to use |
|-----------|-------------------|-------------|
| **Banner** (`display notification`) | Slides in top-right, auto-dismisses, doesn't steal focus | **Default.** Job finished, success path, no action required. |
| **Dialog** (`display dialog`) | Modal popup, stays until clicked, steals focus | Failures or anything the user must acknowledge. Single `OK` button only — `tada` doesn't act on choices. |

Banner is the right default — non-intrusive, fits the muscle memory of
every other macOS notification. Escalate to dialog when the message is
"you need to look at this" rather than "FYI."

## When to invoke

- User says **"notify me", "ping me", "alert me", "let me know when X finishes"**
- A long-running task (training, build, deploy, harvest) you kicked off finishes and the user isn't watching
- After completing a heavyweight step (e.g. a 30+ min job) so the user can pivot back to it
- After a failure mode that needs human attention → use **dialog**, not banner

Do NOT use for:
- Acknowledging short tool calls (<5 s — just reply in chat)
- Per-step progress on a job (would be spammy)
- Anything the user can see scrolling by in the terminal already

## Mechanic 1 — Banner (default)

```bash
osascript -e 'display notification "<MESSAGE>" with title "<TITLE>" sound name "<SOUND>"'
```

- **title** appears bold at the top of the banner
- **message** is the body text
- **sound name** (optional) plays a system sound: `Glass`, `Ping`, `Hero`, `Submarine`, `Funk`, `Frog`, etc. Pick `Glass` for "done" events, `Sosumi` / `Basso` for errors.

Subtitle (optional, second line under title):

```bash
osascript -e 'display notification "<MESSAGE>" with title "<TITLE>" subtitle "<SUBTITLE>" sound name "Glass"'
```

### First-run permission (banner only)

The first banner from a given osascript invoker triggers a one-time
"Allow notifications?" prompt for Script Editor. After approving, all
subsequent banners are silent. If banners never appear, check:

```
System Settings → Notifications → Script Editor
```

and confirm banners are allowed. If the user is stuck on a Mac where
Notification Center never registered Script Editor, fall back to the
dialog mechanism — it requires no permission.

## Mechanic 2 — Dialog (escalation / interactive)

```bash
osascript -e 'display dialog "<MESSAGE>" buttons {"OK"} default button "OK" with title "<TITLE>"'
```

Modal popup. Pops to the foreground, stays until clicked. Works on
every modern Mac with no permission grant.

### With an icon

```bash
osascript -e 'display dialog "<MESSAGE>" buttons {"OK"} default button "OK" with title "<TITLE>" with icon caution'
```

`with icon` accepts `note` (ℹ️), `caution` (⚠️), or `stop` (🛑). Use
`caution` / `stop` for failures.

### Button rule — single acknowledgement button only

The dialog must have **exactly one button**, and its label must be a
pure acknowledgement — something the user clicks to say "seen, move
on." Pick from this allowed list (or any equivalent ack word — match the
vibe of the message):

- `OK` (safe default)
- `Dismiss`
- `Noted`
- `Ack!`
- `Got it!`
- `Cool!`
- `Close`

Tone tip: match the body. Success/celebratory messages can use
`Cool!` or `Got it!`. Failure messages stay neutral — `OK` or
`Dismiss`. Dry/system messages → `Ack!` or `Noted`.

Forbidden: any label that promises an action `tada` can't deliver
(`Open log`, `Retry`, `Cancel`, `Continue`, `Yes`, `No`, etc.). Also
forbidden: multi-button dialogs.

Reason: `tada` only fires the alert — it has no way to act on the
button the user clicks. A button labeled `Open log` that doesn't open
a log is worse than no button at all.

If you want the user to act after the alert, put the next-step pointer
(log path, command to run, etc.) in the dialog body and let them act
after dismissing.

## Quoting

Wrap the AppleScript in **single quotes**; use **double quotes** for
the strings inside. Escape any embedded double quotes with `\"`.
Multi-line messages: AppleScript accepts `\n` inside double-quoted
strings.

```bash
osascript -e "display notification \"Line 1\nLine 2\" with title \"Build done\" sound name \"Glass\""
```

## Example invocations

**Training-run finished — banner (default)**

```bash
osascript -e 'display notification "TrackNet fine-tune wrapped — best val_loss=0.0030 at epoch 22" with title "padel.ai training" sound name "Glass"'
```

**Long build done, banner with subtitle**

```bash
osascript -e 'display notification "Built target/release/edge in 38s" with title "cargo build" subtitle "padel.ai" sound name "Glass"'
```

**Failure — dialog (needs attention)**

```bash
osascript -e 'display dialog "23/25 tests passed — 2 failing" buttons {"OK"} default button "OK" with title "pytest" with icon caution'
```

**Failure with detail — dialog, log path in body**

```bash
osascript -e 'display dialog "Deploy aborted at step 4/7.
Details: logs/deploy-2026-05-18.log" buttons {"OK"} default button "OK" with title "deploy" with icon stop'
```

## Caveats

- macOS only. On Linux/Windows, prefer alternative paths (libnotify
  `notify-send`, Windows toast / MessageBox) — out of scope for v1.
- Banner needs Script Editor notification permission. Most Macs already
  have it; if not, the first run prompts. Worst case (permission
  silently never registers): swap to dialog.
- Dialog blocks focus until clicked. Don't use for chatty progress.
- Do not include sensitive info (tokens, secrets) in the message — the
  alert can be visible to anyone glancing at the user's screen, and
  banners may persist in Notification Center.
- Quote handling is the only consistent foot-gun. Always test once with
  a benign message before piping in user-supplied data.
