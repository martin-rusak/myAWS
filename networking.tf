# ===================================================================
# Networking Config File
# This file contains all the assicated blocks related to networking
# ===================================================================


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

# AWS Elastic Load Balancer
resource "aws_elb" "webapp-elb" {
  name               = "webapp-elb"
  subnets            = var.public_subnets
  availability_zones = slice(data.aws_availability_zones.available.names, 0, var.subnet_count)

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 10
  }

  security_groups = ["${aws_security_group.webapp_http_inbound_sg.id}"]

  tags = var.tags

  depends_on = [
    aws_security_group.webapp_http_inbound_sg
  ]
}
