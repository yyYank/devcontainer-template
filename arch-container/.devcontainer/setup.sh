#!/bin/sh
set -eu

# 必要パッケージのインストール (Arch Linux)
SUDO=""
if command -v sudo >/dev/null 2>&1; then
  SUDO="sudo"
fi

$SUDO pacman -Syu --noconfirm --needed \
  ca-certificates curl git git-delta github-cli docker \
  zsh zsh-autosuggestions zsh-syntax-highlighting

# mise のインストール
curl -fsSL https://mise.run | sh

# ツールのインストール
MISE_CONFIG_FILE=.devcontainer/mise.toml ~/.local/bin/mise install

# npm グローバルパッケージのインストール
MISE_CONFIG_FILE=.devcontainer/mise.toml ~/.local/bin/mise exec -- sh -lc \
  'PATH="$HOME/.local/bin:$PATH"; npm config set prefix "$HOME/.npm-global" && npm install -g typescript ts-node @anthropic-ai/claude-code @openai/codex'
