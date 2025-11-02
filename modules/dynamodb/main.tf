resource "aws_dynamodb_table" "ai_articulos" {
  name           = "${var.project_name}-ai-articulos"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"  # String (UUID)
  }

  attribute {
    name = "created_at"
    type = "S"
  }

  attribute {
    name = "topic"
    type = "S"  # String (e.g., "technology", "health")
  }

  global_secondary_index {
    name            = "CreatedAtIndex"
    hash_key        = "created_at"
    projection_type = "ALL"
  }

  # GSI para consultar artículos por topic
  global_secondary_index {
    name            = "TopicIndex"
    hash_key        = "topic"
    range_key       = "created_at"
    projection_type = "ALL"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  point_in_time_recovery {
    enabled = false
  }

  stream_enabled   = var.enable_streams
  stream_view_type = var.enable_streams ? "NEW_AND_OLD_IMAGES" : null

  tags = {
    Name = "${var.project_name}-ai-articulos"
  }
}
