import boto3, json
iam = boto3.client('iam')

def lambda_handler(event, context):
    # parse user or principal
    try:
        detail = event.get('detail', {})
        user = None
        if 'userIdentity' in detail and 'userName' in detail['userIdentity']:
            user = detail['userIdentity']['userName']
        if not user:
            return {'status':'no-user'}
    except Exception as e:
        return {'error': str(e)}

    try:
        keys = iam.list_access_keys(UserName=user)['AccessKeyMetadata']
        for k in keys:
            iam.update_access_key(UserName=user, AccessKeyId=k['AccessKeyId'], Status='Inactive')
    except Exception as e:
        return {'error': str(e)}

    return {'status':'revoked', 'user': user}
