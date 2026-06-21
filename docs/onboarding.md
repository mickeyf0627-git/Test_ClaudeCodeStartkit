# オンボーディング（開発者向け）

## 1. 前提：sandbox は WSL2 / macOS / Linux のみ
ネイティブWindowsは非対応。**Windowsの人は WSL2 の中で Claude Code を動かす**こと。

## 2. sandbox 依存のインストール（Linux / WSL2）
    sudo apt-get install -y bubblewrap socat   # Ubuntu/Debian
    # Fedora: sudo dnf install -y bubblewrap socat

`install.sh` が不足時に自動実行する。Ubuntu 24.04+ は AppArmor の設定が必要な場合あり（`/sandbox` の Dependencies タブで確認）。

## 3. 標準キットの配置
    ./install.sh        # Mac / Linux / WSL2
    # Windows(WSL2外): ./install.ps1

`claude/` の内容が `~/.claude` に配置される。

## 4. ログインと確認
- 会社Orgアカウントでログイン（`claude` → `/login`）。
- `/status` で `Enterprise managed settings (remote)` を確認。
- `/sandbox` で依存が揃っているか確認。

## 既知の注意
- `docker` / `gh` / `gcloud` / `terraform` は sandbox と相性問題があり得る（`excludedCommands` で調整）。
- `curl` / `wget` は確認(ask)が出る。外部取得は原則 WebFetch を使う。
- 秘密情報ファイル（.env / secrets / 鍵）の読み書きはブロックされる。
