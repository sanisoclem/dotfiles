#!/usr/bin/env bash

SRC_DIR="${1:-}"

SRC_DIR="$(cd "$SRC_DIR" && pwd)"

mkdir -p "$HOME/.config"

for dir in "$SRC_DIR"/*; do
  name="$(basename "$dir")"
  target="$HOME/.config/$name"

  if [[ -e "$target" || -L "$target" ]]; then
    echo "Skipping existing: $target"
    continue
  fi

  ln -s "$dir" "$target"
  echo "Linked: $target -> $dir"
done
