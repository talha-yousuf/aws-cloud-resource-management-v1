#!/bin/bash
# todo: add commands to delete services created in this

echo "INIT"

echo
echo "Fetching account ID..."
account_id=$(aws sts get-caller-identity --query "Account" --output text)
echo "Account ID: $account_id"

app_name="demo-nodejs-app"
app_zip="demo-nodejs-app.zip"
bucket_name="demo-app-bucket-$account_id"
deployment_group_name="demo-deploy-group"
deployment_config_name="CodeDeployDefault.AllAtOnce"

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
