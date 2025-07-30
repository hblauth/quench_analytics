#!/bin/bash

# Deploy monitoring and alerting infrastructure for Google Ads Cloud Function

set -e

echo "🚀 Deploying Monitoring and Alerting Infrastructure"
echo "=================================================="

# Check if we're in the right directory
if [ ! -f "terraform/main.tf" ]; then
    echo "❌ Error: Please run this script from the project root directory"
    exit 1
fi

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "❌ Error: Terraform is not installed"
    exit 1
fi

# Check if gcloud is authenticated
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
    echo "❌ Error: Please authenticate with gcloud first"
    echo "Run: gcloud auth login"
    exit 1
fi

# Get project ID
PROJECT_ID=$(gcloud config get-value project)
echo "📍 Project ID: $PROJECT_ID"

# Navigate to terraform directory
cd terraform

echo ""
echo "🔧 Initializing Terraform..."
terraform init

echo ""
echo "📋 Planning Terraform changes..."
terraform plan -out=tfplan

echo ""
echo "❓ Do you want to apply these changes? (y/N)"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo ""
    echo "🚀 Applying Terraform changes..."
    terraform apply tfplan
    
    echo ""
    echo "✅ Monitoring and alerting infrastructure deployed successfully!"
    echo ""
    echo "📊 What was deployed:"
    echo "- Email notification channel for alerts"
    echo "- Log-based metric for function errors"
    echo "- Alert policies for function failures, timeouts, and no data"
    echo "- Monitoring dashboard for function metrics"
    echo ""
    echo "🔗 Next steps:"
    echo "1. Update the email address in terraform/monitoring.tf if needed"
    echo "2. Run ./scripts/test_alerts.sh to test the alerting system"
    echo "3. Check the Cloud Console Monitoring section"
    echo ""
    echo "📧 Important: Update the email address in terraform/monitoring.tf"
    echo "   before re-applying if you want to receive alerts!"
else
    echo "❌ Deployment cancelled"
    exit 1
fi

# Clean up
rm -f tfplan

echo ""
echo "🎯 To test the alerting system, run:"
echo "   ./scripts/test_alerts.sh" 