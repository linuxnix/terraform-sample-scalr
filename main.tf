




provider "aws" {
  region = "us-east-1"
  version = "~> 2.0"
}
//creatting vpc
resource "aws_vpc" "vpc" {
  cidr_block = "${var.cidr_vpc}"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Environment = "${var.environment_tag}"
    Name = "${var.environment_tag}_Terraform_VPC"
  }
}
//creating internet gate way
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Environment = "${var.environment_tag}"
    Name = "${var.environment_tag}_Terraform_internet_gateway"
  }
}

//creating public subnet with vpc
resource "aws_subnet" "subnet_public" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${var.cidr_subnet}"
  map_public_ip_on_launch = "true"
  availability_zone = "${var.availability_zone}"
  tags = {
    Environment = "${var.environment_tag}"
    Name = "${var.environment_tag}_Terraform_Public_subnet"

  }
}
//creating route table
resource "aws_route_table" "rtb_public" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = {
    Environment = "${var.environment_tag}"
    Name = "${var.environment_tag}_Terraform_RTB"
  }
}

// subnet assosiation with route table
resource "aws_route_table_association" "rta_subnet_public" {
  subnet_id      = "${aws_subnet.subnet_public.id}"
  route_table_id = "${aws_route_table.rtb_public.id}"
}


//creating security group
resource "aws_security_group" "sg_22" {
  name = "sg_22"
  vpc_id = "${aws_vpc.vpc.id}"
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Environment = "${var.environment_tag}"
    Name = "${var.environment_tag}_Terraform_SG"
  }
}



resource "aws_instance" "testInstance" {
  ami           = "${var.instance_ami}"
  instance_type = "${var.instance_type}"
  subnet_id = "${aws_subnet.subnet_public.id}"
  vpc_security_group_ids = ["${aws_security_group.sg_22.id}"]
  user_data = "<<- EOF
               mkdir /var/log/ts
  EOF"
  key_name = "chandukey" 

  
  tags = {
    Environment = "${var.environment_tag}"
    Name = "${var.environment_tag} Ec2 Terraformm"
  }
}
