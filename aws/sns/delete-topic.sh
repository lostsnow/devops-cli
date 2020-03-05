#!/usr/bin/env bash

# This script delete AWS SNS Topics
# Requires AWS CLI Setup

# Change working directory
DIR_PATH="$(
    cd "$(echo "${0%/*}")"
    pwd
)"
ROOT_PATH=$(dirname $(dirname ${DIR_PATH}))
source ${ROOT_PATH}/base.sh
source ${ROOT_PATH}/aws/aws.sh

# Set Variables

# Optionally limit to a single AWS Region
Region=""

profile=default

# Check required commands
check_command "aws"
check_command "jq"

aws_check_config

usage() {
    echo -e "Usage: $(basename $0) [arg...]"
    echo
    echo -e "Options:"
    echo -e "  -p <profile>             AWS CLI profile name"
    echo -e "  -r <region>              AWS region"
    echo -e "  -h, --help               Show this help message and exit"
    echo
    usage_region
    exit 1
}

OPTS=$(getopt -o hp:r: --long help -n $(basename $0) -- "$@")

if [ $? != 0 ]; then
    fail_echo "Failed parsing options." >&2
    usage
    exit 1
fi

eval set -- "$OPTS"

while true; do
    case "$1" in
    -h | --help)
        usage
        ;;
    -p)
        # Check for AWS CLI profile argument passed into the script
        # http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-multiple-profiles
        profile="$2"
        shift 2
        ;;
    -r)
        Region="$2"
        shift 2
        ;;
    --)
        shift
        break
        ;;
    *)
        break
        ;;
    esac
done

function DeleteTopic() {
    cmd=$(aws sns delete-topic --topic-arn "$SNS_TOPIC_ARN" --profile $profile --region $Region)
    echo $cmd
}

echo "Using $profile profile"
echo

if [[ -z "$Region" ]]; then
    SelectRegion
    echo
fi

SelectSNSTopicArn
echo

DeleteTopic

completed
