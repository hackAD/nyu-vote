Meteor.publish("adminGroups", ()->
  user = Meteor.users.findOne(this.userId)
  return Groups.find({admins: if user? then user.profile.netId else "" })
)
Meteor.publish("adminElections", ()->
  user = Meteor.users.findOne(this.userId)
  groups = Groups.
    find({admins: if user? then user.profile.netId else ""}).fetch()
  return Elections.find(
    groups:{$in: if groups.length > 0 then _.map(groups, (g) -> g._id) else []},
    voters: {$ne: if user? then user.profile.netId else ""})
)
Meteor.publish("Elections", () ->
  user = Meteor.users.findOne(this.userId)
  console.log(user)
  groups = Groups.
    find({netIds: if user? then user.profile.netId else ""}).fetch()
  console.log(groups)
  return Elections.find(
    groups:
      {$in: if groups.length > 0 then _.map(groups, (g) -> g._id) else []}
    status:"open",
    voters: {$ne: if user? then user.profile.netId else ""})
)
