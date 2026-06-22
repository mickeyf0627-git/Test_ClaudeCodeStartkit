# Go コーディング規約

## フォーマット・ツール
- `gofmt` / `goimports` 準拠（差分はレビュー対象外）。`golangci-lint` を CI で強制。
- Go modules。`go vet` と `-race` 付きテストを CI で。

## イディオム
- **エラーは必ず処理**（`_ = err` で握りつぶさない）。ラップは `fmt.Errorf("...: %w", err)`。
- 判定は `errors.Is` / `errors.As`。センチネルエラーは `var ErrXxx = errors.New(...)`。
- ライブラリコードで `panic` しない（回復不能な初期化のみ）。
- 「インターフェースを受け取り、構造体を返す」。インターフェースは利用側で最小定義。
- IO/長時間処理は `context.Context` を第1引数に。キャンセル/タイムアウトを伝播。

## 命名・構造
- MixedCaps。パッケージ名は短く、stutter（`user.UserService`）を避ける。
- レイアウトは `cmd/` `internal/` `pkg/`。パッケージは小さく凝集的に。
- 公開APIは最小限。エクスポートには doc コメント。

## 並行処理
- goroutine は所有権と終了条件を明確に（リーク禁止）。`context` でキャンセル。
- 共有状態は `sync` か channel で保護。`-race` で検証。

## テスト
- テーブル駆動テスト。標準 `testing`。安全な範囲で `t.Parallel()`。

## セキュリティ（全社ベースライン）
- 秘密情報・顧客PIIをコード/ログに残さない。外部入力を検証。
- SQL はパラメータ化。`os/exec` に未検証入力を渡さない。
