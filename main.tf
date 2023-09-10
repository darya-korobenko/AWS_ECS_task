terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "dkorobenko"

    workspaces {
      name = "learning-terraform"
    }
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.1.0"
    }
  }
}
