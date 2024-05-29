## Currency Exchange Micro Service - H2

**Currency Exchange Microservice with Kubernetes and Terraform.**

### Resources
- http://localhost:8000/currency-exchange/from/USD/to/INR

``` json
{
  "id": 10001,
  "from": "USD",
  "to": "INR",
  "conversionMultiple": 65.00,
  "environmentInfo": "NA"
}
```

### H2 Console
- http://localhost:8000/h2-console
- Use `jdbc:h2:mem:testdb` as JDBC URL

### Notes
---
### Tables Created
``` sql
create table exchange_value 
(
	id bigint not null, 
	conversion_multiple decimal(19,2), 
	currency_from varchar(255), 
	currency_to varchar(255), 
	primary key (id)
)
```

### Containerization
#### Troubleshooting
- Problem - Caused by: com.spotify.docker.client.shaded.javax.ws.rs.ProcessingException: java.io.IOException: No such file or directory
- Solution - Check if docker is up and running!
- Problem - Error creating the Docker image on MacOS - java.io.IOException: Cannot run program “docker-credential-osxkeychain”: error=2, No such file or directory
- Solution - https://medium.com/@dakshika/error-creating-the-docker-image-on-macos-wso2-enterprise-integrator-tooling-dfb5b537b44e

#### Creating Container
``` bash
mvn package
```

#### Running Container
``` bash
docker run --publish 8000:8000 pauloricardobusch/currency-exchange:0.0.1-SNAPSHOT
```

### Azure Kubernetes Cluster
---
Pre-requisites
- Service Account
- SSH Public Key

``` bash
# Create Service Account To Create Azure K8S Cluster using Terraform
az login
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/<<azure_subscription_id>>"

# Create Public Key for SSH Access
ssh-keygen -m PEM -t rsa -b 4096 # PEM - Privacy Enhanced Mail - Certificate Format RSA- Encryption Algorithm

# ls /Users/<<username>>/.ssh/id_rsa.pub

# Get Cluster Credentials
az aks get-credentials --name <<MyManagedCluster>> --resource-group <<MyResourceGroup>>
```

### AWS EKS Kubernetes Cluster
---
``` bash
aws configure
aws eks --region us-east-1 update-kubeconfig --name eks-cluster
kubectl get pods
kubectl get svc
kubectl get serviceaccounts
kubectl get serviceaccounts default -o yaml
kubectl get secret default-token-hqkvj -o yaml
kubectl cluster-info
```

### Manually setting up from local machine
---
#### Create Service Account For Your Subscription To Create Azure K8S Cluster using Terraform
``` bash
az login
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/<<azure_subscription_id>>"
set TF_VAR_client_id=<<service_account_appId>>
set TF_VAR_client_secret=<<service_account_password>>
```

#### Create Public Key for SSH Access
``` bash
ssh-keygen -m PEM -t rsa -b 4096 # PEM - Privacy Enhanced Mail - Certificate Format RSA- Encryption Algorithm
ls /Users/rangakaranam/.ssh/id_rsa.pub
```

#### Create Resource Group, Storage Account and Storage Container
``` bash
az group create -l eastus -n K8sResourceGroup
az storage account create -n K8sStorageAccount -g K8sResourceGroup -l eastus --sku Standard_LRS
az storage container create -n devterraformstatestorage --account-name <<storage_account_name>> --account-key <<storage_account_key>>
```

#### Execute Terraform Commands
``` bash
# comment backend
terraform init
terraform apply

# add backend
# terraform init with backend
terraform init -backend-config="storage_account_name=<<storage_account_name>>" -backend-config="container_name=<<storage_container_name>>" -backend-config="access_key=<<storage_account_key>>" -backend-config="key=<<k8s.environment.tfstate>>"
```

#### Set up kubectl
``` bash
terraform output kube_config>~/.kube/config
```

#### Launch up
``` bash
kubectl proxy
open 'http://localhost:8001/api/v1/namespaces/kube-system/services/kubernetes-dashboard/proxy/#!/overview?namespace=default'
```
