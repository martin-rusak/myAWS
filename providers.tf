# ===================================================================
# Providers Terraform File
# This file contains all the assicated blocks related to providers
# ===================================================================
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.1.0"
    }
  }
}

# ===================================================================
# AWS Provider
# ===================================================================
provider "aws" {
  region = var.myAWSregion
}