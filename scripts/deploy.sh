#!/bin/bash

STACK_NAME="demoStack"
S3_BUCKET="demoBucket"
APP_DIR="demo-app"
APP_TAR="demo-app.tar.gz"
CF_TEMPLATE="cloud-formation.yaml"
REGION="us-east-1"
APP_NAME="CodeDeployApplication"

# Check if S3 bucket exists
if ! aws s3 ls "s3://$S3_BUCKET" --debug >/dev/null 2>&1; then
    echo "S3 bucket $S3_BUCKET does not exist, creating it..."
    if ! aws s3 mb s3://$S3_BUCKET --region $REGION --debug; then
        echo "Failed to create S3 bucket $S3_BUCKET"
        exit 1
    fi
else
    echo "S3 bucket $S3_BUCKET exists."
fi

# Package the Node.js app into a tar.gz file
echo "Packaging the Node.js app..."
if ! tar -czf $APP_TAR $APP_DIR; then
    echo "Failed to package the app into a tar.gz file"
    exit 1
fi

# Upload the package to S3
echo "Uploading the package to S3..."
if ! aws s3 cp $APP_TAR s3://$S3_BUCKET/ --debug; then
    echo "Failed to upload the package to S3"
    exit 1
fi

# Deploy the CloudFormation stack
echo "Deploying CloudFormation stack..."
if ! aws cloudformation deploy --debug \
    --template-file $CF_TEMPLATE \
    --stack-name $STACK_NAME \
    --capabilities CAPABILITY_NAMED_IAM \
    --region $REGION; then
    echo "Failed to deploy CloudFormation stack"
    exit 1
fi

# Get stack outputs and export them as environment variables
echo "Exporting environment variables..."

# Fetch stack outputs
outputs=$(aws cloudformation describe-stacks --debug \
    --stack-name $STACK_NAME \
    --query "Stacks[0].Outputs" \
    --output text)

# Adjust these keys based on the outputs from the CloudFormation template
RDS_HOSTNAME=$(echo "$outputs" | grep 'RDSHostname' | awk '{print $2}')
RDS_USERNAME=$(echo "$outputs" | grep 'RDSUsername' | awk '{print $2}')
RDS_PASSWORD=$(echo "$outputs" | grep 'RDSPassword' | awk '{print $2}')
RDS_DBNAME=$(echo "$outputs" | grep 'RDSDBName' | awk '{print $2}')
REDIS_HOSTNAME=$(echo "$outputs" | grep 'RedisHostname' | awk '{print $2}')
DEPLOYMENT_GROUP=$(echo "$outputs" | grep 'DeploymentGroupName' | awk '{print $2}')

if [[ -z "$RDS_HOSTNAME" || -z "$RDS_USERNAME" || -z "$RDS_PASSWORD" || -z "$RDS_DBNAME" || -z "$REDIS_HOSTNAME" || -z "$DEPLOYMENT_GROUP" ]]; then
    echo "Failed to fetch some stack outputs."
    exit 1
fi

export RDS_HOSTNAME
export RDS_USERNAME
export RDS_PASSWORD
export RDS_DBNAME
export REDIS_HOSTNAME
export DEPLOYMENT_GROUP

echo "Environment variables exported."

# Deploy the application using CodeDeploy
echo "Deploying the application using CodeDeploy..."

if ! aws deploy create-deployment --debug \
    --application-name $APP_NAME \
    --deployment-config-name CodeDeployDefault.AllAtOnce \
    --deployment-group-name $DEPLOYMENT_GROUP \
    --s3-location bucket=$S3_BUCKET,key=$APP_TAR,bundleType=tar; then
    echo "Failed to create deployment using CodeDeploy"
    exit 1
fi

# Cleanup
echo "Cleaning up..."
rm -f $APP_TAR

echo "Deployment completed successfully."
