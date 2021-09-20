# Garden Enterprise Azure Setup

This Terraform creates several ressources that you need for your Garden Enterprise Setup:

* A vnet and subnet for the AKS cluster.
* An AKS cluster
* A postgres RDS with a vnet rule for the AKS Clusters vnet.
* An application registration with a principal and permissions to access Azure Key Vault.
* An Azure Key Vault instance and Key for auto-unsealing Garden Enterprise (Hashicorp) Vault for secret storage.

Garden Enterprise also needs a load balancer and an ingress controller. The NGINX ingress controller is bundled with Garden Enterprise and allows
installation with a load balancer service. But any other load balancer and ingress controller setup should work as well.

## Usage

Please go through the `variables.tf` file and create a `variables.tfvars` file with your values. At least all passwords
and the location of the resource group should be changed.

This module creates a new resource group, if you want to use an existing one you can either import it to state or change
the code to just use an exisiting resource group via a data source.

You also might want to put your state in a S3 bucket. See [here](https://www.terraform.io/docs/language/settings/backends/azurerm.html) for more documentation.

To create your infrastructure run:
```
terraform apply -var-file=variables.tfvars
```

The Terraform modules outputs all parameters necessary for Garden Enterprise installation.

## Post Terraform Deployment

### Installing extension on Postgres RDS

As Azure Postgres Server runs in the same vnet as the AKS cluster and the firewall towards the Postgres Server is completely closed you can only reach it from your AKS cluster. Garden Enterprise requires the `uuid-ossp` extension and you will need to install it from a pod in your cluster once. To do that please run:

```
kubectl run -it postgres --image=postgres -- /bin/sh
```

And once in the postgres pod run the following command, replacing the password, username, host and database with your own:

```
export PGPASSWORD='8@7xLo*iDq3AePrmAdYXipmv' && psql -h garden-enterprise-postgres.postgres.database.azure.com -p 5432 -d postgres -U postgres@garden-enterprise-postgres.postgres.database.azure.com -c 'CREATE EXTENSION "uuid-ossp";'
```

## Troubleshooting

Sometimes the apply fails, because a dependent resource has been created but is not accessible yet, in that case just run the apply again.
One of these occasions is when the access policy to Azure Vault for your user/app has been applied, but is somehow not yet ready, the error includes:
 
```
Service returned an error. Status=403 Code="Forbidden" Message="The user, group or application does not have keys get permission on key vault 'ge-terraform-vault;location=germanywestcentral'.
```
