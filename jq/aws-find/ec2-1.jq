.Reservations
| map(.Instances)
| flatten
| sort_by(.LaunchTime)
| reverse
| map(select(.State.Name | contains($state)))
