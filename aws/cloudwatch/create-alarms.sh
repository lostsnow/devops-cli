#!/usr/bin/env bash
# This script creates AWS CloudWatch alarms based on standard metrics and user input to setup alarms for each environment
# Requires AWS CLI Setup and you must setup your ALARMACTION

# Change working directory
DIR_PATH="$( cd "$( echo "${0%/*}" )"; pwd )"
ROOT_PATH=$(dirname $(dirname ${DIR_PATH}))
source ${ROOT_PATH}/base.sh
source ${ROOT_PATH}/aws/aws.sh

ALARMACTION=""


# Check required commands
check_command "aws"
check_command "jq"

aws_check_config

# Verify ALARMACTION is setup with some alert mechanism
if [[ -z $ALARMACTION ]] || [[ "$ALARMACTION" == "arn:aws:sns:us-east-1:YOURACCOUNTNUMBER:YOURSNSALERTNAME" ]]; then
    echo "Alarm Action SNS Topic ARN?"
    echo "Example: arn:aws:sns:us-east-1:YOURACCOUNTNUMBER:YOURSNSALERTNAME"
    read -r ALARMACTION
    if [[ -z $ALARMACTION ]]; then
        fail "Alarm Action must be configured."
    fi
fi

HorizontalRule
echo "Create CloudWatch Alarms"
HorizontalRule
echo

read -r -p "Client Name? " CLIENT
if [[ -z $CLIENT ]]; then
    fail "Invalid Client Name!"
fi
HorizontalRule
read -r -p "How Many Servers Total? " SERVERNUM
if [[ $SERVERNUM > 0 ]] && echo "$SERVERNUM" | egrep -q '^[0-9]+$'; then
    read -r -p "Loadbalanced Environment? (y/n) " LOADBALANCED

    # If Loadbalanced Environment
    if [[ $LOADBALANCED =~ ^([yY][eE][sS]|[yY])$ ]]; then
        read -r -p "Load Balancer ID? " LBID
        if [[ -z $LBID ]]; then
            fail "Invalid Load Balancer ID!"
        fi

        # Load Balancer Unhealthy Host Check
        aws cloudwatch put-metric-alarm --alarm-name "$CLIENT Unhealthy Host Check" --alarm-description "$CLIENT Load Balancer Unhealthy Host Detected" --metric-name "UnHealthyHostCount" --namespace "AWS/ELB" --statistic "Sum" --period 60 --threshold 0 --comparison-operator "GreaterThanThreshold" --dimensions Name=LoadBalancerName,Value=$LBID --evaluation-periods 3 --alarm-actions "$ALARMACTION" --profile $profile
        HorizontalRule
        echo "Load Balancer Unhealthy Host Alarm Set"
        HorizontalRule
        # Load Balancer High Latency Check
        aws cloudwatch put-metric-alarm --alarm-name "$CLIENT LB High Latency" --alarm-description "$CLIENT Load Balancer High Latency" --metric-name "Latency" --namespace "AWS/ELB" --statistic "Average" --period 60 --threshold 15 --comparison-operator "GreaterThanThreshold" --dimensions Name=LoadBalancerName,Value=$LBID --evaluation-periods 2 --alarm-actions "$ALARMACTION" --profile $profile
        HorizontalRule
        echo "Load Balancer High Latency Alarm Set"
        HorizontalRule
    fi

    # Begin loop to create server alarms
    START=1
    for ((COUNT = $START; COUNT <= $SERVERNUM; COUNT++)); do
        echo "Server #"$COUNT
        read -r -p "Server Environment? (Dev/Staging/Production) " ENVIRONMENT
        if [[ -z $ENVIRONMENT ]]; then
            fail "Invalid Server Environment!"
        fi
        read -r -p "Server Name? (Web01, Web02) " SERVERNAME
        # Avoid "Dev Dev" situation
        if [[ "$ENVIRONMENT" == "$SERVERNAME" ]]; then
            SERVERNAME=""
        fi
        read -r -p "Instance ID? (i-xxxxxxxx or i-xxxxxxxxxxxxxxxxx) " INSTANCEID
        if [[ "$INSTANCEID" =~ ^([i]-........)|([i]-.................)$ ]]; then

            # CPU Check
            aws cloudwatch put-metric-alarm --alarm-name "$CLIENT $ENVIRONMENT $SERVERNAME CPU Check" --alarm-description "$CLIENT $ENVIRONMENT $SERVERNAME CPU usage >90% for 5 minutes" --namespace "AWS/EC2" --dimensions Name=InstanceId,Value=$INSTANCEID --metric-name "CPUUtilization" --statistic "Average" --comparison-operator "GreaterThanThreshold" --unit "Percent" --period 60 --threshold 90 --evaluation-periods 5 --alarm-actions "$ALARMACTION" --profile $profile
            HorizontalRule
            echo $CLIENT $ENVIRONMENT $SERVERNAME "CPU Check Alarm Set"
            HorizontalRule

            # Status Check
            aws cloudwatch put-metric-alarm --alarm-name "$CLIENT $ENVIRONMENT $SERVERNAME Status Check" --alarm-description "$CLIENT $ENVIRONMENT $SERVERNAME Status Check Failed for 5 minutes" --namespace "AWS/EC2" --dimensions Name=InstanceId,Value=$INSTANCEID --metric-name "StatusCheckFailed" --statistic "Maximum" --comparison-operator "GreaterThanThreshold" --unit "Count" --period 60 --threshold 0 --evaluation-periods 5 --alarm-actions "$ALARMACTION" --profile $profile
            HorizontalRule
            echo $CLIENT $ENVIRONMENT $SERVERNAME "Status Check Alarm Set"
            HorizontalRule
        else
            fail "Invalid Instance ID!"
        fi
    done
else
    if [[ $SERVERNUM == 0 ]]; then
        echo "Skipping Server Alarms..."
    else
        tput setaf 1
        echo "Invalid Number of Servers!" && tput sgr0
    fi
fi

read -r -p "Setup Database Alarms? (y/n) " SETUPDB
# If Database Alarms
if [[ $SETUPDB =~ ^([yY][eE][sS]|[yY])$ ]]; then
    HorizontalRule
    read -r -p "How Many Database Hosts Total? " DBNUM
    if [[ $DBNUM > 0 ]] && echo "$DBNUM" | egrep '^[0-9]+$' >/dev/null 2>&1; then

        # Begin loop to create database alarms
        START=1
        for ((COUNT = $START; COUNT <= $DBNUM; COUNT++)); do
            echo "DB #"$COUNT
            read -r -p "Database Environment? (Dev/Staging/Production) " ENVIRONMENT
            if [[ -z $ENVIRONMENT ]]; then
                fail "Invalid Database Environment!"
            fi
            # # Avoid "Beta Beta" situation
            # if [[ $ENVIRONMENT == "Beta" ]]; then
            #   SERVERNAME=""
            # else
            #   echo -n "DB Name? (Web01, Web02) "
            #   read SERVERNAME
            # fi
            read -r -p "DB Instance ID? " DBID
            if [[ -z $DBID ]]; then
                fail "Invalid Database Instance ID!"
            fi

            # Database CPU Check
            aws cloudwatch put-metric-alarm --alarm-name "$CLIENT $ENVIRONMENT DB CPU Check" --alarm-description "$CLIENT $ENVIRONMENT Database CPU usage >90% for 5 minutes" --metric-name "CPUUtilization" --namespace "AWS/RDS" --statistic "Average" --unit "Percent" --period 60 --threshold 90 --comparison-operator "GreaterThanThreshold" --dimensions Name=DBInstanceIdentifier,Value=$DBID --evaluation-periods 5 --alarm-actions "$ALARMACTION" --profile $profile
            HorizontalRule
            echo $CLIENT $ENVIRONMENT "Database CPU Check Alarm Set"
            HorizontalRule

            # Database Memory Usage Check
            aws cloudwatch put-metric-alarm --alarm-name "$CLIENT $ENVIRONMENT DB Mem Check" --alarm-description "$CLIENT $ENVIRONMENT Database Freeable Memory < 200 MB for 5 minutes" --metric-name "FreeableMemory" --namespace "AWS/RDS" --statistic "Average" --unit "Bytes" --period 60 --threshold "200000000" --comparison-operator "LessThanThreshold" --dimensions Name=DBInstanceIdentifier,Value=$DBID --evaluation-periods 5 --alarm-actions "$ALARMACTION" --profile $profile
            HorizontalRule
            echo $CLIENT $ENVIRONMENT "Database Memory Usage Alarm Set"
            HorizontalRule

            # Database Available Storage Space Check
            aws cloudwatch put-metric-alarm --alarm-name "$CLIENT $ENVIRONMENT DB Storage Check" --alarm-description "$CLIENT $ENVIRONMENT Database Available Storage Space < 200 MB" --metric-name "FreeStorageSpace" --namespace "AWS/RDS" --statistic "Average" --unit "Bytes" --period 60 --threshold "200000000" --comparison-operator "LessThanThreshold" --dimensions Name=DBInstanceIdentifier,Value=$DBID --evaluation-periods 1 --alarm-actions "$ALARMACTION" --profile $profile
            HorizontalRule
            echo $CLIENT $ENVIRONMENT "Database Available Storage Space Alarm Set"
            HorizontalRule
        done
    else
        if [[ $DBNUM == 0 ]]; then
            echo "Skipping Database Alarms..."
        else
            tput setaf 1
            echo "Invalid Number of Databases!" && tput sgr0
        fi
    fi
else
    echo "Exiting"
fi

completed
