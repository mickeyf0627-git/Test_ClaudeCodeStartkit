---
description: テスト駆動で実装する（失敗するテスト→最小実装→リファクタ）
argument-hint: "<実装したい振る舞い>"
---
次の振る舞いをテスト駆動で実装してください: $ARGUMENTS

ルール:
1. **まず失敗するテストを書く**（実装より先）。スタックの標準FWで:
   - TypeScript=Vitest / Python=pytest / Go=標準 testing（テーブル駆動）
2. テストが失敗することを確認 → **最小実装で Green** → リファクタ。
3. 各ステップでテストを実行する。`claude/rules` の規約に従う。
4. 公開APIにはテストと型/doc を付ける。外部I/Oはモックする。
