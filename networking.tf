# ===================================================================
# Networking Config File
# This file contains all the assicated blocks related to networking
# ===================================================================


# ===================================================================
# Networking Data
# ===================================================================

# AWS AZS Data
data "aws_availability_zones" "available" {}


# ===================================================================
# Networking Resources
# ===================================================================

# AWS VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  name    = "Terraform-POC"
  version = "3.12.0"

  cidr            = var.AWScidr
  azs             = slice(data.aws_availability_zones.available.names, 0, var.subnet_count)
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true

  create_database_subnet_group = false

  tags = var.tags
}