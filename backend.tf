terraform {
  backend "s3" {
    bucket = "erakiterrafrom-statefiles-data-backup"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
