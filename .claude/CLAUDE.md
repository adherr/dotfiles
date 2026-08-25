# Dependencies

When you need to read a dependency's source code, clone it to `~/src/deps/` instead of using WebFetch. Always clone at the same tag/version that the project depends on (e.g. `git clone --branch v1.2.3 --depth 1`). If the repo already exists at the right version, just read from it.

# Markdown

Don't hard-wrap prose in markdown files. Each paragraph or list item is one line; let the editor soft-wrap.

# Effort estimates

Assume docs/plans/handoffs are executed by agents, not humans. Drop hour/day estimates. If pacing matters, name the blocking gate (CI, deploys, external review), not wall-clock.

# Git auth failing (sandbox / 1Password / signing)

Three separate causes cover most git failures here; diagnose by symptom:

- **SSH git (fetch/pull) failing to resolve `github.com` or timing out** — sandbox network allowlist blocks it; `git push` is excluded from the sandbox already. If not that, check **1Password**.
- **Commit signing failing** — the SSH signing key is served by 1Password, so first check **1Password is running**.

When I go AFK I often leave agents running, and the **1Password fingerprint prompt times out**, so signing (and SSH-agent ops) will fail through no fault of yours. In that case it's fine to make **provisional unsigned commits** to keep moving — just flag that they need to be **rewritten as signed when I'm back** (e.g. `git rebase --exec 'git commit --amend --no-edit -S'`). Don't burn time debugging signing in this situation; see also the "don't chase commit signing" memory.

# Git: upstream ≠ push target (magit)

My branches often have `@{upstream}` on a merge target (e.g. `origin/main`) but push to their own same-named branch. Upstream only drives pull/ahead-behind, never where a push lands — don't warn that a push could clobber the upstream branch. (Verified: a naked CLI `git push` here just refuses; it never writes to main.) Check `@{push}` if unsure.

# PR descriptions

Keep the description succinct; put deep-dive/planning context in a collapsed `<details>` block (link the in-repo doc — reviewers who want depth expand or read it).

# Code comments

Default to no comment. Add one only when the code can't explain itself — a non-obvious "why", a gotcha, a workaround. When you do, keep it to one terse line; never a multi-line explanation of what the code does or how it got that way.
