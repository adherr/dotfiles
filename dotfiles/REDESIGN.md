# Dotfiles redesign

## Current state

The repo's git dir lives at `~/dotfiles/.git`. `~/.git` is a *file* containing `gitdir: dotfiles/.git`, which makes `$HOME` itself a full worktree of the same repo — same index, same HEAD, accessible from either `~` or `~/dotfiles`. That's why Emacs, magit, and anything else that walks up looking for `.git` treats all of `$HOME` as one repo.

`.gitignore` uses a blanket-deny-then-allowlist pattern (`/*` at the top, then `!/.zshrc`, `!/.config/starship.toml`, etc.) to keep only 19 files tracked out of everything in `$HOME`. Two submodules: `.config/emacs` (hand-rolled-emacs) and `dotfiles/PlexMono` (a font). Runtime versions are pinned via asdf's `.tool-versions` (nodejs, ruby, golang). `Brewfile` is macOS-only and mixes CLI tooling with GUI casks and Mac App Store apps — nothing exists for the Arch/i3 box.

`mise` is already installed and shimmed into the shell, but has no config yet (`~/.config/mise` doesn't exist).

## Problem

- `$HOME`-as-worktree confuses any tool that discovers repos by walking up from cwd — the actual annoyance driving this redesign.
- asdf is being replaced by mise project-wide, but `.tool-versions` is still asdf's file (mise reads it, but committing to mise's own config is less ambiguous going forward).
- `Brewfile` has no equivalent on Arch, and mixes "tool I need everywhere" with "app I want on this particular Mac."
- No bootstrap path — a new machine (personal, work, or a future client MacBook) has to be set up by hand.

## Target architecture

**Repo relocates its git-ness entirely into `~/dotfiles`.** No file or directory at `~/.git` — `$HOME` stops being a worktree of anything. The repo holds the real files; a `mise` task symlinks them out into `$HOME` (`~/dotfiles/home/.zshrc` → `~/.zshrc`, etc.). Because it's a symlink, editing `~/.zshrc` edits the tracked file directly — `git -C ~/dotfiles status` shows it dirty immediately, no sync step, same workflow as today. The only change is where `.git` lives.

**Hand-rolled symlinking as a `mise` task**, not a Makefile and not GNU Stow. `mise` is already the tool doing runtime version pinning, so a `[tasks]` entry in `.mise.toml` running a `link`/`unlink` shell script is one fewer tool in the stack than a separate Makefile, works identically across machines, and needs no separate bootstrap-order dependency. Low-stakes choice — swapping to a Makefile later is a non-event if `mise run` turns out to be awkward for this.

**mise replaces asdf.** `~/.config/mise/config.toml` (tracked, symlinked like everything else) holds pinned global tool versions. Drop `.tool-versions` and the asdf brew formula once nothing references them.

**Package lists split by tool, not by OS abstraction**: `Brewfile` (fed to `brew bundle`) for both Macs, a `pacman.txt`-style list fed to `paru` for Arch. No attempt to unify install commands behind a shared abstraction — each machine's mise task just calls the tool that already knows how to read its own list.

**Submodules stay submodules** — relocating the git dir doesn't affect them.

**Machine-specific config** keeps using the pattern already in place for work vs. personal (`includeif.gitdir` pointing at `~/.gitconfig.focused`) rather than inventing a new mechanism.

## Decisions

- **Repo layout: flat mirror.** `~/dotfiles/home/.zshrc`, `~/dotfiles/home/.config/starship.toml`, etc. — same relative path under `home/` as under `$HOME`. The `link` task just walks the tree and symlinks each file to the same relative path; no explicit source→target mapping to maintain.
- **Orchestration: `mise run`, not a Makefile.** `mise` is already in the stack for runtime versions; a `[tasks]` block in `.mise.toml` covers `link`, `unlink`, and per-platform package install without adding a second build tool. Not a strongly-held choice — trivial to swap for a Makefile later if `mise run` turns out to be awkward for this.
- **Package lists: split by tool, not by machine role.** `Brewfile` for both Macs, a `paru` package list for Arch. No personal-vs-work split unless it turns out to matter in practice.
- **Non-dotfile content relocates to the repo root.** The current `dotfiles/` subdirectory (profile pictures, `PlexMono`, `keyboard_shortcuts.md`) isn't things that get symlinked into `$HOME` — it's just content that happened to live in the old worktree. In the new layout it moves to `~/dotfiles/` directly (sibling of `home/`), since there's no more reason to nest it under a `home`-shaped path it was never part of.
- **Client-specific shell config stays untracked and per-machine, outside the repo entirely.** As a consultant working across multiple clients, aliases/env/PATH additions for one client shouldn't sync to another client's machine or a future client MacBook — not even non-secret bits, since they can leak which clients you work with. `home/.zshrc` sources `~/.config/zsh/local.d/*.zsh(N)` (zsh glob qualifier — no error if the directory or matches don't exist), but `~/.config/zsh/local.d/` itself lives outside `home/`, so it's never visible to `~/dotfiles`' git status at all once the repo boundary is just the repo, not a scan of `$HOME`. Same shape as the existing `.gitconfig.focused` `includeif.gitdir` pattern, but per-machine instead of per-directory since the content itself (not just the inclusion) needs to stay off other machines.

## Interim experiment: keeping the worktree trick, just toggled

Before committing to the symlink-farm rewrite, tried the smaller fix first: set `core.worktree = $HOME` in `~/dotfiles/.git/config` (previously unset — this repo relied solely on the `~/.git` gitdir-file, unlike upstream Karns' repo which sets both), removed the `~/.git` pointer file, and added `regit`/`ungit` aliases to restore/remove it on demand. This worked for CLI git (`git -C ~/dotfiles status` sees the same dirty files with or without the pointer file present) but **breaks magit**: opening a file inside `~/dotfiles` correctly resolves the repo's toplevel to `$HOME` via `core.worktree`, but magit then re-invokes git commands with `$HOME` as the working directory, which requires rediscovering `.git` from there — and fails without the pointer file. Full magit functionality on dotfiles requires `~/.git` present at all times you're using magit, which puts the toggle right back in the way of the workflow it was meant to smooth out.

This is what tipped the decision toward the symlink-farm rewrite: with symlinks, opening `~/.zshrc` follows to its real location at `~/dotfiles/home/.zshrc` (via `vc-follow-symlinks`), so magit discovers an ordinary, self-contained repo with no `core.worktree` override and no rediscovery gap — it just works, the same way it does in every other repo.

## Migration plan

Each step names what has to be true before moving to the next — no wall-clock estimates, since this is likely to be run by an agent.

1. **Write the `mise` tasks** (`link`, `unlink`). Done and tested — `bin/link`/`bin/unlink` walk `home/` and symlink/unsymlink into `$HOME`, verified against a scratch `HOME=$TMPDIR/fake-home`, all currently-tracked files linked correctly, content matched, unlink cleaned up fully.
2. **Cut over.** Not yet done — this is the next step, see the runbook below.
3. **Migrate asdf → mise.** Not started. `mise use --global` for each entry in `.tool-versions`, confirm shells pick up the right versions, then delete `.tool-versions` and drop `asdf` from the Brewfile.
4. **Split package installs by tool**: `Brewfile` stays as-is for both Macs, add a `paru` package list for Arch, wire both into their own `mise` task.
5. **Prove the bootstrap on the Arch box first** — it's the closest thing to "a new machine" already sitting on the desk — before trusting the same setup for an actual new client MacBook.

### Cutover runbook (step 2, ready to execute)

Everything below assumes starting from a clean `git -C ~ status` — commit or stash anything dirty first. `.gitignore` (modified) and `.config/git/` (untracked) are standalone and safe to commit separately right away. `dotfiles/keyboard_shortcuts.md` (modified) is deliberately left uncommitted — it rides along with the rest of the still-untracked migration infra bundle (`.mise.toml`, `bin/`, `homebrew-tableplus/`, `macos/`, `REDESIGN.md`) as one commit, not committed alone.

1. **`git mv` every currently-tracked file into `home/`, preserving its relative path**, run from `~` (the worktree root, since `core.worktree` is still `$HOME` at this point):
   ```
   git -C ~ mv .claude/CLAUDE.md dotfiles/home/.claude/CLAUDE.md
   git -C ~ mv .claude/keybindings.json dotfiles/home/.claude/keybindings.json
   git -C ~ mv .claude/settings.json dotfiles/home/.claude/settings.json
   git -C ~ mv .config/emacs dotfiles/home/.config/emacs
   git -C ~ mv .config/iterm2/com.googlecode.iterm2.plist dotfiles/home/.config/iterm2/com.googlecode.iterm2.plist
   git -C ~ mv .config/iterm2/iterm2_shell_integration.zsh dotfiles/home/.config/iterm2/iterm2_shell_integration.zsh
   git -C ~ mv .config/starship.toml dotfiles/home/.config/starship.toml
   git -C ~ mv .config/git dotfiles/home/.config/git
   git -C ~ mv .docker/config.json dotfiles/home/.docker/config.json
   git -C ~ mv .gitconfig dotfiles/home/.gitconfig
   git -C ~ mv .gitconfig.focused dotfiles/home/.gitconfig.focused
   git -C ~ mv .zshenv dotfiles/home/.zshenv
   git -C ~ mv .zshrc dotfiles/home/.zshrc
   git -C ~ mv "Library/Application Support/Cursor/User/keybindings.json" "dotfiles/home/Library/Application Support/Cursor/User/keybindings.json"
   git -C ~ mv "Library/Application Support/Cursor/User/settings.json" "dotfiles/home/Library/Application Support/Cursor/User/settings.json"
   ```
   `.config/emacs` is a submodule — `git mv` on a submodule path relocates it and updates `.gitmodules`/`.git/modules` correctly in modern git, but verify `git -C ~/dotfiles submodule status` afterward.
2. **`.gitignore` gets replaced, not moved** — it's the one file where the old (`$HOME`-allowlist) and new (short denylist) versions genuinely differ, and the new one already exists at `~/dotfiles/.gitignore` (`.DS_Store`, `settings.local.json`). So: `git -C ~ rm .gitignore`, then `git -C ~/dotfiles add .gitignore` to pick up the already-written new-world version sitting at the repo root.
3. **Root-level files need no `git mv`** — `LICENSE`, `README.md`, `Brewfile`, and everything under the old `dotfiles/` subdirectory (`PlexMono`, the profile photos, `keyboard_shortcuts.md`) are already sitting at the exact path they need to be at in the new repo root (that's what "worktree root = `$HOME`, repo root = `~/dotfiles`" already gave us for free). Same for everything already sitting in `~/dotfiles` untracked right now (`.mise.toml`, `bin/`, `homebrew-tableplus/`, `macos/`, `REDESIGN.md`) — `git -C ~/dotfiles add` those once cutover's in progress.
4. **Commit the move.**
5. **`cd ~/dotfiles && mise run link`** to symlink everything in `home/` back out into the real `$HOME`.
6. **Remove the worktree trick**: `git -C ~/dotfiles config --unset core.worktree`, `git -C ~/dotfiles config --unset alias.regit`, `git -C ~/dotfiles config --unset alias.ungit`. `~/dotfiles` becomes an ordinary, self-contained repo.
7. **Verify**: `git -C ~/dotfiles status` still shows dirty-on-edit for `.zshrc` and friends (edit one, confirm it shows modified). Open a file under `$HOME` in Emacs, confirm magit does *not* think it's a repo. Open a file under `~/dotfiles` (e.g. `home/.zshrc` via its real path, not the symlink), confirm magit *does* work normally there — no `core.worktree` override anymore, so no rediscovery gap, no toggle needed.
8. **Backup note**: this is the one step that touches live shell config (`.zshrc`/`.zshenv` briefly stop existing at their real path mid-move, before `mise run link` puts the symlinks back) — don't open a new shell between the `git mv` and `mise run link` steps.

## Open questions

- Anything else currently relying on `$HOME` being a git worktree (e.g. a script, an alias, muscle memory) that cutover would break?

## Other work done this session (context for a fresh session, not blocking cutover)

- **`Brewfile` cleanup**: removed `sdkman`, `hub`, `bpytop`, `colima`, `scala`/`scala@2.13`/`metals`, `k9s`, `sentry-cli` (+ their taps), swapped `postgresql@12`/`postgresql@15` → plain `postgresql` (aliases to latest). Swapped three `mas` entries (Flycut, Okta Verify, Windows App) for their Homebrew cask equivalents — actually executed on this machine too (`mas uninstall` + `brew install --cask`), not just edited in the file. Added `ruff`/`ty` for Python tooling. `asdf` and `kotlin-language-server` are still present/installed — intentionally untouched pending step 3 and an unresolved "maybe" on Kotlin, respectively.
- **Custom Homebrew tap** at `homebrew-tableplus/` (a local git repo, tapped as `andrewherr/tableplus`) pins TablePlus to a specific licensed build (520) with a `postflight` that disables auto-update checks. Actually installed on this machine now (`cask "andrewherr/tableplus/tableplus-licensed"` shows in a fresh `brew bundle dump`). Tap shows as "untrusted" by Homebrew (`brew trust andrewherr/tableplus` or `trusted: true` in the `Brewfile` tap line would fix it) — currently harmless since `HOMEBREW_REQUIRE_TAP_TRUST` isn't set, but worth revisiting if that ever gets enabled.
- **`bin/macos-defaults`**: imports `macos/symbolichotkeys.plist` (a full export of `com.apple.symbolichotkeys`, captured from this already-configured machine) plus sets `com.apple.keyboard.fnState`. Caps-lock-to-Escape stays manual — no portable macOS default found, likely lives in keyboard firmware (Chrysalis/UHK Agent) for the custom keyboards anyway.
- **`bin/ssh-keys-new-machine`**: generates per-machine SSH auth + signing keys via the `op` CLI (1Password), registers both with GitHub via `gh ssh-key add`. Deliberately does *not* auto-append to `~/.config/git/allowed_signers` — which email(s) to associate with a new machine's key is a judgment call, especially for client machines. Untested end-to-end (needs "Integrate with 1Password CLI" enabled in the 1Password app first) — worth a real dry run next time a new machine gets set up.
- **`.config/git/allowed_signers`/`.config/git/ignore` now tracked** (were previously excluded by the old allowlist `.gitignore`'s directory-level exclusion of `.config/git` — same "excluded directory can never be re-included" gitignore gotcha documented above for `.config/iterm2`, fixed the same way).
- **Emacs config** (submodule, its own repo — separate commits from the dotfiles repo): removed dead client-identifying cruft (a previous work machine's username baked into commented-out Copilot/eslint paths, sorbet-specific config, the `jest`/`emacs-jest` package which was the last thing pulling in the deprecated/archived `magit-popup`). Swapped Kotlin LSP for Ruby (`ruby-lsp-ls`, gem installed) and added Python (`ty-ls` + `ruff`, both installed via Homebrew) to `lsp-enabled-clients`. Fixed a real `lsp-ruff.el` bug: its default `lsp-ruff-lint-select` of `[]` serializes as JSON `[]` ("select zero rules"), not "no override" — silently made ruff's LSP report nothing regardless of `pyproject.toml`. Set to `nil` instead (→ JSON `null`), verified against a cloned copy of `pydantic` with a planted lint violation. A `straight-freeze-versions` lockfile now exists and is committed (`straight/versions/default.el`) after a 137-commit `straight-pull-all` was verified healthy (found and fixed two real breakages along the way: a stale in-memory `diff-hl` after the pull, needed a `load-library` + mode toggle; and a `consult` internal-symbol rename, `consult--source-*` → `consult-source-*`, which was silently failing a `consult-customize` call).
- **Magit note, unrelated to any of the above but worth knowing**: a March 2026 upstream magit change makes `--verbose` (inline diff, collapsed by default) the default for the commit transient. It interacts badly with a much older, previously-dormant `git-commit.el` bug — the "second line is not empty" style-check's regex doesn't know about the scissors line (`# ---- >8 ----`) and can misread the diff below it as your actual message when your message is empty. Workaround: use `C-c C-k` to cancel a commit, not empty-message + `C-c C-c`.
- **AWS credentials reorganized by client**, unrelated to the dotfiles repo itself (lives in `~/.aws/` and `~/src/focused/drafthouse/.mise.toml`, not tracked anywhere — deliberately, same reasoning as the untracked shell client-loader). `~/.aws/config`/`credentials` (all Drafthouse profiles) moved to `~/.aws/clients/drafthouse/`, scoped via a `.mise.toml` `[env]` block in the project directory (`AWS_CONFIG_FILE`/`AWS_SHARED_CREDENTIALS_FILE`, using `{{env.HOME}}` templating since `~` doesn't expand in TOML values). Verified working in a real interactive shell, in and out of the directory. Also added a `db-tunnel` mise task there for a Drafthouse prod Postgres SSM tunnel, recovered from earlier session context since it was never actually committed anywhere (git history confirmed empty for it).
