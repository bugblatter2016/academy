# Exercise 4: Provisioning AWS Environment with Terraform

## Tasks

1. Update your tfvars file with the required variables and values
2. Provision the AWS infrastructure using `terraform apply -var-file=<your var file>.tfvars`
3. Destroy the created infrastructure using `terraform destry -var-file=<your var file>.tfvars`
4. Create a data subnet in the VPC (as part of this, we'll create a route table with no internet access)
5. Create a Aurora RDS instance in the VPC (as part of this we're going to create a data subnet group and security group)
6. Provision the AWS infrastructure using `terraform apply -var-file=<your var file>.tfvars`

## Further Tasks

If you want to take these things further, you could look to complete the following:

* Split the resources out into their own `.tf` files to make them simpler to manage
* Look into [Terraform Scaffold](https://github.com/Zordrak/terraformscaffold)
* Create some private subnets for the instances to sit in and public subnet for ELBs and required route tables
* Create modules for code reuse across multiple components / environments