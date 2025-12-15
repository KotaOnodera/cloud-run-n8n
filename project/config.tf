terraform {
  required_version = ">= 1.14.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 7.0.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 7.0.0"
    }
  }
}

provider "google" {
  user_project_override = true
  region                = local.location
}

terraform {
  backend "local" {
    path = "./state.tfstate"
  }
}