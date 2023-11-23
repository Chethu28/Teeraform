
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

resource "aws_security_group" "websg" {
    ingress {
    description = "HTTP for VPC"
    from_port       = 80
    to_port         = 80
    protocol        =  TCP
    cidr_block = ["0.0.0.0/0"] 
  }

    ingress {
    description = "ssh"
    from_port       = 22
    to_port         = 22
    protocol        =  TCP
    cidr_block = ["0.0.0.0/0"] 
  }
    egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
    tags = {
        Name = "websg"
    }
}

resource "aws_instance" "webserver1" {
    ami = "ami-06aa3f7caf3a30282"
    tags = {
        Name = "webserver1"
    }
    instance_type = "t2.micro"
    subnet_id = aws_subnet.subnet1.id
    vpc_security_group_ids = [aws_security_group.websg.id]
    #vpc_subnet_id = aws_subnet.subnet1.id
     user_data   = base64encode(file("userdata.sh"))
}

resource "aws_instance" "webserver2" {
    ami = "ami-06aa3f7caf3a30282"
    tags = {
        Name = "webserver2"
    }
    instance_type = "t2.micro"
    subnet_id = aws_subnet.subnet2.id
    vpc_security_group_ids = [aws_security_group.websg.id]
    #vpc_subnet_id = aws_subnet.subnet2.id
     user_data   = base64encode(file("userdata.sh"))
}

resource "aws_lb" "ALB" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.websg.id]
  subnet_id = [aws_subnet.subnet1.id , aws_subnet.subnet2.id]
  tags = {
    Name = "ALB"
  }
}
resource "aws_lb_target_group" "ALBTG" {
  name     = "MyTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myVPC.id

  healtch_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_listener" "ALBlistener" {
  load_balancer_arn = aws_lb.ALB.arn
  port              = "80"
  protocol          = "HTTP"
  #ssl_policy        = "ELBSecurityPolicy-2016-08"
  #certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ALBTG.arn
  }
}

output "loadbalancerdns" {
  value = aws_lb.ALB.dns_name
}
