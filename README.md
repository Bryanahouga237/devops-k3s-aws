# AWS Infrastructure & K3s Kubernetes Deployment

## 📋 Overview
This project demonstrates a complete DevOps workflow:
- **Infrastructure as Code (IaC)**: Automated AWS provisioning using Terraform.
- **Lightweight Kubernetes**: Installation and configuration of a K3s cluster.
- **Container Orchestration**: Deployment of a high-availability Nginx application.

## 🏗️ Technical Stack
* **Cloud**: AWS (EC2 t3.micro, VPC, Security Groups)
* **IaC**: Terraform
* **Orchestrator**: K3s
* **App**: Nginx (2 Replicas)

## 📁 Project Structure
* `/terraform`: AWS infrastructure configuration (`main.tf`).
* `/kubernetes`: Kubernetes manifests (`app.yaml`) including Deployment, Service (NodePort), and ConfigMap for custom HTML.

## 🚀 Quick Start
1. **Provision Infrastructure**:
   ```bash
   cd terraform && terraform init && terraform apply