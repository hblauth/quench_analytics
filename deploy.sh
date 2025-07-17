#!/bin/bash

# Quench Analytics Deployment Script
# This script deploys the infrastructure and cloud functions

set -e

echo "🚀 Starting Quench Analytics deployment..."

# Check if we're in the right directory
if [ ! -f "config.py" ]; then
    echo "❌ Error: config.py not found. Please run this script from the project root."
    exit 1
fi

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "❌ Error: Terraform is not installed. Please install Terraform first."
    exit 1
fi

# Check if gcloud is installed and authenticated
if ! command -v gcloud &> /dev/null; then
    echo "❌ Error: gcloud CLI is not installed. Please install Google Cloud SDK first."
    exit 1
fi

# Check if user is authenticated
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
    echo "❌ Error: Not authenticated with gcloud. Please run 'gcloud auth login' first."
    exit 1
fi

echo "✅ Prerequisites check passed"

# Deploy infrastructure with Terraform
echo "🏗️  Deploying infrastructure with Terraform..."
cd terraform

# Initialize Terraform if needed
if [ ! -d ".terraform" ]; then
    echo "📦 Initializing Terraform..."
    terraform init
fi

# Plan the deployment
echo "📋 Planning Terraform deployment..."
terraform plan -out=tfplan

# Apply the plan
echo "🚀 Applying Terraform configuration..."
terraform apply tfplan

cd ..

echo "✅ Infrastructure deployment completed"

# Deploy Cloud Function
echo "⚡ Deploying Google Ads Cloud Function..."

# Create deployment package
echo "📦 Creating deployment package..."
cd cloud_functions/google_ads
zip -r function.zip . -x "*.pyc" "__pycache__/*" "*.git*"

# Deploy to Cloud Functions
echo "🚀 Deploying to Cloud Functions..."
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

cd ../..

echo "✅ Cloud Function deployment completed"

# Create Cloud Scheduler job
echo "⏰ Setting up Cloud Scheduler..."
gcloud scheduler jobs create http google-ads-ingestion-scheduler \
    --schedule="0 6 * * 1" \
    --uri="$(gcloud functions describe google-ads-ingestion --gen2 --region=us-central1 --format='value(serviceConfig.uri)')" \
    --http-method=POST \
    --time-zone="UTC" \
    --description="Schedule Google Ads data ingestion every Monday at 6 AM UTC"

echo "✅ Cloud Scheduler setup completed"

echo ""
echo "🎉 Deployment completed successfully!"
echo ""
echo "📊 Next steps:"
echo "1. Set up your Google Ads API credentials in Secret Manager:"
echo "   - GOOGLE_ADS_DEVELOPER_TOKEN"
echo "   - GOOGLE_ADS_CLIENT_ID"
echo "   - GOOGLE_ADS_CLIENT_SECRET"
echo "   - GOOGLE_ADS_REFRESH_TOKEN"
echo "   - GOOGLE_ADS_LOGIN_CUSTOMER_ID"
echo ""
echo "2. Test the function:"
echo "   curl -X POST $(gcloud functions describe google-ads-ingestion --gen2 --region=us-central1 --format='value(serviceConfig.uri)')"
echo ""
echo "3. Set up dbt and run transformations:"
echo "   cd dbt && dbt deps && dbt run"
echo ""
echo "4. Connect to Looker Studio for dashboards"
echo ""
echo "📚 Documentation: docs/architecture.md" 