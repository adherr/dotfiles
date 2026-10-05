# Sourced on ALL zsh invocations (interactive, non-interactive, scripts) — unlike
# .zshrc which is interactive-only. Put env that must reach non-interactive
# subshells here.

# Silence zoxide's "detected a possible configuration issue" doctor message.
# `cd` is aliased to `z`, and non-interactive agent subshells don't install
# zoxide's chpwd hook, so the doctor fires on every cd. zoxide intends
# _ZO_DOCTOR=0 as the off switch; it lives here so it reaches those subshells.
export _ZO_DOCTOR=0

# settings.json env values don't expand ~/$HOME, so this can't live there
export CLAUDE_CODE_TMPDIR="$HOME/src/claude-tmp"
