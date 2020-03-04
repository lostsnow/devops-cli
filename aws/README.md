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

### CloudWatch

#### [Create Alarms for EC2](cloudwatch/create-alarms-ec2.sh)

Create CloudWatch Alarms for all running EC2 Instances in all regions available

* CPUHigh
* StatusCheckFailed

Usage:

```
./cloudwatch/create-alarms-ec2.sh -h
```

```shell
./cloudwatch/create-alarms-ec2.sh -p <profile name>
```
