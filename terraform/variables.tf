
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 2
}

variable "my_ip" {
  description = "Personal IP (only IP that can ssh into the master node)"
  type = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "europe-west9"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "europe-west9-b"
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
  default     = "spark-vpc"
}

variable "subnet_cidr" {
  description = "CIDR range for subnet (256 IP addresses)"
  type        = string
  default     = "10.0.0.0/24"
}

variable "machine_type" {
  description = "VM machine type"
  type        = string
  default     = "e2-medium"
}

variable "ansible_user" {
  description = "SSH user for Ansible (from GCP OS Login)"
  type        = string
  default     = "mpsi_mekkaoui_ossama_moussa_gmai"
}
