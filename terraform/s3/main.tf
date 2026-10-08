terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "terraform-modulo3"
}

resource "aws_s3_bucket" "backup" {
  bucket = "bucket-codigo-backup-psokev99-modulo3"

  tags = {
    Name    = "bucket-codigo-backup-psokev99-modulo3"
    Project = "Modulo3-DevOps"
    Purpose = "Database-Backups"
  }
}

resource "aws_s3_bucket_public_access_block" "backup" {
  bucket = aws_s3_bucket.backup.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
