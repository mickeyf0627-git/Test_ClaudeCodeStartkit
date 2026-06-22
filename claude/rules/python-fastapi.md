# Python / FastAPI コーディング規約

## Python 全般
- Python 3.11+。**型ヒント必須**、`mypy`（または pyright）を strict 寄りで通す。
- `ruff` で lint ＋ format（Black 互換）。`print` ではなく `logging`。
- `src/` レイアウト。依存は明示（pyproject.toml）。仮想環境前提。
- マジックナンバー/文字列は定数化。可変デフォルト引数禁止。

## FastAPI
- 入出力は **Pydantic v2 モデル**で定義し、`response_model` を明示。ステータスコードを明示。
- 依存は `Depends` で注入。ドメインごとに `APIRouter` を分割。
- IOバウンドな処理は `async def`。**イベントループをブロックしない**（同期重処理は別スレッド/プロセス）。
- 設定は `pydantic-settings` で環境変数から。**秘密情報はコードに書かない**。

## エラー・DB
- エラーは `HTTPException` ＋構造化レスポンス。`except:`（bare）禁止、握りつぶし禁止。
- DB は非同期 SQLAlchemy 等＋リポジトリパターン。マイグレーションは Alembic。
- **SQL は必ずパラメータ化**（文字列結合禁止）。

## テスト
- `pytest` ＋ `httpx.AsyncClient`。フィクスチャで依存を差し替え。カバレッジを計測。
- 外部I/Oはモック。テストは決定論的に。

## セキュリティ（全社ベースライン）
- 入力は Pydantic で必ず検証。`eval`/`exec`/未検証の `pickle` 禁止。
- **顧客PIIをログに出さない**。秘密情報は環境変数/シークレットストアから。
