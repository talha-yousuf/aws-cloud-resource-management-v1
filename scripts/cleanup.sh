#!/bin/bash

STACK_NAME="demoStack"
S3_BUCKET="demoBucket"
APP_TAR="demo-app.tar.gz"

# Cleanup resources (delete CloudFormation stack, S3 object, and app package file)
cleanup() {
    echo "Cleaning up resources..."

    # Delete CloudFormation stack
    echo "Deleting CloudFormation stack..."
    aws cloudformation delete-stack --stack-name $STACK_NAME --debug

    # Remove app package file from S3
    echo "Removing app package file from S3..."
    aws s3 rm s3://$S3_BUCKET/$APP_TAR --debug

    # Delete local app package file
    echo "Removing local app package file..."
    rm $APP_TAR

    echo "Cleanup complete."
}
