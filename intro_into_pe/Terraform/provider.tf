# declare a the provider we can use to connect to aws
provider "aws" {
  region = "${var.aws_region}"
}
