import json
import os
import boto3
from datetime import datetime

def handler(event, context):
    """
    Lambda handler to score security findings and map to financial risk categories.
    
    Args:
        event: S3 event containing details of new finding
        context: Lambda context
    """
    s3 = boto3.client('s3')
    sagemaker = boto3.client('sagemaker-runtime')
    bucket = os.environ['BUCKET']
    endpoint_name = os.environ.get('SAGEMAKER_ENDPOINT')
    
    # Process each record from S3 event
    for record in event['Records']:
        # Get the finding from S3
        source_key = record['s3']['object']['key']
        finding = json.loads(s3.get_object(
            Bucket=bucket,
            Key=source_key
        )['Body'].read().decode('utf-8'))
        
        # Basic scoring logic (replace with SageMaker if endpoint configured)
        if endpoint_name:
            # Use SageMaker endpoint for scoring
            response = sagemaker.invoke_endpoint(
                EndpointName=endpoint_name,
                ContentType='application/json',
                Body=json.dumps(finding)
            )
            score = json.loads(response['Body'].read().decode())
        else:
            # Simple severity-based scoring
            severity = finding.get('Severity', 'MEDIUM').upper()
            score = {
                'CRITICAL': 90,
                'HIGH': 70,
                'MEDIUM': 50,
                'LOW': 30,
                'INFORMATIONAL': 10
            }.get(severity, 50)
        
        # Enrich finding with score
        finding['risk_score'] = score
        finding['scored_at'] = datetime.utcnow().isoformat()
        
        # Store scored finding
        dest_key = source_key.replace('raw/', 'scored/')
        s3.put_object(
            Bucket=bucket,
            Key=dest_key,
            Body=json.dumps(finding),
            ContentType='application/json'
        )
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Findings scored successfully'
        })
    }