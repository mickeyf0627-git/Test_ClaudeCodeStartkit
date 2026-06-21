# AILLIO_ClaudeCodeStartkit

Aillio 社内向け Claude Code 導入の標準キット & ポリシー設定。
前提：Team プラン / 全員 BYOD（私物端末）/ MDM未導入 / 顧客PIIあり /「Path B（BYOD維持）」。
設計の根拠は別途のセキュリティ設計書を参照。

## 構成は2層に分かれる（混同しないこと）

| | ① Managed settings（強制） | ② Starter Kit（配布・非強制） |
|---|---|---|
| 置き場 | `managed/managed-settings.json` → claude.ai 管理画面 | `claude/` → 各自の `~/.claude` |
| 強制力 | 最優先・上書き不可 | 低（本人が編集・削除可） |
| 役割 | ガードレール | 作業台 |

**強制力があるのは①だけ。** ②はDX・標準化のための配布物。

## ディレクトリ
- `managed/` … server-managed settings の**真実の源**。`OPERATIONS.md` の手順で管理画面へ反映。
- `claude/` … `~/.claude` へ配置する標準キット（settings.json / CLAUDE.md / skills / rules / agents / commands / hooks）。
- `policy/` … 利用規程（同意対象）。
- `docs/` … オンボーディング（WSL2・sandbox依存）。
- `install.sh` / `install.ps1` … `claude/` を `~/.claude` へ配置するセットアップ。

## クイックスタート
1. **管理者**：`managed/managed-settings.json` を `managed/OPERATIONS.md` の手順で claude.ai に反映。
2. **開発者**：`docs/onboarding.md` に従い WSL2 / sandbox 依存をセットアップ → `install.sh`（WSL2外のWindowsは `install.ps1`）。
3. `/status` で `Enterprise managed settings (remote)` を確認。

## 反映前に必ず置換するプレースホルダ
- `managed/managed-settings.json` の `forceLoginOrgUUID`（Aillio の Org UUID）
- `OTEL_EXPORTER_OTLP_ENDPOINT`（社内 OTel collector。未定なら env の OTEL 行を一旦外す）
