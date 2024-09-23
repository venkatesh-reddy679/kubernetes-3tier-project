# Three-Tier Web Application Deployment on AWS EKS using Terraform, AWS EKS, ArgoCD, Prometheus, Grafana, and Jenkins

![Three-Tier Banner](assets/Three-Tier.gif)

# step 1: deploying EKS cluster on AWS using Terraform and Jenkins pipeline

By following modular approach, derived terraform configuration files to (pass the inputs in terraform.tfvars, and backend-config.tfvars in dev folder)

-> use AWS S3 backend to store the resource state information. created an s3 bucket and dynamodb table for state locking and passed the information in the file **Jenkins-Server-TF/AWS_EKS/dev/backend-config.tfvars**

-> create a vpc with three public and three private subnets in three availability zones
   
-> an EKS cluster with AWS managed node group which is accessible only from within the cluster which will be deployed only in private subnets

-> a jump server with ssh-key based authentication disabled. connect to the jump server using sessions manager. Installing the required tools like aws cli, eksctl, helm, and kubectlpasing the start-up script to the jump server using file **Jenkins-Server-TF/AWS_EKS/module/ec2/user-data.sh**


