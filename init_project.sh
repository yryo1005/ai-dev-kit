#!/usr/bin/env bash
# =====================================================================================
# ai-dev-kit を用いたプロジェクトの初期化スクリプト
#
# 使い方（作業ディレクトリで実行する）:
#   bash <(curl -fsSL https://raw.githubusercontent.com/yryo1005/ai-dev-kit/main/init_project.sh)
#   bash <(curl -fsSL https://raw.githubusercontent.com/yryo1005/ai-dev-kit/main/init_project.sh) --tokens
#
# 処理内容:
#   1. git init（未初期化の場合）
#   2. .gitignore の作成・追記（既にある行は追加しない）
#   3. .ai/ 以下へのサブモジュールの追加（既にある場合は git submodule update --init）
#   4. CLAUDE.md，AGENTS.md，.vscode/settings.json のコピー（既にある場合は上書きしない）
#   5. .logs/，.orders/，.reports/ の作成と .orders/order_001.md の作成
#   6. (--tokens 指定時) tokens.json の復号
#
# 何度実行しても既存のファイルを壊さない（冪等）ように作成している．
# =====================================================================================
set -euo pipefail

# ---------------------------------------------------------------- 設定
GITHUB_BASE="https://github.com/yryo1005"
SUBMODULES=(ai-dev-kit ai-tex-kit ai-pptx-kit ai-agent pptx-render)
TOKENS_URL="${GITHUB_BASE}/ai-dev-kit/releases/download/v1.0.0/tokens.json.enc"

GITIGNORE_LINES=(
    "# API tokens"
    "tokens.json"
    "tokens.json.enc"
    "# Python"
    ".venv_*/"
    "__pycache__/"
    "*.py[cod]"
    "# Jupyter"
    ".ipynb_checkpoints/"
    "# Test"
    ".pytest_cache/"
    "# Machine Learning"
    "datasets/"
    "outputs/"
    "# VS Code"
    ".vscode/*"
    "!.vscode/settings.json"
    "# WSL"
    "*.Identifier"
)

# ---------------------------------------------------------------- 引数
WITH_TOKENS=0
FORCE=0
WITH_SUBMODULES=1

usage() {
    cat <<'EOF'
使い方: init_project.sh [オプション]

オプション:
  --tokens          tokens.json.enc をダウンロードし，tokens.json に復号する（パスワードの入力が必要）
  --force           CLAUDE.md，AGENTS.md，.vscode/settings.json を ai-dev-kit の最新版で上書きする
  --no-submodules   サブモジュールを追加しない（ファイルのコピー元となる .ai/ai-dev-kit は必要）
  -h, --help        このヘルプを表示する
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --tokens) WITH_TOKENS=1 ;;
        --force) FORCE=1 ;;
        --no-submodules) WITH_SUBMODULES=0 ;;
        -h|--help) usage; exit 0 ;;
        *) echo "不明なオプション: $1" >&2; usage; exit 1 ;;
    esac
    shift
done

info() { printf '\033[1;34m[init]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[warn]\033[0m %s\n' "$*" >&2; }

PROJECT_ROOT="$(pwd)"
if [[ "${PROJECT_ROOT}" == "${HOME}" ]]; then
    warn "ホームディレクトリで実行しようとしています．作業ディレクトリを作成し，その中で実行してください．"
    exit 1
fi
info "プロジェクトを初期化します: ${PROJECT_ROOT}"

# ---------------------------------------------------------------- 1. git init
if git -C "${PROJECT_ROOT}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    info "Gitリポジトリは初期化済みです．"
else
    git init
fi

# ---------------------------------------------------------------- 2. .gitignore
touch .gitignore
added=0
for line in "${GITIGNORE_LINES[@]}"; do
    if ! grep -qxF -- "${line}" .gitignore; then
        echo "${line}" >> .gitignore
        added=$((added + 1))
    fi
done
info ".gitignore に ${added} 行を追加しました．"

# ---------------------------------------------------------------- 3. サブモジュール
if [[ ${WITH_SUBMODULES} -eq 1 ]]; then
    mkdir -p .ai
    for name in "${SUBMODULES[@]}"; do
        path=".ai/${name}"
        if git config -f .gitmodules --get "submodule.${path}.url" >/dev/null 2>&1; then
            info "サブモジュール ${path} は登録済みです．"
        else
            info "サブモジュール ${path} を追加します．"
            git submodule add "${GITHUB_BASE}/${name}.git" "${path}"
        fi
    done
    git submodule update --init --recursive
fi

KIT_DIR=".ai/ai-dev-kit"
if [[ ! -d "${KIT_DIR}" ]]; then
    warn "${KIT_DIR} がありません．--no-submodules を外して実行してください．"
    exit 1
fi

# ---------------------------------------------------------------- 4. 設定ファイルのコピー
copy_file() {
    local src="$1" dst="$2"
    if [[ -e "${dst}" && ${FORCE} -eq 0 ]]; then
        info "${dst} は既に存在するためコピーしません（上書きする場合は --force）．"
        return
    fi
    mkdir -p "$(dirname "${dst}")"
    cp "${src}" "${dst}"
    info "${src} → ${dst} をコピーしました．"
}
copy_file "${KIT_DIR}/CLAUDE.md" "CLAUDE.md"
copy_file "${KIT_DIR}/AGENTS.md" "AGENTS.md"
copy_file "${KIT_DIR}/settings.json" ".vscode/settings.json"

# ---------------------------------------------------------------- 5. 作業用ディレクトリ
for dir in .logs .orders .reports; do
    mkdir -p "${dir}"
    # 空のディレクトリはGitで管理されないため .gitkeep を置く
    if [[ -z "$(ls -A "${dir}")" ]]; then
        touch "${dir}/.gitkeep"
    fi
done
if ! ls .orders/order_*.md >/dev/null 2>&1; then
    echo "" > .orders/order_001.md
    info ".orders/order_001.md を作成しました．ここにAIへの指示を記述してください．"
fi

# ---------------------------------------------------------------- 6. tokens.json
if [[ ${WITH_TOKENS} -eq 1 ]]; then
    if [[ -f tokens.json ]]; then
        info "tokens.json は既に存在します．"
    else
        info "tokens.json.enc をダウンロードして復号します．"
        wget -q -O tokens.json.enc "${TOKENS_URL}"
        if openssl enc -d -aes-256-cbc -pbkdf2 -iter 100000 -in tokens.json.enc -out tokens.json; then
            rm -f tokens.json.enc
            chmod 600 tokens.json
            info "tokens.json を作成しました．"
        else
            rm -f tokens.json
            warn "tokens.json の復号に失敗しました．パスワードを確認し，--tokens を付けて再実行してください．"
        fi
    fi
elif [[ ! -f tokens.json ]]; then
    warn "tokens.json がありません．APIを利用する場合はプロジェクトルートに配置してください．"
fi

# ---------------------------------------------------------------- 完了
cat <<EOF

$(info "初期化が完了しました．")
次の手順:
  1. ai-agent をコマンドとして使う場合は，次を実行してください（~/.bashrc への追記も可）．
       export PATH="\$PATH:${PROJECT_ROOT}/.ai/ai-agent/bin"
  2. .orders/order_001.md にAIへの指示を記述し，Claude Code に実行を依頼してください．
  3. 初期状態をコミットする場合:
       git add -A && git commit -m "Initialize project with ai-dev-kit"
EOF
