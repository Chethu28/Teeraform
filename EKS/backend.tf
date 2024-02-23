terraform {
  backend "s3" {
    bucket = "jenkins-eks-1936"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"
  }
}