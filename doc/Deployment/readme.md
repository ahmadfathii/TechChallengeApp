# Servian DevOps Tech Challenge - Deployment Guide
## Overview
This guide will help you to deploy Servian TECHNICALSHALLENGEAPP, The deployment cycle has been implemented as an automated (End to End) cycle which completely provision the required infrastructure from scratch, build docker image for the app and deploy it to AKS cluster.
## Infrastructure Overview:
TECHNICALSHALLENGEAPP App is a single page golang application that is backed by azure devops postgres single server.
- This repo is a fork from [servian/TechChallengeApp repo](https://github.com/servian/TechChallengeApp) based on latest commit on origin master branch .
- DevOps/cicd is child branch used for developing deployment solution for the app.
- Application will be built as a docker image using repo [docker file](Dockerfile)
- Application images will be stored on an Azure Cluster Registry.
- Application will be backed by Azure postgres single server , connection string parameters will be injected as container environment variable and also injected on [conf.toml](conf.toml)
- application ACR docker image will be deployed to AKS cluster.
- k8s service and azure load balancer will exposed the application for external use.
- azure container blob to store remote tfstate file to used as a terraform backend.   
## Tool and Technology: 
- terraform 
- Azure Kubernetes service (AKS)
- Azure Kubernetes Registry (ACR)
- Docker.
- Azure Devops Pipeline (YML)
## Pipeline Overview:
   Azure DevOps Pipeline is selected as CI/CD Tool .
### pipeline List:
- CD-TechChallengeApp-Infra #Infra Deployment pipeline
- CD-TechChallengeApp-App   #App Deployment pipeline
### Pipeline Configuration:
    - A service connection to azure subscription should be created with name “serviceconnection-acr”
    - Terraform.tfvars already added to azure pipeline secure library as a secure file , this file has a permission  for pipelines to use.
    - Database login information is defined as pipeline variables (later it will be exported as a k8s secret)
    - Dockerfile has a runtime parameter “arch” to define base image architecture, it is defined as pipeline variables with default value “amd64”
    - Pipeline is configured to create azure kubernetes registry “ACR”, once it is created you should create azure service connection for ACR named 'serviceconnection-acr' as it will be referenced during ACR push and pull operation. 
#### 1-	[End-To-End pipeline](CI-infra-deploy.yml)
This is an azure devops yml pipeline to provision the required infrastructure and deploy the app using a declarative terraform files, it is a multi-staged pipeline and have a three option to select from while triggering it:
##### 1- Action "init"
This action will trigger the stage (create_tf_backend_resources) which pass the required parameters to the pipeline template (templates\template-azure-backend-create.yml) to create the following resources: 
    - terraform backend resource group.
    - storage account 
    - storage container to host terraform tfstate files for infra and app.
    
##### 2- Action "Apply"
   will trigger three stages:
   ###### 2.1 -Stage: deploy_tf_base_infra 
          This stage passes the required parameters to the pipeline template templates\template-terraform-deploy.yml) to create the following resources on directory (Terraform/base) :   
          - Managed Azure AKS with RBAC enabled + Azure ACR + resource groups .
          - Azure Postgres single server + resource group and required firewall rule.
          - Azure Active Directory app and required service principle & roles to push and pull Image to ACR  
   ###### 2.2 -Stage: build_docker_image
        This stage passes the required parameters to the pipeline template (templates\template-docker-push-to-acr.yml) to build the app docker image then push it to Azure ACR.

   ###### 2.3 -Stage:  deploy_app_to_k8s
        This stage passes the required parameters to the pipeline template (templates\template-terraform-deploy.yml) to create the following resources on directory (Terraform/k8s): 
       - install kubelogin plugin to login to AKS "non-interactive" 
       - k8s deployment resources (namespace, service, deployment)

##### 3-Action "Destroy"
        will trigger the stage (template-terraform-destroy.yml) which pass the required parameters to the pipeline template (templates\template-terraform-destroy.yml) to destroy all resources created by terraform on directories (Terraform/*) 




Pipeline workflow:
1-	This end-to-end pipeline will be triggered on-demand.
2-	Make sure the pipeline configuration section is done before triggering it.
3-	Trigger the pipeline with “init” as the action option will run stage “create_tf_backend_resources” which use azure cli to create the following resources:
i.	Azure resource group
ii.	Azure storage account
iii.	Azure storage container (will be used later to store tfstate files)
All the required resource configuration are defined as pipeline variables.
4-	Now you initiated terraform required infrastructure and ready to use terraform to provision the required infrastructure, run the pipeline with option “Apply” and it will do the following:
a.	 Provision required resources defined on  “./terraform/base” directory , these terraform files declare the required infrastructure to deploy azure postgres single db server , AKS , ACR , service principles , azure AAD application and ask admin group, Role assignments.
b.	Using app Dockerfile, pipeline will build and push a docker image to ACR with tag $(build_Id).
c.	Make aks deployment using terraform for deployment declared on directory “. /terraform/k8s” and create namespace, service, deployment.
5-	To destroy the resources created by terraform, you can trigger the pipeline with Action option “Destroy”.
Note: the backed resource that created by azure cli will not deleted during destroy action
#### 2. [CI-app-deploy](CI-app-deploy.yml)
This pipeline will deploy any change to application itself, build a new docker image for the app and push it to kubernetes..
Pipeline workflow:
1-	Make sure the pipeline configuration section is done before triggering it.
2-	Once pull request merges to master branch, this pipeline will be triggered
3-	As you already provision the required infra using pipeline (CD-TechChallengeApp-Infra pipeline) this pipeline will do the following steps: 
a.	Using docker task, build and push docker image to ACR.
b.	Terraform will deploy the k8s resources on directory “. /terraform/base” and deploy the app based on ACR image tag (build_id).

        Pipeline Templates:
        To reuse pipeline stages without need to duplicate the file, azure template yml file is there to be called by main pipelines .
### pipeline Templates: 
    We have five template files on directory [templates](./templates)   	 
## Application Test:
   application has been deployed to aks , you can access using:
   - [application url](http://20.101.27.172/)
   - [application Healthcheck URL](http://20.101.27.172/healthcheck/)
   - [application Debug URL](http://20.101.27.172/debug/)
   - [application swagger URL](http://20.101.27.172/swagger/)
## Security:
   - terraform.tfvars file is not part of source control and stored as secure library file on azure devops.
   - azure service connection , managed identity and service principle , RBAC access and roles assignment are used for access azure secure resources with restricted internet connection and firewall rules for azure managed resources.
   - part of infra deployment pipeline , there is manual validation (Team leader approval) is required to review the terraform plan before proceeding with terraform apply.
   - use variable type secret for pipeline variable like db password.  
   - [should have ] enable terraform scan tool like terratest , chekov. 
   - [should have ] static code analysis tool like sonarqube.
   - [should have ] whitesource scan and OWASP ZAP Security Tests in Azure DevOps.
   - [should have ] scan docker image against security vulnerabilities. 
   - [should have ] add secrets to key vault or aks secrets.
## Recommendation:
   - Enhance deployment process by updating infra deployment pipeline and add a condition task before terraform apply step to run only if there is a change on resources .
   - Protect the master branch and activate Pull Request Validation and PR decoration.
   - Enforce Pull Request quality gates and static code analysis.
   - Consider multiple environment deployment and branching strategy.
     
   