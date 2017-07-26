map([
    .PublicIpAddress // "",
    .PrivateIpAddress // "",
    ((.Tags // []) | map(select(.Key == "Name")) | .[] | .Value) // "",
    ((.Tags // []) | map(select(.Key == "color")) | .[] | .Value) // "",
    ((.Tags // []) | map(select(.Key == "ansible-playbook")) | .[] | .Value) // "",
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
