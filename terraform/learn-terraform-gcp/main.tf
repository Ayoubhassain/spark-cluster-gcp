terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.8.0"
    }
  }
}

provider "google" {
  project = var.project
#   region  = "us-central1"
  region = var.region
#   zone    = "us-central1-c"
  zone = var.zone 
}

resource "google_compute_network" "vpc" {
  name = "terraform-network"
}

resource "google_compute_instance" "vm_instance" {
  name = "terraform-instance"
  machine_type = "f1-micro"
  tags = ["web", "dev"]

  boot_disk {
    initialize_params {
    #   image = "debian-cloud/debian-11"
        image = "cos-cloud/cos-stable"
    }
  }

  network_interface {
    network = google_compute_network.vpc.name
    access_config {
    }
  }
}




