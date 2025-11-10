variable "region" {
  description = "AWS region for deployment"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "cidr_blocks_egress" {
  description = "CIDR blocks allowed for egress traffic"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
  default     = ["10.0.101.0/24"]
}

variable "public_subnet_names" {
  description = "Names for public subnets"
  type        = list(string)
  default     = ["public-ap-south-1a"]
}

variable "ami" {
  description = "AMI ID to use for EC2 instances"
  type        = string
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}

variable "windows_key" {
  description = "Name of the Windows key pair"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "cidr_blocks_ingress_bastion" {
  description = "CIDR blocks allowed for SSH access to bastion or EC2"
  type        = list(string)
  default     = ["45.119.28.163/32"]
}