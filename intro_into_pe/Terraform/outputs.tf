# output the name of dns address of our elb so we can connect to it
output "address" {
  value = "${aws_elb.web.dns_name}"
}