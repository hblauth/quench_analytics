{{
  config(
    materialized='view'
  )
}}

with source as (
  select * from {{ source('raw', 'google_ads_campaigns') }}
),

renamed as (
  select
    -- Campaign identifiers
    campaign_id,
    campaign_name,
    
    -- Campaign metadata
    status,
    start_date,
    end_date,
    advertising_channel_type,
    advertising_channel_sub_type,
    bidding_strategy_type,
    
    -- Financial metrics (convert from micros to actual currency)
    budget_amount_micros / 1000000.0 as budget_amount,
    cost_micros / 1000000.0 as cost,
    
    -- Performance metrics
    impressions,
    clicks,
    conversions,
    conversions_value,
    
    -- Calculated metrics
    case 
      when impressions > 0 then round(clicks / impressions, 4)
      else 0 
    end as ctr,
    
    case 
      when clicks > 0 then round(cost_micros / 1000000.0 / clicks, 2)
      else 0 
    end as cpc,
    
    case 
      when impressions > 0 then round(cost_micros / 1000000.0 / impressions * 1000, 2)
      else 0 
    end as cpm,
    
    case 
      when cost_micros > 0 then round(conversions_value / (cost_micros / 1000000.0), 2)
      else 0 
    end as roas,
    
    -- Metadata
    ingestion_timestamp,
    _loaded_at
  from source
)

select * from renamed 