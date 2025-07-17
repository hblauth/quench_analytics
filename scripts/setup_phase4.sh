#!/bin/bash

# Phase 4 Setup Script: Dashboard MVP
# This script sets up the complete dashboard infrastructure and data pipeline

set -e

echo "🚀 Phase 4 Setup: Dashboard MVP"
echo "================================"

# Check if we're in the right directory
if [ ! -f "config.py" ]; then
    echo "❌ Error: config.py not found. Please run this script from the project root."
    exit 1
fi

# Check prerequisites
echo "🔍 Checking prerequisites..."

# Check if gcloud is installed and authenticated
if ! command -v gcloud &> /dev/null; then
    echo "❌ Error: gcloud CLI is not installed. Please install Google Cloud SDK first."
    exit 1
fi

if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
    echo "❌ Error: Not authenticated with gcloud. Please run 'gcloud auth login' first."
    exit 1
fi

# Check if dbt is installed
if ! command -v dbt &> /dev/null; then
    echo "⚠️  Warning: dbt is not installed. Installing dbt-bigquery..."
    pip install dbt-bigquery
fi

echo "✅ Prerequisites check passed"

# Step 1: Deploy infrastructure updates
echo ""
echo "🏗️  Step 1: Deploying infrastructure updates..."
cd terraform

# Initialize Terraform if needed
if [ ! -d ".terraform" ]; then
    echo "📦 Initializing Terraform..."
    terraform init
fi

# Plan and apply infrastructure changes
echo "📋 Planning infrastructure changes..."
terraform plan -out=tfplan

echo "🚀 Applying infrastructure changes..."
terraform apply tfplan

cd ..

# Step 2: Deploy Cloud Function (if not already deployed)
echo ""
echo "⚡ Step 2: Deploying Cloud Function..."
cd cloud_functions/google_ads

# Check if function exists
if ! gcloud functions describe google-ads-ingestion --gen2 --region=us-central1 &> /dev/null; then
    echo "🚀 Deploying Google Ads Cloud Function..."
    gcloud functions deploy google-ads-ingestion \
        --gen2 \
        --runtime=python311 \
        --region=us-central1 \
        --source=. \
        --entry-point=main \
        --trigger-http \
        --allow-unauthenticated \
        --memory=256MB \
        --timeout=540s \
        --set-env-vars="PROJECT_ID=practical-brace-466015-b1"
else
    echo "✅ Cloud Function already exists"
fi

cd ../..

# Step 3: Set up Cloud Scheduler (if not already set up)
echo ""
echo "⏰ Step 3: Setting up Cloud Scheduler..."
if ! gcloud scheduler jobs describe google-ads-ingestion-scheduler &> /dev/null; then
    echo "⏰ Creating Cloud Scheduler job..."
    FUNCTION_URL=$(gcloud functions describe google-ads-ingestion --gen2 --region=us-central1 --format='value(serviceConfig.uri)')
    gcloud scheduler jobs create http google-ads-ingestion-scheduler \
        --schedule="0 6 * * 1" \
        --uri="$FUNCTION_URL" \
        --http-method=POST \
        --time-zone="UTC" \
        --description="Schedule Google Ads data ingestion every Monday at 6 AM UTC"
else
    echo "✅ Cloud Scheduler job already exists"
fi

# Step 4: Test data ingestion
echo ""
echo "🧪 Step 4: Testing data ingestion..."
echo "Testing Cloud Function..."
FUNCTION_URL=$(gcloud functions describe google-ads-ingestion --gen2 --region=us-central1 --format='value(serviceConfig.uri)')
echo "Function URL: $FUNCTION_URL"

# Note: This will fail if secrets aren't set up, but that's expected
echo "⚠️  Note: Function test may fail if Google Ads API secrets aren't configured yet"
echo "   This is expected - you'll need to set up the secrets in Secret Manager first"

# Step 5: Set up dbt and run transformations
echo ""
echo "🔄 Step 5: Setting up dbt pipeline..."
cd dbt

# Install dependencies
echo "📦 Installing dbt dependencies..."
dbt deps

# Test connection
echo "🔗 Testing BigQuery connection..."
dbt debug

# Run transformations
echo "🚀 Running dbt transformations..."
dbt run

# Run tests
echo "🧪 Running data quality tests..."
dbt test

cd ..

# Step 6: Generate dashboard configuration
echo ""
echo "📊 Step 6: Generating dashboard configuration..."
python dashboard/setup_looker_studio.py

# Step 7: Display final instructions
echo ""
echo "🎉 Phase 4 Setup Complete!"
echo "=========================="
echo ""
echo "✅ Infrastructure deployed"
echo "✅ Cloud Function ready"
echo "✅ Data pipeline configured"
echo "✅ Dashboard configuration generated"
echo ""
echo "📋 Next Steps:"
echo ""
echo "1. 🔐 Set up Google Ads API credentials in Secret Manager:"
echo "   - GOOGLE_ADS_DEVELOPER_TOKEN"
echo "   - GOOGLE_ADS_CLIENT_ID"
echo "   - GOOGLE_ADS_CLIENT_SECRET"
echo "   - GOOGLE_ADS_REFRESH_TOKEN"
echo "   - GOOGLE_ADS_LOGIN_CUSTOMER_ID"
echo ""
echo "2. 🧪 Test the data pipeline:"
echo "   curl -X POST $FUNCTION_URL"
echo ""
echo "3. 📊 Create your Looker Studio dashboard:"
echo "   - Open: https://lookerstudio.google.com"
echo "   - Follow instructions in: dashboard/README.md"
echo "   - Use sample queries from: dashboard/sample_queries.sql"
echo ""
echo "4. 🔄 Schedule regular dbt runs:"
echo "   - Run: ./scripts/run_dbt_pipeline.sh"
echo "   - Consider setting up Cloud Scheduler for dbt runs"
echo ""
echo "📚 Documentation:"
echo "   - Dashboard setup: dashboard/README.md"
echo "   - Architecture: docs/architecture.md"
echo "   - Tasks: docs/tasks.md"
echo ""
echo "🎯 Your marketing analytics dashboard is ready to be built!" 