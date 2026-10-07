# spark-cluster-gcp

Automated deployment of an Apache Spark cluster on Google Cloud, from bare infrastructure to a running job.

One command provisions the machines and the network with Terraform, then Ansible installs and configures Java, Spark and a shared NFS storage. The cluster is validated with a WordCount benchmark.

## What it does

- **Provision:** creates the VMs and a private subnet on GCP with Terraform, so worker nodes are not exposed to the internet.
- **Configure:** installs Java and Spark, sets up the master and workers, and mounts a shared NFS volume with Ansible.
- **Run:** submits a WordCount job to the cluster.
- **Measure:** compares execution time with one and two executors.

## Architecture

| Component | Role |
|---|---|
| Terraform | VMs, VPC, private subnet, firewall rules |
| Ansible | Java, Spark, NFS server and clients |
| Spark master | Schedules jobs on the workers |
| Spark workers | Run executors, isolated in the private subnet |
| NFS | Shared storage for input data and results |

```
terraform apply ──> GCP VMs + private subnet
        │
        ▼
ansible-playbook ──> Java + Spark + NFS
        │
        ▼
spark-submit WordCount ──> results on NFS
```

## Results

| Executors | WordCount execution time |
|---|---|
| 1 | 28 s |
| 2 | 19 s |

<!-- Add the dataset size used for the benchmark if you have it -->

## Project structure

```
terraform/      # infrastructure: VMs, VPC, private subnet, firewall
ansible/        # playbooks: Java, Spark master/workers, NFS
scripts/        # helper scripts to deploy and run the cluster
tests/          # WordCount job and benchmark
rapport.pdf     # project report (French)
```

## Getting started

**Prerequisites:** a GCP project, Terraform, Ansible, and a service account key (never commit it).

```bash
cd terraform
terraform init
terraform apply

cd ../ansible
ansible-playbook -i inventory site.yml
```
<!-- Replace with your exact commands -->

## What I learned

Writing infrastructure as code end to end, isolating compute nodes in a private network, and making a cluster reproducible from a single command.

## Context

Team project, ENSEEIHT, Infrastructure and Big Data major. Built with @MEKKAOUIOssamaMoussa.
