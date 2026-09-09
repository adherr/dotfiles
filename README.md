# dotfiles

## Setup

On a new machine, roughly in this order:

- `brew bundle` — install everything in `Brewfile`.
- `mise install` — install pinned tools from `~/.config/mise/config.toml` (node, ruby, and `prettier` via mise's npm backend). Emacs' `prettier.el` requires the `prettier` npm module directly (via `NODE_PATH`) rather than shelling out to a `prettier` binary, so it has to come from here, not Homebrew's `prettier` formula. See the comment in `home/.config/emacs/init.el`.
- `mise run link` — symlink `home/` out into `$HOME`.

Other `mise run` tasks are opt-in, situational setup steps — see `.mise.toml` for the full list. `macos` runs all macOS-only steps (`macos-defaults`, `tableplus-defaults`, `ghostty-terminfo-install`) in one shot, plus `ssh-keys-new-machine` if run as `mise run macos -- --with-ssh-keys`; each is also runnable individually.
