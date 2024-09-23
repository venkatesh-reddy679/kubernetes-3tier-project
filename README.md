# Three-Tier Web Application Deployment on AWS EKS using Terraform, AWS EKS, ArgoCD, Prometheus, Grafana, and Jenkins

![Three-Tier Banner](assets/Three-Tier.gif)

## step 1: deploying EKS cluster on AWS using Terraform and Jenkins pipeline

By following modular approach, derived terraform configuration files to 

(pass the inputs in terraform.tfvars, and backend-config.tfvars in **Jenkins-Server-TF/AWS_EKS/dev** folder)

-> use AWS S3 backend to store the resource state information. created an s3 bucket and dynamodb table for state locking and passed the information in the file **Jenkins-Server-TF/AWS_EKS/dev/backend-config.tfvars**

-> create a vpc with three public and three private subnets in three availability zones
   
-> an EKS cluster with AWS managed node group which is accessible only from within the cluster which will be deployed only in private subnets

-> a jump server with ssh-key based authentication disabled. connect to the jump server using sessions manager. Installing the required tools like aws cli, eksctl, helm, and kubectl by passing the start-up script to the jump server using file **Jenkins-Server-TF/AWS_EKS/module/ec2/user-data.sh**

### settign up the jenkins server

A Jenkins server is an automation tool used for continuous integration (CI) and continuous delivery (CD) in software development. It helps automate the process of building, testing, and deploying code changes, ensuring that code quality is maintained and deployment is consistent. Jenkins integrates with various tools and platforms through plugins, supports defining workflows as code, and can scale across multiple machines to handle large workloads. It is widely used to improve development efficiency and ensure early detection of issues.
setup:
1. Install the required version of java as jenkins is built in java and run on Java Virtual Machine (JVM)
    1. sudo apt update
    2. sudo apt -get install openjdk-17-jdk
   
    ![image](https://github.com/venkatesh-reddy679/Board_Game-CI-CD/assets/60383183/c01b7211-ebb6-47fb-8871-4a9954220068)
   
2. Install jenkins
    1. sudo apt install apt-transport-https -y
    2. wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo apt-key add -
    3. sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
    4. sudo apt update
    5. sudo apt install jenkins -y
    6. sudo systemctl start jenkins
    7. sudo systemctl enable jenkins
    and the jenkins server is exposed on port 8080 by default. Make sure to keep the port open on the virtual machine and on firewall if any
   
   ![image](https://github.com/venkatesh-reddy679/Board_Game-CI-CD/assets/60383183/685691ab-91d0-4b55-9644-a64d40d6cab1)
   
   retrieve the password from the given file, proceed with installation of required plugins, and create first admin user.
   
   ![image](https://github.com/venkatesh-reddy679/Board_Game-CI-CD/assets/60383183/63a27b55-b43a-4414-80e2-01189d9d880f)

3. Install Docker on the same jenkins server to run sonarqube and nexus repository as docker containers.
    1. sudo apt-get update
    2. sudo apt-get install ca-certificates curl
    3. sudo install -m 0755 -d /etc/apt/keyrings
    4. sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    5. sudo chmod a+r /etc/apt/keyrings/docker.asc
    6. echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    7. sudo apt-get update
    8. sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
       
    ![image](https://github.com/venkatesh-reddy679/Board_Game-CI-CD/assets/60383183/3b500ba5-53ad-458b-bb86-69afb39809cc)

    to enable any user like jenkins user to run the docker commands as the root user, like creating containers, deleting containers, etc.
   
    ![image](https://github.com/venkatesh-reddy679/Board_Game-CI-CD/assets/60383183/869cae3c-fadf-4474-842c-9336eaff5dff)

Install the below mentioned plugins . go to manage jenkins -> plugins -> available plugins
1. nodejs
2. sonarqube-scanner (tool to perform automatic code review)
3. terraform
4. docker
5. docker pipeline
6. OWASP (for dependency check)
7. AWS credentials (to store aws access key ID and secret access key)
8. AWS steps (to setup environment to interact with AWS api)


To use the third-party tools installed as plugins in the jenkins pipelines, Configure the installed plugins as tools in manage jenkins -> tools

![image](https://github.com/user-attachments/assets/fc6340a5-86eb-4c33-91ad-23c71c3d7bf8)
![image](https://github.com/user-attachments/assets/316ef025-5547-4274-a2b1-30388712d7e6)
![image](https://github.com/user-attachments/assets/2ebc56f5-99d1-451f-adf5-898df1aed1cb)
![image](https://github.com/user-attachments/assets/4974f49f-8f06-4757-809c-d8e23ec888a8)









