#!/usr/bin/env python3
"""
Looker Studio Dashboard Setup Script
This script helps set up the connection between BigQuery and Looker Studio
"""

import json
import config
from google.cloud import bigquery
from google.cloud import secretmanager

def get_project_info():
    """Get project information for dashboard setup"""
    print("🔍 Project Information:")
    print(f"Project ID: {config.PROJECT_ID}")
    print(f"Raw Dataset: {config.RAW_DATASET}")
    print(f"Staging Dataset: {config.STAGING_DATASET}")
    print(f"Analytics Dataset: {config.ANALYTICS_DATASET}")
    print()

def get_bigquery_tables():
    """List available BigQuery tables for dashboard connection"""
    client = bigquery.Client(project=config.PROJECT_ID)
    
    print("📊 Available BigQuery Tables:")
    
    # Check raw dataset
    try:
        raw_tables = list(client.list_tables(config.RAW_DATASET))
        print(f"\n{config.RAW_DATASET} dataset:")
        for table in raw_tables:
            print(f"  - {table.table_id}")
    except Exception as e:
        print(f"  Error accessing {config.RAW_DATASET}: {e}")
    
    # Check staging dataset
    try:
        staging_tables = list(client.list_tables(config.STAGING_DATASET))
        print(f"\n{config.STAGING_DATASET} dataset:")
        for table in staging_tables:
            print(f"  - {table.table_id}")
    except Exception as e:
        print(f"  Error accessing {config.STAGING_DATASET}: {e}")
    
    # Check analytics dataset
    try:
        analytics_tables = list(client.list_tables(config.ANALYTICS_DATASET))
        print(f"\n{config.ANALYTICS_DATASET} dataset:")
        for table in analytics_tables:
            print(f"  - {table.table_id}")
    except Exception as e:
        print(f"  Error accessing {config.ANALYTICS_DATASET}: {e}")
    
    print()

def generate_dashboard_config():
    """Generate dashboard configuration for Looker Studio"""
    dashboard_config = {
        "project_id": config.PROJECT_ID,
        "datasets": {
            "raw": {
                "name": config.RAW_DATASET,
                "tables": ["google_ads_campaigns"]
            },
            "staging": {
                "name": config.STAGING_DATASET,
                "tables": ["stg_google_ads"]
            },
            "analytics": {
                "name": config.ANALYTICS_DATASET,
                "tables": ["campaign_summary"]
            }
        },
        "recommended_queries": {
            "campaign_overview": f"""
                SELECT 
                    advertising_channel_type,
                    COUNT(DISTINCT campaign_id) as campaign_count,
                    SUM(cost) as total_spend,
                    AVG(ctr) as avg_ctr,
                    AVG(roas) as avg_roas
                FROM `{config.PROJECT_ID}.{config.ANALYTICS_DATASET}.campaign_summary`
                GROUP BY advertising_channel_type
                ORDER BY total_spend DESC
            """,
            "weekly_performance": f"""
                SELECT 
                    week_start,
                    SUM(total_spend) as weekly_spend,
                    SUM(total_impressions) as weekly_impressions,
                    SUM(total_clicks) as weekly_clicks,
                    AVG(avg_ctr) as avg_ctr
                FROM `{config.PROJECT_ID}.{config.ANALYTICS_DATASET}.campaign_summary`
                WHERE week_start >= DATE_SUB(CURRENT_DATE(), INTERVAL 8 WEEK)
                GROUP BY week_start
                ORDER BY week_start DESC
            """,
            "top_campaigns": f"""
                SELECT 
                    campaign_name,
                    cost,
                    impressions,
                    clicks,
                    ctr,
                    roas
                FROM `{config.PROJECT_ID}.{config.STAGING_DATASET}.stg_google_ads`
                WHERE cost > 0
                ORDER BY cost DESC
                LIMIT 10
            """
        }
    }
    
    # Save configuration to file
    with open("dashboard/dashboard_config.json", "w") as f:
        json.dump(dashboard_config, f, indent=2)
    
    print("📋 Dashboard configuration saved to dashboard/dashboard_config.json")
    print()

def print_setup_instructions():
    """Print step-by-step setup instructions"""
    print("🎯 Looker Studio Dashboard Setup Instructions:")
    print()
    print("1. 📊 Open Looker Studio (https://lookerstudio.google.com)")
    print("2. 🔗 Click 'Create' > 'Data Source'")
    print("3. 🔍 Search for 'BigQuery' and select it")
    print("4. 🔐 Authenticate with your Google account")
    print("5. 📁 Select your project and dataset:")
    print(f"   - Project: {config.PROJECT_ID}")
    print(f"   - Dataset: {config.ANALYTICS_DATASET}")
    print(f"   - Table: campaign_summary")
    print("6. ✅ Click 'Connect'")
    print("7. 🎨 Start building your dashboard!")
    print()
    print("📈 Recommended Dashboard Components:")
    print("   - Campaign Performance Overview (Table)")
    print("   - Weekly Spend Trend (Time Series)")
    print("   - Channel Performance (Bar Chart)")
    print("   - ROAS by Campaign (Scatter Plot)")
    print("   - Key Metrics Summary (Scorecards)")
    print()

def main():
    """Main function to run dashboard setup"""
    print("🚀 Looker Studio Dashboard Setup")
    print("=" * 40)
    print()
    
    get_project_info()
    get_bigquery_tables()
    generate_dashboard_config()
    print_setup_instructions()
    
    print("✅ Setup complete! Follow the instructions above to create your dashboard.")
    print("📚 For more help, check the dashboard/dashboard_config.json file.")

if __name__ == "__main__":
    main() 