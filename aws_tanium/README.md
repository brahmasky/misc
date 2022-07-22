# AWS Tanium Deployment

This module will deploy tanos appliances with the details provided in the tfvars file for AWS environment. An example for deployment in DEV environment is
```
terraform init
terraform apply -var-file=aws_dev.tfvars
```
Or if running from a different folder from script
```
terraform -chdir=<PATH>/tanium-cicd/terraform/aws_tanium_deployment init
terraform -chdir=<PATH>tanium-cicd/terraform/aws_tanium_deployment plan -var-file=aws_dev.tfvars
terraform -chdir=<PATH>tanium-cicd/terraform/aws_tanium_deployment apply -var-file=aws_dev.tfvars
terraform -chdir=<PATH>tanium-cicd/terraform/aws_tanium_deployment destroy -var-file=aws_dev.tfvars
```
