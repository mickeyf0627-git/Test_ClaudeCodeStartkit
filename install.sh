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

# 推奨プラグインを導入（security-guidance / commit-commands は managed で自動有効のため対象外）
# ※ ログイン後に実行されている前提。未ログイン等で失敗しても install は止めない。
if command -v claude >/dev/null 2>&1; then
  for p in pr-review-toolkit skill-creator; do
    if claude plugin install "$p@claude-plugins-official" --scope user >/dev/null 2>&1; then
      echo "[install] plugin 導入: $p"
    else
      echo "[install] $p は未導入。ログイン後に: /plugin install $p@claude-plugins-official"
    fi
  done
  # webapp-testing 等（example-skills プラグイン・anthropic-agent-skills marketplace）
  if claude plugin install "example-skills@anthropic-agent-skills" --scope user >/dev/null 2>&1; then
    echo "[install] plugin 導入: example-skills (webapp-testing 等)"
  else
    echo "[install] example-skills 未導入。ログイン後に: /plugin install example-skills@anthropic-agent-skills"
  fi
fi

# --- 許可済みMCPの登録（トークンは ${ENV} 参照＝コミットしない。ログイン/設定は docs/mcp-setup.md） ---
if command -v claude >/dev/null 2>&1; then
  claude mcp add --scope user playwright -- npx @playwright/mcp@latest >/dev/null 2>&1 && echo "[install] MCP: playwright" || true
  claude mcp add-json --scope user context7 '{"type":"stdio","command":"npx","args":["-y","@upstash/context7-mcp","--api-key","${CONTEXT7_API_KEY:-}"]}' >/dev/null 2>&1 && echo "[install] MCP: context7 (要 CONTEXT7_API_KEY)" || true
  claude mcp add --scope user --transport http github https://api.githubcopilot.com/mcp/ >/dev/null 2>&1 && echo "[install] MCP: github (/mcp でOAuth)" || true
  claude mcp add-json --scope user supabase '{"type":"stdio","command":"npx","args":["-y","@supabase/mcp-server-supabase@latest","--read-only","--project-ref=${SUPABASE_PROJECT_REF:-}"],"env":{"SUPABASE_ACCESS_TOKEN":"${SUPABASE_ACCESS_TOKEN:-}"}}' >/dev/null 2>&1 && echo "[install] MCP: supabase (非prod/read-only・要 SUPABASE_ACCESS_TOKEN)" || true
  echo "[install] MCPのログイン/トークンは docs/mcp-setup.md を参照"
fi

echo "[install] 完了。'claude' を起動し '/login' で会社Orgにログイン、'/status' を確認してください。"
