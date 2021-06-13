data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
 
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
 
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
 
  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*"]
  }
 
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
 
  filter {
    name   = "block-device-mapping.volume-type"
    values = ["gp2"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
 
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
 
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
 
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "ec2" {
  name   = var.name
  vpc_id = var.vpc_id

  dynamic "ingress" {
      for_each = var.ingress_ports
      content {
          from_port   = ingress.value
          to_port     = ingress.value
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
      }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.name
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_key_pair" "default" {
  key_name   = var.key_name
  public_key = var.public_key
}

resource "aws_instance" "default" {
  ami           = var.ami_type == "amazon_linux" ? data.aws_ami.amazon_linux.id : data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = aws_key_pair.default.id
  vpc_security_group_ids  = [aws_security_group.ec2.id]

  tags = {
    Name = var.name
  }
}

resource "aws_eip" "default" {
  instance = aws_instance.default.id
}