provider "aws" {
    region = "us-east-1"
}

variable "ami_value" {
    description = "value of the ami"
  
}

variable "instance_type" {
    description = "value of the instance type"
    type = map(string)

    default = {
      "dev" = "t2.micro"
      "stage" = "t2.medium"
      "prod"  = "t3.micro"
    }
  
}

module "ec2instance" {
    source = "/workspaces/Teeraform/Day-6/Modules/ec2-instance"
    ami_value = var.ami_value
    instance_type = lookup(var.instance_type, terraform.workspace, "t2.small")
}