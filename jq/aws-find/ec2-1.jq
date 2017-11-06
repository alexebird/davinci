.Reservations
| map(.Instances)
| flatten
| sort_by(.LaunchTime)
| reverse
| map(. + {
    name:  (((.Tags // []) | map(select(.Key == "Name")) | .[] | .Value) // ""),
    color: (((.Tags // []) | map(select(.Key == "color")) | .[] | .Value) // ""),
    role:  (((.Tags // []) | map(select(.Key == "ansible-playbook")) | .[] | .Value) // ""),
    env:   (((.Tags // []) | map(select(.Key == "env")) | .[] | .Value) // "")
  }
)
| map(select(.env | contains($env)))
| map(select(.State.Name | contains($state)))
