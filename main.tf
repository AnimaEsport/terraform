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

resource "aws_security_group" "wp_lb_sg" {
    name = "wp-lb"
    description = "Security Group for Wordpress load balancer"
    vpc_id = "${aws_vpc.main.id}"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "wp_web_sg" {
    name = "wp-web"
    description = "Security Group for Wordpress web server"
    vpc_id = "${aws_vpc.main.id}"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "wp_db_sg" {
    name = "wp-db"
    description = "Security Group for Wordpress database"
    vpc_id = "${aws_vpc.main.id}"

    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        self = true
    }
}

resource "aws_db_subnet_group" "wp_db" {
  name       = "main"
  subnet_ids = ["${aws_subnet.public.*.id}"]
}

resource "aws_rds_cluster" "wp_db" {
  cluster_identifier      = "wp-db"
  database_name           = "wordpress"
  master_username         = "root"
  master_password         = "${var.db_password}"
  backup_retention_period = 5
  preferred_backup_window = "05:00-06:00"
  vpc_security_group_ids  = ["${aws_security_group.wp_db_sg.id}"]
  db_subnet_group_name    = "${aws_db_subnet_group.wp_db.name}"
  skip_final_snapshot     = true
}

resource "aws_rds_cluster_instance" "wp_db" {
    count              = 2
    identifier         = "wp-db-${count.index}"
    cluster_identifier = "${aws_rds_cluster.wp_db.id}"
    instance_class     = "db.t2.small"
}