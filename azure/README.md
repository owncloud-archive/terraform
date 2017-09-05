# Terraform: Azure

TBD

## Setup

Write the required variables `azure_subscription`, `azure_client`, `azure_secret` and `azure_tenant` into `.auto.tfvars`, otherwise you won't be able to connect to the Azure API. Optionally you can also overwrite the variables defined within [variables.tf](variables.tf).

```
cat << EOF >| .auto.tfvars
azure_subscription = "your_subscription_id"
azure_client = "your_client_id"
azure_secret = "your_secret_id"
azure_tenant = "your_tenant_id"
EOF
```

```
terraform init
terraform plan
terraform apply
```

## Usage

After you have applied the setup you can connect to the instance via SSH, per default the user got the password `owncloud!234`, except you have overwritten the variable while setup.

```
ssh $(terraform output ssh)
docker info
docker ps -a
```

## Cleanup

If you are down with the setup you just need to execute the single following command to get rid of all the created Azure resources.

```
terraform destroy -force
```
