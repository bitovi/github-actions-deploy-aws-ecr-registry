#!/bin/bash

set -ex

echo ""
if [[ ${#TF_STATE_BUCKET} > 63 ]]; then
  echo "Bucket name exceeds name limit"
  exit 63
else
  echo "Creating TF_STATE_BUCKET: $TF_STATE_BUCKET"
  if [ "$AWS_DEFAULT_REGION" == "us-east-1" ]; then
    aws s3api create-bucket --bucket $TF_STATE_BUCKET --region $AWS_DEFAULT_REGION --acl private || true
  else
    aws s3api create-bucket --bucket $TF_STATE_BUCKET --region $AWS_DEFAULT_REGION --create-bucket-configuration LocationConstraint=$AWS_DEFAULT_REGION --acl private|| true
  fi
  
  AWS_PRINCIPAL=$(aws sts get-caller-identity --query "Arn" --output text)
  AWS_ORG_ID=$(aws organizations describe-organization --query Organization.Id --output text)

  # Set bucket policy
  aws s3api put-bucket-policy --bucket "$TF_STATE_BUCKET" --policy '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "'"$AWS_PRINCIPAL"'"
        },
        "Action": "s3:*",
        "Resource": "arn:aws:s3:::'"$TF_STATE_BUCKET"'/*"
      }
    ]
  }'

  aws s3api put-bucket-policy --bucket "$TF_STATE_BUCKET" --policy '{
    "Version": "2012-10-17",
    "Statement": [{
        "Sid": "AllowGetObject",
        "Principal": {
            "AWS": "*"
        },
        "Effect": "Allow",
        "Action": "s3:*",
        "Resource": "arn:aws:s3:::'"$TF_STATE_BUCKET"'/*"
        "Condition": {
            "StringEquals": {
                "aws:PrincipalOrgID": ["'"$AWS_ORG_ID"'"]
            }
        }
    }]
  }'

  if ! [[ -z $(aws s3api head-bucket --bucket $TF_STATE_BUCKET 2>&1) ]]; then
    echo "Bucket does not exist or permission is not there to use it."
    exit 63
  fi
fi