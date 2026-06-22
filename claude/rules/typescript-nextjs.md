# TypeScript / Next.js コーディング規約

## TypeScript
- `strict: true`。`any` を使わない（`unknown` ＋絞り込み）。非null断定 `!` は原則禁止（理由をコメント）。
- export する関数の戻り値型は明示。型の定義はオブジェクト形状に `interface`、ユニオン/ユーティリティに `type`。
- 例外より戻り値型（`Result`/`{ ok, error }`）を優先。投げる場合は型付きエラー。
- `satisfies` を活用。マジックナンバー/文字列は定数化。
- import は tsconfig paths による絶対参照。循環依存禁止。

## Next.js (App Router)
- 既定は **Server Component**。`"use client"` は本当に必要な箇所だけ（イベント/状態/ブラウザAPI）。
- データ取得は Server Component / Route Handler 側で。**秘密情報をクライアントへ渡さない**（`process.env` はサーバー専用、公開値のみ `NEXT_PUBLIC_`）。
- 画像は `next/image`、メタデータは Metadata API。リダイレクト/エラーは規約のファイル規則（`error.tsx`/`not-found.tsx`）で。
- Server Actions の入力は必ず検証（zod 等）。

## React
- 関数コンポーネント＋フック。クラスコンポーネント禁止。
- 派生状態に `useEffect` を使わない（レンダー中に算出）。リスト `key` は安定キー。
- メモ化（`memo`/`useMemo`/`useCallback`）は計測してから。

## 品質・ツール
- ESLint（typescript-eslint）＋ Prettier を CI で強制。フォーマット差分はレビュー対象外にする。
- テスト：ユニット/コンポーネントは Vitest ＋ Testing Library、E2E は Playwright。
- Promise を放置しない（floating promise 禁止）。`async/await` で例外処理。
- パッケージマネージャはリポジトリ標準（pnpm 推奨）。lockfile をコミット。

## セキュリティ（全社ベースライン）
- 秘密情報・顧客PIIをコード/ログ/プロンプトに含めない。入力は境界で検証。
- 外部入力を `dangerouslySetInnerHTML` 等へ直接渡さない。
