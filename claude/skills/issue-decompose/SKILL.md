---
name: issue-decompose
description: |
  Epic Issue（要件定義）をTask Issue群に分解するスキル。
  ユーザーが `/issue-decompose {Issue番号}` と入力したとき、または「このIssueを分解して」
  「タスクに落とし込んで」「サブIssueを作って」などと言ったときに使うこと。
  Epic IssueまたはPRDを読んで実装単位のTask Issueを自動生成し、
  depends_on・conflicts_with メタデータ・AI提案・ラベルを設定する。
---

# issue-decompose スキル

Epic Issue（要件定義）またはPRD（`.claude/prds/`）を読んで、並列実装可能なTask Issue群に分解するスキル。
各Task IssueにはAIの実装提案と `depends_on`・`conflicts_with` メタデータを付与し、
`/parallel-dev` が自動でWave実行計画を立てられるようにする。

## 推奨モデル

**Opus** を使用すること。
依存関係・競合の判定・タスク粒度の設計は上流工程の判断であり、Opusを推奨。
```
/model opus  # 実行前に切り替える
```

## 前提条件

- `gh` CLI が認証済みであること（`gh auth status` で確認）
- 対象リポジトリに以下のラベルが存在すること
  （未作成の場合は `bash .github/scripts/setup-labels.sh` で初期化）
  - `企画` / `タスク` / `セッションログ`
  - `レビュー待ち` / `承認済み` / `ブロック中` / `実装中` / `完了`

## 実行手順

### Step 1: コンテキストを収集する

**Epic Issue の内容を取得する**
```bash
gh issue view {番号} --json number,title,body,labels,comments
```

**PRDが存在する場合は合わせて読む**

Epic IssueにPRDへの参照（`.claude/prds/*.md`）がある場合は、そのファイルも読む。
PRDの「影響範囲」「受け入れ条件」「スコープ外」を参照して分解精度を上げる。

**既存コードのスキャン（重要）**

変更が予想されるディレクトリの主要ファイルを確認する。
これにより `conflicts_with` の検出精度が上がる。

### Step 2: タスクを分析・分解する

Epic Issueの内容から、以下の観点でTask Issueを設計する。

**分解の原則:**
- 1 Task = 1エージェントが単独で完結できる単位
- 変更ファイルが明確に区切れる単位（frontend / backend を混在させない）
- ユニットテストは各実装タスクに含める（実装エージェントが担当）
- E2E・統合テストは**必ず最終Waveの独立タスク**として分離する
- 各タスクは3〜8時間で完了できる粒度を目安とする

**E2E・統合テストタスクの自動追加:**

機能実装を含むIssueを分解する場合、以下の条件に当てはまるとき E2E・統合テストタスクを最終Waveに自動追加する。
- フロントエンドのUI変更を含む場合 → Playwright E2Eテストタスクを追加
- 複数サービスをまたぐAPIの変更を含む場合 → 統合テストタスクを追加

E2E・統合テストタスクのメタデータ:
```
depends_on: [全実装タスクの番号]   ← 必ず全実装完了後
conflicts_with: []
変更スコープ: tests/e2e/ または tests/integration/
```

**depends_on の判定基準:**
- Aが生成する関数・型・APIをBが使う → B depends_on A
- DBスキーマ変更がAPIより前に必要 → API depends_on migration
- テストは実装完了後 → test depends_on implementation

**conflicts_with の判定基準:**
- 同じファイルを両タスクが変更する → 互いに conflicts_with を設定
- 同じ設定ファイル（`package.json`, `requirements.txt` 等）を変更する
- 同じDBテーブル定義を変更する

### Step 3: Task Issue を作成する

各タスクについて以下のコマンドでIssueを作成する。

```bash
gh issue create \
  --title "{タスクのタイトル}" \
  --label "タスク,レビュー待ち" \
  --body "$(cat <<'EOF'
## 概要
{タスクの目的を1〜2行で}

## 変更スコープ
変更可能なファイル・ディレクトリ（**スコープ外は変更禁止**）:
- `{ファイルパス1}`
- `{ファイルパス2}`

## 受け入れ条件
- [ ] {条件1}
- [ ] {条件2}
- [ ] テストが通ること

## メタデータ
depends_on: [{依存するTask Issue番号のリスト、なければ空}]
conflicts_with: [{競合するTask Issue番号のリスト、なければ空}]

## 親Issue
#{Epic Issue番号}
EOF
)"
```

**依存関係があるタスクは `--label "タスク,ブロック中"` にする。**

> **注意**: `conflicts_with` は相互に設定する。
> タスクAとBが競合する場合、AにはBを、BにはAを設定する。

### Step 4: AI実装提案をコメントとして投稿する

各Task Issueに対して、実装方針をコメントで提案する。

```bash
gh issue comment {Task Issue番号} --body "$(cat <<'EOF'
## 🤖 AI実装提案

### 実装方針
{どのようなアプローチで実装するか}

### 主な変更箇所
| ファイル | 変更内容 |
|---|---|
| `{ファイル}` | {変更の概要} |

### conflicts_with の理由
{競合を設定した場合、なぜ競合するかを説明}

### depends_on の理由
{依存を設定した場合、なぜ依存するかを説明}

### 懸念点・確認事項
- {懸念点があれば記載}

---
レビューして問題なければ `approved` ラベルを付けてください。
`/parallel-dev` が depends_on / conflicts_with を読んでWave実行計画を自動生成します。
EOF
)"
```

### Step 5: Epic Issue にTask一覧と実行計画を追記する

```bash
gh issue comment {Epic Issue番号} --body "$(cat <<'EOF'
## 📋 Task 分解完了

### Wave実行計画（/parallel-dev が自動生成する予定）

**Wave 1（並列実行可能）**
- [ ] #{番号} {タイトル} — `{スコープ}`
- [ ] #{番号} {タイトル} — `{スコープ}`

**Wave 2（Wave1完了後）**
- [ ] #{番号} {タイトル} — depends_on: [#{番号}]

**Wave 3（Wave2完了後）**
- [ ] #{番号} {タイトル} — depends_on: [#{番号}]

### conflicts_with の関係
| タスク | 競合するタスク | 競合ファイル |
|---|---|---|
| #{番号} | #{番号} | `{ファイルパス}` |

### 次のステップ
1. 各Task IssueのAI提案をレビューする
2. 問題なければ `approved` ラベルを付ける
3. `/parallel-dev {番号},{番号}` で Wave 1 の並列実装を開始する
EOF
)"
```

### Step 6: 結果を報告する

---

## ✅ Issue 分解完了

**Epic**: #{番号} {タイトル}

### 作成したTask Issue と依存関係

| # | タイトル | スコープ | depends_on | conflicts_with | Wave |
|---|---|---|---|---|---|
| #{番号} | {タイトル} | `{dir}` | — | — | 1 |
| #{番号} | {タイトル} | `{dir}` | — | #{番号} | 1 |
| #{番号} | {タイトル} | `{dir}` | #{番号} | — | 2 |

### 次のアクション
1. 各IssueのAI提案コメントをレビューしてください
2. 問題なければ `approved` ラベルを付けてください
3. `/parallel-dev {Wave1の番号}` で Wave 1 を開始できます

---

## 注意点

- `conflicts_with` は**必ず相互設定**する（A→BならB→Aも設定）
- 依存関係は保守的に設定する（曖昧な場合は depends_on を付ける）
- `承認済み` ラベルはユーザーが手動で付ける（ゲートレビュー）
- PRDの「スコープ外」に書かれた内容はTask Issueに含めない
- E2E・統合テストタスクには必ず `webapp-testing スキルを使うこと` と明記する
