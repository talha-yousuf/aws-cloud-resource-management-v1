#!/bin/bash

STACK=demoApp
TEMPLATE=file://cloud-formation.yaml
CAPABILITY=CAPABILITY_NAMED_IAM
REGION=us-east-1

show_menu() {
    echo "0 - Exit"
    echo "1 - Validate Template"
    echo "2 - Create Stack"
    echo "3 - Update Stack"
    echo "4 - Delete Stack"
    echo "5 - List Stack Outputs"
    echo "6 - List Stacks"
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
        aws cloudformation describe-stacks --stack-name $STACK_NAME --query "Stacks[0].Outputs" --output table --region $REGION
        ;;
    6)
        aws cloudformation list-stacks --query "StackSummaries[].[StackName, StackStatus]" --output table --region $REGION
        ;;
    *)
        echo "Invalid option, please try again."
        return
        ;;
    esac
}

while true; do
    show_menu
    read -p "Select an option: " option
    run_command $option
    echo
done
