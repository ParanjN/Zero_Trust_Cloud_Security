import json
import os
import boto3
from datetime import datetime

def handler(event, context):
    """
    Lambda handler to ingest security findings from EventBridge and store in S3.
    
    Args:
        event: The EventBridge event containing security findings
        context: Lambda context
    """
    bucket = os.environ['BUCKET']
    s3 = boto3.client('s3')
    
    # Generate a unique key for the finding
    timestamp = datetime.utcnow().strftime('%Y/%m/%d/%H/%M/%S')
    source = event.get('source', 'unknown')
    finding_id = event.get('id', datetime.utcnow().isoformat())
    
    key = f"raw/{source}/{timestamp}-{finding_id}.json"
    
    # Store raw event in S3
    s3.put_object(
        Bucket=bucket,
        Key=key,
        Body=json.dumps(event),
        ContentType='application/json'
    )
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Finding stored successfully',
            'location': f"s3://{bucket}/{key}"
        })
    }