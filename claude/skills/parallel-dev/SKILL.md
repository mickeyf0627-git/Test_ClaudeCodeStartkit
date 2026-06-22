---
name: parallel-dev
description: |
  approved ラベルのTask IssueをGit worktreeで並列実装するスキル。
  ユーザーが `/parallel-dev {Issue番号,番号,...}` と入力したとき、または
  「並列で実装して」「このIssueを並列開発して」などと言ったときに使うこと。
  depends_on/conflicts_with を読んでWave実行計画を自動生成し、
  各Waveをサブエージェントで並列実装→Draft PR作成まで行う。
---

# parallel-dev スキル

`承認済み` ラベルのTask Issueに対して、`depends_on` / `conflicts_with` メタデータを読んで
Wave実行計画を自動生成し、Git worktreeでサブエージェントを並列起動するスキル。
E2E・統合テストタスクは自動的に最終Waveとして認識し、`webapp-testing` スキルで実行する。

## 前提条件

- `gh` CLI が認証済みであること
- 対象Issueに `承認済み` ラベルが付いていること（ゲートレビュー済み）
- `depends_on` に記載されたIssueが完了・マージ済みであること
- 作業ブランチが `main`（または `develop`）の最新状態であること

---

## 実行手順

### Step 1: 対象 Issue のメタデータを収集する

指定されたIssue番号それぞれについてメタデータを取得する。

```bash
gh issue view {番号} --json number,title,body,labels
```

各Issueのボディから以下を抽出する：

```
depends_on: [リスト]       ← 依存するTask Issue番号
conflicts_with: [リスト]   ← 競合するTask Issue番号
変更スコープ（ファイル一覧）
```

### Step 2: Wave実行計画を構築する

取得したメタデータから依存グラフを構築し、Wave（実行波）を決定する。

**Wave分けのアルゴリズム:**

```
Wave 1 = depends_on が空のIssue
Wave 2 = depends_on が Wave1のIssueのみのIssue
Wave N = depends_on が Wave(N-1)以前のIssueのみのIssue
最終Wave = E2E・統合テストタスク（タイトルに「E2E」「統合テスト」を含む）
```

**conflicts_with の処理:**

同一Wave内で `conflicts_with` が設定されているペアが存在する場合、
一方を次のWaveに移動する（アルファベット/番号順で番号が大きい方を後ろへ）。

**E2E・統合テストタスクの識別:**

Issueのタイトルに「E2E」「統合テスト」「Playwright」を含む場合、または
変更スコープが `tests/e2e/` / `tests/integration/` の場合は「テストタスク」として扱い、
必ず最終Waveに配置する。

**実行計画の例:**

```
指定Issue: #43, #44, #45, #46
  #43: depends_on=[]   conflicts_with=[]
  #44: depends_on=[]   conflicts_with=[#43] ← #43と同ファイル
  #45: depends_on=[#44] conflicts_with=[]
  #46: depends_on=[#43,#44] conflicts_with=[]

→ Wave計画:
  Wave 1: #43          （#44は#43と競合→Wave2に移動）
  Wave 2: #44          （#43完了後、競合解消）
  Wave 3: #45, #46     （#44完了後、deps解決。互いに競合なし→並列）
```

### Step 3: 実行計画をユーザーに提示して承認を得る

---

## 🚀 Wave実行計画

| Wave | Issue | タイトル | スコープ | 理由 |
|---|---|---|---|---|
| Wave 1 | #{番号} | {タイトル} | `{dir}` | 独立 |
| Wave 2 | #{番号} | {タイトル} | `{dir}` | conflicts_with #{番号} |
| Wave 3 | #{番号} | {タイトル} | `{dir}` | depends_on #{番号} |
| Wave 3 | #{番号} | {タイトル} | `{dir}` | depends_on #{番号} |

**Wave 1 同時実行数**: {N} エージェント
**総Wave数**: {N}

実行してもよいですか？（Wave 1 から順番に実行します）

---

ユーザーの承認を得てから Step 4 に進む。

### Step 4: 各WaveのサブエージェントをWave順に起動する

**通常タスク（実装Wave）と E2E・統合テストWave で指示内容を切り替える。**

**同一メッセージ内でAgentツールを並列呼び出しする（Wave内のIssue数分）。**

各サブエージェントへの指示プロンプト：

```
# Task: Issue #{番号} の実装

## Issue 内容
タイトル: {タイトル}
{Issue本文全文（depends_on/conflicts_with含む）}

## 作業ルール
- 変更可能スコープ: {ファイル・ディレクトリのリスト}
- **スコープ外のファイルは絶対に変更しないこと**
- コーディング規約は CLAUDE.md / Agent.md に従うこと
- シークレットをコードにハードコードしないこと

## conflicts_with について
このタスクは #{競合Issue番号} と以下のファイルで競合します: {ファイルリスト}
それらのファイルはこのWaveでは他のエージェントが変更しないため、安全に作業できます。

## 完了条件（この順で実行すること）
1. Issue の受け入れ条件をすべて満たす実装を行う
2. テストを実行してすべてパスすることを確認する
3. Draft PR を作成する:
   gh pr create \
     --title "{タイトル} (#{番号})" \
     --body "## 概要\n{実装内容}\n\n## 変更ファイル\n{一覧}\n\n## テスト結果\n{結果}\n\nCloses #{番号}" \
     --draft \
     --base main
4. Issue にコメントを投稿する:
   gh issue comment #{番号} --body "## ✅ 実装完了\nDraft PR: {URL}\n### 実装内容\n{箇条書き}"
5. Issue のラベルを 実装中 → 完了 に変更する:
   gh issue edit #{番号} --remove-label "実装中" --add-label "完了"
```

**Agentツールのパラメータ:**
- `model: "sonnet"` — 実装タスク・E2Eテストタスク共通
- `isolation: "worktree"` でブランチを分離する
- `run_in_background: true` で並列実行する

### Step 5: Wave 1 完了後、次の Wave を実行する

Wave 1 の全サブエージェントが完了したら：

1. 結果を確認（失敗がないか）
2. Wave 2 の `conflicts_with` が解消されているか確認
3. Wave 2 のサブエージェントを同様に並列起動
4. 以降 Wave N まで繰り返す

### Step 6: 全Wave完了後にサマリーを報告する

---

## 📊 並列実装完了レポート

### Wave別結果

**Wave 1**
| Issue | ステータス | Draft PR | 備考 |
|---|---|---|---|
| #{番号} | ✅ 完了 | #{PR番号} | |

**Wave 2**
| Issue | ステータス | Draft PR | 備考 |
|---|---|---|---|
| #{番号} | ✅ 完了 | #{PR番号} | |

**Wave 3**
| Issue | ステータス | Draft PR | 備考 |
|---|---|---|---|
| #{番号} | ✅ 完了 | #{PR番号} | |
| #{番号} | ⚠️ 要確認 | — | {エラー内容} |

### 次のステップ
1. 各Draft PRをレビューして Ready for Review に変更する
2. `/pr-review {PR番号}` でCLAUDE.md規約チェックを実行する
3. CIが通ったことを確認してマージする

---

## 注意点

- **Wave内は並列、Wave間は直列** — これが依存・競合を安全に解決する仕組み
- サブエージェント同士はコンテキストを共有しない
- 失敗したIssueは個別に `/parallel-dev {番号}` で再実行する
- API コスト: Wave内の並列数 × Wave数分のトークンが消費される
- `conflicts_with` が見つかった場合は必ずWaveを分けること（同Wave内で実行しない）
- E2E・統合テストタスクは必ず全実装Waveの完了後に実行すること
- テスト失敗時はバグIssueを作成して `バグ` / `優先度:高` ラベルを付ける
