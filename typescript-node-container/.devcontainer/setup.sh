#!/bin/sh
set -eu

# mise のインストール
curl -fsSL https://mise.run | sh

# mise の bash 設定
echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc

# ツールのインストール
MISE_CONFIG_FILE=.devcontainer/mise.toml ~/.local/bin/mise install

# npm グローバルパッケージのインストール
MISE_CONFIG_FILE=.devcontainer/mise.toml ~/.local/bin/mise exec -- sh -lc \
  'npm config set prefix "$HOME/.npm-global" && npm install -g typescript ts-node @anthropic-ai/claude-code @openai/codex'

# apt パッケージのインストール
sudo apt-get update
sudo apt-get install -y git-delta zsh-autosuggestions zsh-syntax-highlighting
