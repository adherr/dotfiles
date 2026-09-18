# dotfiles

## Project setup

- `home/` mirrors `$HOME`. `mise run link` (`bin/link`) walks every file in `home/` and symlinks it to the same relative path under `$HOME`. `home/.config/emacs` is a submodule and is linked as a whole directory, not walked file-by-file.
- `Brewfile` is generated, not hand-edited: after installing/removing a formula or cask, run `brew bundle dump --force --file=Brewfile` to regenerate it from the current `brew` state.
- New machine bootstrap order: `brew bundle` (installs `Brewfile`), `mise install` (pinned tool versions from `~/.config/mise/config.toml`), `mise run link` (symlink `home/` into `$HOME`). Other `mise run` tasks (see `.mise.toml`) are opt-in, situational (e.g. `macos-defaults`, `ghostty-terminfo-install`).
- macOS app config that needs to live under `~/.config/<app>` (e.g. Karabiner Elements) goes in `home/.config/<app>/` and gets picked up automatically by `bin/link`.
- Respect XDG base dir semantics, not just the letter of `$XDG_*_HOME`: config (`XDG_CONFIG_HOME`) is hand-edited/version-controlled, cache (`XDG_CACHE_HOME`) is regenerable and safe to delete, state (`XDG_STATE_HOME`) is generated but worth keeping (history, logs), data (`XDG_DATA_HOME`) is generated and substantive. When wiring up a new tool's paths, pick the directory that matches what the file actually is, not whichever is closest at hand.
- For live Emacs work (including the `home/.config/emacs` submodule), use `mcp__ide__executeCode`, not `emacsclient`/`emacs --batch` under Bash — the Bash sandbox blocks writes outside its allowlist (e.g. `~/.cache`). Never call `module-load` on a live process just to verify a download; it can crash Emacs. A fresh restart is the only safe way to confirm a native module loads.
