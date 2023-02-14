variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones to use for subnets."
  #   default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "aws_region" {
  type        = string
  description = "AWS Region"
  # default = "us-east-1"
}

variable "aws_dev_profile" {
  type = string
}

variable "aws_demo_profile" {
  type = string
}

variable "cidr_block" {
  type        = string
  description = "CIDR Block for aws_vpc"
  # default = "10.0.0.0/16"
}

variable "public_tag" {
  type = string
  # default = "public"
}

variable "public_subnet_name" {
  type = string
  # default = "public_subnet_"
}

variable "private_tag" {
  type = string
  # default = "private"
}

variable "private_subnet_name" {
  type = string
  # default = "private_subnet_"
}

variable "subnet_prefix" {
  type = string
  # default = "10.0."
}

variable "subnet_suffix" {
  type = string
  # default = ".0/24"
}

variable "public_route_table_cidr" {
  type = string
  # default = "0.0.0.0/0"
}