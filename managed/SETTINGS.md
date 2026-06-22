# Managed settings の中身（現在の設定一覧）

`managed-settings.json` に入れている各設定の**意味と狙い**。JSONの人間向け対応表です。
**設定を変えたら、このファイルも更新すること。** 反映手順は [OPERATIONS.md](OPERATIONS.md)、効力確認は [../docs/testing.md](../docs/testing.md)。

> 強制力は managed 層のみ（下位スコープからは上書き不可）。なぜこの値かの根拠はセキュリティ設計書を参照。

## 認証・アカウント
| キー | 値 | 目的 |
|---|---|---|
| `forceLoginMethod` | `"claudeai"` | ログイン方法を claude.ai に固定 |
| `forceLoginOrgUUID` | `<要置換>` | 会社Org以外でのログインをブロック（**実UUIDに要置換**） |

## バージョン・ロックダウン
| キー | 値 | 目的 |
|---|---|---|
| `requiredMinimumVersion` | `"2.1.139"` | 最低CCバージョン（`forceRemoteSettingsRefresh` 利用のため必要） |
| `allowManagedPermissionRulesOnly` | `false` | deny は床として常に有効。project が allow を追加可（運用負荷を下げる） |
| `disableAutoMode` | `"disable"` | auto mode を無効（分類器ベースの自動承認を使わず決定論的permissionを優先） |
| `forceRemoteSettingsRefresh` | `true` | 取得失敗時は起動拒否（フェイルクローズ）。※**初回展開は false 推奨**（OPERATIONS参照） |

## permissions（権限の床）
| 区分 | 中身 | 目的 |
|---|---|---|
| `disableBypassPermissionsMode` | `"disable"` | `--dangerously-skip-permissions` を無力化（起動はするが bypass しない） |
| `deny`（拒否） | 機密ファイルの Read/Write/Edit（`.env*` / `secrets` / `credentials` / `*.pem` / `*.key` / `id_rsa` / `~/.ssh` / `~/.aws` / `gcloud`）、破壊系（`sudo` / `rm -rf /`,`~` / `mkfs` / `dd`） | 機密保護・破滅的操作の禁止 |
| `ask`（確認） | 外部送信（`curl` / `wget`）、破壊的だが正当（`rm -rf`一般 / `git push --force` / `git reset --hard` / `git clean -fd`） | 人の目を通す |
| `allow`（自動許可・最小） | `git status` / `git diff` / `npm test` / `npm run lint` | 安全な既定。project が更に追加可 |
| WebFetch | （ルール無し＝許可） | 正規のWeb取得経路 |

## MCP
| キー | 値 | 目的 |
|---|---|---|
| `allowManagedMcpServersOnly` | `true` | 承認済みMCPのみ接続可（ユーザー追加をブロック） |
| `allowedMcpServers` | `[{ serverName: github }]` | 当面 GitHub のみ許可（追加は 申請→`mcp-security-review`→人間承認→Owner登録） |

## plugin / marketplace
| キー | 値 | 目的 |
|---|---|---|
| `strictKnownMarketplaces` | `[anthropics/claude-plugins-official]` | 公式 marketplace 以外を禁止 |
| `enabledPlugins` | `security-guidance`, `commit-commands` | 全員に自動有効化（無効化不可） |

## hooks
| イベント | 内容 | 目的 |
|---|---|---|
| `SessionStart` | 利用規程リマインド（PII・秘密情報を入れない）を表示 | コンプラ補強。**ログは残さない**（PIIリスク無し） |

## sandbox（WSL2 / macOS / Linux のみ。素のWindowsは非対応）
| キー | 値 | 目的 |
|---|---|---|
| `enabled` | `true` | OSレベルの FS / ネットワーク隔離 |
| `failIfUnavailable` | `false` | sandbox 不可環境は警告のみ（定着後 `true` 検討） |
| `allowUnsandboxedCommands` | `true` | 逃がし弁あり（慣れたら `false` で厳格化） |
| `allowManagedDomainsOnly` | `true` | 許可ドメイン以外を遮断（egress制御の本体） |
| `allowedDomains` | Anthropic API / npm / pypi / github 等 | 通信許可先 |
| `filesystem.denyRead` | `~/.aws` / `~/.ssh` / `gcloud` | 認証情報ディレクトリの読取拒否 |

## telemetry（env）
| キー | 値 | 目的 |
|---|---|---|
| `CLAUDE_CODE_ENABLE_TELEMETRY` | `"1"` | OTel 有効化 |
| `OTEL_METRICS_EXPORTER` / `OTEL_LOGS_EXPORTER` | `"otlp"` | エクスポータ |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | `<要置換>` | 送信先（**社内collectorに要置換／未定なら外す**） |
| `OTEL_LOG_USER_PROMPTS` | `"0"` | **prompt本文を記録しない（PII二次流出防止）** |
| `OTEL_LOG_TOOL_DETAILS` | `"1"` | MCP / ツール名のメタデータを記録 |

## 要置換のプレースホルダ（本配信前に必須）
- `forceLoginOrgUUID` … Aillio の Org UUID
- `OTEL_EXPORTER_OTLP_ENDPOINT` … 社内 OTel collector（未定なら env の OTEL 行を外す）
