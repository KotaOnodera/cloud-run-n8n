# Store the database password in Secret Manager
resource "google_secret_manager_secret" "n8n_db_password_secret" {
  secret_id = "n8n-db-password"
  project   = local.project_id

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "n8n_db_password_secret_version" {
  secret      = google_secret_manager_secret.n8n_db_password_secret.id
  secret_data = random_password.db_password.result
}

# Store the encryption key in Secret Manager
resource "google_secret_manager_secret" "n8n_encryption_key_secret" {
  secret_id = "n8n-encryption-key"
  project   = local.project_id

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "n8n_encryption_key_secret_version" {
  secret      = google_secret_manager_secret.n8n_encryption_key_secret.id
  secret_data = random_password.encryption_key.result
}