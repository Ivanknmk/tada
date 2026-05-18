# tada

> Make your machine say "ta-da!" when a long-running task finishes.

A tiny [Claude Code](https://claude.com/claude-code) skill that lets
the agent fire a native macOS alert when a long job wraps — training
run, deploy, build, harvest, whatever. macOS works out of the box;
Linux and Windows are on the roadmap.

## Two mechanisms, picked by context

`tada` ships two native macOS alerts. The agent picks the right one
for the situation — you don't configure anything.

<table>
<tr>
<td width="50%" valign="top">

**Banner** — lightweight FYI

```
┌──────────────────────────────────┐
│  🎉  tada                         │
│  Training finished — best        │
│  val_loss=0.0030 at epoch 22     │
└──────────────────────────────────┘
```

- Slides in top-right
- Auto-dismisses
- Doesn't steal focus
- Optional sound
- Used for: **success / done / FYI**

</td>
<td width="50%" valign="top">

**Dialog** — interactive / escalation

```
┌────────────────────────────────┐
│  pytest                        │
├────────────────────────────────┤
│  ⚠  23/25 tests passed —      │
│     2 failing                  │
│                                │
│                        [ OK ]  │
└────────────────────────────────┘
```

- Modal popup, front-and-center
- Stays until clicked
- Steals focus
- Optional multi-button choice
- Used for: **failures / needs ack / "open log?"**

</td>
</tr>
</table>

The agent reads [`SKILL.md`](./SKILL.md) and chooses banner for
"finished cleanly" events and dialog for "needs your attention" ones.
Same one-line `osascript` invocation underneath — no install, no
daemon, no API key.

## Why

Long-running CLI jobs are great until you have to babysit them. Claude
Code can fire-and-forget a 30-minute training run, but the UX gap is
real: how do you know when it's done? `tada` plugs that gap with zero
infrastructure. No third-party service, no Cargo/pip/npm dep — just
the OS's own alert system.

## Install

```bash
git clone https://github.com/Ivanknmk/tada.git ~/.claude/skills/tada
```

That's it. Restart Claude Code (or wait for the next message — skills
are re-scanned on each turn). The agent will discover the skill
automatically when you say things like:

- "notify me when training finishes"
- "ping me when the build is done"
- "let me know once the deploy lands"

`tada` is **not** a CLI you call directly — it's a *skill* that the
Claude Code agent invokes on your behalf, using your OS's built-in
alert system.

## Platforms

| OS      | Backend                                | Status       |
|---------|----------------------------------------|--------------|
| macOS   | `osascript` (banner + dialog)          | ✅ shipping  |
| Linux   | `notify-send` / `zenity`               | 🛠 roadmap   |
| Windows | BurntToast / `System.Windows.MessageBox` | 🛠 roadmap |

PRs welcome — see [Contributing](#contributing) below.

## First-run permission (banner only)

The first **banner** fires a one-time system prompt: *"Allow
notifications from Script Editor?"* Click **Allow**. Subsequent
banners are silent. If banners never appear, check:

```
System Settings → Notifications → Script Editor
```

and make sure banners are enabled. (Dialogs need no permission.)

## What the agent does under the hood

For curious humans — Claude reads [`SKILL.md`](./SKILL.md) and runs
one of:

```bash
# Banner — lightweight FYI
osascript -e 'display notification "<message>" with title "<title>" sound name "Glass"'

# Dialog — interactive / escalation
osascript -e 'display dialog "<message>" buttons {"OK"} default button "OK" with title "<title>"'
```

Run either yourself to test. The skill is the wrapping that makes the
agent discover the right invocation given a natural-language prompt.

## Try it manually

Already on macOS? Test both in one line each:

```bash
# Banner
osascript -e 'display notification "It works!" with title "tada" sound name "Glass"'

# Dialog
osascript -e 'display dialog "It works!" buttons {"OK"} default button "OK" with title "tada"'
```

If you see the banner and the dialog, the skill works the moment you install it.

## Contributing

Tiny project, easy to grok. The full implementation lives in
[`SKILL.md`](./SKILL.md). Linux and Windows backends are the obvious
next contributions:

- **Linux banner**: `notify-send "title" "message" --icon=dialog-information`
- **Linux dialog**: `zenity --info --text="message" --title="tada"` / `kdialog --msgbox`
- **Windows banner**: BurntToast PowerShell module
- **Windows dialog**: `Add-Type -AssemblyName PresentationFramework; [System.Windows.MessageBox]::Show('msg','tada')`

PRs should keep the zero-install promise on the default code path
(prefer built-in OS tooling over Cargo/pip/npm deps).

## License

[MIT](./LICENSE) — do what you want with it.

## Credits

Built by [@ivanknmk](https://github.com/ivanknmk) in collaboration
with Claude Code. The "agent should never make me babysit a long job"
philosophy comes from years of being frustrated by training runs that
finish silently at 3am.
