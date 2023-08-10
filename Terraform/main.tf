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

# Define VPC Network
resource "google_compute_network" "my_network" {
  name = "my-network"
}

# Define Subnets
resource "google_compute_subnetwork" "frontend_subnet" {
  name          = "frontend-subnet"
  region        = "europe-west1"
  ip_cidr_range = "10.0.1.0/24"
  network       = google_compute_network.my_network.self_link
}

resource "google_compute_subnetwork" "backend_subnet" {
  name          = "backend-subnet"
  region        = "europe-west1"
  ip_cidr_range = "10.0.2.0/24"
  network       = google_compute_network.my_network.self_link
}

# Define Firewall Rules
resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = google_compute_network.my_network.self_link

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
}
# Define Google Cloud Storage bucket
resource "google_storage_bucket" "my_bucket" {
  name = "website2-bucket"
  location = "europe-west1"
}

# Define HTTP(S) Load Balancers
resource "google_compute_backend_bucket" "my_backend_bucket" {
  name        = "my-backend-bucket"
  bucket_name = google_storage_bucket.my_bucket.name
}

resource "google_compute_url_map" "my_url_map" {
  name    = "my-url-map"
  default_service = google_compute_backend_bucket.my_backend_bucket.self_link
}

# # Define the HTTP forwarding rule
# resource "google_compute_global_forwarding_rule" "http_rule" {
#   name       = "http-rule"
#   target     = google_compute_url_map.my_url_map.self_link
#   port_range = "80"
# }

# # Define the HTTPS forwarding rule
# resource "google_compute_global_forwarding_rule" "https_rule" {
#   name       = "https-rule"
#   target     = google_compute_url_map.my_url_map.self_link
#   port_range = "443"
# }