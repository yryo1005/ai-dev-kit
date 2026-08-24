import os
import json
import numpy as np
import random
import torch

class ResultLogger:
    def __init__(self, target_path = None):
        self.names = None
        self.history = {}

        if target_path:
            self.load(target_path)

    def set_names(self, *names):
        if self.names:
            raise

        self.names = list(names)
        for name in self.names:
            if name not in self.history:
                self.history[name] = []

    def __call__(self, *values):
        if self.names is None:
            raise
        if len(values) != len(self.names):
            raise

        for name, value in zip(self.names, values):
            self.history[name].append(value)

    def save(self, target_path):
        with open(target_path, "w") as f:
            json.dump(self.history, f, indent=4)

    def load(self, target_path):
        with open(target_path, "r") as f:
            data = json.load(f)
            self.history = data
            self.names = list(data.keys())

    def __getitem__(self, key):
        return self.history.get(key, [])

""" ResultLoggerの使用例
from utils import ResultLogger

# 1. ロガーの初期化と指標の登録
logger = ResultLogger()
logger.set_names("train_loss", "train_acc", "val_loss", "val_acc")

# 2. 訓練ループ内での記録
for epoch in range(epochs):
    # --- 訓練や検証の処理（平均値の計算など） ---
    t_loss, t_acc = 0.42, 0.85
    v_loss, v_acc = 0.45, 0.83
    
    # 関数のようによびだして値を記録（登録した順番通りに値を渡す）
    logger(t_loss, t_acc, v_loss, v_acc)

# 3. 実験結果の保存
logger.save("outputs/experiment_log.json")

# 4. 後からグラフを描画したい時などの読み込み
past_logger = ResultLogger("outputs/experiment_log.json")
train_losses = past_logger["train_loss"] # 履歴リストを直感的に取得

"""

def set_seed(seed=0):
    random.seed(seed)
    np.random.seed(seed)
    os.environ["PYTHONHASHSEED"] = str(seed)
    torch.manual_seed(seed)
    torch.cuda.manual_seed_all(seed)

    torch.backends.cudnn.deterministic = True
    torch.backends.cudnn.benchmark = False

    os.environ["CUBLAS_WORKSPACE_CONFIG"] = ":4096:8"

    torch.use_deterministic_algorithms(True)