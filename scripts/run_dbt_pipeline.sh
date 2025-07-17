#!/bin/bash

# dbt Pipeline Runner for Quench Analytics
# This script runs the dbt transformations to prepare data for the dashboard

set -e

echo "🔄 Starting dbt Pipeline for Quench Analytics"
echo "=============================================="

# Check if we're in the right directory
if [ ! -f "dbt/dbt_project.yml" ]; then
    echo "❌ Error: dbt project not found. Please run this script from the project root."
    exit 1
fi

# Check if dbt is installed
if ! command -v dbt &> /dev/null; then
    echo "❌ Error: dbt is not installed. Please install dbt first:"
    echo "   pip install dbt-bigquery"
    exit 1
fi

# Check if gcloud is authenticated
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
    echo "❌ Error: Not authenticated with gcloud. Please run 'gcloud auth login' first."
    exit 1
fi

echo "✅ Prerequisites check passed"

# Navigate to dbt directory
cd dbt

# Install dbt dependencies
echo "📦 Installing dbt dependencies..."
dbt deps

# Test connection to BigQuery
echo "🔗 Testing BigQuery connection..."
dbt debug

# Run dbt transformations
echo "🚀 Running dbt transformations..."

# Run staging models first
echo "📊 Building staging models..."
dbt run --select staging

# Run marts models
echo "📈 Building analytics models..."
dbt run --select marts

# Run tests
echo "🧪 Running data quality tests..."
dbt test

# Generate documentation
echo "📚 Generating documentation..."
dbt docs generate

echo ""
echo "✅ dbt pipeline completed successfully!"
echo ""
echo "📊 Data is now ready for dashboard creation:"
echo "   - Raw data: practical-brace-466015-b1.raw.google_ads_campaigns"
echo "   - Staging data: practical-brace-466015-b1.staging.stg_google_ads"
echo "   - Analytics data: practical-brace-466015-b1.analytics.campaign_summary"
echo ""
echo "🎯 Next steps:"
echo "1. Open Looker Studio: https://lookerstudio.google.com"
echo "2. Create a new data source using BigQuery"
echo "3. Connect to the 'campaign_summary' table"
echo "4. Start building your dashboard!"
echo ""
echo "📚 For detailed setup instructions, see: dashboard/README.md" 