# Dependencies

When you need to read a dependency's source code, clone it to `~/src/deps/` instead of using WebFetch. Always clone at the same tag/version that the project depends on (e.g. `git clone --branch v1.2.3 --depth 1`). If the repo already exists at the right version, just read from it.

# Markdown

Don't hard-wrap prose in markdown files. Each paragraph or list item is one line; let the editor soft-wrap.
