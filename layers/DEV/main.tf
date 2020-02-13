provider "aws" {
  region  = var.region
}

terraform {
  backend "s3" {
    bucket = "tui-state-files"
    key    = "jenkins/statefile"
    region  = "eu-central-1"
  }
}

module "network" {
  source = "../../modules/jenkins"

  username  = var.username
  region  = var.region
  cidr_block		=	var.cidr_block
  dns_support		=	var.dns_support
  dns_hostnames		=	var.dns_hostnames
  subnet_cidr		=	var.subnet_cidr
  publicip_on_launch	=	var.publicip_on_launch
  igw_tag			=	var.igw_tag
  rtb_tag			=	var.rtb_tag
  ami_id			=	var.ami_id
  instance		=	var.instance
  key			=	var.key

}
