# Enman Rails API

Rails 8 製の REST API サーバーです。**OpenAPI ドリブン開発**を採用しており、`api/` 配下の YAML を唯一の真実 (Single Source of Truth) として、コントローラ・シリアライザの雛形を自動生成します。

---

## 技術スタック

| 項目 | 内容 |
| :--- | :--- |
| 言語 | Ruby（`Gemfile` で管理） |
| フレームワーク | Rails 8 |
| DB | PostgreSQL（Docker Compose で起動） |
| API 仕様 | OpenAPI 3.0.3 |
| コード生成 | `openapitools/openapi-generator-cli`（Docker）＋ 自作 Rake タスク |
| 認証 | JWT（`jwt` gem / `Authorization: Bearer <token>`） |
| シリアライザ | Alba |
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

## 秘匿情報の管理

DB 接続情報・JWT シークレット・暗号化キーはすべて **Rails credentials** で管理します。  
`.env` ファイルや環境変数は使いません。

```bash
make credentials-show   # 現在の credentials を表示
make credentials-edit   # vim で credentials を編集
```

credentials の構成：

```yaml
secret_key_base: ...
jwt_secret: ...

db:
  host: db
  username: enman
  password: password
  database_development: enman_development
  database_test: enman_test
  database_production: enman_production

active_record_encryption:
  primary_key: ...
  deterministic_key: ...
  key_derivation_salt: ...
```

> `config/master.key` がすべての credentials を復号する鍵です。  
> `.gitignore` に含まれているため、チームメンバーには別途共有してください。

---

## OpenAPI ドリブン開発フロー

このプロジェクトでは API 仕様（YAML）を先に書き、コントローラ・シリアライザを自動生成する流れを取ります。

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
app/controllers/generated/*_base_controller.rb     # ベースクラス（毎回上書き・編集禁止）
app/controllers/*_controller.rb                    # 実装クラス（初回のみ生成・以降は手動編集）
app/serializers/generated/**/*_base_serializer.rb  # ベースシリアライザ（毎回上書き・編集禁止）
app/serializers/**/*_serializer.rb                 # 実装シリアライザ（初回のみ生成・以降は手動編集）
config/routes/openapi.rb                           # ルーティング（自動生成）
```

### 新しいエンドポイントを追加する手順

```bash
# 1. api/paths/ にパスファイルを作成する
#    ファイル名: パスの / と {} を _ に置換
#    例: /admin/users/{id} → api/paths/admin__users__id.yaml

# 2. api/OpenAPI.yaml の paths セクションに $ref を追記する

# 3. resolved YAML を再生成する
make gen

# 4. コントローラ・シリアライザ・ルーティングを生成する
make code-gen

# 5. app/controllers/*_controller.rb の各アクションに実装を書く
```

> **注意:** `app/controllers/generated/` および `app/serializers/generated/` は毎回上書きされます。直接編集しないでください。

---

## 認証

JWT ベースの Bearer 認証を採用しています。

1. `POST /auth/signup` または `POST /auth/login` でトークンを取得
2. 以降のリクエストに `Authorization: Bearer <token>` ヘッダーを付与

認証が必要なエンドポイントは `before_action :authenticate_user!` を付けます。

```ruby
class SomeController < Generated::SomeBaseController
  before_action :authenticate_user!

  def index
    # current_user でログインユーザーを参照できる
  end
end
```

---

## make コマンド一覧

| コマンド | 内容 |
| :--- | :--- |
| `make gen` | OpenAPI CLI（Docker）で `api/resolved/` を生成する |
| `make code-gen` | Rake タスクでコントローラ・シリアライザ・ルーティングを生成する |
| `make gen-all` | `gen` → `code-gen` を順に実行する |
| `make setup` | `gen` → Docker 上で `bundle install` + `db:create` + `db:migrate` を実行する |
| `make db-create` | DB を作成する |
| `make db-migrate` | マイグレーションを実行する |
| `make db-setup` | `db-create` → `db-migrate` を順に実行する |
| `make credentials-show` | credentials の内容を表示する |
| `make credentials-edit` | vim で credentials を編集する |

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
├── models/
│   ├── tenant.rb             # テナントモデル（signup! クラスメソッド）
│   └── user.rb               # ユーザーモデル（JWT発行・認証・login!）
├── serializers/
│   ├── generated/            # 自動生成ベースシリアライザー（編集禁止）
│   └── *_serializer.rb       # 実装シリアライザー（手動編集）

config/
├── credentials.yml.enc       # 暗号化された秘匿設定（master.key で復号）
├── master.key                # 復号キー（.gitignore 済み・チーム内で共有）
└── routes/
    └── openapi.rb            # 自動生成ルーティング

lib/
├── openapi/
│   ├── code_generator.rb     # コード生成ロジック本体
│   ├── parser.rb             # OpenAPI スペックのパーサー
│   └── generators/           # コントローラ・シリアライザ・ルーティング生成
└── templates/openapi/        # ERB テンプレート
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
