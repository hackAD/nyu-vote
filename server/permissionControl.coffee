Meteor.methods(
  'isElectionAdmin': (election_id) ->
    return Elections.find({"_id": election_id, "admins": Meteor.user().profile.netId}).count() == 1
  'isGlobalAdmin': () ->
    return Groups.find({"name": "global", "admins": Meteor.user().profile.netId}).count() == 1
  'isGroupAdminOf': (group_ids) ->
    if typeof(group_ids) == "string"
      group_ids = [group_ids]
    return Groups.find({"_id": {$in:group_ids}, "admins": Meteor.user().profile.netId}).count() == group_ids.length
  'isAGroupAdmin': () ->
    return Groups.find({"admins": Meteor.user().profile.netId}).count() > 0
)