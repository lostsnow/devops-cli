#!/usr/bin/env bash

function verify_alarm() {
    profile=$1
    Region=$2
    ALARM_NAME=$3

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
}