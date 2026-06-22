# MCP のセットアップ（許可済み4サービス）

`install.sh` / `install.ps1` が **サーバー登録を自動化**します。**ユーザーがやるのは各サービスのログイン／トークン設定だけ**（トークンはコミットせず環境変数で渡す）。

許可済み（managed `allowedMcpServers`）：**github / supabase / playwright / context7**

## install が自動でやること（登録）
| MCP | 登録内容 |
|---|---|
| `playwright` | `npx @playwright/mcp@latest`（認証不要） |
| `context7` | `npx -y @upstash/context7-mcp --api-key ${CONTEXT7_API_KEY}` |
| `github` | リモートMCP（OAuth） |
| `supabase` | `npx -y @supabase/mcp-server-supabase --read-only --project-ref=${SUPABASE_PROJECT_REF}`（**read-only固定**） |

トークンは設定に直書きせず `${ENV}` 参照。なのでコミットに秘密が乗りません。

## ユーザーがやること（サービスログインのみ）
| MCP | やること |
|---|---|
| playwright | なし |
| github | `/mcp` で **OAuthログイン**（ブラウザ） |
| context7 | APIキーを環境変数に：`export CONTEXT7_API_KEY=...` |
| supabase | **非prodプロジェクトの read-only トークン**：`export SUPABASE_ACCESS_TOKEN=...` ＋ `export SUPABASE_PROJECT_REF=<非prod ref>` |

> 環境変数はシェルのプロファイル（`~/.bashrc` / `~/.zshrc` 等）に設定。**トークンを `.mcp.json` やリポジトリに直書きしない**（コミット禁止）。

## ⚠️ Supabase は非prod・read-only 限定
顧客PIIのある**本番DBには接続しない**。`--read-only` で書込を禁止し、`SUPABASE_PROJECT_REF` には**非prod**を指定すること。prod接続が必要になったら必ず `mcp-security-review` を通す。

## 確認
`/mcp` で各サーバーの接続状態を確認（OAuthログインもここから）。未設定のトークンがあるサーバーは接続エラーになる＝環境変数を設定する合図。

> ※ Supabase の正確なパッケージ名/フラグは、導入時に Supabase 公式 MCP ドキュメントで最終確認すること。
