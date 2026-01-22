terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

provider "google" {
  credentials = file("../gcp-credentials.json")
  project     = var.project_id
  region      = var.region
}

resource "google_compute_network" "spark_network" {
  name                    = var.network_name
  auto_create_subnetworks = false
  description             = "Private network for Spark cluster"
}

resource "google_compute_subnetwork" "spark_subnet" {
  name          = "${var.network_name}-subnet"
  region        = var.region
  ip_cidr_range = var.subnet_cidr
  network       = google_compute_network.spark_network.id
  description   = "Subnet for Spark nodes"
}

# FIREWALL: SSH Access
# terraform/main.tf

# FIREWALL: SSH Access
resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.network_name}-allow-ssh"
  network = google_compute_network.spark_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = [var.my_ip]

  target_tags = ["edge-node"] 
}

# ============================================
# FIREWALL: Spark Communication
# ============================================
# Opens ports for Spark components to talk to each other:
#   - 7077: Spark Master (workers connect here)
#   - 8080: Spark Master Web UI (you can see cluster status)
#   - 8081: Spark Worker Web UI
#   - 4040: Spark Application UI (when jobs run)
resource "google_compute_firewall" "allow_spark" {
  name    = "${var.network_name}-allow-spark"
  network = google_compute_network.spark_network.name

  allow {
    protocol = "tcp"
    ports    = ["7077", "8080", "8081", "4040"]
  }

  source_ranges = [var.my_ip]
  target_tags   = ["spark"]
}


# FIREWALL: Internal Communication
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.network_name}-allow-internal"
  network = google_compute_network.spark_network.name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = [var.subnet_cidr]

}

# Master Instance
resource "google_compute_instance" "spark_master" {
  name         = "spark-master"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 20
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.spark_subnet.id
    access_config {

    }
  }

  tags = ["spark"]

  metadata = {
    enable-oslogin = "TRUE"
    spark-role     = "master"
  }

  labels = {
    role    = "master"
    cluster = "spark-main"
  }

}

# Worker Instances (Dynamic Scaling)
resource "google_compute_instance" "spark_worker" {
  count        = var.worker_count
  name         = "spark-worker-${count.index + 1}"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 20
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.spark_subnet.id
    access_config {}
  }

  tags = ["spark"]

  metadata = {
    enable-oslogin = "TRUE"
    spark-role     = "worker"
  }
}

# Edge Node (Submission Node)
resource "google_compute_instance" "spark_edge" {
  name         = "spark-edge"
  machine_type = "e2-medium" # Can be smaller, but e2-medium is fine
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 20
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.spark_subnet.id
    access_config {}
  }

  tags = ["spark", "edge-node"]

  metadata = {
    enable-oslogin = "TRUE"
    spark-role     = "edge"
  }
}

# Storage Node (NFS Server)
resource "google_compute_instance" "spark_storage" {
  name         = "spark-storage"
  machine_type = "e2-medium" # Can be e2-small to save money, but medium is safe
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 20
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.spark_subnet.id
    # We give it a public IP so Ansible can install the NFS server software
    access_config {}
  }

  tags = ["spark"]

  metadata = {
    enable-oslogin = "TRUE"
    spark-role     = "storage"
  }
}
