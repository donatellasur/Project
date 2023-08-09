provider "google" {
  credentials = file("../clever-oasis-395212-7b3da5dc7717.json")
  project     = "clever-oasis-395212"
  region      = "europe-west1"
}
resource "google_container_cluster" "gke_cluster" {
  name               = "my-gke-cluster"
  location           = "europe-west1-b"
  initial_node_count = 3
}

resource "google_sql_database_instance" "my_database" {
  name             = "my-database"
  database_version = "MYSQL_8_0"
  region           = "europe-west1"

  settings {
    tier = "db-f1-micro"
    backup_configuration {
      enabled = true
    }
  }
   deletion_protection = false
}

resource "google_compute_network" "my_project_network" {
  name = "my-network"
}

resource "google_compute_subnetwork" "subnet" {
  name          = "my-subnet"
  region        = "europe-west1"
  network       = google_compute_network.my_project_network.self_link
  ip_cidr_range = "10.0.0.0/24"
}

resource "google_compute_firewall" "allow-http" {
  name    = "allow-http"
  network = google_compute_network.my_project_network.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
}
resource "google_compute_instance_template" "my_instance_template" {
  name = "my-instance-template"
  machine_type = "n1-standard-1"  # Adjust as needed

  # Configure boot disk options
  disk {
    source_image = "projects/debian-cloud/global/images/debian-10-buster-v20230711"  # Use a valid image
    auto_delete  = true
  }

  # Define the container spec
  lifecycle {
    create_before_destroy = true
  }

  network_interface {
    network = google_compute_network.my_project_network.id
    subnetwork = google_compute_subnetwork.subnet.id
  }
}

resource "google_compute_instance_group_manager" "gke_instance_group_manager" {
  name             = "gke-instance-group-manager"
  base_instance_name = "gke-instance"
  zone             = "europe-west1-b"
  target_size      = 2

  version {
    instance_template = google_compute_instance_template.my_instance_template.self_link
  }
}

resource "google_compute_global_forwarding_rule" "http-rule" {
  name       = "http-rule"
  target = google_compute_instance_group_manager.gke_instance_group_manager.instance_group
  port_range = "80"
}

resource "google_compute_backend_service" "backend-service" {
  name = "backend-service"

  protocol = "HTTP"

  backend {
    group = google_compute_instance_group_manager.gke_instance_group_manager.instance_group
  }

  health_checks = [google_compute_http_health_check.health-check.self_link]
}


resource "google_compute_http_health_check" "health-check" {
  name = "health-check"
}