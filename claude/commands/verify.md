---
description: 変更が実際に動くか検証する（影響スタックの lint/test/build を実行し結果を報告）
argument-hint: "[対象パッケージや観点(任意)]"
---
直近の変更が意図どおり動くかを**実際に実行して**検証してください。$ARGUMENTS

手順:
1. monorepo のどのパッケージ/スタックが変更されたか特定する。
2. 影響範囲に応じて検証を実行:
   - TypeScript/Next.js: `pnpm lint` / `pnpm test`（Vitest）/ 必要なら Playwright
   - Python/FastAPI: `ruff check` / `pytest`
   - Go: `go vet ./...` / `go test -race ./...`
3. 失敗は出力を添えてそのまま報告（取り繕わない）。通った項目・スキップした項目も明記。
4. 「動いた/直った」は実行結果を根拠にのみ述べる。
