# devcontainer templates

このリポジトリは、複数の devcontainer テンプレートを配備するためのテンプレート集です。

## テンプレート
- `go-node-container`: Go + Node.js 向け
- `typescript-node-container`: TypeScript + Node.js 向け（`mise` で Node 管理）

## 使い方
テンプレートを任意のプロジェクトへコピーします。

```bash
make list
make deploy OUT=/Users/yy_yank/typescript-project
make deploy TEMPLATE=go-node-container OUT=/Users/yy_yank/go-project
```

## 補足
- `TEMPLATE` のデフォルトは `typescript-node-container`
- `OUT` は必須
- 各テンプレートの `.devcontainer/` 配下に個別 README があります
- 各 devcontainer は再ビルド後に `docker` コマンドを利用できます
