# Servian DevOps Tech Challenge - Deployment Guide
## Overview
This guide will help you to deploy Servian TECHNICALSHALLENGEAPP, The deployment cycle has been implemented as an automated (End to End) cycle which completely provision the required infrastructure from scratch, build docker image for the app and deploy it to AKS managed cluster.
## Infrastructure Overview:
TECHNICALSHALLENGEAPP App is a single page golang application that is backed by azure devops postgres single server.
- This repo is a fork from repo [servian/TechChallengeApp](https://github.com/servian/TechChallengeApp) based on latest commit on origin master branch .
- Branch "devops/cicd" is a child branch used for developing deployment solution for the app.
- The application will be built as a docker image using [Dockerfile](/Dockerfile)
- The application images will be stored on an Azure Cluster Registry (ACR).
![image](https://user-images.githubusercontent.com/113764231/191387156-15a8c61e-b18d-42d0-be54-4710da07a11a.png)

- The app will be backed by Azure postgres single server , connection string parameters will be injected as container environment variable and also injected   on [conf.toml](conf.toml)
- Application ACR docker image will be deployed to AKS managed cluster.

- AKS service load balancer will exposed the application for external use.
![image](https://user-images.githubusercontent.com/113764231/191386998-2c20c484-8318-48b6-969f-aa4e1831aa5e.png)

- azure container to store remote tfstate files to be used as a terraform backend.
![image](https://user-images.githubusercontent.com/113764231/191386893-11586bc5-03f3-48d4-ad67-0808fa458590.png)

- azure resources that serve the application:
![image](https://user-images.githubusercontent.com/113764231/191385332-3d4e0bf2-09b4-4586-a2c1-9fdb483e13d9.png)
![image](https://user-images.githubusercontent.com/113764231/191387543-d9c972db-4fc5-4f44-ba4c-f1460fbbd07e.png)
- AKS Managed Cluster Resource group:
![image](https://user-images.githubusercontent.com/113764231/191384417-a405bcf9-61a1-41e2-9afc-691d88073352.png)
## Tool and Technology: 
- Terraform 
- Azure Kubernetes service (AKS)
- Azure Kubernetes Registry (ACR)
- Docker.
- Azure Devops Pipeline (YML)
## Pipeline Overview:
   Azure DevOps Pipeline is selected as CI/CD Tool .
### Pipeline Configuration:
- A service connection to azure subscription should be created with name “serviceconnection-acr”
- Terraform.tfvars already added to azure pipeline secure library as a secure file , this file has a permission  for pipelines to use.
- Database login information is defined as pipeline variables (later it will be exported as a k8s secret)
- Dockerfile has a runtime parameter “arch” to define base image architecture, it is defined as pipeline variables with default value “amd64”
- Pipeline is configured to create azure kubernetes registry “ACR”, once it is created you should create azure service connection for ACR named 'serviceconnection-acr' as it will be referenced during ACR push and pull operation. 
### Pipeline List:
- CD-TechChallengeApp-Infra    #Pipeline to deploy Infra
- CD-TechChallengeApp-App      #Pipeline to deploy App 
#### 1-	[CD-TechChallengeApp-Infra ](/CI-infra-deploy.yml)
This is an azure devops end-to-end yml pipeline to provision the required infrastructure and deploy the app using a declarative terraform files, 
![image](https://user-images.githubusercontent.com/113764231/191380881-8c49c75d-ded8-487e-bec4-e2b66980c453.png)
</br>
it is a multi-staged pipeline with three option to select from while triggering it:
![image](https://user-images.githubusercontent.com/113764231/191381022-b401a10b-f816-4928-b435-05328a942f78.png)

##### 1-Action "Init":
This action will trigger the stage "create_tf_backend_resources" which pass the required parameters to the template [template-azure-backend-create](/templates/template-azure-backend-create.yml) to create the following resources: terraform backend resource group -  storage account - storage container to host terraform tfstate files for infra and app.

##### 2- Action "Apply"
will trigger three stages:
###### 2.1 -Stage: deploy_tf_base_infra
![image](https://user-images.githubusercontent.com/113764231/191381381-14d2f482-d13f-43f6-af8b-c3971000c992.png)
</br>
This stage passes the required parameters to [template-terraform-deploy pipeline template](/templates/template-terraform-deploy.yml) to create the resources decalred on directory (Terraform/base) :   
- Managed Azure AKS with RBAC enabled + Azure ACR + resource groups .
- Azure Postgres single server + resource group and required firewall rule.
- Azure Active Directory app and required service principle & roles to push and pull Image to ACR  
###### 2.2 -Stage: build_docker_image
![image](https://user-images.githubusercontent.com/113764231/191381636-01e2b7ec-6f69-408d-9468-f81e031221c8.png)
</br>
This stage passes the required parameters to the [template-docker-push-to-acr pipeline template](/templates/template-docker-push-to-acr.yml) to build the app docker image then push it to Azure ACR.

###### 2.3 -Stage:  deploy_app_to_k8s
![image](https://user-images.githubusercontent.com/113764231/191381806-23cbb654-0161-4045-907c-aa8d0f6571a0.png)
</br>
This stage passes the required parameters to [template-terraform-deploy pipeline template](/templates/template-terraform-deploy.yml) to create the  resources decalred on directory [Terraform/k8s](/Terraform/k8s): 
- install kubelogin plugin to login to AKS "non-interactive" 
- k8s deployment resources (namespace, service, deployment)
##### 3-Action "Destroy"
![image](https://user-images.githubusercontent.com/113764231/191382103-211cb0b6-299f-474b-b2f3-27ae8748cc5f.png)
</br>
will trigger the stage template-terraform-destroy which pass the required parameters to pipeline template [template-terraform-destroy](/templates/template-terraform-destroy.yml) to destroy all resources created by terraform on directories(Terraform/*)

##### CD-TechChallengeApp-Infra Pipeline workflow:
- This end-to-end pipeline will be triggered on-demand.
- Make sure the pipeline configuration section is done before triggering it.
- Trigger the pipeline with “init” as the action option will run stage “create_tf_backend_resources” which use azure cli to create the following resources "Azure resource group- Azure storage account- azure storage container (will be used later to store tfstate files)"
- Now you initiated terraform required infrastructure and ready to use terraform to provision the required infrastructure, run the pipeline with option “Apply” and it will do the following:
   - Provision required resources defined on  “terraform/base” directory , these terraform files declare the required infrastructure to deploy azure postgres single db server , AKS , ACR , service principles , azure AAD application and ask admin group, Role assignments.
   - Using app Dockerfile, pipeline will build and push a docker image to ACR with tag $(build_Id).
   - Terrafoorm will deploy k8s tf files on directory “. /terraform/k8s” and create k8s namespace, k8s service, k8s deployment.
   - To destroy the resources created by terraform, you can trigger the pipeline with Action option “Destroy”.
> the backed resource that created by azure cli will not deleted during destroy action

##### 2. [CD-TechChallengeApp-App](CI-app-deploy.yml)
![image](https://user-images.githubusercontent.com/113764231/191389941-637cb20f-924c-48da-a84d-55708c2e90c0.png)
</br>
This pipeline will deploy any change to application itself, build a new docker image for the app and push it to kubernetes.

###### 1.Stage: build_docker_image
![image](https://user-images.githubusercontent.com/113764231/191396268-008e1e6a-993a-4f8a-b44c-fb8dfbe51876.png)
</br>
This stage passes the required parameters to the [template-docker-push-to-acr pipeline template](/templates/template-docker-push-to-acr.yml) to build the app docker image then push it to Azure ACR.

###### 2.Stage:  deploy_app_to_k8s
![image](https://user-images.githubusercontent.com/113764231/191396347-134fff57-288c-42c0-b5d9-daf8cc323e2b.png)

</br>
This stage passes the required parameters to [template-app-deploy pipeline template](/templates/template-app-deploy.yml) to create the  resources decalred on directory [Terraform/k8s](/Terraform/k8s): 
- install kubelogin plugin to login to AKS "non-interactive" 
- deploy k8s deployment resources (namespace, service, deployment)

##### CD-TechChallengeApp-App Pipeline workflow:
1-	Make sure the pipeline configuration section is done before triggering it.
2-	Once pull request merges to master branch, this pipeline will be triggered
3-	As you already provision the required infra using pipeline "CD-TechChallengeApp-Infra pipeline" this pipeline will do the following steps: 
a.	Using docker task, build and push docker image to ACR.
b.	Terraform will deploy the k8s resources on directory [terraform/base](/terraform/base) and deploy the app based on ACR image tag (build_id).

### Pipeline Templates:
To reuse pipeline stages without need to duplicate the file, azure template yml file is there to be called by main pipelines .
![image](https://user-images.githubusercontent.com/113764231/191380622-052bc198-e87a-45ff-8ac9-e0513232bb00.png)
</br>

## Terraform Folder structure
![image](https://user-images.githubusercontent.com/113764231/191382444-5612d4ed-ab88-4677-a1d5-b6bb4be38f78.png)
</br>
- base folder : contains all base resources required to build app infratracture.
- k8s folder  : contains app k8s files required to deploy the app plus the service priniciple required for aks access. 
- terraform.tfvars is stored on pipeline as a secure pipeline library file.

## Application Test:
The app has been deployed to aks , you can access using:
- [App url](http://20.101.27.172/)
![image](https://user-images.githubusercontent.com/113764231/191382824-6636041d-8b54-4708-801d-2e07128fe325.png)
---

- [App Healthcheck URL](http://20.101.27.172/healthcheck/)
![image](https://user-images.githubusercontent.com/113764231/191390409-0b9a65b4-3dc6-44cc-a5e2-9e99e550972b.png)
---

- [App Debug URL](http://20.101.27.172/debug)
![image](https://user-images.githubusercontent.com/113764231/191382991-fb46b05e-216e-4263-9e5c-c3c58ee59a8a.png)
---

- [App swagger URL](http://20.101.27.172/swagger/)
![image](https://user-images.githubusercontent.com/113764231/191383057-ae575de4-87b9-48ca-980f-94a4a8efedc8.png)
 

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
   - add healthcheck as a liveness probe for k8s deployment.
     
   
