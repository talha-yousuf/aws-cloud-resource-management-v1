#!/bin/bash

STACK_NAME="demoStack"
S3_BUCKET="demoBucket"
APP_DIR="demo-app"
APP_TAR="demo-app.tar.gz"
CF_TEMPLATE="cloud-formation.yaml"
REGION="us-east-1"
APP_NAME="CodeDeployApplication"

# Check if S3 bucket exists
if ! aws s3 ls "s3://$S3_BUCKET" >/dev/null 2>&1; then
    echo "S3 bucket $S3_BUCKET does not exist, creating it..."
    if ! aws s3 mb s3://$S3_BUCKET --region $REGION; then
        echo "Failed to create S3 bucket $S3_BUCKET"
        exit 1
    fi
else
    echo "S3 bucket $S3_BUCKET exists."
fi

# Upload the package to S3
echo "Uploading the package to S3..."
if ! aws s3 cp $APP_TAR s3://$S3_BUCKET/; then
    echo "Failed to upload the package to S3"
    exit 1
fi

aws cloudformation deploy \
    --template-file $CF_TEMPLATE \
    --stack-name $STACK_NAME \
    --capabilities CAPABILITY_NAMED_IAM \
    --region $REGION

aws deploy create-deployment \
    --application-name $APP_NAME \
    --deployment-config-name CodeDeployDefault.AllAtOnce \
    --deployment-group-name $DEPLOYMENT_GROUP \
    --s3-location bucket=$S3_BUCKET,key=$APP_TAR,bundleType=tar
