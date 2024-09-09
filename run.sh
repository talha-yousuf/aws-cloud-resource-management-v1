#!/bin/bash

STACK=demoApp
TEMPLATE=file://cf-template.yaml
CAPABILITY=CAPABILITY_NAMED_IAM
REGION=us-east-1

show_menu() {
    echo "0 - Exit"
    echo "1 - Validate Template"
    echo "2 - Create Stack"
    echo "3 - Update Stack"
    echo "4 - Delete Stack"
    echo "5 - Describe Stack"
    echo "6 - List All Stacks"
    echo "7 - List All Stacks Statuses"
}

run_command() {
    case $1 in
    0)
        exit 0
        ;;
    1)
        aws cloudformation validate-template --template-body $TEMPLATE --region $REGION
        ;;
    2)
        aws cloudformation create-stack --stack-name $STACK --template-body $TEMPLATE --capabilities $CAPABILITY --region $REGION
        ;;
    3)
        aws cloudformation update-stack --stack-name $STACK --template-body $TEMPLATE --capabilities $CAPABILITY --region $REGION
        ;;
    4)
        aws cloudformation delete-stack --stack-name $STACK --region $REGION
        ;;
    5)
        aws cloudformation describe-stacks --stack-name $STACK --region $REGION
        ;;
    6)
        aws cloudformation list-stacks --region $REGION
        ;;
    7)
        aws cloudformation list-stacks --region $REGION --query "StackSummaries[].[StackName, StackStatus]" --output table
        ;;
    *)
        set +x
        echo "Invalid option, please try again."
        return
        ;;
    esac
}

while true; do
    echo
    echo 'Select an option:'
    echo

    show_menu
    read -p "Enter number: " option

    echo
    echo 'Running:'
    echo

    set -x
    run_command $option
    set +x

    echo
done
