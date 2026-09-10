# dotfiles

## Project setup

- `home/` mirrors `$HOME`. `mise run link` (`bin/link`) walks every file in `home/` and symlinks it to the same relative path under `$HOME`. `home/.config/emacs` is a submodule and is linked as a whole directory, not walked file-by-file.
- `Brewfile` is generated, not hand-edited: after installing/removing a formula or cask, run `brew bundle dump --force --file=Brewfile` to regenerate it from the current `brew` state.
- New machine bootstrap order: `brew bundle` (installs `Brewfile`), `mise install` (pinned tool versions from `~/.config/mise/config.toml`), `mise run link` (symlink `home/` into `$HOME`). Other `mise run` tasks (see `.mise.toml`) are opt-in, situational (e.g. `macos-defaults`, `ghostty-terminfo-install`).
- macOS app config that needs to live under `~/.config/<app>` (e.g. Karabiner Elements) goes in `home/.config/<app>/` and gets picked up automatically by `bin/link`.
