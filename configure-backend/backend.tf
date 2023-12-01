terraform {
  backend "s3" {
    bucket = "mytfstatefile11111"
    key    = "mytfstatefile11111/statefile.tfstate"
    region = "us-east-1"
    encrypt = true
    dynamodb_table = "terraform-lock"
  }
}