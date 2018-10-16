variable "public_key_path" {
  type        = "string"
  description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect.
Example: ~/.ssh/terraform.pub
DESCRIPTION
}

variable "aws_region" {
  type        = "string"
  description = "AWS region to launch servers."
  default     = "us-west-1"
}

variable "aws_amis" {
  type        = "map"
  description = "Map of AMI IDs for each AWS region"
}

variable "owner" {
  type        = "string"
  description = "Name of the owner of the resources"
}

variable "vpc_cidr_block" {
  type        = "string"
  description = "The CIDR block of the vpc"
}

variable "default_subnet_cidr_block" {
  type        = "string"
  description = "The CIDR block of the default subnet"
}