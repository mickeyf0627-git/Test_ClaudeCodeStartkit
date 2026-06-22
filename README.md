# TEST_ClaudeCodeStartkit

 社内向け Claude Code 導入の標準キット & ポリシー設定。

## 前提
Team プラン / 全員 BYOD（私物端末）/ MDM未導入 / 顧客情報アリ。
設計の根拠は別途のセキュリティ設計書を参照。

## 構成は2層に分かれる（混同しないこと）

| | ① Managed settings（強制） | ② Starter Kit（配布・非強制） |
|---|---|---|
| 置き場 | `managed/managed-settings.json` → claude.ai 管理画面 | `claude/` → 各自の `~/.claude` |
| 強制力 | 最優先・上書き不可 | 低（本人が編集・削除可） |
| 役割 | ガードレール | 作業台 |

**強制力があるのは①だけ。** ②はDX・標準化のための配布物。

## ディレクトリ
- `managed/` … server-managed settings の**真実の源**（`managed-settings.json`）。設定の中身は [`SETTINGS.md`](managed/SETTINGS.md)、反映手順は [`OPERATIONS.md`](managed/OPERATIONS.md)。
- `claude/` … `~/.claude` へ配置する標準キット（settings.json / CLAUDE.md / skills / rules / agents / commands / hooks）。
- `policy/` … 利用規程（同意対象）。
- `docs/` … クイックスタート（`quickstart.md`）・MCP導入（`mcp-setup.md`）・公式marketplaceカタログ（`marketplace-catalog.md`）・効力テスト（`testing.md`）。
- `install.sh` / `install.ps1` … `claude/` を `~/.claude` へ配置するセットアップ。

## コマンド・プラグイン・規約（`claude/`）
配布は2系統。**公式プラグインは公式marketplace限定**、**社内固有は自作 `.md`**。
（自作の commands/skills/agents は自由に追加可能。）

### 公式プラグイン（marketplace は Anthropic公式2つ `claude-plugins-official` / `anthropics/skills` のみ許可）
managed設定の `strictKnownMarketplaces` で**この2つ以外を禁止**（`anthropics/skills` は `extraKnownMarketplaces` のキー `anthropic-agent-skills` で自動登録）。使えるもの一覧 → [docs/marketplace-catalog.md](docs/marketplace-catalog.md)。
- **managed `enabledPlugins` で自動導入（全員・無効化不可）**：`security-guidance`（書き込み時の自動セキュリティレビュー）／ `commit-commands`
- **`install.sh` が onboarding 時に自動導入（後で各自 `/plugin disable` 可）**：`pr-review-toolkit` / `skill-creator` / `example-skills`（**webapp-testing** 等を含む）
- **任意インストール（各自 `/plugin install <name>@claude-plugins-official`）**：`code-review` / `feature-dev`
- **スタック対応LSP（任意・要 language-server バイナリ）**：`typescript-lsp` / `pyright-lsp` / `gopls-lsp`

### 自作コマンド（`claude/commands/`）
- `/handover` … 引き継ぎドキュメント生成
- `/verify` … 変更を実際に実行して検証（lint/test/build）
- `/tdd` … テスト駆動実装
- `/plan` … 実装前の計画立案（コードは書かない）
- `/web-source-review` … 外部Webソースの安全性審査（SSRF/prompt injection）

### 規約（`claude/rules/`）
monorepo 前提・全社セキュリティ基準込み：`typescript-nextjs.md` / `python-fastapi.md` / `go.md`

### スキル（`claude/skills/`）
- `mcp-security-review` … MCP追加申請の一次審査（実インシデント由来9項目を0/1/2点で採点・満点18・クリティカルゲート・**外部API不要**）
- `issue-decompose` … Epic Issue / PRD を並列実装可能な Task Issue 群に分解（`claude-code-team-template` から移管。ラベル体系・`.claude/prds/` に依存）
- `parallel-dev` … 承認済み Task Issue を Git worktree で並列実装→Draft PR（issue-decompose と対。E2EはWeb `webapp-testing` で実行）

### エージェント（`claude/agents/`）
公式プラグイン（code-review / pr-review-toolkit / feature-dev / code-simplifier）と重複しない Aillio 固有のもの：
- `security-reviewer` … 差分を PII・秘密情報・脆弱性の観点でレビュー（読み取り専用）
- `build-error-resolver` … monorepo のビルド/型/lint エラーを最小修正で解消

### フック（hooks）
- **Managed（強制）**：`SessionStart` で利用規程リマインド（顧客PII・秘密情報を入れない）を表示。実体は `managed/managed-settings.json` の `hooks`（説明は [`managed/SETTINGS.md`](managed/SETTINGS.md)）。**ログは残さない**ので PII リスクなし。
- **`claude/hooks/`**：現状は空（user / project 固有フックの置き場）。`allowManagedHooksOnly` は使っていないため、必要なら各自・各repoでフックを追加できる（強制ではない）。

## クイックスタート
1. **管理者**：`managed/managed-settings.json` を `managed/OPERATIONS.md` の手順で claude.ai に反映。
2. **開発者**：[`docs/quickstart.md`](docs/quickstart.md) に従ってセットアップ（インストール → ログイン → `install.sh` → 確認）。
3. `/status` で `Enterprise managed settings (remote)` を確認。

## 反映前に必ず置換するプレースホルダ
- `OTEL_EXPORTER_OTLP_ENDPOINT`（社内 OTel collector。未定なら env の OTEL 行を一旦外す）
