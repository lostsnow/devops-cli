#!/usr/bin/env bash

# Verify AWS CLI Credentials are setup
# http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html
function aws_check_config() {
    if ! grep -q aws_access_key_id ~/.aws/credentials; then
        fail "AWS config not found or CLI not installed. Please run \"aws configure\"."
    fi
}

function usage_region() {
    echo -e "Regions:"
    echo -e "  ap-northeast-1"
    echo -e "  ap-northeast-2"
    echo -e "  ap-south-1"
    echo -e "  ap-southeast-1"
    echo -e "  ap-southeast-2"
    echo -e "  ca-central-1"
    echo -e "  eu-central-1"
    echo -e "  eu-north-1"
    echo -e "  eu-west-1"
    echo -e "  eu-west-2"
    echo -e "  eu-west-3"
    echo -e "  sa-east-1"
    echo -e "  us-east-1"
    echo -e "  us-east-2"
    echo -e "  us-west-1"
    echo -e "  us-west-2"
}

# Get list of all regions (using EC2)
function GetEc2Regions() {
    profile=$1
    AWSregions=$(aws ec2 describe-regions --output=json --profile $profile 2>&1)

    if [ ! $? -eq 0 ]; then
        fail "$AWSregions"
    else
        echo "$AWSregions" | jq '.Regions | .[] | .RegionName' | cut -d \" -f2 | sort
    fi
}

# Select region (using EC2)
function SelectRegion() {
    echo "Get Regions"
    ParseRegions=$(GetEc2Regions $profile 2>&1)
    if [ ! $? -eq 0 ]; then
        fail "$ParseRegions"
    fi

    TotalRegions=$(echo "$ParseRegions" | wc -l | rev | cut -d " " -f1 | rev)
    echo "Regions:"
    HorizontalRule
    info_echo "$ParseRegions"
    HorizontalRule
    echo "TotalRegions: $TotalRegions"
    echo
    read -r -p "Region: " Region
    if [[ -z $Region ]]; then
        fail "Region must be configured."
    fi
}

# Get SNS topic arns
function GetSNSTopicArns() {
    profile=$1
    Region=$2

    if [[ -z $profile ]] || [[ -z $Region ]]; then
        fail "Parameter profile and Region required"
    fi

    SNSTopics=$(aws sns list-topics --profile $profile --region $Region 2>&1)
    if [ ! $? -eq 0 ]; then
        fail "$SNSTopics"
    fi
    echo "$SNSTopics" | jq '.Topics | .[] | .TopicArn' | cut -d \" -f2
}

# Select SNS topic arn
function SelectSNSTopicArn() {
    echo "Get SNS Topic Arns"
    TopicArns=$(GetSNSTopicArns $profile $Region)
    if [ ! $? -eq 0 ]; then
        fail "$TopicArns"
    fi
    if [[ -z $TopicArns ]]; then
        fail "No SNS topic arns found in $Region."
    fi

    echo "SNS Topics Found:"
    HorizontalRule
    info_echo "$TopicArns"
    HorizontalRule
    echo
    read -r -p "ARN: " SNS_TOPIC_ARN
    if [[ -z $SNS_TOPIC_ARN ]]; then
        fail "SNS topic arn must be configured."
    fi
}

# Get list of all EC2 Instances in one region
function GetEc2Instances() {
    profile=$1
    Region=$2

    Instances=$(aws ec2 describe-instances --filters Name=instance-state-name,Values=running --region $Region --output=json --profile $profile 2>&1)
    if [ ! $? -eq 0 ]; then
        fail "$Instances"
    else
        # if [[ $DEBUGMODE = "1" ]]; then
        # echo Instances: "$Instances"
        # fi
        echo "$Instances" | jq '.Reservations | .[] | .Instances | .[] | .InstanceId' | cut -d \" -f2
    fi
}

# Get list of all RDS Instances in one region
function GetRdsInstances() {
    profile=$1
    Region=$2

    Instances=$(aws rds describe-db-instances --query 'DBInstances[?DBInstanceStatus==`available`]' --region $Region --output=json --profile $profile 2>&1)
    if [ ! $? -eq 0 ]; then
        fail "$Instances"
    else
        echo "$Instances" | jq '.[] | .DBInstanceIdentifier' | cut -d \" -f2
    fi
}
