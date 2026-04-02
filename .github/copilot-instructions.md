# Copilot Instructions

## プロジェクト概要

- **名称**: Enman Rails API
- **フレームワーク**: Rails 8（API モード）
- **言語**: Ruby
- **DB**: SQLite（開発 / テスト）
- **API ポート**: `localhost:1234`
- **開発スタイル**: OpenAPI ドリブン開発（YAML が唯一の真実）
- **コンテナ**: Docker Compose

---

## 開発フロー（OpenAPI ドリブン）

新しいエンドポイントを追加・変更する際は、**必ずこの順序**で作業する。

### Step 1 — OpenAPI YAML を書く

`api/paths/` に新しいパスファイルを作成し、`api/OpenAPI.yaml` に `$ref` を追記する。

```
api/
├── OpenAPI.yaml          ← paths セクションに $ref を追記
└── paths/
    └── <new_path>.yaml   ← 新しいエンドポイントの定義を書く
```

**ファイル名規則**: パスの `/` と `{` `}` を `_` に置換する。  
例: `/admin/users/{id}` → `admin__users__id.yaml`

### Step 2 — `make gen` で resolved YAML を生成する

```bash
make gen
# Docker で openapi-generator-cli を実行し、
# api/resolved/openapi/openapi.yaml（$ref 解決済み単一ファイル）を生成する
```

> Docker が起動していない場合はエラーになる。

### Step 3 — `make code-gen` でコントローラ・ルーティングを生成する

```bash
make code-gen
# bundle exec rake openapi:generate_code を実行する
# 生成物:
#   app/controllers/generated/*_base_controller.rb  ← 毎回上書き（編集禁止）
#   app/controllers/*_controller.rb                 ← 初回のみ生成（以降は手動編集）
#   config/routes/openapi.rb                        ← ルーティング（自動生成）
```

特定リソースのみ生成したい場合:
```bash
bundle exec rake openapi:generate_code[users]
```

### Step 4 — 実装クラスにロジックを書く

`app/controllers/*_controller.rb` の各アクションに実装を追加する。  
`app/controllers/generated/` は**絶対に手動編集しない**（`make code-gen` で上書きされる）。

---

## make コマンド早見表

| コマンド | 内容 |
| :--- | :--- |
| `make gen` | OpenAPI CLI（Docker）で resolved YAML を生成 |
| `make code-gen` | Rake でコントローラ・ルーティングを生成 |
| `make gen-all` | `gen` → `code-gen` を連続実行 |
| `make setup` | `gen` → Docker 上で `bundle install` + `db:create` + `db:migrate` |

---

## ファイル構成（重要箇所）

```
api/
├── OpenAPI.yaml              # ルート定義（ここに $ref を追記する）
├── paths/                    # エンドポイントごとの YAML（ここを編集する）
└── resolved/openapi/         # 自動生成（コミット不要・編集禁止）

app/controllers/
├── generated/                # 自動生成ベースクラス（編集禁止）
└── *_controller.rb           # 実装クラス（ここにロジックを書く）

app/serializers/
├── generated/                # 自動生成ベースシリアライザー（編集禁止）
└── *_serializer.rb           # 実装シリアライザー（ここを編集する）
```

---

## 開発プロセス（Step-by-Step）

- **分割統治**: 一度に巨大な機能を実装せず、動作可能な最小単位（1機能、1関数）で提案すること。
- **合意形成**: 実装を始める前に、まず「これから行う実装のステップ」を箇条書きで提示し、私の承認を得ること。
- **インクリメンタル**: 各ステップが完了するたびに、ビルドとテストが通る状態を維持すること。
- **コード品質**: コードは読みやすく、保守しやすいものにすること。冗長なコードや複雑なロジックは避けること。
- **OpenAPI ファースト**: 実装より先に `api/paths/*.yaml` を書くこと。コントローラを直接作成しないこと。
