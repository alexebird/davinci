map([
    .PublicIpAddress // "",
    .PrivateIpAddress // "",
    .name,
    .color,
    .role,
    .env,
    .State.Name // "",
    .InstanceType // "",
    .ImageId // "",
    .LaunchTime // "",
    .KeyName // "",
    .SubnetId // "",
    .CidrBlock // "",
    .InstanceId // ""
])
| .[]
| @csv
