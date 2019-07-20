terraform {
  backend "gcs" {
    bucket = "tf-state-japple-minecraft"
    prefix = "state/"
  }
}

