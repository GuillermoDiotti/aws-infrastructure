# ============================================
# S3 BUCKET
# ============================================

resource "aws_s3_bucket" "institutional_site" {
  bucket = "${var.project_name}-institutional-site"

  tags = merge(
    {
      Name    = "${var.project_name}-institutional-site"
      Purpose = "static-website"
    },
    var.tags
  )
}

# ============================================
# S3 BUCKET CONFIGURATION
# ============================================

resource "aws_s3_bucket_website_configuration" "institutional" {
  bucket = aws_s3_bucket.institutional_site.id

  index_document {
    suffix = var.index_document
  }

  error_document {
    key = var.error_document
  }
}

# Versionado del bucket (recomendado)
resource "aws_s3_bucket_versioning" "institutional" {
  bucket = aws_s3_bucket.institutional_site.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Bloquear acceso público (solo CloudFront accede)
resource "aws_s3_bucket_public_access_block" "institutional" {
  bucket = aws_s3_bucket.institutional_site.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ============================================
# CLOUDFRONT ORIGIN ACCESS IDENTITY
# ============================================

resource "aws_cloudfront_origin_access_identity" "institutional" {
  comment = "OAI for ${var.project_name} institutional site"
}

# ============================================
# S3 BUCKET POLICY
# ============================================

resource "aws_s3_bucket_policy" "institutional" {
  bucket = aws_s3_bucket.institutional_site.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontAccess"
        Effect = "Allow"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.institutional.iam_arn
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.institutional_site.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.institutional]
}

# ============================================
# CLOUDFRONT DISTRIBUTION
# ============================================

resource "aws_cloudfront_distribution" "institutional" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.index_document
  comment             = "${var.project_name} Institutional Static Site"
  price_class         = var.price_class

  origin {
    domain_name = aws_s3_bucket.institutional_site.bucket_regional_domain_name
    origin_id   = "S3-${var.project_name}-institutional"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.institutional.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.project_name}-institutional"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = var.cache_min_ttl
    default_ttl            = var.cache_default_ttl
    max_ttl                = var.cache_max_ttl
    compress               = var.enable_compression
  }

  # Custom error responses (para SPA routing si fuera necesario)
  custom_error_response {
    error_code         = 404
    response_code      = 404
    response_page_path = "/${var.error_document}"
  }

  custom_error_response {
    error_code         = 403
    response_code      = 403
    response_page_path = "/${var.error_document}"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = merge(
    {
      Name = "${var.project_name}-institutional-cdn"
    },
    var.tags
  )
}

# ============================================
# CLOUDWATCH LOG GROUP (opcional)
# ============================================

resource "aws_cloudwatch_log_group" "cloudfront_logs" {
  name              = "/aws/cloudfront/${var.project_name}-institutional"
  retention_in_days = 7

  tags = merge(
    {
      Name = "${var.project_name}-cloudfront-logs"
    },
    var.tags
  )
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.institutional_site.id
  key          = "index.html"
  source       = "${path.root}/static_page/index.html"
  content_type = "text/html"
  etag         = filemd5("${path.root}/static_page/index.html")

  tags = {
    Name = "index-page"
  }

  depends_on = [aws_s3_bucket_policy.institutional]
}