$ErrorActionPreference = "Stop"
$dest = Join-Path $HOME ".claude"
$src  = Join-Path $PSScriptRoot "claude"

Write-Host "[install] Starter Kit を $dest へ配置します"
New-Item -ItemType Directory -Force -Path $dest | Out-Null
Copy-Item -Recurse -Force (Join-Path $src "*") $dest

Write-Host "[install] 注意: sandbox はネイティブWindows非対応です。"
Write-Host "[install] PII作業を含む場合は WSL2 の中で Claude Code を実行し、WSL2側で install.sh を使ってください。"
# 推奨プラグインを導入（security-guidance / commit-commands は managed で自動有効のため対象外）
if (Get-Command claude -ErrorAction SilentlyContinue) {
  foreach ($p in @("pr-review-toolkit","skill-creator")) {
    try {
      claude plugin install "$p@claude-plugins-official" --scope user *> $null
      Write-Host "[install] plugin 導入: $p"
    } catch {
      Write-Host "[install] $p は未導入。ログイン後に: /plugin install $p@claude-plugins-official"
    }
  }
}

# 許可済みMCPの登録（トークンは ${ENV} 参照＝コミットしない。ログイン/設定は docs/mcp-setup.md）
if (Get-Command claude -ErrorAction SilentlyContinue) {
  try { claude mcp add --scope user playwright -- npx '@playwright/mcp@latest' *> $null; Write-Host "[install] MCP: playwright" } catch {}
  try { claude mcp add-json --scope user context7 '{"type":"stdio","command":"npx","args":["-y","@upstash/context7-mcp","--api-key","${CONTEXT7_API_KEY:-}"]}' *> $null; Write-Host "[install] MCP: context7 (要 CONTEXT7_API_KEY)" } catch {}
  try { claude mcp add --scope user --transport http github 'https://api.githubcopilot.com/mcp/' *> $null; Write-Host "[install] MCP: github (/mcp でOAuth)" } catch {}
  try { claude mcp add-json --scope user supabase '{"type":"stdio","command":"npx","args":["-y","@supabase/mcp-server-supabase@latest","--read-only","--project-ref=${SUPABASE_PROJECT_REF:-}"],"env":{"SUPABASE_ACCESS_TOKEN":"${SUPABASE_ACCESS_TOKEN:-}"}}' *> $null; Write-Host "[install] MCP: supabase (非prod/read-only・要 SUPABASE_ACCESS_TOKEN)" } catch {}
  Write-Host "[install] MCPのログイン/トークンは docs/mcp-setup.md を参照"
}

Write-Host "[install] 完了。'claude' を起動し '/login' で会社Orgにログイン、'/status' を確認してください。"
