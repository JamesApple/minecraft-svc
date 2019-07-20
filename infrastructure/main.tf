data "google_project" "minecraft" {
  project_id = var.project_id
}

resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
}

resource "google_project_service" "stackdriver" {
  service = "stackdriver.googleapis.com"
}

resource "google_project_service" "monitoring" {
  service = "monitoring.googleapis.com"
}


resource "google_project_service" "iam" {
  service = "iam.googleapis.com"
}

resource "google_storage_bucket" "tf-state" {
  name     = "tf-state-${data.google_project.minecraft.project_id}"
  location = "australia-southeast1"

  versioning {
    enabled = true
  }
}

data "google_compute_image" "debian_image" {
  family  = "debian-9"
  project = "debian-cloud"
}

resource "google_compute_instance" "default" {
  depends_on   = [google_project_service.compute]
  name         = "main"
  machine_type = "n1-standard-2"

  tags = ["app"]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.debian_image.self_link
    }
  }

  attached_disk {
    source      = google_compute_disk.app-server.self_link
    device_name = google_compute_disk.app-server.name
    mode        = "READ_WRITE"
  }

  metadata = {
    ssh-keys = "jamesapple:${file("~/.ssh/id_rsa.pub")}"
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.app-server.address
    }
  }

  service_account {
    email  = google_service_account.app-server.email
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_address" "app-server" {
  name = "app-server"
}


resource "google_service_account" "app-server" {
  depends_on   = [google_project_service.iam]
  account_id   = "app-server"
  display_name = "Minecraft App Server"
}


resource "google_compute_disk" "app-server" {
  name = "app-server"
  type = "pd-ssd"
  size = "50"
}

output "static_ip" {
  value = google_compute_address.app-server.address
}

resource "google_project_iam_member" "app-logging" {
  role   = "roles/logging.logWriter"
  member = "serviceAccount:${google_service_account.app-server.email}"
}

resource "google_compute_firewall" "allow-app-access" {
  name    = "allow-app-access"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["25565"]
  }

  target_tags = ["app"]
}


data "template_file" "ansible_hosts" {
  template = "${file("${path.module}/templates/hosts.cfg")}"
  vars = {
    app_ips = join("\n", [google_compute_address.app-server.address]),
  }
}

resource "null_resource" "ansible-hosts" {
  triggers = {
    template = data.template_file.ansible_hosts.rendered
  }

  provisioner "local-exec" {
    command = <<HOSTS
    echo '${data.template_file.ansible_hosts.rendered}' > ansible_hosts
    HOSTS
  }
}

output "disk-name" {
  value = google_compute_disk.app-server.name
}
