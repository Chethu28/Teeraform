provider "aws" {
    region = "us-east-1"
}

variable "ami_value" {
    description = "value of the ami"
}

variable "instance_type" {
    description = "value of the instance type example t2.micro"
  
}

resource "aws_instance" "example" {
    ami = var.ami_value
    instance_type = var.instance_type
  
}