#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="$HOME/.claude"

echo "[install] Starter Kit を $DEST へ配置します"
mkdir -p "$DEST"
cp -R "$SCRIPT_DIR/claude/." "$DEST/"

# sandbox 依存（Linux / WSL2 のみ。macOS は Seatbelt 内蔵で不要）
if [ "$(uname)" = "Linux" ]; then
  need=()
  command -v bwrap >/dev/null 2>&1 || need+=(bubblewrap)
  command -v socat >/dev/null 2>&1 || need+=(socat)
  if [ "${#need[@]}" -gt 0 ]; then
    echo "[install] sandbox 依存を導入します: ${need[*]}"
    if command -v apt-get >/dev/null 2>&1; then sudo apt-get install -y "${need[@]}";
    elif command -v dnf >/dev/null 2>&1; then sudo dnf install -y "${need[@]}";
    else echo "[install] 手動で ${need[*]} を導入してください"; fi
  fi
fi

echo "[install] 完了。'claude' を起動し '/login' で会社Orgにログイン、'/status' を確認してください。"
