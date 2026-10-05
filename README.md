# dotfiles

## Setup

Each machine has a role: `full` (my own/employer laptops) or `client` (client-owned terminal hosts: curated `Brewfile.client`, no full-machine-only setup). On a new machine:

- Install Homebrew and mise, clone this repo to `~/dotfiles`.
- `mise run init -- --role full` (or `client`).
- `mise run bootstrap` — symlinks `home/` into `$HOME`, runs `brew bundle` for the role's Brewfile, `mise install`, and the macOS setup steps. Pass `-- --with-ssh-keys` to also generate and register this machine's SSH keys.

`mise install` covers pinned tools from `~/.config/mise/config.toml` (node, ruby, and `prettier` via mise's npm backend). Emacs' `prettier.el` requires the `prettier` npm module directly (via `NODE_PATH`) rather than shelling out to a `prettier` binary, so it has to come from here, not Homebrew's `prettier` formula. See the comment in `home/.config/emacs/init.el`.

Client-specific config (git identities, aliases, env) never goes in this repo; it lives untracked on each machine in `~/.gitconfig.local`, `~/.config/zsh/local.d/`, `~/.config/fish/conf.d/`, or `~/.config/mise/conf.d/`.

See `.mise.toml` for the other tasks.
