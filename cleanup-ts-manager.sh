#!/usr/bin/env bash
# One-time cleanup of parsers and queries previously installed by ts-manager.
# Run this on each machine after pulling the updated dotfiles, then delete it.

set -euo pipefail

PARSER_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/parser"
QUERY_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/queries"

LANGUAGES=(
    go python rust zig lua
    javascript typescript tsx
    markdown markdown_inline
    svelte vue
)

for lang in "${LANGUAGES[@]}"; do
    rm -f "$PARSER_DIR/$lang.so" "$PARSER_DIR/$lang.dylib"
    rm -rf "$QUERY_DIR/$lang"
done

echo "ts-manager artifacts removed."
