# Vault Integration with AWS EC2 Instance and Terraform

This repository provides a guide for integrating HashiCorp Vault with an AWS EC2 instance running Ubuntu and configuring Terraform to read secrets from Vault.

## Table of Contents

- [Introduction](#introduction)
- [Step 1: Create an AWS EC2 Instance with Ubuntu](#step-1-create-an-aws-ec2-instance-with-ubuntu)
- [Step 2: Install Vault on the EC2 Instance](#step-2-install-vault-on-the-ec2-instance)
  - [Download the signing key to a new keyring](#download-the-signing-key-to-a-new-keyring)
  - [Verify the key's fingerprint](#verify-the-keys-fingerprint)
  - [Add the HashiCorp repo](#add-the-hashicorp-repo)
  - [Install Vault](#install-vault)
- [Step 3: Start Vault](#step-3-start-vault)
- [Step 4: Configure Terraform to Read Secrets from Vault](#step-4-configure-terraform-to-read-secrets-from-vault)
  - [Enable AppRole Authentication in Vault](#enable-approle-authentication-in-vault)
- [Conclusion](#conclusion)

## Introduction

This guide provides detailed steps for integrating HashiCorp Vault with an AWS EC2 instance running Ubuntu and configuring Terraform to read secrets from Vault. The process involves creating an EC2 instance, installing Vault on the instance, starting Vault, and configuring Terraform to authenticate using Vault's AppRole method.

## Step 1: Create an AWS EC2 Instance with Ubuntu

1. Navigate to the AWS Management Console.
2. Go to the EC2 service.
3. Click "Launch Instance."
4. Select the "Ubuntu Server xx.xx LTS" AMI.
5. Choose your desired instance type.
6. Configure instance settings.
7. Click "Launch."

## Step 2: Install Vault on the EC2 Instance

### Download the signing key to a new keyring
```
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
```

### Verify the key's fingerprint
```
gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint
```

### Add the HashiCorp repo
```
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
```

```
sudo apt update
```

### Install Vault
```
sudo apt install vault
```

## Step 3: Start Vault

### Start Vault with the following command:
```
vault server -dev -dev-listen-address="0.0.0.0:8200"
```

## Step 4: Configure Terraform to Read Secrets from Vault


### Enable AppRole Authentication in Vault
  ### Enable AppRole authentication:
```
vault auth enable approle

```

### Create a policy (e.g., terraform) in Vault:
```
# Use the provided policy configuration or create your own
vault policy write terraform - <<EOF
path "*" {
  capabilities = ["list", "read"]
}

path "secrets/data/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "kv/data/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}


path "secret/data/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "auth/token/create" {
capabilities = ["create", "read", "update", "list"]
}
EOF
```


### Create an AppRole and associate the policy:
```
vault write auth/approle/role/terraform \
    secret_id_ttl=10m \
    token_num_uses=10 \
    token_ttl=20m \
    token_max_ttl=30m \
    secret_id_num_uses=40 \
    token_policies=terraform

```
### Generate Role ID and Secret ID:
## Generate Role ID:
```
vault read auth/approle/role/terraform/role-id
```

### Generate Secret ID:
```
vault write -f auth/approle/role/terraform/secret-id
```

## Save the Role ID and Secret ID for use in your Terraform configuration.

## Conclusion
### You have successfully set up an AWS EC2 instance with Ubuntu, installed and started Vault, and configured Terraform to authenticate using Vault's AppRole method. This integration enhances security by centralizing and managing secrets with HashiCorp Vault.
