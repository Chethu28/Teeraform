#################### VPC ##########################

module "ec2_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "jenkins-vpc"
  cidr = var.cidr

  azs = data.aws_availability_zones.availability_zones.names
  #private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets          = var.public_subnets
  map_public_ip_on_launch = true
  enable_dns_hostnames    = true
  #enable_nat_gateway = true
  #enable_vpn_gateway = true\

  tags = {
    name        = "ec2-jenkins-vpc"
    Terraform   = "true"
    Environment = "dev"
  }
  public_subnet_tags = {
    name = "ec2-jenkins"
  }
}

###################### SG ###########################

module "jenkins_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "jenkins-sg"
  description = "Security group for user-service with custom ports open within VPC"
  vpc_id      = module.ec2_vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "TCP"
      description = "TCP"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "TCP"
      description = "ssh"
      cidr_blocks = "0.0.0.0/0"
    }
]
  egress_with_cidr_blocks = [
  {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"  
  }  
  ]  
  tags = {

    name = "jenkins_sg"

  } 
}

######################## EC2 ########################
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "jenkins-server"

  instance_type          = var.instance_type
  key_name               = "jenkins-key"
  monitoring             = true
  vpc_security_group_ids = [module.jenkins_sg.security_group_id]
  subnet_id              = module.ec2_vpc.public_subnets[0]

  associate_public_ip_address = true 
  availability_zone = data.aws_availability_zones.availability_zones.names[0]

  user_data = file("jenkins-terraform-kubectl.sh")

  tags = {
    name = "jenkins-server"
    Terraform   = "true"
    Environment = "dev"
  }
}