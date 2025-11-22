output "forensic_bucket" { value = aws_s3_bucket.forensics.bucket }
output "isolate_lambda" { value = aws_lambda_function.isolate_ec2.arn }
output "lockdown_lambda" { value = aws_lambda_function.lockdown_s3.arn }
output "revoke_lambda" { value = aws_lambda_function.revoke_iam.arn }
