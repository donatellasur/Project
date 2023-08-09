provider "google" {
  credentials = "D:\\Important Stuff\\Computacenter\\Proiect\\clever-oasis-395212-7b3da5dc7717.json"
  project = "clever-oasis-395212"
  region = "europe-west1"
}

resource "google_container_cluster" "gke_cluster" {
  name     = "my-gke-cluster"
  location = "europe-west1-b"
  initial_node_count = 3
}

resource "google_sql_database_instance" "my_database" {
  name             = "my-database-instance"
  database_version = "MYSQL_8_0"

  settings {
    tier = "db-f1-micro"
    backup_configuration {
      enabled = true
    }
    deletion_protection_enabled = false
  } 
}

# resource "kubernetes_horizontal_pod_autoscaler" "hpa" {
#   metadata {
#     name = "my-gke-cluster-hpa"
#     namespace = "default"  # Replace with your desired namespace if needed
#   }

#   spec {
#     max_replicas = 5
#     min_replicas = 2
#     scale_target_ref {
#       kind = "Deployment"
#       name = google_container_cluster.gke_cluster.name
#       api_version = "apps/v1"
#     }

#     target_cpu_utilization_percentage = 50
#   }
# }