data "aws_ami" "latest_ami" {
  most_recent = true
  filter {
    name   = "name"
    values = ["webapp-ami-*"]
  }
}

resource "aws_security_group" "sg_webapp_dev" {
  name        = var.security_group
  description = "security group for ec2-webapp-dev"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.security_group
  }
}

resource "aws_instance" "ec2-webapp-dev" {
  count                       = 1
  ami                         = data.aws_ami.latest_ami.id
  key_name                    = var.aws_keypair_dev
  instance_type               = var.instance_type
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_subnets[0].id
  vpc_security_group_ids      = [aws_security_group.sg_webapp_dev.id]
  root_block_device {
    volume_size = 50
    volume_type = "gp2"
  }
  disable_api_termination = false
  tags = {
    Name = var.ec2_tag_name
  }
}