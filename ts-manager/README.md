# ts-manager

Manages Neovim treesitter parsers and queries without relying on the nvim-treesitter plugin.

Clones grammar repos, pins them to semver tags, compiles `.so` parser files, and installs
query files — all driven by a plain TOML config.

## Requirements

- Python 3.14+
- `uv`
- `git`
- `tree-sitter` CLI (`brew install tree-sitter` or `cargo install tree-sitter-cli`)
  - Falls back to `gcc` directly if unavailable
- Node.js (only needed if a grammar repo doesn't ship a pre-generated `src/parser.c`)

## Usage

```sh
# Install all parsers
uv run ts_manager/main.py install

# Install specific language(s)
uv run ts_manager/main.py install go rust

# Update all (only recompiles if the upstream tag changed)
uv run ts_manager/main.py update

# Show installed vs latest available tags
uv run ts_manager/main.py status
```

## How it works

1. Reads `config.toml` for the language registry (repo URL, optional grammar subdirectory)
2. Detects the ABI version expected by your local Neovim build
3. For each language, resolves the latest semver tag via `git ls-remote`
4. Clones the grammar repo at that tag into `.cache/grammars/<lang>/`
5. Compiles the parser to `~/.local/share/nvim/site/parser/<lang>.so`
6. Copies query files to `~/.local/share/nvim/site/queries/<lang>/`
7. Records the pinned tag and commit in `lock.toml`

On subsequent runs, languages whose tag hasn't changed are skipped.

If the configured parser install root is not backed by a Neovim `runtimepath` entry,
`ts-manager` emits a warning because Neovim will not discover those parsers.

## Query sources

By default, queries are sourced from each grammar's own repo. For richer highlighting,
a `queries_repo` can be specified in `config.toml` as `"owner/repo@ref"` to pull queries
from a separate source instead.

Currently all languages use `nvim-treesitter/nvim-treesitter@master` as their query source.
That branch was frozen (not deleted) when the plugin was archived, so it remains readable
but will not receive updates.

**TODO**: Periodically check whether upstream grammar repos have closed the query coverage
gap and migrate languages off the nvim-treesitter queries where they've become
self-sufficient. Good candidates to check first are languages with active grammar
maintainers (zig, svelte, lua).

To investigate, compare line counts between what's installed and what nvim-treesitter master has:

```sh
# Show installed query files and line counts per language
for lang in go python rust zig lua javascript typescript tsx markdown svelte vue; do
  count=$(ls ~/.local/share/nvim/site/queries/$lang/*.scm 2>/dev/null | wc -l | tr -d ' ')
  files=$(ls ~/.local/share/nvim/site/queries/$lang/*.scm 2>/dev/null | xargs -n1 basename | tr '\n' ' ')
  echo "$lang: $count files [$files]"
done

# Compare line count of a specific language's highlights against nvim-treesitter master
wc -l ~/.local/share/nvim/site/queries/go/highlights.scm
curl -s https://raw.githubusercontent.com/nvim-treesitter/nvim-treesitter/master/queries/go/highlights.scm | wc -l

# In Neovim: confirm treesitter is active (not regex fallback) on the current buffer
# @-prefixed captures = treesitter; bare names like goFunction = regex syntax
:lua print(vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] ~= nil)

# In Neovim: inspect highlight groups under the cursor and their source
:Inspect
```

## Adding a language

Add a stanza to `config.toml`:

```toml
[languages.mylang]
repo = "https://github.com/someone/tree-sitter-mylang"
# grammar_path = "sublang"  # optional: subdirectory if the repo contains multiple grammars
```

Then run `uv run ts_manager/main.py install mylang`.
