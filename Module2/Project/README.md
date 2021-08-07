# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
For this project, you will write a Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.

### Getting Started
This repository contains:
1. A Terraform module for deploying a tagging policy on Azure;
2. A Packer template configuration, for building (and pushing to Azure) a virtual machine (VM) image;
3. A Terraform module for deploying a configurable number of virtual machines using the image created above.

Items #2 and #3 allow for configuring input variables, as specified in the [server.json](server.json) and [variables.tf](variables.tf) files, respectively.

### Dependencies
1. Create an [Azure Account](https://portal.azure.com)
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions

1) Create the resource group, needed to push the Packer VM image to Azure:
```console
az group create -l westeurope -n project1-dev-rg --tags app=project1 environment=dev
```
The output will be a JSON representation of your resource group. Copy the resource group ID since we will import it later into terraform.

2) Build and push the Packer VM image:
```console
packer build server.json
```

3) Initialize terraform and import the existing resource group we created in step 1. This is necessary so that Terraform identifies the resource as it is already deployed. Replace `<RESOURCE-GROUP-ID>` below with the ID you copied in step 1.
```console
terraform init
terraform import azurerm_resource_group.app <RESOURCE-GROUP-ID>
```
A message will confirm whether the resource was successfully imported.

4) Create and save the Terraform plan:
```console
terraform plan -out solution.plan
```

5) Deploy the infrastructure by applying the plan:
```console
terraform apply solution.plan
```

### Output

After the infrastructure was deployed, you should be able to see the resources on the Azure Portal, e.g., on the section "All resources", or via the Azure CLI:
```console
az resource list --resource-group <RESOURCE-GROUP-NAME> --location <LOCATION>
```
Replace `<RESOURCE_GROUP_NAME>` and `<LOCATION>` according to your deployment configurations.
