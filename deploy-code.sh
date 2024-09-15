#!/bin/bash
# todo: add commands to delete services created in this

echo "INIT"

echo
echo "Fetching account ID..."
account_id=$(aws sts get-caller-identity --query "Account" --output text)
echo "Account ID: $account_id"

region="us-east-1"
app_name="demo-nodejs-app"
app_zip="demo-nodejs-app.zip"
bucket_name="demo-app-bucket-$account_id"
deployment_group_name="demo-deploy-group"
deployment_config_name="CodeDeployDefault.AllAtOnce"

echo
echo "Fetching the list of existing S3 buckets..."
bucket_list=$(aws s3api list-buckets --query "Buckets[].Name" --output text)
echo "You have following buckets: $bucket_list"

echo
echo "Checking if the bucket '$bucket_name' already exists?"
if echo "$bucket_list" | grep -qw "$bucket_name"; then
    echo "Bucket '$bucket_name' already exists."
else
    echo "Bucket '$bucket_name' does not exist."

    echo
    echo "Creating Bucket '$bucket_name' now..."
    aws s3api create-bucket --bucket "$bucket_name" --region "$region"

    echo
    echo "Verifying bucket creation..."
    if aws s3api head-bucket --bucket "$bucket_name" 2>/dev/null; then
        echo "Bucket '$bucket_name' created successfully."

        echo
        echo "Fetching the list of existing S3 buckets again..."
        bucket_list=$(aws s3api list-buckets --query "Buckets[].Name" --output text)
        echo "You have following buckets now: $bucket_list"
    else
        echo "Bucket '$bucket_name' could not be created."
        exit 1
    fi
fi

echo
echo "Bundling app code into zip..."
powershell Compress-Archive -Path "$app_name" -DestinationPath "$app_zip" -Force
if [ -f "$app_zip" ]; then
    echo "Zip created."
else
    echo "Zip could not be created"
    exit 1
fi

echo
echo "Uploading app bundle to S3..."
aws s3 cp "$app_zip" "s3://$bucket_name/"

echo
echo "Checking if the file exists in the S3 bucket?"
if aws s3api head-object --bucket "$bucket_name" --key "$app_zip" >/dev/null 2>&1; then
    echo "'$app_zip' uploaded to bucket '$bucket_name'."
else
    echo "'$app_zip' was not uploaded to bucket '$bucket_name'."
    exit 1
fi

echo
echo "Cleaning up..."
rm -rf "$app_zip"

echo
echo "Checking if the revision already exists?"
existing_revision=$(aws deploy list-deployments \
    --application-name "$app_name" \
    --deployment-group-name "$deployment_group_name" \
    --query 'deployments[?contains(revision.s3Location.key, `'"$app_zip"'`)]' \
    --output text)

if [ -z "$existing_revision" ]; then
    echo "Registering new application revision..."
    aws deploy register-application-revision \
        --application-name "$app_name" \
        --s3-location bucket="$bucket_name",key="$app_zip",bundleType=zip
else
    echo "Revision already registered. Skipping registration."
fi

echo
echo "Checking if a recent deployment exists with the same revision?"
recent_deployment_id=$(aws deploy list-deployments \
    --application-name "$app_name" \
    --deployment-group-name "$deployment_group_name" \
    --query "deployments[?contains(revision.s3Location.key, '$app_zip')]" \
    --output text)

if [ -z "$recent_deployment_id" ]; then
    echo
    echo "Creating new deployment..."
    deployment_id=$(aws deploy create-deployment \
        --application-name "$app_name" \
        --deployment-group-name "$deployment_group_name" \
        --s3-location bucket="$bucket_name",key="$app_zip",bundleType=zip \
        --deployment-config-name "$deployment_config_name" \
        --description "Deployment of the application bundle from S3" \
        --query 'deploymentId' \
        --output text)

    if [ -z "$deployment_id" ]; then
        echo "Deployment creation failed."
        exit 1
    else
        echo "Deployment created successfully. Deployment ID: $deployment_id"
    fi
else
    echo "A recent deployment with the same revision already exists. Deployment ID: $recent_deployment_id"
fi
