resource "google_cloud_run_v2_service" "n8n" {
  provider             = google-beta
  name                 = "n8n"
  project              = local.project_id
  location             = local.location
  launch_stage         = "BETA"
  iap_enabled          = true
  default_uri_disabled = false
  deletion_protection  = false
  description          = "n8n Cloud Run"
  ingress              = "INGRESS_TRAFFIC_ALL"
  template {
    service_account = google_service_account.n8n_service_account.email
    volumes {
      name = "cloudsql"
      cloud_sql_instance {
        instances = [google_sql_database_instance.n8n_db_instance.connection_name]
      }
    }
    containers {
      image   = "n8nio/n8n:latest"
      command = ["/bin/sh"]
      args    = ["-c", "sleep 5; n8n start"]
      ports {
        container_port = 5678
      }
      resources {
        cpu_idle = false
        limits = {
          cpu    = "1000m"
          memory = "2Gi"
        }
        startup_cpu_boost = true
      }
      startup_probe {
        failure_threshold     = 1
        initial_delay_seconds = 30
        period_seconds        = 240
        timeout_seconds       = 240
        tcp_socket {
          port = 5678
        }
      }
      env {
        name  = "N8N_HOST"
        value = local.n8n_host
      }
      env {
        name  = "WEBHOOK_URL"
        value = local.n8n_base_url
      }
      env {
        name  = "N8N_EDITOR_BASE_URL"
        value = local.n8n_base_url
      }
      env {
        name  = "N8N_PORT"
        value = "5678"
      }
      env {
        name  = "N8N_PROTOCOL"
        value = "https"
      }
      env {
        name  = "DB_TYPE"
        value = "postgresdb"
      }
      env {
        name  = "DB_POSTGRESDB_DATABASE"
        value = google_sql_database.n8n_database.name
      }
      env {
        name  = "DB_POSTGRESDB_USER"
        value = google_sql_user.n8n_user.name
      }
      env {
        name  = "DB_POSTGRESDB_HOST"
        value = "/cloudsql/${google_sql_database_instance.n8n_db_instance.connection_name}"
      }
      env {
        name  = "DB_POSTGRESDB_PORT"
        value = "5432"
      }
      env {
        name  = "DB_POSTGRESDB_SCHEMA"
        value = "public"
      }
      env {
        name  = "GENERIC_TIMEZONE"
        value = "JST"
      }
      env {
        name  = "QUEUE_HEALTH_CHECK_ACTIVE"
        value = "true"
      }
      env {
        name = "DB_POSTGRESDB_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.n8n_db_password_secret.secret_id
            version = "latest"
          }
        }
      }
      env {
        name = "N8N_ENCRYPTION_KEY"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.n8n_encryption_key_secret.secret_id
            version = "latest"
          }
        }
      }
      volume_mounts {
        mount_path = "/cloudsql"
        name       = "cloudsql"
      }
    }
    scaling {
      max_instance_count = 2
      min_instance_count = 0
    }
  }
  traffic {
    percent = 100
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
  }
}

# Output the URL of the Cloud Run service
output "n8n_url" {
  value = google_cloud_run_v2_service.n8n.uri
}
