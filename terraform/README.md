# Commit cronjob application
Terraform stack for cronjob deployment

## Prerequisites
The following are needed to prepare the infrastructure:
* install awscli, helm
* set up aws credentials: `aws configure --profile=<profile name>`
* set default AWS profile: `export AWS_PROFILE=<profile name>`

## Bootstraping the AWS infrastructure
Please follow the [Bootstrap documentation](https://github.com/celticmask/commit/blob/main/terraform/bootstrap/README.md) for initializing the S3 bucket and DynamoDB table

## Deploying infrastructure
1. Put values to variables.auto.tfvars (change server URL as well)
2. Run stack
```bash
terraform init
terraform apply
```

Resources created by Terraform stack overview
* VPC
* Private subnets, Public subnets, NATs, etc.
* App. ECR
* EKS cluster
* NGINX ingress controller
* Kubernetes service account for Cronjob
* Cronjob namespace
* Cronjob
