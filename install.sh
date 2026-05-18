#!/usr/bin/env bash
# tada — install / link this skill directory into ~/.claude/skills/tada
#
# Usage:
#   ./install.sh         # symlink this checkout into ~/.claude/skills/tada
#   FORCE=1 ./install.sh # overwrite an existing installation
#
# Skills live at ~/.claude/skills/<name>/SKILL.md. Claude Code auto-
# discovers them on each turn — no daemon, no service, no restart.

set -euo pipefail

SKILL_NAME="tada"
TARGET="$HOME/.claude/skills/$SKILL_NAME"
SRC="$(cd "$(dirname "$0")" && pwd)"

if [[ ! -f "$SRC/SKILL.md" ]]; then
    echo "[tada install] expected SKILL.md alongside this script, got nothing at $SRC/SKILL.md" >&2
    exit 1
fi

mkdir -p "$(dirname "$TARGET")"

if [[ -e "$TARGET" || -L "$TARGET" ]]; then
    if [[ "${FORCE:-0}" != "1" ]]; then
        echo "[tada install] $TARGET already exists. Re-run with FORCE=1 to replace it." >&2
        exit 1
    fi
    rm -rf "$TARGET"
fi

ln -s "$SRC" "$TARGET"
echo "[tada install] linked $TARGET → $SRC"
echo "[tada install] ready. Try saying 'notify me when X finishes' to Claude Code."
