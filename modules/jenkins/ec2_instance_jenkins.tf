resource "aws_vpc" "vpc_main" {
  cidr_block = "${var.cidr_block}"
  enable_dns_support   = "${var.dns_support}"
  enable_dns_hostnames = "${var.dns_hostnames}"

  tags = {
    Name = "${var.username}-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.vpc_main.id}"
  cidr_block              = "${var.subnet_cidr}"
  map_public_ip_on_launch = "${var.publicip_on_launch}"
  tags = {
    Name                  = "Public Subnet"
  }
}

resource "aws_security_group" "allow_web" {
  name        = "allow-web-traffic"
  description = "Allow all inbound/outbound traffic on 80 443"
  vpc_id      = "${aws_vpc.vpc_main.id}"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow-ssh-traffic"
  description = "Allow ssh traffic on 22"
  vpc_id      = "${aws_vpc.vpc_main.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc_main.id}"
  tags = {
    "Environment" = "${var.igw_tag}"
  }
}

resource "aws_route_table" "rtb_public" {
  vpc_id = "${aws_vpc.vpc_main.id}"
route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.igw.id}"
  }
tags = {
    "Environment" = "${var.rtb_tag}"
  }
}

resource "aws_route_table_association" "rta_subnet_public" {
  subnet_id      = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.rtb_public.id}"
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "tui-jenkins-new"
  public_key = "${tls_private_key.example.public_key_openssh}"
}

resource "aws_instance" "jenkins_server" {
  ami           = "${var.ami_id}"
  instance_type = "${var.instance}"
  #key_name      = "${var.key}"
  key_name      = "${aws_key_pair.generated_key.key_name}"
  vpc_security_group_ids = ["${aws_security_group.allow_ssh.id}","${aws_security_group.allow_web.id}"]
  subnet_id     = "${aws_subnet.public.id}"

  provisioner "remote-exec" {
  connection {
      type = "ssh"
      user = "ubuntu"
      host  = "${aws_instance.jenkins_server.public_ip}"
      private_key = "${tls_private_key.example.private_key_pem}"
    }

   inline = [
   "sudo apt update -y",
   "sudo apt-get install openjdk-8-jdk --assume-yes",
   "sudo apt-get install nginx --assume-yes",
   "wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | sudo apt-key add -",
   "sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'",
   "sudo apt-get update -y",
   "sudo apt-get install jenkins --assume-yes"
   ]
  }
}
