# Enman Rails API

Rails 8 製の REST API サーバーです。**OpenAPI ドリブン開発**を採用しており、`api/` 配下の YAML を唯一の真実 (Single Source of Truth) として、コントローラの雛形を自動生成します。

---

## 技術スタック

| 項目 | 内容 |
| :--- | :--- |
| 言語 | Ruby（`Gemfile` で管理） |
| フレームワーク | Rails 8 |
| DB | SQLite（開発 / テスト） |
| API 仕様 | OpenAPI 3.0.3 |
| コード生成 | `openapitools/openapi-generator-cli`（Docker）＋ 自作 Rake タスク |
| コンテナ | Docker Compose |
| API サーバーポート | `localhost:1234` |

---

## 開発環境セットアップ

### 前提条件

- Docker Desktop が起動していること
- `make` コマンドが使えること

### 初回セットアップ（推奨）

```bash
make setup
```

内部では以下を実行します。

1. `make gen` — OpenAPI CLI（Docker）で `api/resolved/openapi/openapi.yaml` を生成
2. `docker compose run --rm app` — `bundle install`, `db:create`, `db:migrate` を実行

### サーバー起動

```bash
docker compose up
```

起動後は `http://localhost:1234` でアクセスできます。

---

## OpenAPI ドリブン開発フロー

このプロジェクトでは API 仕様（YAML）を先に書き、コントローラを自動生成する流れを取ります。

```
api/OpenAPI.yaml          # ルート定義（各パスを $ref で参照）
api/paths/*.yaml          # エンドポイントごとの操作定義
        │
        │  make gen
        ▼
api/resolved/openapi/openapi.yaml   # $ref を解決した単一 YAML（自動生成・コミット不要）
        │
        │  make code-gen
        ▼
app/controllers/generated/*_base_controller.rb   # ベースクラス（毎回上書き・編集禁止）
app/controllers/*_controller.rb                  # 実装クラス（初回のみ生成・以降は手動編集）
config/routes/openapi.rb                         # ルーティング（自動生成）
```

### 新しいエンドポイントを追加する手順

```bash
# 1. api/paths/ にパスファイルを作成する
#    ファイル名: パスの / と {} を _ に置換
#    例: /admin/users/{id} → api/paths/admin__users__id.yaml

# 2. api/OpenAPI.yaml の paths セクションに $ref を追記する

# 3. resolved YAML を再生成する
make gen

# 4. コントローラ・ルーティングを生成する
make code-gen

# 5. app/controllers/*_controller.rb の各アクションに実装を書く
```

> **注意:** `app/controllers/generated/` 配下は毎回上書きされます。直接編集しないでください。

---

## make コマンド一覧

| コマンド | 内容 |
| :--- | :--- |
| `make gen` | OpenAPI CLI（Docker）で `api/resolved/` を生成する |
| `make code-gen` | Rake タスクでコントローラ・ルーティングを生成する |
| `make gen-all` | `gen` → `code-gen` を順に実行する |
| `make setup` | `gen` → Docker 上で `bundle install` + `db:create` + `db:migrate` を実行する |

---

## ファイル構成（主要部）

```
api/
├── OpenAPI.yaml              # ルート OpenAPI 定義
├── paths/                    # エンドポイント定義（$ref の参照元）
└── resolved/openapi/         # 自動生成された単一 YAML（編集不要）

app/
├── controllers/
│   ├── generated/            # 自動生成ベースクラス（編集禁止）
│   └── *_controller.rb       # 実装クラス（手動編集）
├── serializers/
│   ├── generated/            # 自動生成ベースシリアライザー（編集禁止）
│   └── *_serializer.rb       # 実装シリアライザー（手動編集）

lib/
├── openapi/
│   ├── code_generator.rb     # コード生成ロジック本体
│   └── README.md             # コード生成の詳細ドキュメント
├── tasks/
│   └── generate_controllers.rake
└── templates/openapi/        # ERB テンプレート

config/routes/
└── openapi.rb                # 自動生成ルーティング
```

---

## テスト実行

```bash
docker compose run --rm app bin/rails test
```

---

## 参考ドキュメント

- `lib/openapi/README.md` — コード生成の詳細な仕組み・制約・拡張案
- `api/resolved/README.md` — resolved YAML について
