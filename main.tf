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

resource "aws_subnet" "public" {
    vpc_id                  = "${aws_vpc.main.id}"
    count                   = 2
    cidr_block              = "${element(split(",", "172.16.10.0/24,172.16.20.0/24"), count.index)}"
    availability_zone       = "${element(split(",", "eu-west-3a,eu-west-3b"), count.index)}"
    map_public_ip_on_launch = true
}

resource "aws_route_table" "public" {
    vpc_id = "${aws_vpc.main.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.main.id}"
    }
}

resource "aws_route_table_association" "public" {
    count          = 2
    subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
    route_table_id = "${aws_route_table.public.id}"
}