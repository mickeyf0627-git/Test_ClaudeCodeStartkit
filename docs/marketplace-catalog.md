# 公式 marketplace カタログ（使えるプラグイン・スキル）

本キットが許可している **Anthropic 公式の2 marketplace** で使えるものの早見表。
- `claude-plugins-official` … 起動時に自動利用可
- `anthropic-agent-skills`（＝ `anthropics/skills`）… `extraKnownMarketplaces` のキー `anthropic-agent-skills` で自動登録

インストール：`/plugin install <name>@<marketplace>`（例：`/plugin install code-review@claude-plugins-official`）。
**本キットの自動導入**：managed `enabledPlugins`＝`security-guidance` / `commit-commands`、`install.sh`＝`pr-review-toolkit` / `skill-creator` / `example-skills`。

## claude-plugins-official（開発で使う主なもの）
| プラグイン | 概要 | 本キット |
|---|---|---|
| `security-guidance` | 変更ごとに脆弱性をレビューし同セッションで修正 | ✅ 自動(enabledPlugins) |
| `commit-commands` | git commit / push / PR 作成のワークフロー | ✅ 自動(enabledPlugins) |
| `pr-review-toolkit` | コメント/テスト/エラー処理に特化したPRレビューagent群 | ✅ 自動(install.sh) |
| `skill-creator` | Skill を作成・改善・評価するツール | ✅ 自動(install.sh) |
| `code-review` | 複数の専門agentによるPR自動レビュー | 任意 |
| `feature-dev` | 専門agentによる機能開発ワークフロー | 任意 |
| `code-simplifier` | 機能を保ったままコードを簡潔化 | 任意 |
| `code-modernization` | レガシーコード近代化の構造化ワークフロー | 任意 |
| `claude-md-management` | CLAUDE.md の保守・改善 | 任意 |
| `project-artifact` | プロジェクト状況ページを生成・共有 | 任意 |
| `frontend-design` | 高品質なフロントエンドUIを生成 | 任意 |
| `mcp-server-dev` / `plugin-dev` / `agent-sdk-dev` | MCP / プラグイン / Agent SDK 開発キット | 任意 |
| `*-lsp`（typescript / pyright / gopls / clangd / csharp / jdtls / kotlin / php / lua） | 各言語の LSP（型チェック・コードナビ）。要 language-server バイナリ | 任意（ts/py/go 推奨） |

**外部連携（MCPを同梱・要認証）**：`github` / `gitlab` / `linear` / `asana` / `notion` / `figma` / `firebase` / **`playwright`** / `discord` / `imessage` など。
**クラウド/DB/監視（参考・多数）**：`aws-*`, `azure`, `cloudflare`, `mongodb`, `postgres`系, `datadog`, `posthog` 等。全カタログ → https://claude.com/plugins

## anthropic-agent-skills（＝ anthropics/skills）
スキルは3プラグインに束ねられている（単体プラグイン化されていない）。
| プラグイン | 含むスキル（概要） | 本キット |
|---|---|---|
| **`example-skills`** | **webapp-testing**(Webアプリのブラウザテスト) / frontend-design / canvas-design / theme-factory / algorithmic-art / brand-guidelines / internal-comms / doc-coauthoring / mcp-builder / skill-creator / web-artifacts-builder / slack-gif-creator | ✅ 自動(install.sh) |
| `document-skills` | docx / pdf / pptx / xlsx の作成・編集 | 任意 |
| `claude-api` | Claude API / SDK のリファレンス | 任意 |

> ⚠️ `webapp-testing` 目当てで `example-skills` を入れると上記スキルが**まとめて**入る（コンテキストコスト）。単体で絞りたい場合は、該当 skill だけ `claude/skills/` にコピーする方式もある。

## 本キット独自（自作 skills/commands/agents）
marketplace ではなく `claude/` に同梱・配布：
- skills：`mcp-security-review` / `issue-decompose` / `parallel-dev`
- commands：`/handover` `/verify` `/tdd` `/plan` `/web-source-review`
- agents：`security-reviewer` / `build-error-resolver`
- rules：`typescript-nextjs` / `python-fastapi` / `go`
