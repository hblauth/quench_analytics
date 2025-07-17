{{
  config(
    materialized='table'
  )
}}

with google_ads_campaigns as (
  select * from {{ ref('stg_google_ads') }}
),

campaign_summary as (
  select
    -- Date dimensions
    date_trunc(start_date, week) as week_start,
    date_trunc(start_date, month) as month_start,
    
    -- Campaign dimensions
    advertising_channel_type,
    advertising_channel_sub_type,
    bidding_strategy_type,
    status,
    
    -- Aggregated metrics
    count(distinct campaign_id) as campaign_count,
    sum(budget_amount) as total_budget,
    sum(cost) as total_spend,
    sum(impressions) as total_impressions,
    sum(clicks) as total_clicks,
    sum(conversions) as total_conversions,
    sum(conversions_value) as total_conversion_value,
    
    -- Calculated metrics
    round(sum(cost) / nullif(sum(impressions), 0) * 1000, 2) as avg_cpm,
    round(sum(cost) / nullif(sum(clicks), 0), 2) as avg_cpc,
    round(sum(clicks) / nullif(sum(impressions), 0), 4) as avg_ctr,
    round(sum(conversions) / nullif(sum(clicks), 0), 4) as avg_cvr,
    round(sum(conversions_value) / nullif(sum(cost), 0), 2) as avg_roas,
    
    -- Metadata
    max(ingestion_timestamp) as last_updated
    
  from google_ads_campaigns
  where start_date is not null
  group by 1, 2, 3, 4, 5, 6
)

select * from campaign_summary 