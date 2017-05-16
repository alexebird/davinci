.AutoScalingGroups
| map({
    name: .AutoScalingGroupName,
    created: .CreatedTime,
    size: .Instances | length,
    asg_type: .Tags[] | select(.Key == "asg-type") | .Value,
    color: .Tags[] | select(.Key == "color") | .Value
  })
| sort_by(.created)
| reverse
| .[]
| select((.name | contains("masters")) and (.size != 0))
| (.name, .asg_type, .color, .size)
