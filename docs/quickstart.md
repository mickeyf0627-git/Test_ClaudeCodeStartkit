# クイックスタート（開発者向けオンボーディング）

Aillio で Claude Code を使い始めるための手順。所要 15〜30分。
前提：Team プラン・会社Orgアカウント・BYOD（私物端末）・顧客PIIを扱う環境。

---

## 0. 事前準備
- 会社Orgアカウント（claude.ai）に**招待済み**であること（未招待なら管理者へ。「You haven't been added to your organization yet」が出る場合もこれ）。
- **Windowsの人は WSL2 を使う**（sandbox がネイティブWindows非対応のため。WSL2内でClaude Codeを動かす）。

## 1. Claude Code をインストール
いずれかの方法で：
```
npm install -g @anthropic-ai/claude-code@latest     # npm の場合
```
（ネイティブインストーラ等は公式手順を参照）

バージョン確認（**2.1.139 以降**が必要＝managed設定の要件）：
```
claude --version
```

## 2. 会社Orgでログイン
```
claude        # 起動
/login        # 会社Orgアカウントを選択（※個人アカウントは禁止）
```

## 3. Starter Kit を配置
リポジトリを取得して install を実行（`claude/` 配下が `~/.claude` に配置される）：
```
git clone https://github.com/mickeyf0627-git/AILLIO_ClaudeCodeStartkit.git
cd AILLIO_ClaudeCodeStartkit
./install.sh          # macOS / Linux / WSL2（bubblewrap/socat も不足時に自動導入）
# WSL2外の Windows: ./install.ps1
```

## 4. 適用確認
Claude Code 内で：
```
/status        # Setting sources に「Enterprise managed settings」が出れば統制が効いている
/sandbox       # 依存(bubblewrap/socat)が揃い enabled か（WSL2/macOS/Linux）
/permissions   # 効いているルールを確認（任意）
```

## 5. 公式プラグイン
- **managed で自動（操作不要・無効化不可）**：`security-guidance`（書き込み時の自動セキュリティレビュー）／ `commit-commands`
- **`install.sh` が自動導入（onboarding時）**：`pr-review-toolkit` ／ `skill-creator`
- **任意で入れる**：
  ```
  /plugin install code-review@claude-plugins-official
  /plugin install feature-dev@claude-plugins-official
  ```
- **LSP（任意・要バイナリをPATHに）**：`typescript-lsp`(`typescript-language-server`) ／ `pyright-lsp`(`pyright`) ／ `gopls-lsp`(`gopls`)

## 6. 使えるもの
- **コマンド**：`/plan`（実装計画）・`/tdd`（テスト駆動）・`/verify`（検証）・`/handover`（引き継ぎ）・`/web-source-review`（外部URL審査）
- **エージェント**：`security-reviewer`（PII/脆弱性レビュー）・`build-error-resolver`（ビルド修復）
- **スキル**：`mcp-security-review`（MCP申請の一次審査）
- **規約**：`~/.claude/rules`（TypeScript/Next・Python/FastAPI・Go）
- **MCP**：`github` / `supabase`(非prod・read-only) / `playwright` / `context7`（`install.sh` が登録。ログイン/トークンは [mcp-setup.md](mcp-setup.md)）

## 7. 守ること（利用規程の要点）
- 顧客PII・本番の秘密情報を**プロンプト／ツール入力に入れない**（開発は合成・マスキングデータで）。
- **個人アカウント禁止**（会社Orgのみ）。
- **未承認MCP禁止**（利用は申請制：申請→`mcp-security-review`→承認→Owner登録）。
- managed設定の**無効化・回避をしない**。
- 詳細は [`policy/acceptable-use.md`](../policy/acceptable-use.md)。

## 8. 困ったとき
- `claude doctor` … 設定の健全性チェック。
- `/status` に managed が出ない … バージョン（2.1.139+）とログインOrgを確認。
- `curl`/`wget` で確認(ask)が出る … 仕様。外部取得は原則 **WebFetch** を使う。
- `docker`/`gh`/`gcloud`/`terraform` が sandbox で失敗 … `excludedCommands` で調整（管理者へ相談）。
- ログイン不可 … `/logout` → `/login`、`claude update` 後に再試行。

## 参照
- 利用規程：[`policy/acceptable-use.md`](../policy/acceptable-use.md)
- 管理者向け運用：[`managed/OPERATIONS.md`](../managed/OPERATIONS.md)
- 効力テスト：[`docs/testing.md`](testing.md)
