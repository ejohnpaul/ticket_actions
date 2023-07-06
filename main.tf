terraform {
  required_version = "~> 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  backend "s3" {
    bucket = "landmark-automation-kenmak"
    key    = "prod/terraform.tfstate"
    region = "us-west-2"
    #dynamodb_table = "terraform-lock"
  }
}

#2. Provider block: plugin /api

provider "aws" {
  #profile = "docker"
  region = "us-west-2"
  default_tags {
    tags = local.default_tags
  }
}

#3. Resource block:
resource "aws_instance" "bootcamp30" {
  # ami = "ami-0e5b6b6a9fdb6db8" # Amazon Linux
  ami           = data.aws_ami.amzlinux2.id
  instance_type = var.instance_type
  #instance_type = "t2.micro"
  #delete_on_termination = true

  tags = {
    Name = local.name
  }
}

#4. Variables block / inputs:

variable "instance_type" {
  description = "EC2 Instance Type"
  #type = list(string)
  type    = any
  default = "t2.micro"
  #default = ["t2.micro", "t2.medium", "t3.large"]
}

variable "environment" {
  description = "environment"
  type        = string
  default     = "prod"
}

variable "app_name" {
  description = "app name"
  type        = string
  default     = "jenkins"
  #default = ["t2.micro", "t2.medium", "t3.large"]
}
#5. Output blocks:

output "public_ip" {
  description = "ec2 instance public ip"
  value       = aws_instance.bootcamp30.public_ip
}

output "az" {
  description = "ec2 instance public ip"
  value       = aws_instance.bootcamp30.availability_zone
}

#6. local value blocks:

locals {
  name = "${var.app_name}-${var.environment}"
  #portfolio = "bootcamp30-prod-jenkins-HR"
  default_tags = {
    "Ken:Department" = "DevOps"
    "Ken:Portfolio"  = "CloudOps"
    "Ken:ManagedBy"  = "Terraform"
  }
}
#jenkins-production

data "aws_region" "current" {}

#7. Data sources:
data "aws_ami" "amzlinux2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}
/*
8. Modules block:

module "ec2" {
source = "./my_instance"
version = "1.0.1"

"t2.medium"
}

9. Moved blocks:

moved {
from = "aws_instance.bootcamp30 "
to = "aws_instance.bootcamp31 "
}
*/