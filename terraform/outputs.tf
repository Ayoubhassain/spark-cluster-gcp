
output "network_name" {
  description = "Name of the VPC network"
  value = google_compute_network.spark_network.name
}

output "subnet_cidr" {
  description = "CIDR range of the subnet"
  value = google_compute_subnetwork.spark_subnet.ip_cidr_range
}

output "test_vm_name" {
  description = "Name of the test VM"
  value = google_compute_instance.test_vm.name
}

output "test_vm_internal_ip" {
  description = "Internal IP of test VM"
  value = google_compute_instance.test_vm.network_interface[0].network_ip
}

output "test_vm_external_ip" {
  description = "External IP of test VM (for SSH)"
  value = google_compute_instance.test_vm.network_interface[0].access_config[0].nat_ip
}

output "ssh_command" {
  description = "Command to SSH into test VM"
  value = "gcloud compute ssh ${google_compute_instance.test_vm.name} --zone=${var.zone}"
}


