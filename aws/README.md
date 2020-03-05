# aws

## Requirements

* awscli
* jq

```shell
sudo pip3 install awscli
sudo apt install jq
```

## Config

```shell
aws configure --profile <profile name>
```

## Tools

> Use `-h` or `--help` show help message

### CloudWatch

#### [Create Alarms for EC2](cloudwatch/create-alarms-ec2.sh)

Create CloudWatch Alarms for all running EC2 Instances in all regions available

* CPUHigh
* StatusCheckFailed

Example:

```shell
./cloudwatch/create-alarms-ec2.sh -p <profile name>
```

#### [Create Alarms for RDS](cloudwatch/create-alarms-rds.sh)

Create CloudWatch Alarms for all running RDS Instances in all regions available

* CPUHigh
* MemoryUsageHigh

Example:

```shell
./cloudwatch/create-alarms-rds.sh -p <profile name>
```

### Simple Notification Service

#### [Create SNS Topic](sns/create-topic.sh)

Example:

```shell
./sns/create-topic.sh -p <profile name> --name <topic name>
```

#### [Delete SNS Topic](sns/delete-topic.sh)

Example:

```shell
./sns/delete-topic.sh -p <profile name>
```