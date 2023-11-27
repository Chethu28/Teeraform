module "ec2_instance" {
    source = "./modules/ec2-instance"
    ami_value = "ami-06aa3f7caf3a30282"
    instance_type_name = "t2.micro"
}
