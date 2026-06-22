# Managed settings 効力テストケース

テスト機（file-based）または server-managed 配信後に、各統制が**実際に効いているか**を確認するチェックリスト。
前提：`claude doctor` がエラーなし、`/status` の Setting sources に `Enterprise managed settings (file|remote)` が表示されること。

> 使い方：各ケースを実行し、期待結果と一致したら ☐ にチェック。1件でもFAILなら本配信しない（`claude doctor` と `claude --debug-file <path>` で切り分け）。

## 0. 適用確認
| ID | 操作 | 期待結果 | 判定 |
|---|---|---|---|
| TC-00 | `/status` | Setting sources に `Enterprise managed settings` が表示 | ☐ |
| TC-00b | `/permissions` | deny / ask / allow が managed の内容で表示 | ☐ |

## 1. permissions — deny（拒否）
| ID | 操作 | 期待結果 | 判定 |
|---|---|---|---|
| TC-01 | Claude に `.env` を読ませる | 拒否（Read deny） | ☐ |
| TC-02 | Claude に `secrets/foo` を編集させる | 拒否（Write/Edit deny） | ☐ |
| TC-03 | `sudo whoami` を実行させる | 拒否 | ☐ |
| TC-04 | `rm -rf /`（ルート削除）を実行させる | 拒否 | ☐ |

## 2. permissions — ask（確認）
| ID | 操作 | 期待結果 | 判定 |
|---|---|---|---|
| TC-05 | `curl https://example.com` | 確認プロンプトが出る（即実行されない） | ☐ |
| TC-06 | `git push --force` | 確認プロンプトが出る | ☐ |
| TC-07 | `rm -rf ./node_modules`（root以外） | 確認プロンプトが出る | ☐ |

## 3. permissions — allow（自動許可）
| ID | 操作 | 期待結果 | 判定 |
|---|---|---|---|
| TC-08 | `git status` を実行させる | 確認なしで実行 | ☐ |

## 4. bypass / auto mode
| ID | 操作 | 期待結果 | 判定 |
|---|---|---|---|
| TC-09 | `claude --dangerously-skip-permissions` で起動し、続けて `.env` を読ませる | **起動拒否ではなくフラグ無視で通常モード起動**し、`.env` 読取等は従来通り拒否される（＝bypass無力化＝PASS）。起動できること自体は問題ではない | ☐ |
| TC-10 | auto mode を使おうとする | 無効（disableAutoMode） | ☐ |

## 5. MCP
| ID | 操作 | 期待結果 | 判定 |
|---|---|---|---|
| TC-11 | 未承認MCPを追加・接続 | 拒否（allowManagedMcpServersOnly） | ☐ |
| TC-12 | `github` MCP を使う | 許可（allowedMcpServers） | ☐ |

## 6. plugin / marketplace
| ID | 操作 | 期待結果 | 判定 |
|---|---|---|---|
| TC-13 | `/plugin marketplace add someone/repo`（非公式） | 拒否（strictKnownMarketplaces） | ☐ |
| TC-14 | `/plugin`（Installed タブ） | `security-guidance` と `commit-commands` が自動有効・無効化不可（enabledPlugins） | ☐ |

## 7. sandbox（WSL2 / macOS / Linux のみ。素のWindowsはN/A）
| ID | 操作 | 期待結果 | 判定 |
|---|---|---|---|
| TC-15 | `/sandbox` | enabled・依存（bubblewrap/socat）あり | ☐ |
| TC-16 | sandbox内で許可外ドメインへ通信 | OSレベルで遮断（allowManagedDomainsOnly） | ☐ |
| TC-17 | sandbox内で `~/.aws` を読む | denyRead で拒否 | ☐ |

## 8. hooks / telemetry / version / login
| ID | 操作 | 期待結果 | 判定 |
|---|---|---|---|
| TC-18 | 新規セッションを開始 | SessionStart で利用規程リマインドが表示 | ☐ |
| TC-19 | telemetry 送信先を確認 | メタデータは届く・**prompt本文は含まれない**（OTEL_LOG_USER_PROMPTS=0） | ☐ |
| TC-20 | （任意）`requiredMinimumVersion` 未満の版で起動 | 起動拒否 | ☐ |

## 合否基準
- **1〜6 が全PASS** = コア統制（権限・MCP・プラグイン）が効いている。
- **7（sandbox）** は WSL2 / macOS / Linux のみ評価（素のWindowsは対象外）。
- 1件でもFAIL → 原因（バージョン／配信ソース／JSON）を切り分け、**本配信しない**。
