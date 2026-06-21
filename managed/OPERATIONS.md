# Managed settings 運用手順

`managed-settings.json` は **server-managed settings の真実の源**。このリポジトリをマスターとし、変更はPR経由で行う。

## 反映手順（Owner / Primary Owner のみ）
1. このリポジトリで変更し、**PRレビュー**（セキュリティ変更は2名）を通す。
2. 反映前に**テスト機**で検証：`claude doctor`（必要なら `claude --debug-file <path>` で "Remote settings" を確認）。
3. claude.ai → **Admin Settings → Claude Code → Managed settings** に `managed-settings.json` の内容を貼り付けて **Save**。
4. 利用者に再起動してもらい、`/status` の `Setting sources` が **`Enterprise managed settings (remote)`** になることを確認。

## 反映前に必ず置換するプレースホルダ
- `forceLoginOrgUUID` … Aillio の Org UUID（Console で確認）
- `OTEL_EXPORTER_OTLP_ENDPOINT` … 社内 OTel collector のエンドポイント（未定なら env の OTEL 行を一旦外す）

## 注意
- server-managed では `managed-mcp.json` は配布不可。MCP許可は `allowedMcpServers` キーで（このファイルに記述）。
- 変更監査は本リポジトリの **Git履歴（PR）を主**とする（console の audit-log export は使えれば補助）。
- `requiredMinimumVersion: 2.1.139` … `forceRemoteSettingsRefresh` 利用のため必要。
- このJSONは**コメント無しの有効なJSON**。そのまま貼り付け可。

## 見直しサイクル
四半期ごとに `permissions.deny` / `sandbox.allowedDomains` / `allowedMcpServers` を棚卸し。
