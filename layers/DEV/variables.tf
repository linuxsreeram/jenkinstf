variable  "username" { default = "datascienceuser"}
variable "region" { default = "eu-central-1" }
variable "cidr_block" { default = "192.168.0.0/16" }
variable "dns_support" { default = "true" }
variable "dns_hostnames" { default = "true" }
variable "subnet_cidr" {default = "192.168.0.1/24" }
variable "publicip_on_launch" { default = "true" }
variable "igw_tag" { default = "jenkins-igw" }
variable "rtb_tag" { default = "jenkins-rtb-public" }
variable "ami_id" { default = "ami-050a22b7e0cf85dd0" }
variable "instance" { default = "t2.micro"}
variable "key" { default = "jenkins-test"}
