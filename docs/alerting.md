# Monitoring and Alerting System

## Overview

The Quench Analytics platform includes a comprehensive monitoring and alerting system for the Google Ads Cloud Function to ensure reliable data ingestion and timely notification of issues.

## Components

### 1. Email Notification Channel
- **Type**: Email alerts
- **Configuration**: Set in `terraform/monitoring.tf`
- **Default**: `admin@quenchanalytics.com` (update this for your email)

### 2. Log-Based Metrics
- **Metric Name**: `google-ads-function-errors`
- **Filter**: Captures all ERROR level logs from the Google Ads function
- **Purpose**: Tracks function failures for alerting

### 3. Alert Policies

#### Function Failure Alert
- **Trigger**: Any error in the Google Ads function
- **Condition**: Error logs detected
- **Action**: Email notification
- **Use Case**: API failures, authentication issues, unexpected errors

#### Function Timeout Alert
- **Trigger**: Function execution timeout
- **Condition**: Logs containing "timeout"
- **Action**: Email notification
- **Use Case**: API response delays, function configuration issues

#### No Data Alert
- **Trigger**: Zero campaigns retrieved
- **Condition**: Logs containing "Retrieved 0 campaigns"
- **Action**: Email notification
- **Use Case**: API changes, account issues, no active campaigns

### 4. Monitoring Dashboard
- **Name**: "Google Ads Function Monitoring"
- **Metrics**:
  - Function execution count
  - Function errors
  - Function execution time
- **Access**: Cloud Console Monitoring section

## Deployment

### Automated Deployment
```bash
./scripts/deploy_monitoring.sh
```

### Manual Deployment
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

## Configuration

### Update Email Address
1. Edit `terraform/monitoring.tf`
2. Update the `email_address` in the notification channel
3. Reapply Terraform:
   ```bash
   cd terraform
   terraform apply
   ```

### Customize Alert Thresholds
Modify the alert policies in `terraform/monitoring.tf`:
- Change `threshold_value` for different sensitivity
- Adjust `duration` for different time windows
- Modify `trigger.count` for different trigger conditions

## Testing

### Test the Alerting System
```bash
./scripts/test_alerts.sh
```

This script will:
1. Test normal function execution
2. Check recent logs
3. Verify alert policies are configured
4. Confirm notification channels exist
5. Check monitoring dashboard

### Manual Error Testing
To test error alerts manually:

1. **Temporary Error Injection**:
   ```python
   # Add this to cloud_functions/google_ads/main.py for testing
   raise Exception("Test error for alerting")
   ```

2. **Trigger the Function**:
   ```bash
   curl -X POST <FUNCTION_URL>
   ```

3. **Check for Alerts**:
   - Monitor your email for notifications
   - Check Cloud Console Monitoring section
   - Review Cloud Logging for error logs

## Monitoring Dashboard

### Access the Dashboard
1. Go to [Cloud Console Monitoring](https://console.cloud.google.com/monitoring)
2. Navigate to "Dashboards"
3. Find "Google Ads Function Monitoring"

### Dashboard Metrics
- **Function Execution Status**: Shows successful vs failed executions
- **Function Errors**: Displays error count over time
- **Function Execution Time**: Tracks performance trends

## Troubleshooting

### Common Issues

#### Alerts Not Triggering
1. Check if the function is actually failing
2. Verify log filters in alert policies
3. Ensure notification channel is properly configured
4. Check Cloud Logging for function logs

#### Email Notifications Not Received
1. Verify email address in notification channel
2. Check spam/junk folders
3. Ensure notification channel is enabled
4. Test notification channel manually

#### Dashboard Not Showing Data
1. Verify function has been executed recently
2. Check metric filters in dashboard
3. Ensure monitoring APIs are enabled
4. Wait for data to populate (may take a few minutes)

### Debugging Commands

```bash
# Check function logs
gcloud logging read "resource.type=cloud_function AND resource.labels.function_name=google-ads-ingestion" --limit=10

# List alert policies
gcloud alpha monitoring policies list --filter="displayName:Google Ads"

# List notification channels
gcloud alpha monitoring channels list --filter="displayName:Quench Analytics"

# Check function status
gcloud functions describe google-ads-ingestion --region=us-central1
```

## Best Practices

### Alert Management
1. **Avoid Alert Fatigue**: Don't create too many alerts
2. **Use Meaningful Names**: Clear, descriptive alert names
3. **Include Context**: Add documentation to alert policies
4. **Test Regularly**: Verify alerts work as expected

### Monitoring Optimization
1. **Set Appropriate Thresholds**: Balance sensitivity with noise
2. **Use Log-Based Metrics**: Leverage structured logging
3. **Monitor Performance**: Track execution times and resource usage
4. **Document Incidents**: Keep records of alerts and resolutions

### Maintenance
1. **Regular Reviews**: Periodically review alert effectiveness
2. **Update Contact Information**: Keep notification channels current
3. **Clean Up Old Alerts**: Remove obsolete alert policies
4. **Monitor Costs**: Watch for excessive monitoring costs

## Integration with CI/CD

### Automated Testing
Include alert testing in your deployment pipeline:
```bash
# In your CI/CD pipeline
./scripts/test_alerts.sh
```

### Infrastructure as Code
All monitoring configuration is managed through Terraform:
- Version controlled
- Reproducible deployments
- Easy rollbacks
- Environment consistency

## Future Enhancements

### Planned Improvements
1. **Slack Integration**: Add Slack notification channel
2. **PagerDuty Integration**: For critical alerts
3. **Custom Metrics**: Business-specific KPIs
4. **Anomaly Detection**: ML-based alerting
5. **Alert Escalation**: Multi-level notification policies

### Advanced Monitoring
1. **Performance Baselines**: Track normal vs abnormal behavior
2. **Dependency Monitoring**: Monitor API dependencies
3. **Cost Monitoring**: Track function execution costs
4. **Security Monitoring**: Detect suspicious activity 