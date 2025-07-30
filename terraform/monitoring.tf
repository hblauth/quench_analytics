# Monitoring and Alerting for Google Ads Cloud Function

# Create a notification channel for email alerts
resource "google_monitoring_notification_channel" "email_alerts" {
  display_name = "Quench Analytics Email Alerts"
  type         = "email"
  
  labels = {
    email_address = "admin@quenchanalytics.com"  # Replace with actual email
  }
}

# Create a log-based metric for function errors
resource "google_logging_metric" "function_errors" {
  name   = "google-ads-function-errors"
  filter = "resource.type=\"cloud_function\" AND resource.labels.function_name=\"google-ads-ingestion\" AND severity>=ERROR"
  
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
    display_name = "Google Ads Function Errors"
    description  = "Number of errors in Google Ads ingestion function"
  }
}

# Create an alert policy for function failures
resource "google_monitoring_alert_policy" "function_failure" {
  display_name = "Google Ads Function Failure Alert"
  combiner     = "OR"
  enabled      = true

  conditions {
    display_name = "Function execution failure"
    
    condition_threshold {
      filter = "metric.type=\"logging.googleapis.com/user/google-ads-function-errors\""
      
      comparison = "COMPARISON_GREATER_THAN"
      threshold_value = 0
      
      duration = "0s"
      
      trigger {
        count = 1
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email_alerts.name]
  
  documentation {
    content   = "The Google Ads ingestion function has failed. Check the Cloud Function logs for details."
    mime_type = "text/markdown"
  }
}

# Create an alert policy for function execution timeouts
resource "google_monitoring_alert_policy" "function_timeout" {
  display_name = "Google Ads Function Timeout Alert"
  combiner     = "OR"
  enabled      = true

  conditions {
    display_name = "Function execution timeout"
    
    condition_threshold {
      filter = "resource.type=\"cloud_function\" AND resource.labels.function_name=\"google-ads-ingestion\" AND textPayload:\"timeout\""
      
      comparison = "COMPARISON_GREATER_THAN"
      threshold_value = 0
      
      duration = "0s"
      
      trigger {
        count = 1
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email_alerts.name]
  
  documentation {
    content   = "The Google Ads ingestion function has timed out. Check the function configuration and API response times."
    mime_type = "text/markdown"
  }
}

# Create an alert policy for missing data (no campaigns retrieved)
resource "google_monitoring_alert_policy" "no_data_alert" {
  display_name = "Google Ads No Data Alert"
  combiner     = "OR"
  enabled      = true

  conditions {
    display_name = "No campaign data retrieved"
    
    condition_threshold {
      filter = "resource.type=\"cloud_function\" AND resource.labels.function_name=\"google-ads-ingestion\" AND textPayload:\"Retrieved 0 campaigns\""
      
      comparison = "COMPARISON_GREATER_THAN"
      threshold_value = 0
      
      duration = "0s"
      
      trigger {
        count = 1
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email_alerts.name]
  
  documentation {
    content   = "The Google Ads ingestion function retrieved 0 campaigns. This may indicate an API issue or no active campaigns."
    mime_type = "text/markdown"
  }
}

# Create a dashboard for monitoring the function
resource "google_monitoring_dashboard" "function_dashboard" {
  dashboard_json = jsonencode({
    displayName = "Google Ads Function Monitoring"
    gridLayout = {
      widgets = [
        {
          title = "Function Execution Status"
          xyChart = {
            dataSets = [
              {
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "metric.type=\"cloudfunctions.googleapis.com/function/execution_count\" AND resource.labels.function_name=\"google-ads-ingestion\""
                  }
                }
              }
            ]
          }
        },
        {
          title = "Function Errors"
          xyChart = {
            dataSets = [
              {
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "metric.type=\"logging.googleapis.com/user/google-ads-function-errors\""
                  }
                }
              }
            ]
          }
        },
        {
          title = "Function Execution Time"
          xyChart = {
            dataSets = [
              {
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "metric.type=\"cloudfunctions.googleapis.com/function/execution_times\" AND resource.labels.function_name=\"google-ads-ingestion\""
                  }
                }
              }
            ]
          }
        }
      ]
    }
  })
} 