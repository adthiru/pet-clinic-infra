# S3 bucket for pet clinic application data storage
resource "aws_s3_bucket" "pet_clinic_data" {
  bucket = "pet-clinic-data-${random_string.bucket_suffix.result}"
  
  tags = {
    Name        = "PetClinicDataBucket"
    Environment = "demo"
    Purpose     = "Application data storage"
  }
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# S3 bucket public access block
resource "aws_s3_bucket_public_access_block" "pet_clinic_data" {
  bucket = aws_s3_bucket.pet_clinic_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 bucket policy - basic access without encryption enforcement
resource "aws_s3_bucket_policy" "pet_clinic_data" {
  bucket = aws_s3_bucket.pet_clinic_data.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowApplicationAccess"
        Effect    = "Allow"
        Principal = {
          AWS = module.demo_service_account.iam_role_arn
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.pet_clinic_data.arn}/*"
      },
      {
        Sid       = "AllowApplicationListBucket"
        Effect    = "Allow"
        Principal = {
          AWS = module.demo_service_account.iam_role_arn
        }
        Action   = "s3:ListBucket"
        Resource = aws_s3_bucket.pet_clinic_data.arn
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.pet_clinic_data]
}

# Output the bucket name for application configuration
output "pet_clinic_data_bucket_name" {
  description = "Name of the S3 bucket for pet clinic data storage"
  value       = aws_s3_bucket.pet_clinic_data.bucket
}

output "pet_clinic_data_bucket_arn" {
  description = "ARN of the S3 bucket for pet clinic data storage"
  value       = aws_s3_bucket.pet_clinic_data.arn
}
