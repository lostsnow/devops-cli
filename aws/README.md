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

#### [Create Alarms StatusCheckFailed](cloudwatch/create-alarms-statuscheckfailed.sh)

Create CloudWatch StatusCheckFailed Alarms with Recovery Action for all running EC2 Instances in all regions available

```shell
./cloudwatch/create-alarms-statuscheckfailed.sh <profile name>
```
