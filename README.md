# devcontainer templates

このリポジトリは、複数の devcontainer テンプレートを配備するためのテンプレート集です。

## テンプレート
- `go-node-container`: Go + Node.js 向け
- `typescript-node-container`: TypeScript + Node.js 向け（`mise` で Node 管理）
- `terraform-container`: Terraform 向け（`mise` で Terraform 管理）

## 使い方
テンプレートを任意のプロジェクトへコピーします。

```bash
make list
make deploy out=/Users/yy_yank/typescript-project
make deploy from=go-node-container out=/Users/yy_yank/go-project
make deploy from=terraform-container out=/Users/yy_yank/terraform-project
```

## 補足
- `from` のデフォルトは `typescript-node-container`
- `out` は必須
- 各テンプレートの `.devcontainer/` 配下に個別 README があります
- 各 devcontainer は再ビルド後に `docker` コマンドを利用できます
