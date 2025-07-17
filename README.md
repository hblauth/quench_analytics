# Quench Analytics

A comprehensive ecommerce marketing analytics platform built on Google Cloud Platform (GCP) that ingests data from multiple advertising platforms and provides unified analytics and reporting capabilities.

## 🚀 Quick Start

### Prerequisites

- Google Cloud Platform account with billing enabled
- Google Cloud SDK installed and authenticated
- Terraform installed
- Python 3.11+ with virtualenv
- Google Ads API access

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd quench_analytics
   ```

2. **Set up Python environment**
   ```bash
   virtualenv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   pip install -r requirements.txt
   ```

3. **Configure Google Ads API credentials**
   
   Create the following secrets in Google Cloud Secret Manager:
   - `GOOGLE_ADS_DEVELOPER_TOKEN`
   - `GOOGLE_ADS_CLIENT_ID`
   - `GOOGLE_ADS_CLIENT_SECRET`
   - `GOOGLE_ADS_REFRESH_TOKEN`
   - `GOOGLE_ADS_LOGIN_CUSTOMER_ID`

4. **Deploy the complete platform**
   ```bash
   # Deploy infrastructure and data pipeline
   ./deploy.sh
   
   # Set up dashboard MVP (Phase 4)
   ./scripts/setup_phase4.sh
   ```

5. **Create your dashboard**
   ```bash
   # Run dbt transformations
   ./scripts/run_dbt_pipeline.sh
   
   # Open Looker Studio and follow dashboard/README.md
   ```

## 📊 Architecture

### Data Flow

1. **Data Ingestion**: Cloud Function triggers weekly via Cloud Scheduler
2. **API Call**: Google Ads API queried for campaign data
3. **Storage**: JSON data saved to GCS with date partitioning
4. **Transformation**: dbt models transform raw data to analytics-ready format
5. **Analytics**: Aggregated metrics available in BigQuery analytics dataset
6. **Visualization**: Looker Studio dashboard displays real-time insights

### Components

- **Infrastructure**: Terraform-managed GCP resources
- **Data Ingestion**: Cloud Functions for API integration
- **Data Storage**: Google Cloud Storage for raw data
- **Data Warehouse**: BigQuery for analytics
- **Data Transformation**: dbt for ELT pipeline
- **Scheduling**: Cloud Scheduler for automation
- **Visualization**: Looker Studio for dashboards
- **Monitoring**: Cloud Logging and BigQuery

## 🛠️ Development

### Project Structure

```
quench_analytics/
├── cloud_functions/          # Cloud Functions
│   └── google_ads/           # Google Ads ingestion function
│       ├── main.py           # Function entry point
│       ├── requirements.txt  # Python dependencies
│       ├── config.py         # Configuration settings
│       └── utils.py          # Utility functions
├── dbt/                      # Data transformation
│   ├── dbt_project.yml       # dbt project configuration
│   ├── models/
│   │   ├── sources.yml       # Raw data source definitions
│   │   ├── staging/          # Data cleaning models
│   │   │   └── stg_google_ads.sql
│   │   └── marts/            # Analytics models
│   │       └── campaign_summary.sql
│   └── seeds/                # Static data files
├── dashboard/                # Dashboard setup and configuration
│   ├── setup_looker_studio.py
│   ├── sample_queries.sql    # Ready-to-use SQL queries
│   └── README.md             # Dashboard setup guide
├── docs/                     # Documentation
│   ├── architecture.md       # System architecture
│   └── tasks.md              # Development tasks and progress
├── scripts/                  # Automation scripts
│   ├── setup_phase4.sh       # Complete Phase 4 setup
│   ├── run_dbt_pipeline.sh   # dbt transformation runner
│   └── README.md             # Scripts documentation
├── terraform/                # Infrastructure as Code
│   ├── main.tf               # GCS buckets and BigQuery datasets
│   ├── cloud_functions.tf    # Google Ads Cloud Function
│   ├── scheduler.tf          # Cloud Scheduler configuration
│   ├── bigquery.tf           # BigQuery tables and data loading
│   └── schemas/              # BigQuery schema definitions
├── config.py                 # Main configuration settings
├── utils.py                  # Utility functions
├── requirements.txt          # Python dependencies
├── deploy.sh                 # Main deployment script
├── .gitignore               # Git ignore rules
└── README.md                # This file
```

### Local Development

1. **Set up local environment**
   ```bash
   virtualenv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

2. **Test Cloud Function locally**
   ```bash
   cd cloud_functions/google_ads
   python main.py
   ```

3. **Run dbt transformations**
   ```bash
   cd dbt
   dbt deps
   dbt run
   dbt test
   ```

### Configuration

Key configuration files:
- `config.py`: Main configuration settings
- `terraform/`: Infrastructure variables and schemas
- `dbt/dbt_project.yml`: dbt project configuration

## 📈 Data Models

### Staging Models
- `stg_google_ads`: Cleaned and typed Google Ads campaign data

### Analytics Models
- `campaign_summary`: Aggregated campaign metrics by time and channel

### Key Metrics
- **CTR**: Click-through rate
- **CPC**: Cost per click
- **CPM**: Cost per thousand impressions
- **ROAS**: Return on ad spend
- **Conversion Rate**: Conversions per click

## 📊 Dashboard Features

### Available Components
- **Key Metrics Scorecards**: Total spend, impressions, clicks, CTR, ROAS
- **Time Series Charts**: Weekly spend trends, performance over time
- **Data Tables**: Campaign performance, top performing campaigns
- **Visualizations**: Channel performance, ROAS scatter plots, status distribution
- **Interactive Filters**: Date range, channel type, campaign status

### Dashboard Setup
1. **Automated Setup**: Run `./scripts/setup_phase4.sh`
2. **Manual Setup**: Follow `dashboard/README.md`
3. **Sample Queries**: Use queries from `dashboard/sample_queries.sql`

## 🔧 Deployment

### Automated Deployment
```bash
# Complete platform deployment
./deploy.sh

# Dashboard MVP setup
./scripts/setup_phase4.sh
```

### Manual Deployment

1. **Deploy Infrastructure**
   ```bash
   cd terraform
   terraform init
   terraform plan
   terraform apply
   ```

2. **Deploy Cloud Function**
   ```bash
   cd cloud_functions/google_ads
   gcloud functions deploy google-ads-ingestion \
     --gen2 \
     --runtime=python311 \
     --region=us-central1 \
     --source=. \
     --entry-point=main \
     --trigger-http
   ```

3. **Set up Cloud Scheduler**
   ```bash
   gcloud scheduler jobs create http google-ads-ingestion-scheduler \
     --schedule="0 6 * * 1" \
     --uri="<function-url>" \
     --http-method=POST
   ```

4. **Run dbt Pipeline**
   ```bash
   ./scripts/run_dbt_pipeline.sh
   ```

## 📊 Monitoring

### Logs
- Cloud Function logs: Cloud Logging
- dbt run logs: dbt Cloud or local logs
- BigQuery query logs: BigQuery console

### Alerts
- Cloud Function failures: Cloud Monitoring
- Data quality issues: dbt tests
- Cost monitoring: Cloud Billing alerts

## 🔒 Security

- All API credentials stored in Secret Manager
- Cloud Function uses least-privilege IAM roles
- Data encrypted in transit and at rest
- Audit logging enabled for all GCP services

## 📚 Documentation

- [Architecture Overview](docs/architecture.md)
- [Development Tasks](docs/tasks.md)
- [Dashboard Setup Guide](dashboard/README.md)
- [Scripts Documentation](scripts/README.md)
- [API Reference](docs/api_reference.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:
- Check the documentation in the `docs/` folder
- Review the architecture overview
- Open an issue for bugs or feature requests

## 🚀 Roadmap

### ✅ Phase 4: Dashboard MVP (COMPLETED)
- ✅ Connect BigQuery to Looker Studio
- ✅ Create basic dashboard with campaign metrics
- ✅ Set up automated dashboard refresh

### Phase 5: Monitoring & Alerting
- [ ] Add comprehensive monitoring
- [ ] Implement alerting for failures
- [ ] Set up automated reporting

### Phase 6: Additional Data Sources
- [ ] Meta Ads API integration
- [ ] TikTok Ads API integration
- [ ] GA4 data integration

### Phase 7: Advanced Analytics
- [ ] Cross-platform attribution modeling
- [ ] Customer lifetime value analysis
- [ ] ROI optimization recommendations
- [ ] Predictive analytics

## 🎯 Current Status

**✅ MVP Complete**: The Quench Analytics platform is fully functional with:
- Automated Google Ads data ingestion
- Complete data transformation pipeline
- Interactive Looker Studio dashboard
- Weekly scheduled updates
- Comprehensive documentation

**Ready for Production**: The platform is ready for production use and can be extended with additional data sources and advanced analytics features. 