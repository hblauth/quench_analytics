# Cloud Scheduler job for Google Ads data ingestion
resource "google_cloud_scheduler_job" "google_ads_ingestion" {
  name             = "google-ads-ingestion-scheduler"
  description      = "Schedule Google Ads data ingestion every Monday at 6 AM UTC"
  schedule         = "0 6 * * 1"
  time_zone        = "UTC"
  attempt_deadline = "600s"

  http_target {
    http_method = "POST"
    uri         = google_cloudfunctions2_function.google_ads_ingestion.url

    headers = {
      "User-Agent" = "Google-Cloud-Scheduler"
    }
  }

  depends_on = [
    google_cloudfunctions2_function.google_ads_ingestion
  ]
}

# IAM binding to allow Cloud Scheduler to invoke the function
resource "google_cloudfunctions2_function_iam_member" "invoker" {
  project        = google_cloudfunctions2_function.google_ads_ingestion.project
  location       = google_cloudfunctions2_function.google_ads_ingestion.location
  cloud_function = google_cloudfunctions2_function.google_ads_ingestion.name

  role   = "roles/cloudfunctions.invoker"
  member = "serviceAccount:${google_cloud_scheduler_job.google_ads_ingestion.http_target[0].oidc_token[0].service_account_email}"
} 