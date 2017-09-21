variable "region" {
    default = "us-east-2"
}

provider "aws" {
    region = "${var.region}"
}

resource "aws_s3_bucket" "terraform_state" {
    bucket = "aws-example-terraform-state"

    versioning {
        enabled = true
    }

    lifecycle {
        prevent_destroy = true
    }
}