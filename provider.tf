terraform {
  required_providers {
    aws ={
        source = "hashicorp/aws"
    }
  }
  backend "s3" {
    bucket = "dev-s3-bucket-tfstate-aws03"
    key = "terraform/terraform.tfstate"
    region = "ap-northeast-2"
    dynamodb_table = "terraform-tfstate-lock"
  }
}

provider "aws" {
    region = var.aws_region
    access_key = var.iam_private_key
    secret_key = var.iam_secret_key
}