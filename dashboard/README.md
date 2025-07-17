# Looker Studio Dashboard Setup Guide

This guide will help you set up a comprehensive marketing analytics dashboard in Looker Studio using the Quench Analytics data pipeline.

## 🚀 Quick Setup

### Prerequisites
- Google Cloud Platform account with BigQuery access
- Looker Studio access (free with Google account)
- Quench Analytics data pipeline deployed and running

### Step 1: Verify Data Pipeline
Before creating the dashboard, ensure your data pipeline is working:

```bash
# Check if data exists in BigQuery
bq ls practical-brace-466015-b1:staging
bq ls practical-brace-466015-b1:analytics

# Run dbt transformations if needed
cd dbt
dbt run
```

### Step 2: Connect to BigQuery
1. Open [Looker Studio](https://lookerstudio.google.com)
2. Click **Create** → **Data Source**
3. Search for **BigQuery** and select it
4. Authenticate with your Google account
5. Select your project: `practical-brace-466015-b1`
6. Choose dataset: `analytics`
7. Select table: `campaign_summary`
8. Click **Connect**

### Step 3: Create Dashboard Components

#### 📊 Key Metrics Scorecards
Create individual metric cards for:
- **Total Spend**: SUM of cost
- **Total Impressions**: SUM of impressions  
- **Total Clicks**: SUM of clicks
- **Average CTR**: AVG of ctr
- **Average ROAS**: AVG of roas

#### 📈 Time Series Charts
1. **Weekly Spend Trend**
   - Chart Type: Time series
   - Dimension: week_start
   - Metric: total_spend

2. **Performance Over Time**
   - Chart Type: Line chart
   - Dimensions: week_start, advertising_channel_type
   - Metrics: total_spend, avg_ctr

#### 📋 Data Tables
1. **Campaign Performance Table**
   - Use the `campaign_summary` table
   - Add filters for date range and channel type
   - Sort by total_spend DESC

2. **Top Performing Campaigns**
   - Use custom SQL query from `sample_queries.sql`
   - Limit to top 20 campaigns by ROAS

#### 🎯 Charts and Visualizations
1. **Channel Performance Bar Chart**
   - Chart Type: Bar chart
   - Dimension: advertising_channel_type
   - Metrics: total_spend, avg_ctr, avg_roas

2. **ROAS vs Spend Scatter Plot**
   - Chart Type: Scatter plot
   - X-axis: cost
   - Y-axis: roas
   - Color: advertising_channel_type

3. **Campaign Status Distribution**
   - Chart Type: Pie chart
   - Dimension: status
   - Metric: campaign_count

## 📋 Dashboard Layout Recommendations

### Header Section
- Dashboard title: "Quench Analytics - Marketing Performance"
- Date range picker
- Channel filter dropdown

### Top Row - Key Metrics
- 4-5 scorecard components showing key KPIs
- Use consistent formatting and colors

### Middle Section - Performance Trends
- Weekly spend trend (time series)
- Channel performance comparison (bar chart)
- ROAS vs spend scatter plot

### Bottom Section - Detailed Data
- Campaign performance table
- Top performing campaigns list
- Campaign status distribution

## 🔧 Advanced Features

### Custom SQL Queries
Use the queries in `sample_queries.sql` for more complex visualizations:

1. **Campaign Performance Overview**: Summary by channel and sub-type
2. **Weekly Performance Trend**: Time-based analysis
3. **Top Performing Campaigns**: Best ROI campaigns
4. **ROAS vs Spend Scatter Plot**: Investment vs return analysis
5. **Channel Performance Comparison**: Cross-channel analysis
6. **Key Metrics Summary**: Overall performance indicators
7. **Monthly Performance by Channel**: Long-term trends
8. **Campaign Status Distribution**: Status breakdown

### Filters and Controls
Add interactive filters for:
- Date range selection
- Advertising channel type
- Campaign status
- Spend threshold
- ROAS threshold

### Calculated Fields
Create custom calculated fields in Looker Studio:
- **Profit Margin**: (conversions_value - cost) / cost
- **Efficiency Score**: (ctr * roas) / 100
- **Cost per Conversion**: cost / conversions

## 📊 Dashboard Refresh

### Automatic Refresh
- BigQuery tables update automatically when new data is ingested
- Looker Studio refreshes data every 12 hours by default
- Manual refresh available in dashboard settings

### Data Freshness
- Cloud Function runs weekly (Mondays at 6 AM UTC)
- dbt transformations should be scheduled to run after data ingestion
- Dashboard will show latest data within 24 hours

## 🎨 Design Best Practices

### Color Scheme
- Use consistent colors for different channels
- Green for positive metrics (ROAS, conversions)
- Red for negative metrics (high CPC, low CTR)
- Blue for neutral metrics (spend, impressions)

### Layout
- Keep related metrics together
- Use appropriate chart types for data
- Ensure mobile responsiveness
- Add clear titles and descriptions

### Interactivity
- Add drill-down capabilities
- Include hover tooltips
- Enable cross-filtering between charts
- Add export functionality

## 🔍 Troubleshooting

### Common Issues

1. **No Data Showing**
   - Check if BigQuery tables exist and have data
   - Verify dbt transformations have run successfully
   - Check data source connection in Looker Studio

2. **Slow Dashboard Performance**
   - Use appropriate date filters
   - Limit data in custom SQL queries
   - Consider materializing frequently used queries

3. **Authentication Errors**
   - Ensure proper BigQuery permissions
   - Check Google account access to Looker Studio
   - Verify project ID is correct

### Support Resources
- [Looker Studio Help Center](https://support.google.com/looker-studio/)
- [BigQuery Documentation](https://cloud.google.com/bigquery/docs)
- [dbt Documentation](https://docs.getdbt.com/)

## 📈 Next Steps

### Dashboard Enhancements
- Add more data sources (Meta Ads, TikTok Ads)
- Implement advanced analytics (attribution modeling)
- Create executive summary views
- Add automated reporting

### Advanced Analytics
- Customer lifetime value analysis
- Cross-platform attribution
- Predictive analytics for campaign performance
- A/B testing results integration

### Automation
- Set up automated dashboard sharing
- Create email reports
- Implement alerting for performance thresholds
- Schedule regular dashboard reviews 