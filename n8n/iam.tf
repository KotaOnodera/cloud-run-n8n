resource "google_cloud_run_v2_service_iam_member" "n8n_iap_invoker" {
  provider = google-beta
  project  = local.project_id
  location = google_cloud_run_v2_service.n8n.location
  name     = google_cloud_run_v2_service.n8n.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:service-${local.project_number}@gcp-sa-iap.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "n8n_iap_user_accessor" {
  project  = local.project_id
  role     = "roles/iap.httpsResourceAccessor"
  for_each = toset(local.n8n_access_user_email)
  member   = "user:${each.value}"
}

# Create a service account for the Cloud Run service
resource "google_service_account" "n8n_service_account" {
  account_id   = "n8n-service-account"
  display_name = "n8n Service Account"
  project      = local.project_id
}

# Grant the service account access to the database password secret
resource "google_secret_manager_secret_iam_member" "n8n_db_password_secret_accessor" {
  secret_id = google_secret_manager_secret.n8n_db_password_secret.secret_id
  project   = local.project_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.n8n_service_account.email}"
}

# Grant the service account access to the encryption key secret
resource "google_secret_manager_secret_iam_member" "n8n_encryption_key_secret_accessor" {
  secret_id = google_secret_manager_secret.n8n_encryption_key_secret.secret_id
  project   = local.project_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.n8n_service_account.email}"
}

# Grant the service account the Cloud SQL Client role
resource "google_project_iam_member" "n8n_cloudsql_client" {
  project = local.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.n8n_service_account.email}"
}
