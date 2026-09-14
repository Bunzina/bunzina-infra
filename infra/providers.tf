provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "bunzina"
      ManagedBy = "terraform"
    }
  }
}


