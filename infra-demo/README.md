# infra-demo

Small demo project showing:

- Terraform provisioning in AWS
- Puppet code stored in Git
- Jenkins pipeline to deploy an EC2 instance
- Jenkins triggering Puppet after provisioning

## Project structure

infra-demo/
├── README.md
├── Jenkinsfile
├── terraform/
│   ├── main.tf
│   └── dev.tfvars
└── puppet/
    ├── bolt-project.yaml
    ├── inventory.yaml
    ├── site.pp
    └── modules/
        └── profile/
            └── manifests/
                └── webserver.pp

## What it does

1. Jenkins checks out this repo
2. Jenkins runs `terraform init`
3. Jenkins runs `terraform plan`
4. Jenkins pauses for approval
5. Jenkins runs `terraform apply`
6. Jenkins gets the EC2 public IP from Terraform output
7. Jenkins updates the Bolt inventory
8. Jenkins runs Puppet code to install and start nginx

## Prerequisites

- AWS account
- Jenkins server
- Terraform installed on Jenkins
- AWS CLI installed on Jenkins
- Puppet Bolt installed on Jenkins
- Jenkins credentials configured for AWS
- SSH private key available to Jenkins if using SSH/Bolt
- Existing key pair name in AWS for EC2 access

## First run

### Terraform locally

cd terraform
terraform init
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars

### Destroy when finished

terraform destroy -var-file=dev.tfvars

## Notes

This is a starter project. It is intentionally simple.

Later improvements:
- move Terraform state to S3
- add state locking
- use SSM instead of SSH
- split Terraform into modules
- add dev/test environments
