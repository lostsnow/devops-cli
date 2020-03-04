#!/usr/bin/env bash

# This script creates AWS CloudWatch alarms based on standard metrics and user input to setup alarms for each environment
# Requires AWS CLI Setup and you must setup your ALARMACTION

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

# Debug Mode
DEBUGMODE="0"

SetAlarmYN="n"

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
    echo -e "  -d                       Debug mode"
    echo -e "  -h, --help               Show this help message and exit"
    exit 1
}

OPTS=$(getopt -o hp:d --long help -n $(basename $0) -- "$@")

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
    -d)
        DEBUGMODE="1"
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

        # CPUHigh
        CPUHighThreshold=70
        ALARM_NAME="AWS/EC2: [$InstanceName] CPUHigh $InstanceID"
        ALARM_DESC="AWS/EC2: [$InstanceName] CPU usage >$CPUHighThreshold% for 5 minutes"

        if [[ $DEBUGMODE = "1" ]]; then
            warn_echo aws cloudwatch put-metric-alarm --alarm-name \"${ALARM_NAME}\" --alarm-description \"${ALARM_DESC}\" --namespace "AWS/EC2" --dimensions Name=InstanceId,Value=$InstanceID --metric-name "CPUUtilization" --statistic "Average" --comparison-operator "GreaterThanThreshold" --unit "Percent" --period 60 --threshold $CPUHighThreshold --evaluation-periods 5 --alarm-actions \"$ALARMACTION\" --profile $profile --region $Region
        fi
        SetAlarm=$(aws cloudwatch put-metric-alarm --alarm-name "${ALARM_NAME}" --alarm-description "${ALARM_DESC}" --namespace "AWS/EC2" --dimensions Name=InstanceId,Value=$InstanceID --metric-name "CPUUtilization" --statistic "Average" --comparison-operator "GreaterThanThreshold" --unit "Percent" --period 60 --threshold $CPUHighThreshold --evaluation-periods 5 --alarm-actions "$ALARMACTION" --profile $profile --region $Region)
        if [ ! $? -eq 0 ]; then
            fail "SetAlarm: $SetAlarm"
        fi

        if [[ $DEBUGMODE = "1" ]]; then
            warn_echo aws cloudwatch describe-alarms --alarm-names \"${ALARM_NAME}\" --output=json --profile $profile --region $Region 2>&1
        fi
        VerifyAlarm=$(aws cloudwatch describe-alarms --alarm-names "${ALARM_NAME}" --output=json --profile $profile --region $Region 2>&1)
        if [ ! $? -eq 0 ]; then
            fail "VerifyAlarm: $VerifyAlarm"
        fi
        AlarmName=$(echo "$VerifyAlarm" | jq '.MetricAlarms | .[] | .AlarmName')
        if [ ! $? -eq 0 ]; then
            fail "AlarmName: $AlarmName"
        fi
        success_echo "Alarm set: $AlarmName"
        echo
    done
}

echo "Using $profile profile"
echo

SelectRegion
echo
SelectSNSTopicArn
echo
ListInstances

completed
