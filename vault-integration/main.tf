provider "aws" {
  region = "us-east-1"
}

provider "vault" {
  address = "http://0.0.0.0:8200"
  skip_child_token = true
  auth_login {
    path = "auth/approle/login"

    parameters = {
      role_id = "ur-role-id"
      secret_id = "ur-secrets"
    }
  }
}

data "vault_kv_secret_v2" "example" {
  mount = "kv"
  name  = "mysecret"
}

resource "aws_instance" "example" {
    ami = "ami-0fc5d935ebf8bc3bc"
    instance_type = "t2.micro"
    tags = {
      Name = data.vault_kv_secret_v2.example.data["name"]
    }
}

resource "aws_s3_bucket" "example" {
  bucket = data.vault_kv_secret_v2.example.data["name"]
}