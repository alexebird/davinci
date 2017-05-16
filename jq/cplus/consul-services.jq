flatten(1)
| map([
    .Service.Service,
    .Node.Address,
    (.Checks | if all(.Status == "passing") then
                 "passing"
               else
                 "failing"
               end)
  ])[]
| @csv
