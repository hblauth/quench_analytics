# Cloud Function for Google Ads data ingestion
resource "google_cloudfunctions2_function" "google_ads_ingestion" {
  name        = "google-ads-ingestion"
  location    = "us-central1"
  description = "Ingest Google Ads campaign data and store in GCS"

  build_config {
    runtime     = "python311"
    entry_point = "main"
    source {
      storage_source {
        bucket = google_storage_bucket.function_logs.name
        object = google_storage_bucket_object.function_source.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 540
    environment_variables = {
      PROJECT_ID = config.PROJECT_ID
    }
    secret_environment_variables {
      key        = "GOOGLE_ADS_DEVELOPER_TOKEN"
      project_id = config.PROJECT_ID
      secret     = "GOOGLE_ADS_DEVELOPER_TOKEN"
      version    = "latest"
    }
    secret_environment_variables {
      key        = "GOOGLE_ADS_CLIENT_ID"
      project_id = config.PROJECT_ID
      secret     = "GOOGLE_ADS_CLIENT_ID"
      version    = "latest"
    }
    secret_environment_variables {
      key        = "GOOGLE_ADS_CLIENT_SECRET"
      project_id = config.PROJECT_ID
      secret     = "GOOGLE_ADS_CLIENT_SECRET"
      version    = "latest"
    }
    secret_environment_variables {
      key        = "GOOGLE_ADS_REFRESH_TOKEN"
      project_id = config.PROJECT_ID
      secret     = "GOOGLE_ADS_REFRESH_TOKEN"
      version    = "latest"
    }
    secret_environment_variables {
      key        = "GOOGLE_ADS_LOGIN_CUSTOMER_ID"
      project_id = config.PROJECT_ID
      secret     = "GOOGLE_ADS_LOGIN_CUSTOMER_ID"
      version    = "latest"
    }
  }

  depends_on = [
    google_storage_bucket_object.function_source
  ]
}

# Upload function source code
resource "google_storage_bucket_object" "function_source" {
  name   = "google-ads-function-source.zip"
  bucket = google_storage_bucket.function_logs.name
  source = data.archive_file.function_zip.output_path
}

# Create zip file of function source
data "archive_file" "function_zip" {
  type        = "zip"
  output_path = "${path.module}/google-ads-function-source.zip"
  source_dir  = "${path.module}/../cloud_functions/google_ads"
} 