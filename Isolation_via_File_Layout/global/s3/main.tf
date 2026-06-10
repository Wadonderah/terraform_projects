# bACKEND  S3 BUCKET.
terraform {
  backend "s3" {
    bucket         = "wadoh"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "wadoh-1"
    encrypt        = true
  }
}
