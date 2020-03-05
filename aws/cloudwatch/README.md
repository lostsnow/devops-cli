# AWS CloudWatch

> Use `-h` or `--help` show help message

## [Create Alarms for EC2](create-alarms-ec2.sh)

Create CloudWatch Alarms for all running EC2 Instances in all regions available

* CPUHigh
* StatusCheckFailed

Example:

```shell
./create-alarms-ec2.sh -p <profile name>
```

## [Create Alarms for RDS](create-alarms-rds.sh)

Create CloudWatch Alarms for all running RDS Instances in all regions available

* CPUHigh
* MemoryUsageHigh

Example:

```shell
./create-alarms-rds.sh -p <profile name>
```
