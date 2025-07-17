# Scripts Directory

This directory contains automation scripts for the Quench Analytics platform.

## Available Scripts

### `setup_phase4.sh`
**Purpose**: Complete Phase 4 setup for Dashboard MVP
**Usage**: `./scripts/setup_phase4.sh`
**What it does**:
- Deploys infrastructure updates via Terraform
- Deploys Google Ads Cloud Function
- Sets up Cloud Scheduler for weekly ingestion
- Configures dbt pipeline
- Generates dashboard configuration
- Provides setup instructions

### `run_dbt_pipeline.sh`
**Purpose**: Run the complete dbt data transformation pipeline
**Usage**: `./scripts/run_dbt_pipeline.sh`
**What it does**:
- Installs dbt dependencies
- Tests BigQuery connection
- Runs staging models
- Runs analytics models
- Executes data quality tests
- Generates documentation

## Usage Examples

### Complete Platform Setup
```bash
# Deploy infrastructure and set up dashboard
./scripts/setup_phase4.sh

# Run data transformations
./scripts/run_dbt_pipeline.sh
```

### Regular Data Pipeline
```bash
# Run dbt transformations after new data ingestion
./scripts/run_dbt_pipeline.sh
```

## Prerequisites

Before running these scripts, ensure you have:
- Google Cloud SDK installed and authenticated
- Terraform installed
- dbt installed (`pip install dbt-bigquery`)
- Proper Google Ads API credentials in Secret Manager

## Troubleshooting

### Common Issues

1. **Authentication Errors**
   ```bash
   gcloud auth login
   gcloud config set project practical-brace-466015-b1
   ```

2. **dbt Connection Issues**
   ```bash
   cd dbt
   dbt debug
   ```

3. **Terraform State Issues**
   ```bash
   cd terraform
   terraform init
   terraform plan
   ```

### Getting Help

- Check the main project README.md
- Review docs/architecture.md for system overview
- Check docs/tasks.md for current status 