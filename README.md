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

![image](https://github.com/user-attachments/assets/30cc7dd5-7c9c-4fa8-9d6d-03ae574dcf13)

![image](https://github.com/user-attachments/assets/14804c2e-e260-40ab-89c5-b8e2c488419a)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## step 2: jenkins pipelines for frontend and backend applications

refer to the jenkins files available in the folder Jenkins-Pipeline-Code. all of the stages are same for both the pipelines with minor changes. so, only frontend pipeline is explained in this section

1. pipeline is parametarized to get the region from user. Tool function is used to get the path where jenkins installed the specified tool and credentials function is used to retrieve the secret texts stored in jenkins global credentials. using environment block, specified environment variables to store the path of sonar-scanner tool, to store the aws account ID , and to construct the awe ecr registry url. stages are added to clean the workspace and clone the git repository

   ![image](https://github.com/user-attachments/assets/d91dec4f-3c98-470c-ad5a-b968e340c7f0)

2. Stage for code quality check and quality gate

first, create projects in sonarqube server for frontend and backend applicatin source code analysis

![image](https://github.com/user-attachments/assets/e5c5c656-7e43-447c-98e5-622a1050a411)

choose to analyse the project locally

![image](https://github.com/user-attachments/assets/fd8b8c7d-d288-451b-9c99-4d8343aa56f1)

use the created administrator uer token whcih can be used to analyse multiple projects

![image](https://github.com/user-attachments/assets/4313e85c-ac78-41a9-a4ab-5233429513f4)

choose what programming languages is used in application and what operating system we are going to perform the source code analysis. copy the sonar-scanner command


![image](https://github.com/user-attachments/assets/a8f9d61c-9267-436f-82e5-eb16f928000e)


![image](https://github.com/user-attachments/assets/92f6d029-5c8f-42e5-8132-8619c4c118a0)


withSonarQubeEnv('sonarqube-server') block sets up the environemnt for sonarqube code quality analysis. The maven command "mvn sonar:sonar" triggers the SonarQube analysis for a Maven-based project, sending the analysis data to a SonarQube server.

A Quality Gate in sonarqube server is a set of conditions that a project must meet to be considered of acceptable quality. It is a way to enforce a minimum standard of quality before changes are integrated into the main codebase. These conditions can include metrics like code coverage, number of bugs, code smells, duplications, and other issues.

![image](https://github.com/venkatesh-reddy679/Board_Game-CI-CD/assets/60383183/5e4c8999-ad0f-45fb-bf38-8df5dc5d4a61)

"sonar way" is the default quality gate our project points to. we can a new quality gate with different coverage level by clicking on create button. To set our project to use a customized quality gate, got to project -> project settings -> quality gate -> always use a specific quality gate -> choose the gate

![image](https://github.com/venkatesh-reddy679/Board_Game-CI-CD/assets/60383183/6556d90a-e0a9-46d8-86e0-bf17c6e86b5f)

"waitForQualityGate" step waits until the sonarqube analysis is completed and sonarqube server send the quality gate status to jenkins server  using the webhook that we set on sonarqube server and "abortPipeline: true" will abort the pipeline if the quality gate is failed.

It is a good practice to wrap "waitForQualityGate" in a "timeout" block to prevent the build from waiting indefinitely in case of issues with SonarQube analysis. The timeout block will limit the maximum time the build waits for the Quality Gate status. If the timeout expires before the quality gate status is received, the pipeline will throw a timeout error. If the quality gate status is received before the timeout expired, waitForQualityGate will be passed and pipeline execution will be resumed.

![image](https://github.com/user-attachments/assets/91260f38-e4a3-466b-98b1-29b9418b0302)

3. Stage to scan the directory after cloning the git repository for any known vulenrabilities using trivy that writes the output in table format to a file specified in -o flag and . represents current directory. OWASP (Open Web Application Security Project) provides tools and resources to improve software security. One of its key features is the OWASP Dependency-Check, which scans project dependencies for known vulnerabilities and weaknesses. It helps identify risks in libraries or modules used by your applications, enabling you to address security issues early in the development process. This tool is essential for maintaining secure and compliant software by keeping dependencies up-to-date and mitigating potential threats.

   ![image](https://github.com/user-attachments/assets/b5008a1b-304a-4c52-8afe-daa91f123d04)

4. stage to build the docker image, scane the docker image using trivy, and push the docker images to a private repository hosted on AWS ECR registry.

   ![image](https://github.com/user-attachments/assets/365feb46-c788-4347-b3b5-e977989ec6ae)

5. updating the image in the deployment file and pusing the changes to the same git repository. stored a git personal access token in the jenkins global credentials, and used envronment block to define environment variables to store the git token, repository name, and username.

   ![image](https://github.com/user-attachments/assets/d24e9f0c-ab04-44a8-80b9-559a24c8644f)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## step 3: install ALB ingress controller and argoCD in the eks cluster

1. connect to the jump server using sessions manager and verify kubectl, aws cli, eksctl and helm is installed

   ![image](https://github.com/user-attachments/assets/fd2f9136-5239-4a10-9364-fe5ed8ee578e)

2. run aws configure command to authenticate with AWS api and update the kubeconfig file and verify

   ![image](https://github.com/user-attachments/assets/f1020273-e9d5-456a-9a40-333e84b2f2e4)

3. verify that the security groups associated with eks cluster is allowing incoming traffic

   ![image](https://github.com/user-attachments/assets/a3fcc23f-c343-47fd-95e6-018c1e7b9d0a)

4. follow the offical documentation to install ALB ingress controller [AWS ALB Ingress](https://docs.aws.amazon.com/eks/latest/userguide/lbc-helm.html)

   ![image](https://github.com/user-attachments/assets/a0b723fa-3608-403a-aa46-f96617420185)

5. install ArgoCD using helm chart. Modify the argocd service from clusterIP to LoadBalancer type for external access

   kubectl create namespace argocd

   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

   ![image](https://github.com/user-attachments/assets/8769b74a-a128-44e5-bee8-b680da22655c)

6. install ebs csi driver in the eks cluster using helm to create a storage class that dynamically provisions the persistent storage from AWS ElasticBlockStorage

   helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver

   helm repo update

   helm upgrade --install aws-ebs-csi-driver --namespace kube-system aws-ebs-csi-driver/aws-ebs-csi-driver

   ![image](https://github.com/user-attachments/assets/ffef7473-2d59-40e5-9c88-357098a5c7be)

### step 4: create ArgoCD app-of-apps application to deploy the resources in eks cluster

ArgoCD is an declerative, GitOps continous delivery tool which uses git repository as a single source of truth for ensuring that the desired state (state in git) matches with the live state (state in cluster). ArgoCD-repo-server polls the git repository for every 3 minutes by default and if it detects any changes in the desired state, then based on sync policy, it pulls the changes and applies the changes on cluster.

refer to the Kubernetes-Manifests-file folder for frontend, backend, database and ingress yaml files.

ALB ingress controller is already deployed and is running as a pod in the kube-systemt namepsace. Now, To enable external access to the application running within the cluster, we have to create an Ingress which is an namespaced kubernetes resource that configures the load-balancer to route traffic based on host-name and path.So, whenever we create an ingress resource, ALB contoller creates an Application Load Balancer, configures the target groups based on the rules specified in the ingress resource.

**annotations to add for an ingress resource to create and configure ALB:**

1. alb.ingress.kubernetes.io/scheme: internal/internet-facing
2. alb.ingress.kubernetes.io/target-type: ip/instance -> we have to forward the incoming request to the ip of a pod, so value is ip
3. alb.ingress.kubernetes.io/listen-ports: '[{"HTTP":80}]'
4. alb.ingress.kubernetes.io/subnets: provide the id of public subnetes where the loadbalancer should be deployed. provide comma seperated vallues

In Kubernetes-Manifests-file folder, we have Ingress yaml definition file that creates an ingress resource in the three-tier namespace

In Kubernetes-Manifests-file/Database folder, a secret yaml definition containing mongodb username, and password, a storage class yaml definition that user ebs.csi.aws.com provisioner to dynamically provision the persistent volume, and persistentvolumeclaim definition yaml defining the storageclass name, and requesting the storage required, and a deployment yaml that creates a single replica of mongoDB that uses this persistent volume to keep the data persistent, and finally a service yaml definition to expose the database for the backend over clusterIP.

![image](https://github.com/user-attachments/assets/2358aa11-0778-4217-b22e-c0db46f722ca)

In frontend and backend folders, respective deployment ans service yaml definition files are available.

In this project, we are usign app-of-apps framework in argoCD where a single application will create, update, and delete other applications. ArgoCD application yaml file are avaialble in the folder **argocd**

![image](https://github.com/user-attachments/assets/4bc874aa-eadd-45cc-80fb-d62c21e0f325)

An argocd application is a resource that uses git repository and folder containing manifest files as source and cluster and namespace as destination. So, we create an appliction in argocd web UI that point to the argocd folder and deploys those argocd application yaml files in the argocd namespace.

![image](https://github.com/user-attachments/assets/250c1c0e-ef38-4fd4-9107-19774806e755)
![image](https://github.com/user-attachments/assets/24e9cc03-f110-44e5-91c2-274152dfa676)
![image](https://github.com/user-attachments/assets/05fb11bf-58cb-42ad-b0c5-e2d3e66b82a0)
![image](https://github.com/user-attachments/assets/18630fad-801d-4e01-9458-362d2716fb14)
![image](https://github.com/user-attachments/assets/77835e97-2f1f-40bc-8b52-d3f97d36ba56)
![image](https://github.com/user-attachments/assets/0201ed9e-ff0a-421d-81ed-c6a806b1d8d5)
![image](https://github.com/user-attachments/assets/d369571c-75ad-4690-8c2e-e565159a3b79)
![image](https://github.com/user-attachments/assets/51b38699-3518-4168-8ddb-a4a4f20458f9)

once the ALB ingress controller creates and configures the Application LoadBalancer, access it on the browser

![image](https://github.com/user-attachments/assets/f26ec426-4a32-4875-b031-09fa83f19d9e)
![image](https://github.com/user-attachments/assets/bb484594-6ed4-4158-a41b-c95b155598b1)
![image](https://github.com/user-attachments/assets/73af0c44-791e-46b7-a12d-ce04c9a94a9e)

### Monitoring the eks cluster using prometheus and grafana

Install Prometheus using helm chart

![image](https://github.com/user-attachments/assets/874679dc-dec1-4f9a-ba5c-96da02eed7b6)

edit the promethues service type from clusterIP to LoadBalancer to access it from internet

![image](https://github.com/user-attachments/assets/64822436-339e-4ec1-8303-375ca1b55826)

![image](https://github.com/user-attachments/assets/8274ed88-6cb2-4b9d-bd66-a01c20ea4749)


Installing Grafana using helm chart

![image](https://github.com/user-attachments/assets/f2fda6d7-46cb-4a5d-8a84-986505576910)

edit the grafana service type from clusterIP to LoadBalancer
![image](https://github.com/user-attachments/assets/394919a3-9a3a-44cf-984a-c8c8b36426d0)

retrieve the grafana admin password from the secrete named grafana

![image](https://github.com/user-attachments/assets/dfba779e-4e04-4057-8162-e215f42b6981)

![image](https://github.com/user-attachments/assets/49ecbc40-2e80-46e2-9161-9543d54e61af)

configuring prometheus as datasource for grafana

![image](https://github.com/user-attachments/assets/4ed2d8a9-78bd-4116-abf6-d6cfbf6ec813)

Grafana comes with lot of builtin dashboards to visualize prometheus metrics if we dont want to create dashboard from scratch

![image](https://github.com/user-attachments/assets/0ce6c51a-4cc5-4b5f-b77b-01cf07672b26)
![image](https://github.com/user-attachments/assets/71fbb26b-4915-4f4a-bd48-ead38f2536c6)
![image](https://github.com/user-attachments/assets/d3c69ea5-47d2-4c30-8192-2bb22ac63c22)



























   



   















   











