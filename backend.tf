# ===========================================================
# Backend State Config Block File
# ===========================================================
terraform {
  backend "remote" {
    # Terraform Cloud Config  
    organization = "Rusakmedia"
    workspaces {
      name = "myAWS"
    }
  }
}
