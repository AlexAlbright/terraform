locals {
  region      = "us-east-1"
  environment = "test"
  tld         = "alexalbright.com"    # Top Level Domain that apps will use
  email       = "alexalbright@me.com" # For issuing certificates
  account_id  = "${get_aws_account_id()}"
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "terraform-state-bucket-${local.account_id}"
    key            = "${local.environment}/${path_relative_to_include()}/terraform.tfstate"
    region         = local.region
    encrypt        = true
    dynamodb_table = "${local.environment}-${local.account_id}-terraform-state-lock"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.region}"
  default_tags {
    tags = {
      Environment = "${local.environment}"
      Stack = var.stack
    }
  }
}
EOF
}
