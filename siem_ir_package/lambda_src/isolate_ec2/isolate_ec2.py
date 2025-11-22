import boto3, json, os
ec2 = boto3.client('ec2')
s3 = boto3.client('s3')

def lambda_handler(event, context):
    # simplistic parse - adapt to real GuardDuty finding structure
    try:
        finding = event.get('detail', {})
        instance_id = None
        # GuardDuty finding details may include resource.instanceDetails.instanceId
        if 'resource' in finding and 'instanceDetails' in finding['resource'] and 'instanceId' in finding['resource']['instanceDetails']:
            instance_id = finding['resource']['instanceDetails']['instanceId']
        if not instance_id:
            return {'status': 'no-instance-in-event'}
    except Exception as e:
        return {'error': str(e)}

    # create isolation security group
    try:
        reservations = ec2.describe_instances(InstanceIds=[instance_id])['Reservations']
        if not reservations:
            return {'status':'instance-not-found'}
        vpc_id = reservations[0]['Instances'][0]['VpcId']
        sg = ec2.create_security_group(GroupName=f"isolate-{instance_id}", Description='isolation', VpcId=vpc_id)
        # remove ingress by not adding any ingress rules
        ec2.modify_instance_attribute(InstanceId=instance_id, Groups=[sg['GroupId']])
        # snapshot volumes for evidence
        vols = reservations[0]['Instances'][0]['BlockDeviceMappings']
        for v in vols:
            volid = v['Ebs']['VolumeId']
            ec2.create_snapshot(VolumeId=volid, Description=f"evidence-{instance_id}")
        # store event
        s3.put_object(Bucket=os.environ.get('FORENSIC_BUCKET'), Key=f"{instance_id}/finding.json", Body=json.dumps(finding))
    except Exception as e:
        return {'error': str(e)}
    return {'status':'isolated', 'instance': instance_id}
