resource "google_project_service" "n8n_project_services" {
  project  = google_project.n8n_project.name
  for_each = toset(local.services)
  service  = each.value
}

locals {
  services = [
    # Cloud Run
    "run.googleapis.com",
    # Cloud SQL (データ永続化に利用)
    "sqladmin.googleapis.com",
    # Secret Manager
    "secretmanager.googleapis.com",
    # Identity-Aware Proxy (Cloud Run接続する際の認証に利用)
    "iap.googleapis.com",
    # Cloud Resource Manager (Terraformでプロジェクトを管理する際に利用)
    "cloudresourcemanager.googleapis.com",
    # Gmail API
    "gmail.googleapis.com",
    # Google Drive API
    "drive.googleapis.com",
    # Google Sheets API
    "sheets.googleapis.com",
    # Google Docs API
    "docs.googleapis.com",
    # Google Calendar API
    "calendar-json.googleapis.com",
    # Google Tasks API
    "tasks.googleapis.com",
  ]
}