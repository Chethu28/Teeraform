provider "aws" {
    region = "us-east-1"
}

variable "cidr" {
    default = "10.0.0.0/16"
}

resource "aws_key_pair" "mykey" {
  key_name   = "mykey-pair"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_vpc" "myvpc" {
    cidr_block = var.cidr
}

resource "aws_subnet" "mysubnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.myvpc.id
}
resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "RTA1" {
  subnet_id      = aws_subnet.mysubnet.id
  route_table_id = aws_route_table.RT.id
}

resource "aws_security_group" "sg" {
  name        = "web"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description      = "http protocal"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  
   ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg"
  }
}

resource "aws_instance" "myinstance" {
  ami                     = "ami-0fc5d935ebf8bc3bc"
  instance_type           = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg.id]
  key_name = aws_key_pair.mykey.key_name
  subnet_id = aws_subnet.mysubnet.id 
  
    connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    host     = self.public_ip
  }

  provisioner "file" {
    source      = "app.py"
    destination = "/home/ubuntu/app.py"
  }
    provisioner "remote-exec" {
    inline = [
      "echo 'Hello from the instance'",
      "sudo apt update -y",
      "sudo apt-get install -y python3-pip",
      "cd /home/ubuntu",
      "sudo pip3 install flask",
      "sudo python3 app.py ",
    ]
  }
}