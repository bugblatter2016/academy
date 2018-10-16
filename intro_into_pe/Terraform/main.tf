# create a vpc
# this is the basic building block for our architecture and is where we'll
# deploy all other resources into
resource "aws_vpc" "default" {
  cidr_block           = "${var.vpc_cidr_block}"
  enable_dns_hostnames = "true"
  enable_dns_support   = "true"

  tags {
    Name    = "${var.owner}-main-vpc",
    Owner   = "${var.owner}",
    Project = "IntroductionToPlatformEngineering"
  }
}

# create an internet gateway
# adding an internet gateway will ensure that we can connect to resources from
# outside of the vpc
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name    = "${var.owner}-main-igw",
    Owner   = "${var.owner}",
    Project = "IntroductionToPlatformEngineering"
  }
}

# grant the main route table of the vpc internet access via the internet
# gateway.
#
# note: this is not really the right way to do this, normally the default would
# be no internet access and then you would grant internet access as required on
# public subnets
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

# create a subnet that we can deploy our instance(s) into
resource "aws_subnet" "default" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "${var.default_subnet_cidr_block}"
  map_public_ip_on_launch = true

  tags {
    Name    = "${var.owner}-main-subnet",
    Owner   = "${var.owner}",
    Project = "IntroductionToPlatformEngineering"
  }
}

# the default security group for the vpc
#
# note: once again, this is not the way you would do it in a real project as it
# is giving access on port 22 to anybody
resource "aws_security_group" "default" {
  name        = "${var.owner}-main-sg"
  description = "Default security group for VPC"
  vpc_id      = "${aws_vpc.default.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = ["${aws_security_group.elb.id}"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name    = "${var.owner}-main-sg",
    Owner   = "${var.owner}",
    Project = "IntroductionToPlatformEngineering"
  }
}

# the security group for the public elb
resource "aws_security_group" "elb" {
  name        = "${var.owner}-elb-sg"
  description = "Security Group for ELB"
  vpc_id      = "${aws_vpc.default.id}"

  # inbound access to port 80 from everywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name    = "${var.owner}-elb-sg",
    Owner   = "${var.owner}",
    Project = "IntroductionToPlatformEngineering"
  }
}

# now we create an elb to sit in front of our instance
#
# in real life we'd put this in front of an auto scaling group so that instances
# could scale in or out and be load balanced
resource "aws_elb" "web" {
  name = "${var.owner}-elb"

  subnets         = ["${aws_subnet.default.id}"]
  security_groups = ["${aws_security_group.elb.id}"]
  instances       = ["${aws_instance.web.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  tags {
    Name    = "${var.owner}-elb",
    Owner   = "${var.owner}",
    Project = "IntroductionToPlatformEngineering"
  }
}

# we need to create a keypair so that we can connect to the instance via ssh
# later on a configure it
resource "aws_key_pair" "auth" {
  key_name   = "${var.owner}-key"
  public_key = "${file(var.public_key_path)}"
}

# now we create the 'web' ec2 instance using the AMI that we built in exercise 3,
# in the default subnet
resource "aws_instance" "web" {
  instance_type = "t2.micro"

  # lookup the correct AMI based on the region
  # we specified
  ami = "${lookup(var.aws_amis, var.aws_region)}"

  # the name of our ssh keypair we created above.
  key_name = "${aws_key_pair.auth.id}"

  # our Security group to allow http and ssh access
  vpc_security_group_ids = ["${aws_security_group.default.id}"]

  # we're going to launch into the same subnet as our elb. In a production
  # environment it's more common to have a separate private subnet for
  # backend instances.
  subnet_id = "${aws_subnet.default.id}"
}