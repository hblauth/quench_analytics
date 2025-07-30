import requests
import json
import config
from datetime import datetime, timezone
from google.cloud import storage
from google.ads.googleads.client import GoogleAdsClient
from google.ads.googleads.errors import GoogleAdsException
from utils import get_secret
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def main(request):
    """
    Cloud Function entry point for Google Ads data ingestion.
    Expects HTTP POST or GET request.
    """
    start_time = datetime.now(timezone.utc)
    logger.info("Starting Google Ads data ingestion")
    
    try:
        # Fetch secrets from Secret Manager
        logger.info("Fetching secrets from Secret Manager")
        developer_token = get_secret(config.SECRET_NAMES["developer_token"], config.PROJECT_ID)
        client_id = get_secret(config.SECRET_NAMES["client_id"], config.PROJECT_ID)
        client_secret = get_secret(config.SECRET_NAMES["client_secret"], config.PROJECT_ID)
        refresh_token = get_secret(config.SECRET_NAMES["refresh_token"], config.PROJECT_ID)
        login_customer_id = get_secret(config.SECRET_NAMES["login_customer_id"], config.PROJECT_ID)
        
        logger.info("Successfully retrieved secrets from Secret Manager")

        # Initialize Google Ads client
        logger.info("Initializing Google Ads client")
        client = GoogleAdsClient.load_from_dict({
            "developer_token": developer_token,
            "client_id": client_id,
            "client_secret": client_secret,
            "refresh_token": refresh_token,
            "login_customer_id": login_customer_id,
            "use_proto_plus": True,
        })
        
        logger.info("Google Ads client initialized successfully")

        # Fetch campaign data from Google Ads API
        logger.info("Fetching campaign data from Google Ads API")
        campaigns = fetch_campaign_data(client, login_customer_id)
        
        if len(campaigns) == 0:
            logger.warning("Retrieved 0 campaigns from Google Ads API - this may indicate an issue")
        else:
            logger.info(f"Retrieved {len(campaigns)} campaigns from Google Ads API")

        # Save to GCS
        logger.info("Saving data to Google Cloud Storage")
        date_str = datetime.now(timezone.utc).strftime("%Y-%m-%d")
        destination_blob = f"{config.DATA_SOURCES['google_ads']['gcs_path']}/{date_str}/google_ads_response.json"
        
        storage_client = storage.Client()
        bucket = storage_client.bucket(config.RAW_DATA_BUCKET)
        blob = bucket.blob(destination_blob)
        blob.upload_from_string(json.dumps(campaigns, indent=2), content_type="application/json")
        
        execution_time = (datetime.now(timezone.utc) - start_time).total_seconds()
        logger.info(f"Successfully uploaded data to gs://{config.RAW_DATA_BUCKET}/{destination_blob} in {execution_time:.2f} seconds")

        return (f"Uploaded to gs://{config.RAW_DATA_BUCKET}/{destination_blob}", 200)
        
    except GoogleAdsException as ex:
        execution_time = (datetime.now(timezone.utc) - start_time).total_seconds()
        error_msg = f"Google Ads API error after {execution_time:.2f}s: {ex}"
        logger.error(error_msg)
        logger.error(f"Request ID: {getattr(ex, 'request_id', 'N/A')}")
        logger.error(f"Error code: {getattr(ex, 'error', {}).get('code', 'N/A')}")
        return (error_msg, 500)
        
    except Exception as e:
        execution_time = (datetime.now(timezone.utc) - start_time).total_seconds()
        error_msg = f"Unexpected error after {execution_time:.2f}s: {str(e)}"
        logger.error(error_msg)
        logger.error(f"Error type: {type(e).__name__}")
        return (error_msg, 500)

def fetch_campaign_data(client, customer_id):
    """
    Fetch campaign data from Google Ads API.
    """
    ga_service = client.get_service("GoogleAdsService")
    
    query = """
        SELECT 
            campaign.id,
            campaign.name,
            campaign.status,
            campaign.start_date,
            campaign.end_date,
            campaign.advertising_channel_type,
            campaign.advertising_channel_sub_type,
            campaign.bidding_strategy_type,
            campaign_budget.amount_micros,
            metrics.impressions,
            metrics.clicks,
            metrics.cost_micros,
            metrics.conversions,
            metrics.conversions_value
        FROM campaign 
        WHERE campaign.status != 'REMOVED'
        ORDER BY campaign.id
    """
    
    search_request = client.get_type("SearchGoogleAdsRequest")
    search_request.customer_id = customer_id
    search_request.query = query
    search_request.page_size = 1000
    
    campaigns = []
    
    try:
        for row in ga_service.search(request=search_request):
            campaign = {
                "campaign_id": row.campaign.id,
                "campaign_name": row.campaign.name,
                "status": row.campaign.status.name,
                "start_date": row.campaign.start_date,
                "end_date": row.campaign.end_date,
                "advertising_channel_type": row.campaign.advertising_channel_type.name,
                "advertising_channel_sub_type": row.campaign.advertising_channel_sub_type.name,
                "bidding_strategy_type": row.campaign.bidding_strategy_type.name,
                "budget_amount_micros": row.campaign_budget.amount_micros,
                "impressions": row.metrics.impressions,
                "clicks": row.metrics.clicks,
                "cost_micros": row.metrics.cost_micros,
                "conversions": row.metrics.conversions,
                "conversions_value": row.metrics.conversions_value,
                "ingestion_timestamp": datetime.now(timezone.utc).isoformat()
            }
            campaigns.append(campaign)
            
    except GoogleAdsException as ex:
        logger.error(f"Request with ID '{ex.request_id}' failed with status {ex.error.code().name}")
        logger.error(f"Error message: {ex.error.message}")
        raise
    
    return campaigns 