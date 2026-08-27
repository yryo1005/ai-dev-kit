# 機械学習プログラムに関する規約
- `@.ai/ai-dev-kit/environment_construction.md` の指示に基づき，仮想環境を作成してください
- プログラムの終了後，仕様書と実験結果をまとめたレポートを `@.ai/ai-dev-kit/documentation.md` の指示に基づき作成してください．
- 実験計画を考えるAIエージェント（`machine_learning`ドメイン）が未構築の場合は，`@.ai/ai-agent/README.md`に従いセットアップしてください．サブモジュールとして，あるいはプロジェクト内へ直接実装する形のいずれでもよい．
- `tokens.json`が無い場合はユーザにこれを警告してください．
- `tokens.json`は必ず`.gitignore`に追加してください．

---

# 実験の実施に関わる指示
AIの学習は一度の実行で必ずしもうまくいくわけではなく，データやモデル，ハイパーパラメータを変更して複数回実行することが考えられます．
これを想定してプログラムを記述，実験結果を保存してください．

## コードのモジュール化と実験ディレクトリ
- `model.py`，`data.py`， `train.py` は，実験ごとに以下の規則でディレクトリを作成して保存する．
  `programs/ex{n:03}_{全ての比較手法で共通の条件}/` （※ `n` は実験の通し番号）
  - 例1: `programs/ex001_mnist_cnn/`
  - 例2: `programs/ex002_cifar10_resnet/`

## 学習の実行
- プログラム終了後もログ（実行結果や出力）を残すために，学習は必ず各実験ディレクトリ内の `train.py` で実行する．
- ハイパーパラメータの探索空間や `seed` 数は `train.py` 内で指定する．
- 設定された `seed` 数の分だけ，すべてのハイパーパラメータの組み合わせについてループを回して学習を実行する．
- すでに正常終了した結果（ログファイルや重み）が存在する条件のフォルダがある場合は，その条件の学習をスキップする．
- 学習条件が多数にわたる場合，これをマルチプロセスで並列化して実施し，実験に要する時間を削減する．この際，並列数1で1回学習しその際のDRAM，VRAMの使用量に応じて並列化するプロセス数を変更する．
- グリッドサーチはネストが深くならないように，`itertools.product`を用いて実行する．

## 学習結果の保存規則
- 実験結果は以下のディレクトリ階層に厳格に従って保存する．
  `outputs/ex_{n:03}_{全ての比較手法で共通の条件}/{比較する手法}/{ハイパーパラメータ}/{seed}/` （※ `n` は実験の通し番号）
  - 例1: `outputs/ex001_mnist_cnn/Adam/0.001_32/0/`
  - 例2: `outputs/ex001_mnist_cnn/SGD/0.001_32/0/`
- 学習率やエポック数などの実験条件等のメタデータも同様のディレクトリに `json` ファイルとして保存する．
- 例では比較する手法は最適化手法となっているが，この限りではない．実験に応じ適切にこれを決定する．

## 学習結果の可視化 
- プロジェクトのルートディレクトリに，実験結果を可視化するための `visualize_result.ipynb` を実装する．
- `outputs/` ディレクトリ内を再帰的に走査し，同一条件における全 `seed` の結果から平均と標準偏差を計算し，平均値と標準偏差（エラーバーや塗りつぶし）を含めてプロットする．
- `visualize_result.ipynb` はプログラムの実行終了後，必ず実行しAIエージェントの実行が終わった時点で `outputs/` ディレクトリに可視化結果を保存してください．
- 人間が容易に可視化したい比較手法やハイパーパラメータを，プログラム上の変数やリストで指定・選択できるように設計する．
- 複数の実験条件にまたがって可視化する場合があるため，これに対応したプログラムを記述する．
- `matplotlib` でグラフを作成する際は，原則として正方形（例: `figsize=(5, 5)`）にする．ただし，文字やラベルがはみ出るなどの問題がある場合は，視認性を最優先して適切なサイズに調整する．
- 可視化した結果は，`outputs/` ディレクトリ内の該当する実験のディレクトリに保存する．

---
### **重要** 仕様書・レポートの作成
下記の要求は必ず満たしてください
- すべての実験が終了した後に，これまでに実施した実験の内容や条件，実験結果（グラフや考察）をまとめた `.reports/report.md` を作成すること．
- 作成するプログラムの指示が，`.orders/order_{k}.md`の様に通し番号がある場合，作成するレポートのファイル名を `.reports/report_{k}.md`とする．
- 実験の終了後ユーザーがAIエージェントに次の実験計画を考えさせるかどうかを判断します．そのため，実験終了後AIエージェントの実行コマンドをユーザーに提示してください．
- レポートを作成する際は`@.ai/ai-dev-kit/documentation.md`を必ず参照してください．

---

# 外部モジュール仕様
※ 以下の機械学習で使用する関数およびクラスは，事前に `@.ai/ai-dev-kit/src/machine_learning_utils.py` に定義されています．
同様の機能の関数およびクラスは定義せず，これらを利用してください．

## set_seed 関数
- **概要**: 実験の再現性を担保するための関数．
- **引数**: `seed (int) = 0`
- **戻り値**: なし
- **処理**: Python，NumPy，PyTorch，CUDAのseed値を固定する．CUDA等の処理を決定論的になるよう設定する．

## ResultLogger クラス
- **概要**: 実験中の各種メトリクス（Loss，Accuracyなど）の推移をメモリ上に記録し，JSONファイルとして保存・読み込みを行うための軽量なロガークラス．
- **初期化 (__init__)**:
  - 引数: `target_path (str) = None`
  - 処理: 記録する指標名を管理する `names` と，履歴データを保持する辞書 `history` を初期化する．`target_path` が指定された場合は，自動的に過去のログファイルを読み込む（`load` メソッドを実行）．
- **set_names メソッド**:
  - 概要: 記録したい指標の名前を登録する．
  - 引数: `*names (str)` （例: "loss", "accuracy"）
  - 例外: すでに `names` が登録されている場合は例外を発生させる．
  - 処理: 引数で受け取った名前のリストを作成し，`history` 辞書にそれぞれの空のリストを用意する．すでに存在する指標名がある場合は初期化をスキップする．
- **__call__ メソッド**:
  - 概要: インスタンスを関数のように呼び出し，指標の値を履歴に追加（append）する．
  - 引数: `*values (float/int)`
  - 例外: `set_names` が未実行の場合，または渡された値の数が登録された指標の数と一致しない場合は例外を発生させる．
  - 処理: 登録されている指標名と，渡された値を順番にペア（`zip`）にし，対応する履歴リストの末尾に値を追加する．
- **save メソッド**:
  - 概要: 記録された履歴（`history`）をJSONファイルとして保存する．
  - 引数: `target_path (str)`
- **load メソッド**:
  - 概要: 保存されたJSONファイルから履歴データを読み込む．
  - 引数: `target_path (str)`
  - 処理: JSONファイルから辞書データを読み込み，`history` に格納する．また，辞書のkeyのリストを `names` に自動設定する．
- **__getitem__ メソッド**:
  - 概要: 辞書のようにブラケット `[]` を使って，特定の指標の履歴リストを取得する．
  - 引数: `key (str)`
  - 戻り値: `list` （指定した指標の履歴リスト．存在しない場合は空のリスト `[]` を返す）

---

# 実装すべき共通関数・クラス仕様
AIの学習のプログラムは，データセットの定義，モデルの定義，学習ループの定義の3ブロックに分けられます．
下記の指示に従い，それぞれを定義してください．

## データセットの定義に関するブロック
- データセットを作る際の元データは`datasets/`フォルダ内に格納されています．
- 自然言語モデルで単語の最小出現回数を変更する，のように同じ元データを異なる前処理で複数のデータセットを作成する場合があります．これを踏まえて，下記の規則に則りデータセットを保存してください
  `datasets/ex{n:03}_{全ての比較手法で共通の条件}/{比較する手法}/`（※ `n` は実験の通し番号）
  - 例1: `datasets/ex001_mnist_cnn/no_augment/`
  - 例2: `datasets/ex001_mnist_cnn/rotate/`
- データセットの作成や，データローダ―の読み込み等のデータセットに関わるプログラムは `data.py` に定義してください．

### load_dataloader 関数
- **概要**: 学習/検証用のデータローダーをインスタンス化するための関数．
- **引数**: `seed (int) = 0`
- **戻り値**: `train_dataloader (torch.utils.data.DataLoader)`, `test_dataloader (torch.utils.data.DataLoader)`
- **処理**: 
  - 独自のデータセットの場合，`sklearn.model_selection.train_test_split` を用い，`random_state` に `seed` を指定し，データセットを学習用データと検証用データがが9:1になるよう分割する．
  - `seed` を引数として `set_seed` 関数を実行し，データの並びの初期値を固定する．
  - `seed` を指定した `torch.Generator` を用いてデータのシャッフルを決定論的にする．


## モデルの定義に関するブロック
モデルの作成や，モデルの読み込み等のデータセットに関わるプログラムは `model.py` に定義してください．

### load_model 関数
- **概要**: モデルをインスタンス化するための関数．
- **引数**: `ModelClass (torch.nn.Moduleのクラス)`, `weight_path (str) = None`, `seed (int) = 0`
- **戻り値**: `model (torch.nn.Module)`
- **処理**: 
  - `seed` を引数として `set_seed` 関数を実行し，パラメータの初期値を固定する．
  - `ModelClass` をインスタンス化する．
  - `weight_path` が `None` でない場合，`weight_path` のパラメータをモデルに読み込む．


## 学習ループの定義に関するブロック
学習ループの作成や，誤差関数，評価関数などの学習ループに関わるプログラムは `train.py` に定義してください．

### loss_func 関数
- **概要**: モデルの出力と教師信号の誤差を計算する関数．
- **引数**: `outputs (torch.Tensor)`（モデルの出力）, `teacher_signals (torch.Tensor)`（教師信号）
- **戻り値**: `loss (torch.Tensor)`
- **処理**: 
  - `outputs` と `teacher_signals` の誤差 `loss` を計算する（誤差関数はタスクに応じて定める）．
  - 引数は `torch.Tensor` としているが，必要に応じてこれを変更する．
  - 誤差の総和をデータ数で割った，1データあたりの誤差の平均を計算する．

### metrics_func 関数
- **概要**: モデルの出力と教師信号の一致度を評価する関数．
- **引数**: `outputs (torch.Tensor)`（モデルの出力）, `teacher_signals (torch.Tensor)`（教師信号）
- **戻り値**: `metrics_to_value (dict)` （評価指標の名前がkey，値がvalueの辞書）
- **処理**: 
  - `outputs` と `teacher_signals` の一致度を評価する（評価指標は Accuracy, Perplexity などタスクに応じて定める）．
  - 引数は `torch.Tensor` としているが，必要に応じてこれを変更する．
  - 評価の総和をデータ数で割った，1データあたりの評価の平均を計算する．
  - 誤差（Loss）は `iteration` 関数内の `loss_func` 関数で計算するため，この関数内では計算しない．

### iteration 関数
- **概要**: 1つのミニバッチのデータを学習/検証する関数．
- **引数**: `model (torch.nn.Module)`, `inputs (torch.Tensor)`, `teacher_signals (torch.Tensor)`, `optimizer (torch.optim.Optimizer) = None`
- **戻り値**: `metrics_to_value (dict)` （誤差と評価指標の名前がkey，値がvalueの辞書）
- **処理**: 
  - モデルの出力（`outputs`）を計算する．
  - `loss_func` を用いて誤差を計算する．
  - `optimizer` が `None` ではない場合，勾配を計算し最適化手法でパラメータを更新する．
  - `metrics_func` を用いて評価を計算する．
  - 誤差と評価の項目がkey，それぞれの値がvalueの辞書を作成して返す． 

### epoch 関数
- **概要**: 1つのデータローダーの全データを学習/検証する関数．
- **引数**: `model (torch.nn.Module)`, `dataloader (torch.utils.data.DataLoader)`, `optimizer (torch.optim.Optimizer) = None`
- **戻り値**: `metrics_to_value (dict)` （1データあたりの評価・誤差の平均値の辞書）
- **処理**: 
  - この関数の中で `iteration` 関数を呼び出す．
  - `dataloader` を繰り返し条件，`(inputs, teacher_signals)` を繰り返し変数とするループを回す．
  - `model` のデバイスを確認し，`inputs` と `teacher_signals` を同じデバイスに移動させる．
  - `iteration` 関数を実行する．戻り値はミニバッチ内の平均値であるため，ミニバッチのデータ数を掛け合わせて総和に戻し，エポック全体の合計に累積する．
  - `tqdm` の進捗バーに，その反復時点における1データあたりの評価・誤差の平均値を出力する．
  - 全ミニバッチ終了後，評価・誤差の合計を全データ数で割り，1データあたりの平均値を計算して返す．

### train 関数
- **概要**: モデルを学習する関数．
- **引数**: `target_dir (str)`（結果保存先ディレクトリ）, `ModelClass (torch.nn.Moduleのクラス)`, `load_dataloader (func)`, `epochs (int)`, `batch_size (int)`, `seed (int) = 0`
- **戻り値**: なし
- **処理**: 
  - この関数の中で `epoch` 関数を呼び出す．
  - 引数としてモデルや最適化手法，データセットなどのハイパーパラメータなどを受け取る場合はこれを1つずつ引数とするのではなく辞書にまとめ，`train` 関数内でそれぞれの引数にしていする．
  - `seed`, `batch_size` を引数として `load_dataloader` 関数を実行する．
  - `seed` を引数として `load_model` 関数を実行する．
  - GPUが使用できるか確認し，使用できる場合は `model` をGPUに移動させる．
  - `ResultLogger` を変数名 `logger` としてインスタンス化する（学習・検証データの各種メトリクス名を設定）．
  - **0エポック目（初期状態）**: 学習は行わず，初期値での学習用・検証用データに対する誤差・評価を取得して `logger` に記録する．
  - `epochs` の回数だけ `epoch` 関数による学習および検証を実行する．
  - 各エポック終了後，それぞれの結果を出力する．
  - 各エポック終了後，それぞれの結果を `logger.__call__` に与えて記録する．
  - 各エポック終了後，特定の評価（例: Validation Accuracy）が過去すべての反復において最も優れているか確認し，最高値を更新した場合は `model` の重みを保存する．

---

# ディレクトリ構造の例
```text
./
├── .ai/
│   ├── ai-agent/
│   │   ├── core/
│   │   ├── research/
│   │   ├── machine_learning/
│   │   ├── development/
│   │   ├── documentation/
│   │   └── slide/
│   ├── ai-dev-kit/
│   │   ├── root_prompt.md
│   │   ├── machine_learning.md
│   │   ├── environment_construction.md
│   │   ├── document.md
│   │   └── src/
│   │       └── machine_learning_utils.py
│   ├── ai-tex-kit/
│   └── ai-pptx-kit/
│
├── .venv_{環境名}/
│
├── .logs/
├── .orders/
├── .reports/
│
├── programs/
│   └── ex001_mnist_cnn/
│       ├── model.py
│       ├── data.py
│       ├── train.py
│       └── visualize_result.ipynb
│
├── datasets/
│   └── ex001_mnist_cnn/
│       ├── no_augment/
│       └── augment/
│
├── outputs/
│   └── ex001_mnist_cnn/
│       ├── SGD/
│       │   ├── 0.001_32/
│       │   │   ├── 0/
│       │   │   │   ├── best_model.pth
│       │   │   │   └── log.json
│       │   │   ├── 1/
│       │   │   │   ├── best_model.pth
│       │   │   │   └── log.json
│       │   │   └── 2/
│       │   │       ├── best_model.pth
│       │   │       └── log.json
│       │   │
│       │   └── 0.01_64/
│       │       └── ...
│       │
│       └── Adam/
│           ├── 0.001_32/
│           │   └── ...
│           └── 0.01_64/
│               └── ...
│
├── visualize_result.ipynb
│
├── document.md
├── tokens.json
├── .gitignore
└── requirements_{環境名}.txt
```