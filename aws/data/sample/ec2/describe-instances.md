# ec2 describe-instances

```json
{
    "Reservations": [
        {
            "Groups": [],
            "Instances": [
                {
                    "AmiLaunchIndex": 0,
                    "ImageId": "ami-xx",
                    "InstanceId": "i-xxxx",
                    "InstanceType": "t2.small",
                    "KeyName": "xxx-key",
                    "LaunchTime": "2020-03-05T01:59:12.000Z",
                    "Monitoring": {
                        "State": "disabled"
                    },
                    "Placement": {
                        "AvailabilityZone": "ap-southeast-2a",
                        "GroupName": "",
                        "Tenancy": "default"
                    },
                    "PrivateDnsName": "",
                    "ProductCodes": [],
                    "PublicDnsName": "",
                    "State": {
                        "Code": 48,
                        "Name": "terminated"
                    },
                    "StateTransitionReason": "User initiated (2020-03-05 04:45:19 GMT)",
                    "Architecture": "x86_64",
                    "BlockDeviceMappings": [],
                    "ClientToken": "",
                    "EbsOptimized": false,
                    "Hypervisor": "xen",
                    "NetworkInterfaces": [],
                    "RootDeviceName": "/dev/sda1",
                    "RootDeviceType": "ebs",
                    "SecurityGroups": [],
                    "StateReason": {
                        "Code": "Client.UserInitiatedShutdown",
                        "Message": "Client.UserInitiatedShutdown: User initiated shutdown"
                    },
                    "Tags": [
                        {
                            "Key": "Name",
                            "Value": "new-myeyes"
                        }
                    ],
                    "VirtualizationType": "hvm",
                    "CpuOptions": {
                        "CoreCount": 1,
                        "ThreadsPerCore": 1
                    },
                    "CapacityReservationSpecification": {
                        "CapacityReservationPreference": "open"
                    },
                    "HibernationOptions": {
                        "Configured": false
                    },
                    "MetadataOptions": {
                        "State": "pending",
                        "HttpTokens": "optional",
                        "HttpPutResponseHopLimit": 1,
                        "HttpEndpoint": "enabled"
                    }
                }
            ],
            "OwnerId": "nnnnnnn",
            "ReservationId": "r-xxxxx"
        },
        // ...
    ]
}
```