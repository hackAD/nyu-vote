Template.electionsAdminShow.helpers
  election: () ->
    election = Election.getActive()
    return election
  groups: () ->
    return _.map(@groups, (groupId) ->
      localGroup = Group.fetchOne(groupId)
      if localGroup
        localGroup.exists = true
        return localGroup
      else
        return  {
          _id: groupId
          exists: false
          name: "hidden group"
        }
    )
  canEdit: () ->
    @status == "unopened" && @hasAdmin(Meteor.user())
  openCloseElection: () ->
    if @status == "open" then return "Close" else return "Open"
  openCloseClass: () ->
    if @status == "open" then return "button-secondary" else return "button-success"
  isPickN: () ->
    return @options.voteMode == "pickN"



Template.electionsAdminShow.events
  "click .openCloseElection": (e) ->
    e.preventDefault()
    if (@status != "unopened" ||
        confirm("Once you open this election, it can no longer be modified." +
        " Are you sure you want to do this?"))
      Meteor.call("toggleElectionStatus", @_id)
