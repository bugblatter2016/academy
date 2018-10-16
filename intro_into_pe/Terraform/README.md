# Exercise 2: Provisioning AWS Environment with Terraform

## Tasks

1. Update your tfvars file with the required variables and values
2. Test your code to see what infrastructure will be deployed `terraform plan -var-file=<your var file>.tfvars`
3. Provision the AWS infrastructure using `terraform apply -var-file=<your var file>.tfvars`
4. Test your environment with SSH and a Web Browser
5. Destroy the created infrastructure using `terraform destroy -var-file=<your var file>.tfvars`

## Further Tasks

If you want to take these things further, you could look to complete the following:

* Split the resources out into their own `.tf` files to make them simpler to manage
* Create some private subnets for the instances to sit in and public subnet for ELBs and required route tables
* Create modules for code reuse across multiple components / environments