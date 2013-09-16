Meteor.publish("adminGroups", ()->
  user = Meteor.users.findOne(this.userId)
  return Groups.find({admins:user?.profile.netId})
)
Meteor.publish("adminElections", ()->
  user = Meteor.users.findOne(this.userId)
  groups = Groups.find({admins:user?.profile.netId}).fetch()
  return Elections.find({groups:{$in:groups?}})
)
Meteor.publish("Elections", ()->
  user = Meteor.users.findOne(this.userId)
  groups = Groups.find({netIds:user?.profile.netId}).fetch()
  return Elections.find({groups:{$in:groups?}, status:"open"})
)