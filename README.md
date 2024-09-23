# Three-Tier Web Application Deployment on AWS EKS using Terraform, AWS EKS, ArgoCD, Prometheus, Grafana, and Jenkins

![Three-Tier Banner](assets/Three-Tier.gif)

## step 1: deploying EKS cluster on AWS using Terraform and Jenkins pipeline

### Note: Refer to the folders in jenkins-server/AWS_EKS. A seperate folder named dev  with terraform configuration files is used to have a seperate terraform.tfstate file for each environment like dev, test, and prod. To deploy infrastructure in another environment like test or prod using the same terraform configuration, clone the dev folder with a specific name, update the terraform.tfvars and backed-config.tfvars with values accordingly and execute the terrafrom commands from that specific folder. Make sure to update the environment same as the terraform configuration folder name while running the jenkins pipeline

By following modular approach, derived terraform configuration files to 

-> use AWS S3 backend to store the resource state information. created an s3 bucket and dynamodb table manually for state locking and passed the information in the file **Jenkins-Server-TF/AWS_EKS/dev/backend-config.tfvars**

-> create a vpc with three public and three private subnets in three availability zones
   
-> an EKS cluster with AWS managed node group which is accessible only from within the cluster which will be deployed only in private subnets

-> a jump server with ssh-key based authentication disabled. connect to the jump server using sessions manager. Installing the required tools like aws cli, eksctl, helm, and kubectl by passing the start-up script to the jump server using file **Jenkins-Server-TF/AWS_EKS/module/ec2/user-data.sh**

(pass the inputs in terraform.tfvars, and backend-config.tfvars in **Jenkins-Server-TF/AWS_EKS/dev** folder)

### settign up the jenkins server with required tools

**Jenkins server** is an automation tool used for continuous integration (CI) and continuous delivery (CD) in software development. It helps automate the process of building, testing, and deploying code changes, ensuring that code quality is maintained and deployment is consistent. Jenkins integrates with various tools and platforms through plugins, supports defining workflows as code, and can scale across multiple machines to handle large workloads. It is widely used to improve development efficiency and ensure early detection of issues.
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


**SonarQube** is an open-source platform used for continuous inspection of code quality through static code analysis, detecting bugs, code smells, and security vulnerabilities across more than 25 programming languages. It provides detailed metrics and reports, integrates seamlessly with CI/CD tools like Jenkins, and allows customization of coding rules to enforce standards. By using SonarQube, development teams can improve code quality, maintainability, and security, receive continuous feedback, and ensure compliance with coding best practices, making it an essential tool for maintaining high standards in software development projects.

Sonarqube-scanner plugin performs the code quality analysis, generates the reports, and publish the reports to the configured sonarqube server.

setup: (running the sonarqube server on the same jenkins server as a docker container and publishing the service on port 9000 of the host)
![image](https://github.com/venkatesh-reddy679/Board_Game-CI-CD/assets/60383183/14e01a58-5c9d-4b53-9dcc-9a15f61d6e68)
![image](https://github.com/venkatesh-reddy679/Board_Game-CI-CD/assets/60383183/efbbf27c-0e65-4951-900f-b7a78574644a)
default username: admin && default password: admin

steps to configure the sonarqube server in Jenkins:

1. create a security token in the sonarqube server. go to -> administration -> security -> users (choose the user  you want to authenticatse as) -> click on tokens & generate a new token and save it somewhere
![image](https://github.com/venkatesh-reddy679/Board_Game-CI-CD/assets/60383183/7b913052-6394-4c0e-9260-bf3aba162c10)

2. store the generated security token in the global credentials as a "secret text" in Jenkins server. go to manage jenkins -> credentials -> click on global & click on add credentials
![image](https://github.com/venkatesh-reddy679/Board_Game-CI-CD/assets/60383183/ac65c3e5-bfce-4a00-916f-84391c55b2d3)

3. configure the sonarqube server in jenkins server. go to manage jenkins -> system and scroll to sonarqube server settings.
![image](https://github.com/venkatesh-reddy679/Board_Game-CI-CD/assets/60383183/18453c27-699a-4f54-a388-16b5421b7082)


**Trivy** is an open-source vulnerability scanner used to detect the known vulnerabilities in various components of software development such as docker images, file systems, git repositories and kubernetes clusers. It help us ensure that software is developed deployed with no existing issues.

Jenkins doesn't provide any default plugin for trivy, so we have to manually install it.

commands to install trivy:
1. sudo apt-get install wget apt-transport-https gnupg lsb-release
2. wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
3. echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
4. sudo apt-get update
5. sudo apt-get install -y trivy

![image](https://github.com/venkatesh-reddy679/Board_Game-CI-CD/assets/60383183/3fa2a8d8-ef9a-4f9e-b01e-85f366867b6c)

### jenkins pipeline to deploy EKS cluster

1. stored AWS access key ID and secret access key in the jekins global credentials section

   ![image](https://github.com/user-attachments/assets/b094dc43-7582-403b-b064-db016d4d57c9)

2. making the pipeline parametarized to capture the environment and terraform action from the user. Tools block is used specify  the tools to use in the pipeline. jenkins server will install the specified tool on the machine where the pipeline is executed. Tool function is used to fetch the path where the specified tool is installed. so environment block is used to get the path where terraform is installed and store the path in an environment variable

   ![image](https://github.com/user-attachments/assets/77c329e0-6d91-4923-8d3f-87c1b40978ba)

3. terraform doestn't allow us to use the variable while defining the terraform backend like s3. so, to pass the s3 backend parameters like bucket name, key, region and dynamodb table name, we store those parameters in a seperate .tfvars file and  pass that file during terraform init. withAWS block authenticates the jenkins server with the AWS api using the aws credentials stored. **terraform init** command intializes the s3 backend, install the modules, and download the provider plugin.

   ![image](https://github.com/user-attachments/assets/11c33bc3-cdde-4e39-9083-9cdf24b4cdf9)

4. terraform validate command validate the terraform configuration for any syntax errors or configuration erorrs

   ![image](https://github.com/user-attachments/assets/54fa32c1-9bf6-4bb3-bf62-f8207d5d0094)

4. usign the parameter fetched from user like plan, apply, destroy, this stage runs the terraform plan or terraform apply or terraform destroy.

   ![image](https://github.com/user-attachments/assets/b8bc5ae2-d64f-4315-b609-940a59753636)

to run the pipeline, click on build with parameters and specify the environment and terrafomr action

![image](https://github.com/user-attachments/assets/16c90fc2-5dc5-44de-be4d-2c463ab06373)





   











