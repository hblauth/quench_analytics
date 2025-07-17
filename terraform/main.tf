resource "google_storage_bucket" "raw_data" {
  name     = "quench-prod-ga-raw-data-4bcf52b1"
  location = "US"
}

resource "google_storage_bucket" "function_logs" {
  name     = "quench-prod-ga-function-logs-db91d835"
  location = "US"
}

resource "google_bigquery_dataset" "raw" {
  dataset_id = "raw"
  location   = "US"
}

resource "google_bigquery_dataset" "staging" {
  dataset_id = "staging"
  location   = "US"
}

resource "google_bigquery_dataset" "analytics" {
  dataset_id = "analytics"
  location   = "US"
} 