terraform {
  backend "s3" {
    bucket = "terraform-statefile-bucket-a"
    key    = "state/file.tfstate"
    region = "eu-north-1"
    encrypt      = true
    use_lockfile = true
  }
}