
resource "aws_vpc" "myVPC" {
    cidr_block= "10.0.0.0/16"
    tags = {
       Name = "VPC1"
    }
}
resource "aws_subnet" "subnet1" {
    vpc_id = aws_default_vpc.myVPC.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    tags = {
        Name = "subnet1"
    }
    map_public_ip_on_launch = "true"
}

resource "aws_subnet" "subnet2" {
    vpc_id = aws_default_vpc.myVPC.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1b"
    tags = {
        Name = "subnet2"
    }
    map_public_ip_on_launch = "true"
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.myVPC.id
    tags = {
        Name = "myigw"
    }
}

resource "aws_route_table" "myroutetables" {
    vpc_id = aws_vpc.myVPC.id
    tags = {
        Name = "myroutetables"
    }
    route {
    cidr_block = "10.0.1.0/24"
    gateway_id = aws_internet_gateway.igw.id
  }
}
resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.myroutetables.id
}

resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.myroutetables.id
}