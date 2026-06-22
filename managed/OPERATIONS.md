# Managed settings 運用手順

`managed-settings.json` は **server-managed settings の真実の源**。このリポジトリをマスターとし、変更はPR経由で行う。

## 反映手順（Owner / Primary Owner のみ）
1. このリポジトリで変更し、**PRレビュー**（セキュリティ変更は2名）を通す。
2. 反映前に**テスト機**で検証：`claude doctor`（必要なら `claude --debug-file <path>` で "Remote settings" を確認）。
3. claude.ai → **Admin Settings → Claude Code → Managed settings** に `managed-settings.json` の内容を貼り付けて **Save**。
4. 利用者に再起動してもらい、`/status` の `Setting sources` が **`Enterprise managed settings (remote)`** になることを確認。

## 反映前に必ず置換するプレースホルダ
- `OTEL_EXPORTER_OTLP_ENDPOINT` … 社内 OTel collector のエンドポイント（未定なら env の OTEL 行を一旦外す）

## 注意
- server-managed では `managed-mcp.json` は配布不可。MCP許可は `allowedMcpServers` キーで（このファイルに記述）。
- 変更監査は本リポジトリの **Git履歴（PR）を主**とする（console の audit-log export は使えれば補助）。
- `requiredMinimumVersion: 2.1.139` … `forceRemoteSettingsRefresh` 利用のため必要。
- このJSONは**コメント無しの有効なJSON**。そのまま貼り付け可。

## 見直しサイクル
四半期ごとに `permissions.deny` / `sandbox.allowedDomains` / `allowedMcpServers` を棚卸し。

## 安全な初回展開手順（いきなり全員を避ける）

server-managed は **全Orgメンバーに一律適用**され、テストグループ機能は無い。壊れた設定が全員に波及するのを避けるため、次の順で段階展開する。

1. **file-based で検証** — テスト機の OS保護パスに `managed-settings.json` を置いて検証する。
   - Linux / WSL2: `/etc/claude-code/managed-settings.json`
   - macOS: `/Library/Application Support/ClaudeCode/managed-settings.json`
   - Windows: `C:\Program Files\ClaudeCode\managed-settings.json`
   - `claude doctor` / `/status` / `/permissions` と、実操作（`docs/testing.md` のテストケース）で挙動を確認する。
2. **Orgメンバーシップで範囲を絞る** — まず PoCチームだけを Org に招待して server-managed を投入し、実ユーザーで検証する。問題なければ残りを順次招待する（＝「誰をOrgに入れるか」が影響範囲のコントロールになる）。
3. **`forceRemoteSettingsRefresh` は初回 `false`（または外す）で開始** — `true` のままだと設定・通信の問題時に全員が起動不能になり得る。安定を確認してから `true` に切り替えて締める。
4. **全員へ拡大**する。

### 注意
- 設定をコンソールで戻しても、各端末の**キャッシュは次回取得まで残る**（即時 revert ではない）。だからこそ先に file-based 検証が効く。
- Claude Code **v2.1.169+** は**不正エントリのみ除去して有効分は適用**する（寛容パース）。
- 変更は**次回起動／1時間ポーリング**で反映され、即時全断ではない。
