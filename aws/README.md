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

#### [Create Alarms for RDS](cloudwatch/create-alarms-rds.sh)

Create CloudWatch Alarms for all running RDS Instances in all regions available

* CPUHigh
* MemoryUsageHigh

Usage:

```
./cloudwatch/create-alarms-rds.sh -h
```

```shell
./cloudwatch/create-alarms-rds.sh -p <profile name>
```
