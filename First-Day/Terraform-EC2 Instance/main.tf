  provider "aws" {
     region = "us-east-1"  # Set your desired AWS region
   }

   resource "aws_instance" "First-ec2-with-terraform" {
     ami           = ""  # Specify an appropriate AMI ID
     instance_type = "t2.micro"
     key-name = "mykey"
   }
