# 環境構築に関する規約

## APIトークン
- GeminiやHugging Face HubなどのAPIトークンは，プロジェクトルートの `tokens.json` に格納されています．
- APIを利用する必要がある場合は，`tokens.json` の存在と必要なトークンを確認してください．
- `tokens.json` が存在しない場合は，ユーザーに警告してください．
- `tokens.json` の内容をコード，ログ，レポート等に直接記録しないでください．
- `tokens.json` は必ず `.gitignore` に追加してください．


## Python仮想環境

### 基本方針
- Pythonの仮想環境は `uv` で管理してください．
- 仮想環境を作成する前に，OS，CPU，GPU，CUDA，Python等の実行環境を確認してください．
- 確認した実行環境に基づき，互換性のあるPythonおよびライブラリのバージョンを決定してください．
- `uv` がインストールされているか確認し，インストールされていない場合はインストールしてください．
- 複数の仮想環境を作成する場合があるため，仮想環境のディレクトリ名は `.env_{環境名}` としてください．
- 例えば，PyTorchを使用する機械学習環境の場合は `.env_pytorch` とします．

### 依存ライブラリ
- 使用するライブラリとそのバージョンを `requirements_{環境名}.txt` に*必ず*記述してください．
- 仮想環境へのライブラリのインストールは，原則として `requirements_{環境名}.txt` に基づいて行ってください．
- 既存の `requirements_{環境名}.txt` が存在する場合は，内容を確認してから環境を構築してください．
- ライブラリのバージョンを変更する場合は，変更理由と互換性を確認してください．
- Pythonのバージョンについても，使用するライブラリとの互換性を確認してください．

### Jupyter
プログラムを `ipynb` ファイルで実行する場合があるため，すべてのPython環境に以下のライブラリをインストールしてください．
```text
ipykernel
jupyter
nbconvert
```
仮想環境をJupyterのカーネルとして使用できるよう設定してください．

### VS Code
`uv` で作成した仮想環境がVS Codeから認識されるよう，プロジェクトルートの `.vscode/settings.json` に以下を記述してください．
```json
{
    "python.venvPath": "${workspaceFolder}"
}
```
`.vscode/settings.json` が存在しない場合は作成してください．

## Git

### `.gitignore`
以下のような，Gitで管理する必要がないファイルやディレクトリは `.gitignore` に追加してください．
```gitignore
# Python
.env_*/
__pycache__/
*.py[cod]

# Jupyter
.ipynb_checkpoints/

# Machine Learning
datasets/
outputs/

# API tokens
tokens.json

# VS Code
.vscode/
```

ただし，`.vscode/settings.json` はプロジェクトの環境設定としてGitで管理するため，`.vscode/` 全体を除外する場合は，以下のように例外を設定してください．
```gitignore
.vscode/*
!.vscode/settings.json
```

### Git LFS
大容量ファイルをGitで管理する必要がある場合は，Git LFSの利用を検討してください．
特に以下のようなファイルをGitで管理する場合はGit LFSを使用してください．
```text
*.pth
*.pt
*.ckpt
*.onnx
*.bin
*.safetensors
```

ただし，実験結果やデータセットについては，原則としてGit管理の対象外としてください．

## 環境構築の手順
環境構築を行う場合は，原則として以下の順序で実施してください．

1. OS，CPU，GPU，CUDA等のハードウェア・ソフトウェア環境を確認する．
2. `tokens.json` の存在を確認する．
3. `uv` のインストール状態を確認する．
4. 必要なPythonバージョンを決定する．
5. `.env_{環境名}` に仮想環境を作成する．
6. `requirements_{環境名}.txt` を作成または確認する．
7. `requirements_{環境名}.txt` に基づいてライブラリをインストールする．
8. `ipykernel`，`jupyter`，`nbconvert` がインストールされていることを確認する．
9. `.vscode/settings.json` を作成または確認する．
10. PyTorch等を使用する場合は，GPU，CUDA，cuDNNとの互換性を確認する．
11. PythonからGPUが利用可能であることを確認する．
12. 必要なライブラリをimportできることを確認する．
13. 環境構築が完了したら，使用したPythonおよび主要ライブラリのバージョンを確認する．
