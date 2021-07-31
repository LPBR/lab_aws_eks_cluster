# [LAB] AWS EKS cluster

A laboratory for EKS cluster creation with multiple availability zones using terraform


## Dependencies
 - AWS CLI (https://github.com/aws/aws-cli)
    > Execute `$ aws configure ` (https://github.com/aws/aws-cli#configuration)
 - Terraform (https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Usage
Install terraform dependencies
```
$ terraform init
```

Previews the execution plan and apply it
```
$ terraform plan
$ terraform apply
```

## Clean up
To clean up created resources and avoid costs don't forget to run
```
$ terraform destroy
```
