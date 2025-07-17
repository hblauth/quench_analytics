-- Sample SQL Queries for Looker Studio Dashboard
-- Use these queries as custom SQL data sources in Looker Studio

-- 1. Campaign Performance Overview
-- Use this for a summary table showing key metrics by channel
SELECT 
    advertising_channel_type,
    advertising_channel_sub_type,
    COUNT(DISTINCT campaign_id) as campaign_count,
    SUM(cost) as total_spend,
    SUM(impressions) as total_impressions,
    SUM(clicks) as total_clicks,
    SUM(conversions) as total_conversions,
    SUM(conversions_value) as total_conversion_value,
    AVG(ctr) as avg_ctr,
    AVG(cpc) as avg_cpc,
    AVG(cpm) as avg_cpm,
    AVG(roas) as avg_roas
FROM `practical-brace-466015-b1.staging.stg_google_ads`
WHERE cost > 0
GROUP BY advertising_channel_type, advertising_channel_sub_type
ORDER BY total_spend DESC;

-- 2. Weekly Performance Trend
-- Use this for a time series chart showing spend over time
SELECT 
    DATE_TRUNC(start_date, WEEK) as week_start,
    SUM(cost) as weekly_spend,
    SUM(impressions) as weekly_impressions,
    SUM(clicks) as weekly_clicks,
    SUM(conversions) as weekly_conversions,
    AVG(ctr) as avg_ctr,
    AVG(roas) as avg_roas
FROM `practical-brace-466015-b1.staging.stg_google_ads`
WHERE start_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 WEEK)
GROUP BY week_start
ORDER BY week_start DESC;

-- 3. Top Performing Campaigns
-- Use this for a table showing the best campaigns
SELECT 
    campaign_name,
    advertising_channel_type,
    cost,
    impressions,
    clicks,
    conversions,
    conversions_value,
    ctr,
    cpc,
    roas
FROM `practical-brace-466015-b1.staging.stg_google_ads`
WHERE cost > 0
ORDER BY roas DESC
LIMIT 20;

-- 4. ROAS vs Spend Scatter Plot
-- Use this for a scatter plot showing ROI vs investment
SELECT 
    campaign_name,
    cost,
    roas,
    ctr,
    advertising_channel_type
FROM `practical-brace-466015-b1.staging.stg_google_ads`
WHERE cost > 0 AND roas > 0
ORDER BY cost DESC;

-- 5. Channel Performance Comparison
-- Use this for a bar chart comparing channels
SELECT 
    advertising_channel_type,
    SUM(cost) as total_spend,
    AVG(ctr) as avg_ctr,
    AVG(cpc) as avg_cpc,
    AVG(roas) as avg_roas,
    COUNT(DISTINCT campaign_id) as campaign_count
FROM `practical-brace-466015-b1.staging.stg_google_ads`
WHERE cost > 0
GROUP BY advertising_channel_type
ORDER BY total_spend DESC;

-- 6. Key Metrics Summary (for scorecards)
-- Use this for individual metric cards
SELECT 
    SUM(cost) as total_spend,
    SUM(impressions) as total_impressions,
    SUM(clicks) as total_clicks,
    SUM(conversions) as total_conversions,
    SUM(conversions_value) as total_conversion_value,
    AVG(ctr) as overall_ctr,
    AVG(cpc) as overall_cpc,
    AVG(roas) as overall_roas,
    COUNT(DISTINCT campaign_id) as total_campaigns
FROM `practical-brace-466015-b1.staging.stg_google_ads`
WHERE cost > 0;

-- 7. Monthly Performance by Channel
-- Use this for a stacked bar chart
SELECT 
    DATE_TRUNC(start_date, MONTH) as month_start,
    advertising_channel_type,
    SUM(cost) as monthly_spend,
    SUM(impressions) as monthly_impressions,
    SUM(clicks) as monthly_clicks,
    AVG(ctr) as avg_ctr
FROM `practical-brace-466015-b1.staging.stg_google_ads`
WHERE start_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 6 MONTH)
GROUP BY month_start, advertising_channel_type
ORDER BY month_start DESC, monthly_spend DESC;

-- 8. Campaign Status Distribution
-- Use this for a pie chart showing campaign status
SELECT 
    status,
    COUNT(DISTINCT campaign_id) as campaign_count,
    SUM(cost) as total_spend
FROM `practical-brace-466015-b1.staging.stg_google_ads`
GROUP BY status
ORDER BY campaign_count DESC; 