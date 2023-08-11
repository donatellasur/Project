provider "google" {
  credentials = file("../../clever-oasis-395212-7b3da5dc7717.json")
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


resource "google_compute_network" "my_network" {
  name = "my-network"
}

resource "google_compute_subnetwork" "my_subnet" {
  name          = "my-subnet"
  network       = google_compute_network.my_network.id
  ip_cidr_range = "10.0.0.0/24"
}

resource "google_compute_firewall" "allow-http" {
  name    = "allow-http"
  network = google_compute_network.my_network.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
}