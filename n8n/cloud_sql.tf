# Create a random password for the database user
resource "random_password" "db_password" {
  length  = 16
  special = true
}

# Create a random encryption key
resource "random_password" "encryption_key" {
  length  = 42
  special = true
}

# Create the Cloud SQL for PostgreSQL instance
resource "google_sql_database_instance" "n8n_db_instance" {
  name             = "n8n-db"
  database_version = "POSTGRES_13"
  region           = local.location
  project          = local.project_id

  settings {
    tier              = "db-f1-micro"
    availability_type = "ZONAL"
    disk_size         = 10
    disk_type         = "PD_HDD"
    backup_configuration {
      enabled = false
    }
  }

  deletion_protection = false
}

# Create the n8n database
resource "google_sql_database" "n8n_database" {
  name     = "n8n"
  project  = local.project_id
  instance = google_sql_database_instance.n8n_db_instance.name
}

# Create the n8n database user
resource "google_sql_user" "n8n_user" {
  name     = "n8n-user"
  project  = local.project_id
  instance = google_sql_database_instance.n8n_db_instance.name
  password = random_password.db_password.result
}