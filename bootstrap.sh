#!/usr/bin/env bash


# エラーがあったらそこで即終了、設定していない変数を使ったらエラーにする
set -eu

# is_arm という関数を用意しておく。毎回 uname -m を実行するのは莫迦らしいので、UNAME 環境変数で判断
is_arm() { test "$UNAME" = "arm64"; }

# アーキテクチャ名は UNAME に入れておく
UNAME=$(uname -m)

# dotfiles の場所を設定
DOTPATH=$HOME/dotfiles

# このフォルダの取り扱い
if [ ! -d "$DOTPATH" ]; then
  # 初回実行時はリポジトリがないので、clone してくる
  echo "Cloning dotfiles.git ..."
  git clone https://git@https://github.com/Akasak0/dotfiles "$DOTPATH"
else
  # すでにフォルダがある時はそのことを表示
  echo "$DOTPATH already downloaded."
fi

cd "$DOTPATH"

# ここにある dotfiles をホームに展開 (.git, .DS_Store は除外。他に除外するものが増えたらここに追記)
echo "Deploying dotfiles ..."
for file in .??*; do
    [[ "$file" = ".git" ]] && continue
    [[ "$file" = ".DS_Store" ]] && continue
    ln -fvns "$DOTPATH/$file" "$HOME/$file"
done

# 入っていなければ、コマンドライン・デベロッパツールをインストール
xcode-select -p 1>/dev/null || {
  echo "Installing Command line tools ..."
  xcode-select --install
  echo "Please exec ./bootstrap.sh again in $DOTPATH after installing command-line-tools."
  exit 1
}

# install homebrew
if ! command -v brew > /dev/null 2>&1; then
  echo "Installing homebrew ..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# homebrew, cask and mas
brew bundle -v

# Python のアップデート
PYTHON_VERSION=3.15.1

mise use -g python@${PYTHON_VERSION}
mise exec -- python3 -m pip install pytest pytest-cov numpy pandas openpyxl tk

# node のアップデート
NODE_VERSION=25.9.0

mise use -g node@${NODE_VERSION}
mise exec -- npm install -g chokidar-cli

# GCC のシンボリックリンクを作成
BREW_PREFIX=$(brew --prefix)
GCC_BIN="$BREW_PREFIX/bin"

gpp_path=$(
    find "$GCC_BIN" -maxdepth 1 -name 'g++-[0-9]*' -print |
    sort -V |
    tail -n 1
)

gcc_path=$(
    find "$GCC_BIN" -maxdepth 1 -name 'gcc-[0-9]*' -print |
    sort -V |
    tail -n 1
)

if [[ ! -x "$gcc_path" ]]; then
    echo "Error: GCC executable not found in $GCC_BIN" >&2
    exit 1
fi

ln -sfn "$gpp_path" "$GCC_BIN/g++"
ln -sfn "$gcc_path" "$GCC_BIN/gcc"

# AtCoder Library の導入
if [ ! -d "$HOME/src" ]; then
    mkdir -p "$HOME/src"
fi

if [ ! -d "$HOME/src/ac-library/" ]; then
    git clone https://github.com/atcoder/ac-library.git "$HOME/src/ac-library/"
fi

chmod 755 "$DOTPATH/scripts/a++"
if [ ! -d "$HOME/bin" ]; then
    mkdir -p "$HOME/bin"
    chmod 755 "$HOME/bin"
fi
cp "$DOTPATH/scripts/a++" "$HOME/bin"

# Countdown.app のアップデート
PREVIOUS_PATH=$(pwd)
if [ -d "$HOME/countdown" ]; then
    echo "Updating Countdown.app ..."
    
    # 更新の前に終了しておく
    osascript -e 'tell application "Countdown.app" to quit'

    # 前のディレクトリを記録してから移動
    cd "$HOME/countdown/"

    # 前のブランチを記録してから main に checkout
    PREVIOUS_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    git checkout main

    # 実際に情報を更新
    git pull origin main
    bash scripts/build-app.sh
    open dist/Countdown.app

    # 作業前の状態に戻す
    git checkout "$PREVIOUS_BRANCH"
else
    echo "Installing Countdown.app..."

    # クローンしてビルド
    git clone https://github.com/tuttu630tttu/countdown.git "$HOME/countdown"
    cd "$HOME/countdown"
    bash scripts/build-app.sh
fi
cd "$PREVIOUS_PATH"

