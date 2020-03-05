#!/usr/bin/env bash

# This script creates AWS CloudWatch alarms based on standard metrics and user input to setup alarms for each environment
# Requires AWS CLI Setup and you must setup your Alarm SNS_TOPIC_ARN

# Change working directory
DIR_PATH="$(
    cd "$(echo "${0%/*}")"
    pwd
)"
ROOT_PATH=$(dirname $(dirname ${DIR_PATH}))
source ${ROOT_PATH}/base.sh
source ${ROOT_PATH}/aws/aws.sh
source ${DIR_PATH}/cloudwatch.sh

# Set Variables

# Optionally limit to a single AWS Region
Region=""

# Debug Mode
DEBUGMODE="0"

SetAlarmYN="n"
ALARM_NAME=""

profile=default
AlarmType=all

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
    echo -e "  -t <alarm type>          Alarm type, default: all"
    echo -e "  -d                       Debug mode"
    echo -e "  -h, --help               Show this help message and exit"
    echo
    usage_region
    echo
    echo -e "Alarm types:"
    echo -e "  StatusCheckFailed"
    echo -e "  CPUHigh"
    echo -e "  NetworkOutHigh"
    exit 1
}

OPTS=$(getopt -o hp:dt:r: --long help -n $(basename $0) -- "$@")

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
    -t)
        AlarmType="$2"
        if [[ ! "$AlarmType" =~ ^(all|CPUHigh|StatusCheckFailed|NetworkOutHigh)$ ]]; then
            fail_echo "AlarmType $AlarmType invalid"
            usage
        fi
        shift 2
        ;;
    -r)
        Region="$2"
        shift 2
        ;;
    -d)
        DEBUGMODE="1"
        shift 1
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

# Get list of all EC2 Instances in one region
function ListInstances() {
    echo "Get Ec2 Instances"
    ParseInstances=$(GetEc2Instances $profile $Region)
    if [ ! $? -eq 0 ]; then
        fail "$ParseInstances"
    fi

    if [ -z "$ParseInstances" ]; then
        echo "No Instances found in $Region."
    else
        echo ParseInstances:
        HorizontalRule
        info_echo "$ParseInstances"
        HorizontalRule

        echo "Setting Alarms for Region: $Region"
        echo
        SetAlarms
    fi
}

function SetAlarmCPUHigh() {
    # CPUHigh
    CPUHighThreshold=70
    ALARM_NAME="AWS/EC2: [$InstanceName] CPUHigh $InstanceID"
    ALARM_DESC="AWS/EC2: [$InstanceName] CPU usage >$CPUHighThreshold% for 5 minutes"

    if [[ $DEBUGMODE = "1" ]]; then
        warn_echo aws cloudwatch put-metric-alarm --alarm-name \"${ALARM_NAME}\" --alarm-description \"${ALARM_DESC}\" --namespace "AWS/EC2" --dimensions Name=InstanceId,Value=$InstanceID --metric-name "CPUUtilization" --statistic "Average" --comparison-operator "GreaterThanThreshold" --unit "Percent" --period 60 --threshold $CPUHighThreshold --evaluation-periods 5 --alarm-actions \"$SNS_TOPIC_ARN\" --output=json --profile $profile --region $Region
    fi
    SetAlarm=$(aws cloudwatch put-metric-alarm --alarm-name "${ALARM_NAME}" --alarm-description "${ALARM_DESC}" --namespace "AWS/EC2" --dimensions Name=InstanceId,Value=$InstanceID --metric-name "CPUUtilization" --statistic "Average" --comparison-operator "GreaterThanThreshold" --unit "Percent" --period 60 --threshold $CPUHighThreshold --evaluation-periods 5 --alarm-actions "$SNS_TOPIC_ARN" --output=json --profile $profile --region $Region 2>&1)
    if [ ! $? -eq 0 ]; then
        fail "SetAlarm: $SetAlarm"
    fi
}

function SetAlarmStatusCheckFailed() {
    ALARM_NAME="AWS/EC2: [$InstanceName] StatusCheckFailed $InstanceID"
    if [[ $DEBUGMODE = "1" ]]; then
        warn_echo aws cloudwatch put-metric-alarm --alarm-name \"${ALARM_NAME}\" --metric-name StatusCheckFailed_System --namespace AWS/EC2 --statistic Maximum --dimensions Name=InstanceId,Value="$InstanceID" --unit Count --period 300 --evaluation-periods 1 --threshold 1 --comparison-operator GreaterThanOrEqualToThreshold --alarm-actions \'"$SNS_TOPIC_ARN"\' --output=json --profile $profile --region $Region
    fi
    SetAlarm=$(aws cloudwatch put-metric-alarm --alarm-name "${ALARM_NAME}" --metric-name StatusCheckFailed_System --namespace AWS/EC2 --statistic Maximum --dimensions Name=InstanceId,Value="$InstanceID" --unit Count --period 300 --evaluation-periods 1 --threshold 1 --comparison-operator GreaterThanOrEqualToThreshold --alarm-actions "$SNS_TOPIC_ARN" --output=json --profile $profile --region $Region 2>&1)
    if [ ! $? -eq 0 ]; then
        fail "SetAlarm: $SetAlarm"
    fi
}

function SetAlarmNetworkOutHigh() {
    NetworkOutHighThreshold=30000000
    let NetworkOutHighThresholdMB=NetworkOutHighThreshold/1000000
    ALARM_NAME="AWS/EC2: [$InstanceName] NetworkOutHigh $InstanceID"
    ALARM_DESC="AWS/EC2: [$InstanceName] Network Traffic Out > $NetworkOutHighThresholdMB Mbps for 5 minutes"
    if [[ $DEBUGMODE = "1" ]]; then
        warn_echo aws cloudwatch put-metric-alarm --alarm-name \"${ALARM_NAME}\" --alarm-description \"${ALARM_DESC}\" --namespace AWS/EC2 --dimensions Name=InstanceId,Value="$InstanceID" --metric-name "NetworkOut" --statistic "Average" --comparison-operator GreaterThanThreshold --unit "Bytes" --period 60 --threshold "$NetworkOutHighThreshold" --evaluation-periods 5 --alarm-actions \"$SNS_TOPIC_ARN\" --output=json --profile $profile --region $Region
    fi
    SetAlarm=$(aws cloudwatch put-metric-alarm --alarm-name "${ALARM_NAME}" --alarm-description "${ALARM_DESC}" --namespace AWS/EC2 --dimensions Name=InstanceId,Value="$InstanceID" --metric-name "NetworkOut" --statistic "Average" --comparison-operator GreaterThanThreshold --unit "Bytes" --period 60 --threshold "$NetworkOutHighThreshold" --evaluation-periods 5 --alarm-actions "$SNS_TOPIC_ARN" --output=json --profile $profile --region $Region 2>&1)
    if [ ! $? -eq 0 ]; then
        fail "SetAlarm: $SetAlarm"
    fi
}

function SetAlarms() {
    echo "Begin SetAlarms Function"
    TotalInstancess=$(echo "$ParseInstances" | wc -l | rev | cut -d " " -f1 | rev)
    echo
    echo "Region: $Region"
    echo "TotalInstancess: $TotalInstancess"
    echo
    if [[ $DEBUGMODE = "1" ]]; then
        pause
    fi
    Start=1
    for ((Count = $Start; Count <= $TotalInstancess; Count++)); do
        InstanceID=$(echo "$ParseInstances" | nl | grep -w [^0-9][[:space:]]$Count | cut -f2)

        HorizontalRule
        echo "Count: $Count"
        echo "Instance: $InstanceID"
        HorizontalRule
        echo

        InstanceNameTag=$(aws ec2 describe-tags --filters Name=key,Values=Name Name=resource-id,Values="$InstanceID" --region $Region --output=json --profile $profile 2>&1)
        if [ ! $? -eq 0 ]; then
            fail "$InstanceNameTag"
        fi
        if [ -z "$InstanceNameTag" ]; then
            echo "No InstanceName."
            echo
        fi
        if [[ $DEBUGMODE = "1" ]]; then
            warn_echo "InstanceNameTag: $InstanceNameTag"
            echo
        fi
        InstanceName=$(echo "$InstanceNameTag" | jq '.Tags | .[] | .Value' | cut -d \" -f2)
        if [ ! $? -eq 0 ]; then
            fail "$InstanceName"
        fi
        if [ -z "$InstanceName" ]; then
            echo "No InstanceName."
            echo
        fi

        HorizontalRule
        echo "Instance Name: $InstanceName ($InstanceID)"
        read -r -p "Set Alarm? (y/n): " SetAlarmYN
        HorizontalRule
        echo

        if [[ ${SetAlarmYN} != "y" ]]; then
            echo "Skip Instance: $InstanceName $InstanceID"
            echo
            continue
        fi

        echo "Setting CloudWatch Alarm"

        if [[ "$AlarmType" == "all" ]] || [[ "$AlarmType" == "CPUHigh" ]]; then
            SetAlarmCPUHigh
            verify_alarm $profile $Region "$ALARM_NAME"
        fi
        if [[ "$AlarmType" == "all" ]] || [[ "$AlarmType" == "StatusCheckFailed" ]]; then
            SetAlarmStatusCheckFailed
            verify_alarm $profile $Region "$ALARM_NAME"
        fi
        if [[ "$AlarmType" == "all" ]] || [[ "$AlarmType" == "NetworkOutHigh" ]]; then
            SetAlarmNetworkOutHigh
            verify_alarm $profile $Region "$ALARM_NAME"
        fi

        echo
    done
}

echo "Using $profile profile"
echo

if [[ -z "$Region" ]]; then
    SelectRegion
    echo
fi

SelectSNSTopicArn
echo
ListInstances

completed
