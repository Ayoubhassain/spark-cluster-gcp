
output "network_name" {
  description = "Name of the VPC network"
  value       = google_compute_network.spark_network.name
}

output "subnet_cidr" {
  description = "CIDR range of the subnet"
  value       = google_compute_subnetwork.spark_subnet.ip_cidr_range
}

output "master_name" {
  description = "Name of the master VM"
  value       = google_compute_instance.spark_master.name
}

output "master_internal_ip" {
  description = "Internal IP of master VM"
  value       = google_compute_instance.spark_master.network_interface[0].network_ip
}

output "master_external_ip" {
  description = "External IP of master VM (for SSH)"
  value       = google_compute_instance.spark_master.network_interface[0].access_config[0].nat_ip
}

output "worker_names" {
  description = "Names of worker nodes"
  value = [
    google_compute_instance.worker_1.name,
    google_compute_instance.worker_2.name
  ]
}

output "worker_internal_ips" {
  description = "Internal IPs of workers"
  value = [
    google_compute_instance.worker_1.network_interface[0].network_ip,
    google_compute_instance.worker_2.network_interface[0].network_ip
  ]
}

output "worker_external_ips" {
  description = "External IPs of workers"
  value = [
    google_compute_instance.worker_1.network_interface[0].access_config[0].nat_ip,
    google_compute_instance.worker_2.network_interface[0].access_config[0].nat_ip
  ]
}

output "ssh_command_master" {
  description = "Command to SSH into master"
  value       = "gcloud compute ssh ${google_compute_instance.spark_master.name} --zone=${var.zone}"
}

output "spark_master_ui" {
  description = "URL to access Spark Master Web UI"
  value       = "http://${google_compute_instance.spark_master.network_interface[0].access_config[0].nat_ip}:8080"
}


