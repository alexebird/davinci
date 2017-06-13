#
# this filter takes as an input a list of Allocations
#

# map each allocation
map(
    # set some vars
    . as {
        JobID: $JobID,
        ClientStatus: $ClientStatus,
        TaskStates: $TaskStates,
        TaskResources: $TaskResources,
        TaskGroup: $TaskGroupName,
        CreateTime: $CreateTime}

    # set the alloc id prefix to var
    | ([.ID | scan("[a-z0-9]+")][0]) as $ID

    # set the node id prefix to var
    | ([.NodeID | scan("[a-z0-9]+")][0]) as $NodeID

    # set the eval id prefix to var
    | ([.EvalID | scan("[a-z0-9]+")][0]) as $EvalID

    # since each allocation corresponds 1:1 with a group, get this allocation's group
    | (.Job.TaskGroups | map(select(.Name == $TaskGroupName))[0]) as $TaskGroup

    | (.Job.Type) as $Type

    # get the task list from the group
    | ($TaskGroup.Tasks | map({key: .Name, value: .}) | from_entries) as $Tasks

    # start by iterating the TaskStates of the allocation
    | $TaskStates

    # I have seen some batch jobs stuck in pending have a null TaskStates top-level. This is weird case, but we should handle it. Get rid of nulls.
    | select(. != null)

    | to_entries

    # we only care about the name and state
    | map([
            $JobID,
            $TaskGroupName,
            .key,                # task name
            $ClientStatus,
            .value.State // "",  # task state
            $Type // "",
            (
                ($TaskResources[.key].Networks // []) | map([
                    .IP,
                    ((.DynamicPorts // [])
                        | map(.Value | tostring)
                        | join(","))
                    ] | join(":"))
                | join(",")
            ),
            $NodeID,
            $EvalID,
            $ID,
            ($CreateTime | tostring | sub("[0-9]{9}$"; "") | tonumber | todate)
        ]
    )

# end top-level map
)
| flatten(1)
| .[] | @csv
