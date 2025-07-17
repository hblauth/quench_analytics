# Quench Analytics Architecture

## Project Overview
Quench Analytics is a comprehensive ecommerce marketing analytics platform built on Google Cloud Platform (GCP). The platform ingests data from multiple advertising platforms (Google Ads, Meta Ads, TikTok Ads, etc.) and provides unified analytics and reporting capabilities.

## Current Architecture Status

### ✅ Completed Components

#### Infrastructure (Phase 1)
- **GCS Buckets**: Raw data and function logs buckets created via Terraform
- **BigQuery Datasets**: Raw, staging, and analytics datasets configured
- **Terraform Configuration**: Infrastructure as code for all GCP resources

#### Google Ads Integration (Phase 2)
- **Cloud Function**: Google Ads data ingestion function deployed
- **API Integration**: Real Google Ads API client implemented
- **Data Storage**: Campaign data saved to GCS with date partitioning
- **Scheduling**: Cloud Scheduler configured for weekly ingestion (Mondays 6 AM UTC)
- **Secret Management**: All API credentials stored in Secret Manager

#### Data Transformation (Phase 3)
- **dbt Project**: Complete dbt project structure created
- **Staging Models**: `stg_google_ads.sql` for data cleaning and type conversion
- **Analytics Models**: `campaign_summary.sql` for aggregated metrics
- **Data Quality**: Column tests and documentation configured

### 🏗️ Current Project Structure

```
quench_analytics/
├── terraform/
│   ├── main.tf                 # GCS buckets and BigQuery datasets
│   ├── cloud_functions.tf      # Google Ads Cloud Function
│   └── scheduler.tf            # Cloud Scheduler configuration
├── cloud_functions/
│   └── google_ads/
│       ├── main.py             # Google Ads ingestion function
│       ├── requirements.txt    # Python dependencies
│       ├── config.py           # Configuration settings
│       └── utils.py            # Utility functions
├── dbt/
│   ├── dbt_project.yml         # dbt project configuration
│   ├── models/
│   │   ├── sources.yml         # Raw data source definitions
│   │   ├── staging/
│   │   │   └── stg_google_ads.sql
│   │   └── marts/
│   │       └── campaign_summary.sql
│   └── seeds/
├── config.py                   # Main configuration file
├── utils.py                    # Utility functions
└── docs/
    ├── architecture.md         # This file
    └── tasks.md               # Development tasks and progress
```

### 📊 Data Flow

1. **Data Ingestion**: Cloud Function triggers weekly via Cloud Scheduler
2. **API Call**: Google Ads API queried for campaign data
3. **Storage**: JSON data saved to GCS with date partitioning
4. **Transformation**: dbt models transform raw data to analytics-ready format
5. **Analytics**: Aggregated metrics available in BigQuery analytics dataset

### 🔧 Configuration

#### Environment Variables
- `PROJECT_ID`: GCP project identifier
- `RAW_DATA_BUCKET`: GCS bucket for raw data storage
- `FUNCTION_LOGS_BUCKET`: GCS bucket for function logs

#### Secret Manager
- `GOOGLE_ADS_DEVELOPER_TOKEN`: Google Ads API developer token
- `GOOGLE_ADS_CLIENT_ID`: OAuth client ID
- `GOOGLE_ADS_CLIENT_SECRET`: OAuth client secret
- `GOOGLE_ADS_REFRESH_TOKEN`: OAuth refresh token
- `GOOGLE_ADS_LOGIN_CUSTOMER_ID`: Google Ads customer ID

### 🚀 Next Steps

#### Phase 4: Dashboard MVP
- [ ] Connect BigQuery to Looker Studio
- [ ] Create basic dashboard with campaign metrics
- [ ] Set up automated dashboard refresh

#### Phase 5: Additional Data Sources
- [ ] Meta Ads API integration
- [ ] TikTok Ads API integration
- [ ] GA4 data integration

#### Phase 6: Advanced Analytics
- [ ] Cross-platform attribution modeling
- [ ] Customer lifetime value analysis
- [ ] ROI optimization recommendations

### 🔒 Security & Compliance

- All API credentials stored in Secret Manager
- Cloud Function uses least-privilege IAM roles
- Data encrypted in transit and at rest
- Audit logging enabled for all GCP services

### 📈 Monitoring & Alerting

- Cloud Function logs available in Cloud Logging
- Error handling and retry logic implemented
- Scheduled job monitoring via Cloud Scheduler
- Data quality tests in dbt models

### 🛠️ Development Workflow

1. **Local Development**: Use virtualenv for Python dependencies
2. **Testing**: Test functions locally before deployment
3. **Deployment**: Terraform manages infrastructure, Cloud Functions deployed via zip
4. **Data Pipeline**: dbt handles data transformation and testing
5. **Monitoring**: Cloud Logging and BigQuery for observability
