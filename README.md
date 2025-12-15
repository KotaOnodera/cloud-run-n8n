# n8n on Google Cloud Run

このプロジェクトは、**n8n**（オープンソースのワークフロー自動化ツール）を **Google Cloud Run** 上で動作させるための **Terraform 構成**です。  
Cloud SQL（PostgreSQL）をバックエンドデータベースとして使用し、Secret Manager による安全なシークレット管理を行います。

---

## 構成概要

### ディレクトリ構成

```
project/
 ├─ project.tf        # GCPプロジェクトの作成
 ├─ config.tf         # Terraform設定
 └─ variables.tf      # プロジェクト変数定義

n8n/
 ├─ cloud_run.tf      # Cloud Run サービス定義
 ├─ cloud_sql.tf      # Cloud SQL (PostgreSQL) 構成
 ├─ secret.tf         # Secret Manager シークレット定義
 ├─ iam.tf            # IAMロールとサービスアカウント設定
 ├─ config.tf         # Terraform設定
 └─ variables.tf      # n8n用変数定義
```

---

## セットアップ手順

### 前提条件

- Google Cloud SDK (`gcloud`) がインストール済み
- Terraform v1.14.0 以上
- GCP プロジェクト作成権限を持つアカウント

---

## 利用方法

### 1. 変数の設定

Terraform 実行前に、以下のファイル内の変数を編集してください。

#### `project/variables.tf`

```hcl
locals {
  project_name = "YOUR-PROJECT-NAME"  # GCPプロジェクト名
}
```

#### `n8n/variables.tf`

```hcl
locals {
  location       = "YOUR-LOCATION"                  # 例: asia-northeast1
  n8n_host       = "YOUR-N8N-CLOUD-RUN-HOST"        # Cloud Runのホスト名 ('https://'を削除したもの)
  n8n_base_url   = "YOUR-N8N-CLOUD-RUN-URL"         # Cloud RunのURL
  n8n_access_user_email = ["YOUR-N8N-ACCESS-USER-EMAIL"]  # アクセス許可するユーザーのメール
}
```

### 2. Terraform 初期化と適用

```bash
cd project
terraform init
terraform apply
```

これにより、n8n 用の GCP プロジェクトが作成されます。

### 3. n8n インフラ構築

```bash
cd ../n8n
terraform init
terraform apply
```

これにより以下が自動的に構築されます：

- Cloud SQL (PostgreSQL)
- Secret Manager シークレット（DBパスワード、暗号化キー）
- Cloud Run サービス（n8nコンテナ）
- サービスアカウントとIAM設定

---

## 環境変数

Cloud Run サービスには以下の環境変数が設定されます：

| 変数名 | 説明 |
|--------|------|
| `N8N_HOST` | Cloud Run サービスのホスト名 |
| `WEBHOOK_URL` | WebhookのベースURL |
| `N8N_EDITOR_BASE_URL` | エディタUIのURL |
| `DB_TYPE` | データベース種別（postgresdb） |
| `DB_POSTGRESDB_DATABASE` | データベース名 |
| `DB_POSTGRESDB_USER` | DBユーザー名 |
| `DB_POSTGRESDB_PASSWORD` | Secret Managerから取得 |
| `DB_POSTGRESDB_HOST` | Cloud SQL接続パス |
| `N8N_ENCRYPTION_KEY` | Secret Managerから取得 |
| `GENERIC_TIMEZONE` | JST |

---

## デプロイ後のアクセス

Terraform 実行後、Cloud Run のURLが出力されます。  
ブラウザでアクセスすると n8n のエディタ画面が表示されます。
Cloud Run内のコンテナが起動するまで約30秒ほどかかるため、30秒ほど経過してからリロードしてください。
(`http://localhost:5678`というログが出力されれば起動完了です。)

---

## クリーンアップ

すべてのリソースを削除するには以下を実行します：

```bash
terraform destroy
```
