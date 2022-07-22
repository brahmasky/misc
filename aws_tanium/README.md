# AWS Tanium Deployment

This module will deploy tanos appliances with the details provided in the tfvars file for AWS environment. An example for deployment in DEV environment is
```
terraform init
terraform apply -var-file=aws_dev.tfvars
```
Or if running from a different folder from script
```
terraform -chdir=<PATH>/aws_tanium init
terraform -chdir=<PATH>/aws_tanium plan -var-file=aws_dev.tfvars
terraform -chdir=<PATH>/aws_tanium apply -var-file=aws_dev.tfvars
terraform -chdir=<PATH>/aws_tanium destroy -var-file=aws_dev.tfvars
```
