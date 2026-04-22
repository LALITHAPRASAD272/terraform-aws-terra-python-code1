terraform {
  backend "s3" {
    bucket = "prasad-terraform-state-bucket"
    key    = "project/terraform.tfstate"
    region = "ap-south-2"
  }
}