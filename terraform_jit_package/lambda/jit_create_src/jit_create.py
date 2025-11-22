import os
import json
import boto3
import uuid
from datetime import datetime, timedelta

sso = boto3.client('sso-admin')
dynamodb = boto3.resource('dynamodb')
TABLE_NAME = os.environ['TABLE_NAME']
INSTANCE_ARN = os.environ['INSTANCE_ARN']
DEFAULT_TTL = int(os.environ.get('DEFAULT_TTL', '60'))
table = dynamodb.Table(TABLE_NAME)

def lambda_handler(event, context):
    try:
        body = event.get('body')
        if isinstance(body, str):
            body = json.loads(body)
        principal_id = body['principal_id']
        principal_type = body['principal_type']
        account_id = body['account_id']
        permission_set_name = body['permission_set_name']
        ttl = int(body.get('ttl_minutes', DEFAULT_TTL))
    except Exception as e:
        return {"statusCode":400, "body": json.dumps({"error":"invalid input", "details": str(e)})}

    ps_arn = None
    paginator = sso.get_paginator('list_permission_sets')
    for page in paginator.paginate(InstanceArn=INSTANCE_ARN):
        for ps in page.get('PermissionSets', []):
            try:
                desc = sso.describe_permission_set(InstanceArn=INSTANCE_ARN, PermissionSetArn=ps)
                if desc.get('PermissionSet', {}).get('Name') == permission_set_name:
                    ps_arn = ps
                    break
            except Exception:
                continue
        if ps_arn:
            break

    if not ps_arn:
        return {"statusCode":404, "body": json.dumps({"error":"permission set not found"})}

    try:
        sso.create_account_assignment(
            InstanceArn=INSTANCE_ARN,
            TargetId=account_id,
            TargetType='AWS_ACCOUNT',
            PermissionSetArn=ps_arn,
            PrincipalType=principal_type,
            PrincipalId=principal_id
        )
    except Exception as e:
        return {"statusCode":500, "body": json.dumps({"error":"create assignment failed", "details": str(e)})}

    assignment_id = str(uuid.uuid4())
    expires_at = int((datetime.utcnow() + timedelta(minutes=ttl)).timestamp())

    table.put_item(Item={
        'assignment_id': assignment_id,
        'principal_id': principal_id,
        'principal_type': principal_type,
        'account_id': account_id,
        'permission_set_arn': ps_arn,
        'expires_at': expires_at,
        'created_at': int(datetime.utcnow().timestamp())
    })

    return {"statusCode":200, "body": json.dumps({"assignment_id": assignment_id, "expires_at": expires_at})}
