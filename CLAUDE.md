# Project Instructions

作業開始時には，以下の手順を必ず実行してください．

1. `@.ai/ai-dev-kit/root_prompt.md` を読み込む．
2. ユーザーのタスクの種類を判定する．
3. タスクに該当する追加規約を読み込む．
4. 追加規約の内容を確認した後に作業を開始する．

追加規約の読み込みが完了するまで，ファイルの作成・変更やプログラムの実行を開始してはいけません．

なお，git clone等でリポジトリを複製した際に，
サブモジュールが空で `@.ai/ai-dev-kit/root_prompt.md` が存在しない場合があります．
その場合は，下記のコマンドでサブモジュールを同期してください
```bash
git submodule sync --recursive
git submodule update --init --recursive --force
```