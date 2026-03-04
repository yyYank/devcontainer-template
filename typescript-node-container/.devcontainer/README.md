# typescript-node-container

TypeScript + Node.js 開発向けの devcontainer テンプレートです（`mise` で Node 管理）。

## 構成
- この `.devcontainer/` 配下にテンプレートファイルを集約
- `mise.container.toml`: コンテナ用 Node.js バージョン定義（コンテナ内では `mise.toml` としてマウント）
- `Makefile`: devcontainer 操作用ヘルパー

## 使い方
`.devcontainer` ディレクトリで実行します。

```bash
make up
make up FORCE=1
make zsh
make bash
make rebuild
```

リポジトリルートから実行する場合は `-f` で指定できます。

```bash
make -f .devcontainer/Makefile up
make -f .devcontainer/Makefile up FORCE=1
make -f .devcontainer/Makefile zsh
make -f .devcontainer/Makefile bash
make -f .devcontainer/Makefile rebuild
```

`docker` コマンドを使う場合は、feature 反映のため `make rebuild` を実行してください。

## Node バージョン
`.devcontainer/mise.container.toml` の `node` を変更して管理します。

## プロジェクトへの配備
リポジトリルートで実行します。

```bash
make deploy TEMPLATE=typescript-node-container OUT=/path/to/your-project
```
