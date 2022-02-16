# ===========================================================
# Variable Config File
# ===========================================================

# AWS Region
variable "myAWSregion" {
  description = "Default AWS Region"
  type        = string
  default     = "ca-central-1"
}

# AWS CIDRs
variable "AWScidr" {
  description = "My AWS CIDR range"
  type        = string
  default     = "10.0.0.0/16"
}

# Subnet Count
variable "subnet_count" {
  description = "My subnet count"
  type        = number
  default     = 2
}

# Private Subnets
variable "private_subnets" {
  description = "My private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.3.0/24"]
}

# Public Subnets
variable "public_subnets" {
  description = "My public subnets"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.2.0/24"]
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Terraform   = "true"
    Environment = "POC"
  }
}