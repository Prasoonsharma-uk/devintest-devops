###############################################################################
# Terraform Remote Backend Configuration
# Uses S3 for state storage and DynamoDB for state locking
###############################################################################

terraform {
  backend "s3" {
    # These values are configured via backend config during terraform init
    # in the Azure DevOps pipeline using -backend-config flags:
    #
    #   terraform init \
    #     -backend-config="bucket=<S3_BUCKET_NAME>" \
    #     -backend-config="key=<STATE_FILE_KEY>" \
    #     -backend-config="region=<AWS_REGION>" \
    #     -backend-config="dynamodb_table=<DYNAMODB_TABLE_NAME>" \
    #     -backend-config="encrypt=true"
    #
    # This approach allows the same Terraform code to be used across
    # multiple environments (dev, staging, prod) with different state files.
  }
}
