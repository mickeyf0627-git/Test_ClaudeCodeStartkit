---
name: mcp-security-review
description: MCPサーバー利用申請の一次審査スキル。snyk/agent-scan で候補MCPをスキャンし、結果に組織固有のデータ分類/PII観点を重ねて、追加可否の判断材料（レポート）を作る。Use when reviewing whether a candidate MCP server is safe to add to allowedMcpServers.
---

# MCP セキュリティ一次審査

候補MCPサーバーを **snyk/agent-scan**（MCP/AIエージェント向けで最も広く使われているスキャナ。Apache-2.0、Invariant Labs `mcp-scan` の後継）でスキャンし、結果に Aillio 固有の観点を重ねてレポート化する。
**これは一次審査（自動）であり承認ではない。** 最終承認は人間（セキュリティ担当）が行い、有効化は Owner が managed の `allowedMcpServers` に登録した時点で初めて成立する。

- ツール: https://github.com/snyk/agent-scan
- 関連解説（脅威の背景）: https://invariantlabs.ai/blog/mcp-github-vulnerability

## 前提・注意
- `uv`（uvx）が必要。未導入なら: https://docs.astral.sh/uv/
- agent-scan は **config 内のコマンドを実行**してMCPへ接続するため、**隔離したテスト機/サンドボックスで・ユーザー同意の上**で実行する。
- **顧客PII・本番の秘密情報を渡さない。**

## 手順
1. 候補MCPの設定（`.mcp.json` 等）を用意する。
2. スキャン実行：
   ```
   uvx snyk-agent-scan@latest <path-to-mcp-config>
   ```
   主な検出：**Prompt Injection / Tool Poisoning / Tool Shadowing / Toxic Flows**（隠しシークレット・認証情報の扱いも）。
3. 結果を重大度別に整理・解釈する。
4. **agent-scan が判定しない組織固有の観点**を以下の rubric で補う：
   - **データ分類適合（最重要）**：顧客PIIに触れ得るか／外部SaaSへ送るか
   - 通信形態：ローカル stdio／**リモートHTTP＝データが外部に出る**
   - 提供元の信頼性・供給網（バージョン固定・メンテ状況）
5. 総合判定（承認推奨／条件付き／非推奨）＋付帯条件＋要確認事項をまとめる。

## 出力
- agent-scan の検出サマリ（重大度別）
- 組織 rubric の判定（特にデータ分類／PII）
- 総合判定・条件・人間レビューへの申し送り

## 原則
- 不明・確認不能な点は「高リスク寄り」に倒す。
- このスキルの判定だけで承認しない（人間承認＋Owner登録が必須）。
