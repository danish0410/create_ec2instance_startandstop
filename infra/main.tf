provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {
  state = "available"
}

# ────────────────────────────────────────────────
# VPC MODULE
# ────────────────────────────────────────────────
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.5.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs                 = data.aws_availability_zones.available.names
  public_subnets      = var.public_subnets
  public_subnet_names = var.public_subnet_names

  public_subnet_tags = {
    subnet                   = "public"
    "kubernetes.io/role/elb" = "1"
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

# ────────────────────────────────────────────────
# SECURITY GROUP - PUBLIC EC2
# ────────────────────────────────────────────────
resource "aws_security_group" "public_ec2_sg" {
  name        = "public-ec2-sg"
  description = "Allow SSH from current public IP"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow SSH from your IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.cidr_blocks_ingress_bastion
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.cidr_blocks_egress
  }

  tags = {
    Name = "public-ec2-sg"
  }
}

# ────────────────────────────────────────────────
# EC2 INSTANCE - PUBLIC ONLY
# ────────────────────────────────────────────────
resource "aws_instance" "public_ec2" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = element(module.vpc.public_subnets, 0)
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.public_ec2_sg.id]
  associate_public_ip_address = true
  user_data                   = file("${path.module}/dev_classic_userdata.sh")

  tags = {
    Name = "public-ec2"
  }

  # Optional: simple test provisioner
  provisioner "remote-exec" {
    inline = [
      "echo 'Terraform EC2 setup complete!' > /home/ubuntu/setup-status.txt"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/${var.key_name}.pem")
      host        = self.public_ip
    }
  }
}