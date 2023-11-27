provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "example" {
    ami = "ami-0fc5d935ebf8bc3bc"
    instance_type = "t2.micro"  
}

resource "aws_s3_bucket" "statefilebackup" {
    bucket = "mytfstatefile11111"
}

resource "aws_dynamodb_table" "terraform-lock" {
  name           = "terraform-lock"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockId"
  attribute {
    name = "LockId"
    type = "S"
  }
}