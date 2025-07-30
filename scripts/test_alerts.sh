#!/bin/bash

# Test script for Google Ads Cloud Function alerting
# This script helps test the monitoring and alerting setup

set -e

echo "🧪 Testing Google Ads Cloud Function Alerting System"
echo "=================================================="

# Get the function URL
FUNCTION_URL=$(gcloud functions describe google-ads-ingestion --region=us-central1 --format="value(serviceConfig.uri)")

if [ -z "$FUNCTION_URL" ]; then
    echo "❌ Could not find Google Ads function URL. Make sure the function is deployed."
    exit 1
fi

echo "📍 Function URL: $FUNCTION_URL"
echo ""

# Test 1: Normal execution (should succeed)
echo "🔍 Test 1: Normal execution"
echo "---------------------------"
response=$(curl -s -w "\n%{http_code}" -X POST "$FUNCTION_URL")
http_code=$(echo "$response" | tail -n1)
response_body=$(echo "$response" | head -n -1)

if [ "$http_code" -eq 200 ]; then
    echo "✅ Normal execution successful"
    echo "Response: $response_body"
else
    echo "❌ Normal execution failed with code $http_code"
    echo "Response: $response_body"
fi

echo ""

# Test 2: Check Cloud Logging for recent logs
echo "🔍 Test 2: Checking recent logs"
echo "-------------------------------"
echo "Recent function logs:"
gcloud logging read "resource.type=cloud_function AND resource.labels.function_name=google-ads-ingestion" --limit=5 --format="table(timestamp,severity,textPayload)" --project=$(gcloud config get-value project)

echo ""

# Test 3: Check alert policies
echo "🔍 Test 3: Checking alert policies"
echo "---------------------------------"
echo "Alert policies:"
gcloud alpha monitoring policies list --filter="displayName:Google Ads" --format="table(displayName,enabled,conditions.displayName)" --project=$(gcloud config get-value project)

echo ""

# Test 4: Check notification channels
echo "🔍 Test 4: Checking notification channels"
echo "----------------------------------------"
echo "Notification channels:"
gcloud alpha monitoring channels list --filter="displayName:Quench Analytics" --format="table(displayName,type,labels.email_address)" --project=$(gcloud config get-value project)

echo ""

# Test 5: Check monitoring dashboard
echo "🔍 Test 5: Checking monitoring dashboard"
echo "--------------------------------------"
echo "Monitoring dashboards:"
gcloud alpha monitoring dashboards list --filter="displayName:Google Ads Function Monitoring" --format="table(displayName,createTime)" --project=$(gcloud config get-value project)

echo ""

echo "🎯 Alert Testing Instructions:"
echo "============================="
echo "1. To test error alerts, you can temporarily modify the function to throw an error"
echo "2. Check the Cloud Console Monitoring section for alert policies"
echo "3. Verify email notifications are configured correctly"
echo "4. Monitor the function dashboard for real-time metrics"
echo ""
echo "📧 To receive alerts, update the email address in terraform/monitoring.tf"
echo "   and reapply the Terraform configuration"
echo ""
echo "🔗 Useful links:"
echo "- Cloud Monitoring: https://console.cloud.google.com/monitoring"
echo "- Cloud Logging: https://console.cloud.google.com/logs"
echo "- Cloud Functions: https://console.cloud.google.com/functions" 