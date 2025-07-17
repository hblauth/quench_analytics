# BigQuery external table for Google Ads data
resource "google_bigquery_table" "google_ads_campaigns" {
  dataset_id = google_bigquery_dataset.raw.dataset_id
  table_id   = "google_ads_campaigns"

  external_data_configuration {
    autodetect    = true
    source_format = "NEWLINE_DELIMITED_JSON"

    source_uris = [
      "gs://${google_storage_bucket.raw_data.name}/google_ads/*/google_ads_response.json"
    ]

    hive_partitioning_options {
      mode = "AUTO"
    }
  }

  deletion_protection = false
}

# BigQuery table for processed Google Ads data (staging)
resource "google_bigquery_table" "stg_google_ads" {
  dataset_id = google_bigquery_dataset.staging.dataset_id
  table_id   = "stg_google_ads"

  schema = file("${path.module}/schemas/stg_google_ads_schema.json")

  deletion_protection = false
}

# BigQuery table for campaign summary analytics
resource "google_bigquery_table" "campaign_summary" {
  dataset_id = google_bigquery_dataset.analytics.dataset_id
  table_id   = "campaign_summary"

  schema = file("${path.module}/schemas/campaign_summary_schema.json")

  deletion_protection = false
}

# BigQuery Data Transfer Service for automated loading
resource "google_bigquery_data_transfer_config" "google_ads_loader" {
  display_name  = "Google Ads Data Loader"
  data_source_id = "google_cloud_storage"
  schedule      = "every 24 hours"
  destination_dataset_id = google_bigquery_dataset.raw.dataset_id

  params = {
    data_path_template = "gs://${google_storage_bucket.raw_data.name}/google_ads/*/google_ads_response.json"
    destination_table_name_template = "google_ads_campaigns"
    file_format = "JSON"
    write_disposition = "WRITE_APPEND"
  }

  depends_on = [
    google_bigquery_table.google_ads_campaigns
  ]
} 