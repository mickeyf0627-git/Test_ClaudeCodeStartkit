$ErrorActionPreference = "Stop"
$dest = Join-Path $HOME ".claude"
$src  = Join-Path $PSScriptRoot "claude"

Write-Host "[install] Starter Kit を $dest へ配置します"
New-Item -ItemType Directory -Force -Path $dest | Out-Null
Copy-Item -Recurse -Force (Join-Path $src "*") $dest

Write-Host "[install] 注意: sandbox はネイティブWindows非対応です。"
Write-Host "[install] PII作業を含む場合は WSL2 の中で Claude Code を実行し、WSL2側で install.sh を使ってください。"
Write-Host "[install] 完了。'claude' を起動し '/login' で会社Orgにログイン、'/status' を確認してください。"
