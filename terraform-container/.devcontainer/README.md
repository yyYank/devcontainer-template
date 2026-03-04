# terraform-container

Terraform 開発向けの devcontainer テンプレートです（`mise` で Terraform 管理）。

## 構成
- この `.devcontainer/` 配下にテンプレートファイルを集約
- `mise.container.toml`: コンテナ用ツールバージョン定義（コンテナ内では `mise.toml` としてマウント）
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

## ツールバージョン
`.devcontainer/mise.container.toml` の `terraform` / `tflint` / `trivy` / `node` を変更して管理します。

## プロジェクトへの配備
リポジトリルートで実行します。

```bash
make deploy from=terraform-container out=/path/to/your-project
```
