.LoadBalancerDescriptions
| map([
    .LoadBalancerName,
    .Scheme,
    (.Instances | length),
    (.ListenerDescriptions
        | map(.Listener as $l
            # this is crazy.
            | [
                ([
                    ($l.Protocol),
                    ($l.LoadBalancerPort | tostring)
                ] | join("/")),
                ([
                    ($l.InstanceProtocol),
                    ($l.InstancePort | tostring)
                ] | join("/"))
              ] | join("->"))
        | join(",")),
    .CreatedTime])
| .[]
| @csv

# vim: ft=conf
