map([
    .PublicIpAddress // "",
    .PrivateIpAddress // "",
    ((.Tags // []) | map(select(.Key == "Name")) | .[] | .Value) // "",
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
