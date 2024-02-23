################## vpc ####################
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "vpc-eks"
  cidr = var.cidr

  azs = data.aws_availability_zones.availability_zones.names
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  #map_public_ip_on_launch = false
  enable_dns_hostnames    = true
  enable_nat_gateway = true
  single_nat_gateway = true
  #enable_vpn_gateway = true\

  tags = {
    "kubernetes.io/cluster/my-eks-cluster" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/my-eks-cluster" = "shared"
    "kubernetes.io/role/elb"               = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/my-eks-cluster" = "shared"
    "kubernetes.io/role/internal-elb"      = 1
  }

}
############################## EKS ##########################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"

  cluster_name    = "my-eks-cluster"
  cluster_version = "1.24"

  cluster_endpoint_public_access  = true

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets


  eks_managed_node_groups = {
    example = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_types = ["t2.small"]
    }
  }

  # Cluster access entry
  # To add the current caller identity as an administrator
 # enable_cluster_creator_admin_permissions = true

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
