import os
import boto3
from datetime import datetime
from boto3.dynamodb.conditions import Attr

dynamodb = boto3.resource('dynamodb')
sso = boto3.client('sso-admin')
TABLE_NAME = os.environ['TABLE_NAME']
INSTANCE_ARN = os.environ['INSTANCE_ARN']
table = dynamodb.Table(TABLE_NAME)

def lambda_handler(event, context):
    now = int(datetime.utcnow().timestamp())
    resp = table.scan(
        FilterExpression=Attr('expires_at').lte(now)
    )
    items = resp.get('Items', [])
    for item in items:
        try:
            sso.delete_account_assignment(
                InstanceArn=INSTANCE_ARN,
                TargetId=item['account_id'],
                TargetType='AWS_ACCOUNT',
                PermissionSetArn=item['permission_set_arn'],
                PrincipalType=item['principal_type'],
                PrincipalId=item['principal_id']
            )
        except Exception as e:
            print("delete failed", e)
        try:
            table.delete_item(Key={'assignment_id': item['assignment_id']})
        except Exception as e:
            print("delete item failed", e)
    return {"status": "completed", "processed": len(items)}
