# Three-Tier Web Application Deployment on AWS EKS using Terraform, AWS EKS, ArgoCD, Prometheus, Grafana, and Jenkins

![Three-Tier Banner](assets/Three-Tier.gif)

# step 1: deploying EKS cluster on AWS using Terraform and Jenkins pipeline

1. By following modular approach, derived terraform configuration files to create a vpc with three public and three private subnets in three availability zones, an EKS cluster with AWS managed node group which is accessible only from within the cluster which will be deployed only in private subnets, and a jump server with ssh-key based authentication disabled. please refer to the folder **Jenkins-Server-TF/AWS_EKS**


