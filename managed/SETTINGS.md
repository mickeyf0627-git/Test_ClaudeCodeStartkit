# Managed settings の中身（現在の設定一覧）

`managed-settings.json` に入れている各設定の**意味と狙い**を、技術に詳しくない人でも分かるように説明したものです。
**設定を変えたら、このファイルも更新すること。** 反映手順は [OPERATIONS.md](OPERATIONS.md)、効力確認は [../docs/testing.md](../docs/testing.md)。

> これらは「会社が全員に強制するルール」。各自のPC設定では上書きできません。

## 認証・アカウント（誰がどう使えるか）
| キー | 値 | かんたんな説明（目的） |
|---|---|---|
| `forceLoginMethod` | `"claudeai"` | 会社のClaude（claude.ai）アカウントでだけログインできるようにする |

## 基本のロックダウン（土台のルール）
| キー | 値 | かんたんな説明（目的） |
|---|---|---|
| `requiredMinimumVersion` | `"2.1.139"` | 古いバージョンのClaude Codeを使わせない（ルールが正しく効く新しさを担保） |
| `allowManagedPermissionRulesOnly` | `false` | 「禁止」は全社で固定しつつ、「許可」は各チームが自分で足せる（管理をラクにするため） |
| `disableAutoMode` | `"disable"` | AIが自動でOKを出して進む“おまかせモード”を使わせない（人が確認する形を保つ） |
| `forceRemoteSettingsRefresh` | `true` | 会社のルール設定を受け取れないと起動させない（ルール無しで使われるのを防ぐ）。※**初回展開は false 推奨**（[OPERATIONS](OPERATIONS.md)参照） |

## permissions（やってよい操作・ダメな操作）
| 区分 | 中身 | かんたんな説明（目的） |
|---|---|---|
| `disableBypassPermissionsMode` | `"disable"` | 「すべての確認をスキップする危険モード」を使えないようにする |
| `deny`（禁止） | 機密ファイル（`.env*`・`secrets`・パスワードや鍵・`~/.ssh`・`~/.aws` 等）の読み書き／PCを壊す系（`sudo`・`rm -rf /`・ディスク初期化 等） | パスワードや顧客情報を触らせない・PCを壊す操作を禁止 |
| `ask`（確認） | 外部送信（`curl`・`wget`）／消す系（`rm -rf`・`git push --force`・`git reset --hard` 等） | 外にデータを送る・取り消せない操作は、実行前に必ず人へ確認 |
| `allow`（自動許可） | `git status`・`git diff`・`npm test`・`npm run lint` | 安全でよく使う操作は確認なしで通す（作業の邪魔をしない） |
| WebFetch | （ルール無し＝許可） | Webページの取得は許可（普通の調べ物用） |

## MCP（外部サービス連携）
| キー | 値 | かんたんな説明（目的） |
|---|---|---|
| `allowManagedMcpServersOnly` | `true` | 会社が承認した連携だけ使える（勝手な追加を防ぐ） |
| `allowedMcpServers` | `[github]` | いまは GitHub 連携だけ許可（他は申請→審査を通れば追加） |

## 拡張機能（プラグイン）
| キー | 値 | かんたんな説明（目的） |
|---|---|---|
| `strictKnownMarketplaces` | `[公式ストア]` | 拡張機能は公式ストアからだけ。怪しい配布元を禁止 |
| `enabledPlugins` | `security-guidance`, `commit-commands` | 全員に最初から入れておく拡張（自動セキュリティチェック等）。各自では外せない |

## 起動時のリマインド（hooks）
| イベント | 内容 | かんたんな説明（目的） |
|---|---|---|
| `SessionStart` | 利用規程リマインドを表示 | 起動のたびに「個人情報・秘密情報を入力しないこと」を画面に出す（記録は残さない） |

## サンドボックス（実行を“隔離箱”に閉じ込める。WSL2/Mac/Linuxのみ）
| キー | 値 | かんたんな説明（目的） |
|---|---|---|
| `enabled` | `true` | AIが動かすコマンドを隔離した箱の中で実行し、PC本体やネットを勝手に触らせない |
| `failIfUnavailable` | `false` | 箱が使えない環境では、いったん警告だけ出して動かす（後で厳しくする） |
| `allowUnsandboxedCommands` | `true` | 箱内で動かせない操作は、確認のうえ箱の外で動かす逃げ道を残す |
| `allowManagedDomainsOnly` | `true` | 許可した通信先以外には接続させない（情報の外部持ち出しを防ぐ） |
| `allowedDomains` | Anthropic・npm・pypi・github 等 | 通信してよい相手先 |
| `filesystem.denyRead` | `~/.aws`・`~/.ssh`・`gcloud` | クラウドの認証情報フォルダを読ませない |

## 利用ログ（telemetry）
| キー | 値 | かんたんな説明（目的） |
|---|---|---|
| `CLAUDE_CODE_ENABLE_TELEMETRY` | `"1"` | 利用状況の記録（監査用）を有効にする |
| `OTEL_..._EXPORTER` / `ENDPOINT` | otlp / `<要置換>` | 記録の送り先（**社内の送信先に要差し替え**／未定なら外す） |
| `OTEL_LOG_USER_PROMPTS` | `"0"` | **入力した文章そのものは記録しない**（顧客情報がログに残るのを防ぐ）← 重要 |
| `OTEL_LOG_TOOL_DETAILS` | `"1"` | どのツールを使ったか（名前だけ）は記録する |

## 本配信前に必ず差し替えるもの
- `OTEL_EXPORTER_OTLP_ENDPOINT` … 社内のログ送信先（未定なら telemetry の OTEL 行を外す）
