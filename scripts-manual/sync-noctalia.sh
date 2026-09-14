#!/usr/bin/env bash

set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target="$repo_dir/cachyos/noctalia/settings.toml"

command -v noctalia >/dev/null 2>&1 || {
  echo "error: noctalia not found in PATH" >&2
  exit 1
}

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

noctalia config export full >"$work/full-before.toml" 2>/dev/null || {
  echo "error: could not read current config; is the shell running?" >&2
  exit 1
}

noctalia config export merged >"$work/merged.toml" 2>/dev/null

if [[ ! -s "$work/merged.toml" ]]; then
  echo "error: 'noctalia config export merged' produced nothing; $target left alone" >&2
  exit 1
fi

if ! noctalia config validate "$work/merged.toml" >"$work/validate.log" 2>&1; then
  echo "error: exported config failed validation; $target left alone" >&2
  cat "$work/validate.log" >&2
  exit 1
fi
sed -n 's/^WARN/  warning:/p' "$work/validate.log" >&2 || true

[[ -f "$target" ]] && cp "$target" "$target.bak" # *.bak is gitignored
cp "$work/merged.toml" "$target"

noctalia msg config-reload >/dev/null 2>&1 || true
sleep 2

noctalia config export full >"$work/full-after.toml" 2>/dev/null || true
if ! diff -q "$work/full-before.toml" "$work/full-after.toml" >/dev/null 2>&1; then
  echo "error: effective config changed - this should not happen. Diff:" >&2
  diff "$work/full-before.toml" "$work/full-after.toml" >&2 || true
  echo "restoring previous $target" >&2
  [[ -f "$target.bak" ]] && cp "$target.bak" "$target"
  noctalia msg config-reload >/dev/null 2>&1 || true
  exit 1
fi

echo "synced $target (effective config unchanged)"
echo "review with: git -C '$repo_dir' diff -- cachyos/noctalia/settings.toml"
