#!/bin/bash
###############################################################################
# Bootstrap Terraform Remote Backend
# Creates the S3 bucket and DynamoDB table for Terraform state management
#
# Usage: ./scripts/bootstrap-terraform-backend.sh [project-name] [region]
###############################################################################

set -euo pipefail

PROJECT_NAME="${1:-hello-world-ecs}"
REGION="${2:-us-east-1}"
BUCKET_NAME="${PROJECT_NAME}-terraform-state"
DYNAMODB_TABLE="${PROJECT_NAME}-terraform-locks"

echo "=============================================="
echo "  Bootstrapping Terraform Backend"
echo "  Project: ${PROJECT_NAME}"
echo "  Region:  ${REGION}"
echo "  Bucket:  ${BUCKET_NAME}"
echo "  Table:   ${DYNAMODB_TABLE}"
echo "=============================================="

# Create S3 bucket for Terraform state
echo ""
echo "Creating S3 bucket: ${BUCKET_NAME}..."
if aws s3api head-bucket --bucket "${BUCKET_NAME}" 2>/dev/null; then
    echo "Bucket already exists."
else
    if [ "${REGION}" = "us-east-1" ]; then
        aws s3api create-bucket \
            --bucket "${BUCKET_NAME}" \
            --region "${REGION}"
    else
        aws s3api create-bucket \
            --bucket "${BUCKET_NAME}" \
            --region "${REGION}" \
            --create-bucket-configuration LocationConstraint="${REGION}"
    fi
    echo "Bucket created successfully."
fi

# Enable versioning on the S3 bucket
echo "Enabling versioning on bucket..."
aws s3api put-bucket-versioning \
    --bucket "${BUCKET_NAME}" \
    --versioning-configuration Status=Enabled

# Enable server-side encryption
echo "Enabling server-side encryption..."
aws s3api put-bucket-encryption \
    --bucket "${BUCKET_NAME}" \
    --server-side-encryption-configuration '{
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "aws:kms"
                },
                "BucketKeyEnabled": true
            }
        ]
    }'

# Block all public access
echo "Blocking public access..."
aws s3api put-public-access-block \
    --bucket "${BUCKET_NAME}" \
    --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# Create DynamoDB table for state locking
echo ""
echo "Creating DynamoDB table: ${DYNAMODB_TABLE}..."
if aws dynamodb describe-table --table-name "${DYNAMODB_TABLE}" --region "${REGION}" 2>/dev/null; then
    echo "DynamoDB table already exists."
else
    aws dynamodb create-table \
        --table-name "${DYNAMODB_TABLE}" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --billing-mode PAY_PER_REQUEST \
        --region "${REGION}"
    echo "Waiting for table to become active..."
    aws dynamodb wait table-exists \
        --table-name "${DYNAMODB_TABLE}" \
        --region "${REGION}"
    echo "DynamoDB table created successfully."
fi

echo ""
echo "=============================================="
echo "  Backend Bootstrap Complete!"
echo ""
echo "  Use these values in your Terraform init:"
echo "    -backend-config=\"bucket=${BUCKET_NAME}\""
echo "    -backend-config=\"region=${REGION}\""
echo "    -backend-config=\"dynamodb_table=${DYNAMODB_TABLE}\""
echo "    -backend-config=\"encrypt=true\""
echo "=============================================="
