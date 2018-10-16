# Exercise 1: Building an AMI With Packer

## Tasks

1. Update your individual variables file to ensure it has the required details so you'll be able to ssh to the instance and differentiate it from each other
2. Build the AMI through Packer
3. Update the `001_bootstrap.sh` script to ensure that the cURL package is installed
4. Build the new AMI through Packer

## Further Tasks

If you want to take these things further, you could look to complete the following:

* Add an additional EBS volume to the AMI (look at both `ami_block_device_mappings` & `launch_block_device_mappings`)
* Preconfigure parts of the operating system as part of the build
* Look to share the resulting AMI with another account or make it public
* Ensure the EBS volumes used by the AMI are encrypted (look for `encrypt_boot` & `encrypted` parameters)