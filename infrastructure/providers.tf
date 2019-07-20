provider "google" {
  credentials = file(var.gcp_credentials_path)

  project     = var.project_id
  region      = "australia-southeast1"
  zone        = "australia-southeast1-a"

  version     = "~> 2.10.0"
}
