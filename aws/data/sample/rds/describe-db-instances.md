# rds describe-db-instances

```json
{
    "DBInstances": [
        {
            "DBInstanceIdentifier": "db-xxx",
            "DBInstanceClass": "db.t2.small",
            "Engine": "aurora-mysql",
            "DBInstanceStatus": "stopping",
            "MasterUsername": "user",
            "DBName": "dbname",
            "Endpoint": {
                "Address": "db-xxx.xxx.ap-southeast-2.rds.amazonaws.com",
                "Port": 3306,
                "HostedZoneId": "xxxxxx"
            },
            "AllocatedStorage": 1,
            "InstanceCreateTime": "2018-04-20T04:06:03.558Z",
            "PreferredBackupWindow": "12:46-13:16",
            "BackupRetentionPeriod": 2,
            "DBSecurityGroups": [],
            "VpcSecurityGroups": [
                {
                    "VpcSecurityGroupId": "sg-xxx",
                    "Status": "active"
                }
            ],
            "DBParameterGroups": [
                {
                    "DBParameterGroupName": "prod",
                    "ParameterApplyStatus": "in-sync"
                }
            ],
            "AvailabilityZone": "ap-southeast-2a",
            "DBSubnetGroup": {
                "DBSubnetGroupName": "default",
                "DBSubnetGroupDescription": "default",
                "VpcId": "vpc-xxx",
                "SubnetGroupStatus": "Complete",
                "Subnets": [
                    {
                        "SubnetIdentifier": "subnet-xx1",
                        "SubnetAvailabilityZone": {
                            "Name": "ap-southeast-2b"
                        },
                        "SubnetStatus": "Active"
                    },
                    {
                        "SubnetIdentifier": "subnet-xx2",
                        "SubnetAvailabilityZone": {
                            "Name": "ap-southeast-2c"
                        },
                        "SubnetStatus": "Active"
                    },
                    {
                        "SubnetIdentifier": "subnet-xx3",
                        "SubnetAvailabilityZone": {
                            "Name": "ap-southeast-2a"
                        },
                        "SubnetStatus": "Active"
                    }
                ]
            },
            "PreferredMaintenanceWindow": "tue:16:33-tue:17:03",
            "PendingModifiedValues": {},
            "MultiAZ": false,
            "EngineVersion": "5.7.12",
            "AutoMinorVersionUpgrade": true,
            "ReadReplicaDBInstanceIdentifiers": [],
            "LicenseModel": "general-public-license",
            "OptionGroupMemberships": [
                {
                    "OptionGroupName": "default:aurora-mysql-5-7",
                    "Status": "in-sync"
                }
            ],
            "PubliclyAccessible": false,
            "StorageType": "aurora",
            "DbInstancePort": 0,
            "DBClusterIdentifier": "cluster-xxx",
            "StorageEncrypted": true,
            "KmsKeyId": "arn:aws:kms:ap-southeast-2:nnnn:key/uuiiiiiiiiiid",
            "DbiResourceId": "db-XXXXXX",
            "CACertificateIdentifier": "rds-ca-2019",
            "DomainMemberships": [],
            "CopyTagsToSnapshot": false,
            "MonitoringInterval": 60,
            "EnhancedMonitoringResourceArn": "arn:aws:logs:ap-southeast-2:nnnn:log-group:RDSOSMetrics:log-stream:db-XXXXXX",
            "MonitoringRoleArn": "arn:aws:iam::nnnn:role/rds-monitoring-role",
            "PromotionTier": 1,
            "DBInstanceArn": "arn:aws:rds:ap-southeast-2:nnnn:db:db-xxx",
            "IAMDatabaseAuthenticationEnabled": false,
            "PerformanceInsightsEnabled": false,
            "EnabledCloudwatchLogsExports": [
                "error",
                "slowquery"
            ],
            "DeletionProtection": false,
            "AssociatedRoles": []
        },
        // ...
    ]
}
```