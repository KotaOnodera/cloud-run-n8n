locals {
  project_id     = data.terraform_remote_state.project.outputs.n8n_project_id
  project_number = data.terraform_remote_state.project.outputs.n8n_project_number
  location       = "YOUR-LOCATION"
  n8n_host       = "YOUR-N8N-CLOUD-RUN-HOST"
  n8n_base_url   = "YOUR-N8N-CLOUD-RUN-URL"

  n8n_access_user_email = [
    "YOUR-N8N-ACCESS-USER-EMAIL"
  ]
}

data "terraform_remote_state" "project" {
  backend = "local"
  config = {
    path = "../project/state.tfstate"
  }
}