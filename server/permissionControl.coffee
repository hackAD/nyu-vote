Meteor.methods(
  'isElectionAdmin': (election_id) ->
    return Elections.find({"_id": election_id, "admins": Meteor.user().profile.netId}).count() == 1
  'isglobaladmin': () ->
    return Groups.find({"name": "global", "admins": Meteor.user().profile.netId}).count() == 1
  'isGroupAdminOf': (group_ids) ->
    if typeof(group_ids) == "string"
      group_ids = [group_ids]
    return Groups.find({"_id": {$in:group_ids}, "admins": Meteor.user().profile.netId}).count() == group_ids.length
  'isInGroupAdminsOf': (group_ids) ->
    if typeof(group_ids) == "string"
      group_ids = [group_ids]
    return Groups.find({"_id": {$in:group_ids}, "admins": Meteor.user().profile.netId}).count() > 0
  'isAGroupAdmin': () ->
    return Groups.find({"admins": Meteor.user().profile.netId}).count() > 0
  'isCreatorOf': (netId) ->
    return netId == Meteor.user().profile.netId
  'hasNotVoted': (election_id) ->
    return Elections.find(
      _id:election_id,
      status:"open",
      voters: {$ne: if Meteor.user()?.profile?.netId? then Meteor.user().profile.netId else ""},
    ).count() == 1
  'deleteSuperuser': () ->
    if Meteor.user().isGlobalAdmin()
      console.log "Deleting superuser!"
      Meteor.users.remove({username: "devAdmin"})
    else
      console.log "Not global admin cannot delete"
)
