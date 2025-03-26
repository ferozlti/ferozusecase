# S3 Bucket for CodePipeline artifacts
resource "aws_s3_bucket" "artifact_bucket" {
  bucket = "${var.app_name}-artifacts-${var.aws_account_id}"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "artifact_bucket" {
  bucket = aws_s3_bucket.artifact_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "artifact_bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.artifact_bucket]
  bucket = aws_s3_bucket.artifact_bucket.id
  acl    = "private"
}

# Block public access
resource "aws_s3_bucket_public_access_block" "artifact_bucket" {
  bucket = aws_s3_bucket.artifact_bucket.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
