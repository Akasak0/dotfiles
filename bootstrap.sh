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
PYTHON_VERSION=3.14.3

mise use -g python@${PYTHON_VERSION}
mise exec -- python3 -m pip install pytest pytest-cov numpy pandas openpyxl tk

# node のアップデート
NODE_VERSION=25.9.0

mise use -g node@${NODE_VERSION}
mise exec -- npm install -g chokidar-cli

# gcc のシンボリックリンクの作成
gcc_path=$(
    find /opt/homebrew/bin -maxdepth 1 -type f -name 'g++-[0-9]*' |
    sort -V |
    tail -n 1
)

if [[ -z "$gcc_path" || ! -x "$gcc_path" ]]; then
    echo "Error: GCC executable not found" >&2
    exit 1
fi

ln -sfn "$gcc_path" /opt/homebrew/bin/g++

