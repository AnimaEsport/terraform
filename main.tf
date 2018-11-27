provider "aws" {
    region = "eu-west-3"
}

resource "aws_vpc" "main" {
    cidr_block           = "172.16.0.0/16"
    enable_dns_hostnames = true
}

resource "aws_internet_gateway" "main" {
    vpc_id = "${aws_vpc.main.id}"
}
