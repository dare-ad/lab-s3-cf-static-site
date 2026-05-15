provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Project   = "lab-s3-cf-static-site"
      ManagedBy = "Terraform"
      Owner     = "dare.hagans"
    }
  }
}
