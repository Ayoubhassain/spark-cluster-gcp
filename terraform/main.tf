terraform {
  required_providers {
    google = {
        source = "hashicorp/google"
        version = "~> 6.0"
    }
  }
}

provider "google" {
  credentials = file("../gcp-credentials.json")
  project = var.project_id
  region = var.region
}

resource "google_compute_network" "spark_network" {
  name = var.network_name
  auto_create_subnetworks = false
  description = "Private network for Spark cluster"
}

resource "google_compute_subnetwork" "spark_subnet" {
  name = "${var.network_name}-subnet"
  region = var.region
  ip_cidr_range = var.subnet_cidr
  network = google_compute_network.spark_network.id
  description = "Subnet for Spark nodes"
}

# FIREWALL: SSH Access
resource "google_compute_firewall" "allow_ssh" {
  name = "${var.network_name}-allow-ssh"
  network = google_compute_network.spark_network.name

  allow {
    protocol = "tcp"
    ports = ["22"]
  }

  source_ranges = ["0.0.0.0/0"] # temporaire
  target_tags = ["spark"]

}

# FIREWALL: Spark Communication
resource "google_compute_firewall" "allow_internal" {
  name = "${var.network_name}-allow-internal"
  network = google_compute_network.spark_network.name
  
  allow {
    protocol = "tcp"
    ports = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = [var.subnet_cidr]

}

# Testing Instance
resource "google_compute_instance" "test_vm" {
  name = "spark-test-vm"
  machine_type = var.machine_type
  zone = var.zone

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
  }

}



