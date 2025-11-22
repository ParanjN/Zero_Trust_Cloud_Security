import boto3, json, os
s3 = boto3.client('s3')

def lambda_handler(event, context):
    # parse bucket from CloudTrail event
    try:
        detail = event.get('detail', {})
        bucket = None
        if 'requestParameters' in detail and 'bucketName' in detail['requestParameters']:
            bucket = detail['requestParameters']['bucketName']
        if not bucket:
            return {'status':'no-bucket'}
    except Exception as e:
        return {'error': str(e)}

    # enable object lock legal hold (requires bucket to have object lock enabled at creation)
    try:
        s3.put_object_legal_hold(Bucket=bucket, Key='forensic-trigger', LegalHold={'Status':'ON'})
        # add a restrictive bucket policy (example: deny delete unless from security role)
        policy = {
            "Version":"2012-10-17",
            "Statement":[
                {"Effect":"Deny","Principal":"*","Action":"s3:DeleteObject","Resource":f"arn:aws:s3:::{bucket}/*"}
            ]
        }
        s3.put_bucket_policy(Bucket=bucket, Policy=json.dumps(policy))
        # copy event to forensic bucket
        s3.copy_object(Bucket=os.environ.get('FORENSIC_BUCKET'), CopySource={'Bucket':bucket,'Key':'forensic-trigger'}, Key=f"{bucket}/forensic_trigger.json")
    except Exception as e:
        return {'error': str(e)}

    return {'status':'locked', 'bucket': bucket}
