resource "google_project" "n8n_project" {
  name       = local.project_name
  project_id = local.project_name
}

output "n8n_project_id" {
  value = google_project.n8n_project.project_id
}

output "n8n_project_number" {
  value = google_project.n8n_project.number
}
