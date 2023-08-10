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

# ---------------------------------------------------pana aici a mers----------------------------------------------------------

# resource "google_compute_backend_service" "web-backend" {
#   name        = "web-backend"
#   port_name   = "http"
#   protocol    = "HTTP"
  
#   backend {
#     group = google_compute_instance_group.my_group.self_link
#   }
  
#   health_checks = [google_compute_http_health_check.web-health-check.self_link]
# }

# resource "google_compute_http_health_check" "web-health-check" {
#   name               = "web-health-check"
#   request_path       = "/"
#   port               = 80
#   check_interval_sec = 10
#   timeout_sec        = 5
#   unhealthy_threshold = 2
#   healthy_threshold   = 2
# }

# resource "google_compute_url_map" "web-map" {
#   name = "web-map"
  
#   default_url_redirect {
#     https_redirect = true
#     strip_query = true
#   }
# }

# resource "google_compute_ssl_certificate" "web-ssl-cert" {
#   name        = "web-ssl-cert"
#   certificate = filebase64("../../certificate.pfx")
#   # the key is already included with a self-signed ssl
#   private_key = filebase64("../../certificate.pfx")
# }

# resource "google_compute_target_https_proxy" "web-https-proxy" {
#   name              = "web-https-proxy"
#   ssl_certificates = [google_compute_ssl_certificate.web-ssl-cert.self_link]
#   url_map           = google_compute_url_map.web-map.self_link
# }

# resource "google_compute_global_forwarding_rule" "web-forwarding-rule" {
#   name        = "web-forwarding-rule"
#   target      = google_compute_target_https_proxy.web-https-proxy.self_link
#   port_range  = "443"
#   description = "Web forwarding rule"
# }