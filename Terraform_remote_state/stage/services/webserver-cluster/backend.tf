terraform {
  backend "s3" {
    bucket = "wadoh-terraform-state"
    key    = "stage/services/webserver-cluster/terraform.tfstate"
    region = "us-east-2"
    use_lockfile = true
  }
}