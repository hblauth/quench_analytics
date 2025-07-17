# Configuration settings for the Quench Analytics project

# GCP Project ID
PROJECT_ID = "practical-brace-466015-b1"

# GCS Bucket names
RAW_DATA_BUCKET = "quench-prod-ga-raw-data-4bcf52b1"
FUNCTION_LOGS_BUCKET = "quench-prod-ga-function-logs-4bcf52b1"

# BigQuery dataset names
RAW_DATASET = "raw"
STAGING_DATASET = "staging"
ANALYTICS_DATASET = "analytics"

# Google Ads API configuration
GOOGLE_ADS_API_VERSION = "v16"
GOOGLE_ADS_LOGIN_CUSTOMER_ID = None  # Will be fetched from Secret Manager

# Secret names in Secret Manager
SECRET_NAMES = {
    "developer_token": "GOOGLE_ADS_DEVELOPER_TOKEN",
    "client_id": "GOOGLE_ADS_CLIENT_ID", 
    "client_secret": "GOOGLE_ADS_CLIENT_SECRET",
    "refresh_token": "GOOGLE_ADS_REFRESH_TOKEN",
    "login_customer_id": "GOOGLE_ADS_LOGIN_CUSTOMER_ID"
}

# Data ingestion settings
DATA_SOURCES = {
    "google_ads": {
        "enabled": True,
        "schedule": "0 6 * * 1",  # Every Monday at 6 AM UTC
        "gcs_path": "google_ads"
    },
    "meta_ads": {
        "enabled": False,
        "schedule": "0 6 * * 1",
        "gcs_path": "meta_ads"
    },
    "tiktok_ads": {
        "enabled": False,
        "schedule": "0 6 * * 1", 
        "gcs_path": "tiktok_ads"
    }
} 